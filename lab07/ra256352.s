//Cristiano Sampaio Pinheiro RA:256352
.data 
position:.asciz "POS: 0000 0000\n"

.text
  .align 1
  .globl _start

_start:
  	//Aloca espaço para caracteres lidos, 64(valores)x3(maximo de caracteres para cada valor)+63(espaços entre os valores)+1('\n')= 256 posições = 1024 bytes
	.common char_line, 1024, 2
	//Aloca espaço para decimais que correspodem aos caracteres lidos, 64 posições = 256 bytes
	.common int_line, 256, 2
	//Aloca espaço para posição do veiculo e quantidade de linhas da imagem 
	.common x, 4, 2 //int posição x
	.common y, 4, 2	//int posição y
	.common L, 4, 2 //int tamanho L 
	//Chama função para ler a primeira linha
	jal read_line
	//Chama função para converter os valores lidos para decimal 
	jal int_transform
	//Guarda a posição inicial do veiculo
	la t0, int_line
	lw a0, 0(t0)
	sw a0, x, a1
	addi t0, t0, 4
	lw a0, 0(t0)
	sw a0, y, a1
	//Chama função para ler linha para saltar linha com "P2"
	jal read_line
	//Chama função para ler linha e armazena a quantidade de linhas
	jal read_line
	jal int_transform
	la t0, int_line
	addi t0, t0, 4
	lw a0, 0(t0)
	sw a0, L, a1
	//Chama função para ler linha para saltar linha com "255" e saltar primeira linha 
	jal read_line
	jal read_line 

	//Laço para definir a rota do veículo
	li t0, 1
	loop:
		//Preserva o valor de t0
		addi sp, sp, -4
		sw t0, 0(sp)

		jal read_line
		jal int_transform
		jal find_direction

		//Modifica valor de x e y
		lw a1, x
		add a0, a1, a0
		sw a0, x, a1

		lw a0, y
		addi a0, a0, 1
		sw a0, y, a1

		jal print_value
		
		//Recupera valor de t0
		lw t0, 0(sp)
		addi sp, sp, 4

		addi t0, t0, 1
		lw t5, L
		blt t0, t5, loop

	//Finaliza codigo
	li a0, 0 # exit code
  	li a7, 93 # syscall exit
  	ecall


//Função para ler conteudo de uma linha
read_line:
	li t0, 10			//'\n' = 10
	la t1, char_line	//Salva endereço em t1
	li a2, 1 			//Numero de bytes a serem lidos
	li a7, 63			//63 para leitura
	
	1:
		li a0, 0 		//Valor do file descriptor (stdin)
		mv a1, t1		//Salva byte lido no vetor	
		ecall			//Chama o sistema
		
		lw a0, 0(t1)	//Coloca valor lido em a0
		addi t1, t1, 4	//Incrementa endereço
		bne a0, t0, 1b	//Caso não seja '\n' continua loop
	ret

//Função para transformar o vetor de caracteres em um vetor numerico FUNCIONAL
int_transform:
	la t0, char_line	//Endereço do vetor de caracteres
	la t1, int_line		//Endereço do vetor de inteiros a ser formado
	li t2, 32 			//'space' = 32
	li t3, 10			//t3 = 10 para conversao e para '\n'
	mv t4, t0			//Guarda endereço do vetor
	
	1:
		addi t0, t0, 4 			//Avança para proximo caracter
		lw a0, 0(t0)			//a0 recebe caracter
		beq a0, t2, transform	//Se encontrou um espaço inicia conversao 
		beq a0, t3, transform	//Se encontrou uma quebra de linha inicia conversao 
		j 1b					//Continua laço se não encontrou espaço ou quebra de linha
	
	//Converte numero sabendo que têm no maximo 3 digitos
	transform:
		mv t5, t0
		addi t5, t5, -4
		lw a0, 0(t5)			//a0 recebe digito menos significativo em char
		addi a0, a0, -48		//Converte para decimal
		beq t5, t4, save_int	//Se chegar ao inicio do vetor salva valor
	
		addi t5, t5, -4
		lw a1, 0(t5)			//a1 recebe segundo digito menos significativo
		beq a1, t2, save_int	//Se for um espaço finaliza o laço
		addi a1, a1, -48		//Converte para decimal
		mul a1, a1, t3		
		add a0, a0, a1			//Acumula resultado em a0
		beq t5, t4, save_int	//Se chegar ao inicio do vetor salva valor
	
		addi t5, t5, -4
		lw a1, 0(t5)			//a1 recebe terceiro digito menos significativo
		beq a1, t2, save_int	//Se for um espaço finaliza laço
		addi a1, a1, -48		//Converte para decimal
		mul a1, a1, t3	
		mul a1, a1, t3	
		add a0, a0, a1			//Acumula resultado em a0

	save_int:
		sw a0, 0(t1)			//Salva valor no vetor de inteiros
		addi t1, t1, 4			//Incrementa endereço do vetor de inteiros
		lw a0, 0(t0)	
		bne a0, t3, 1b			//Se o ultimo caracter não for '\n' continua laço
	
	ret

//Função para definir direção a ser tomada
find_direction:
	li t0, 100			//Pixels com valores maiores que 100 são brancos  
	la t1, int_line		//Endereço do vetor
	mv a0, t1 			//Contador apra o vetor
	li t5, 4			//byte=4bits, usado para ajustar valores

	//Encontra a parte externa da borda da esqueda
	lw a1, int_line
	bge a1, t0, 2f		//Para quando a primeira posição já é parte da borda
	1:
		addi a0, a0, 4	//Avança endereço
		lw a1, 0(a0)
		blt a1, t0, 1b	//Verifica se deve continuar procurando um pixel branco
	//Encontra a parte interna da borda da esquerda 
	2:
		addi a0, a0, 4
		lw a1, 0(a0)
		bge a1, t0, 2b	//Verifica se deve continuar procurando um pixel preto
	
	lw t2, x
	sub t4, a0, t1		//Subtrai endereço inicial
	div t4, t4, t5		//Corrige valor dos bytes
	sub t2, t2, t4		//t2 guarda a distancia da borda esquerda ate o veiculo
	//Encontra a parte interna da borda da direita
	3:
		addi a0, a0, 4
		lw a1, 0(a0)
		blt a1, t0, 3b	//Verifica se deve continuar procurando um pixel branco
	
	addi a0, a0, 4		//Corrige posição para ultimo pixel usavel
	lw t3, x
	sub t4, a0, t1		//Subtrai endereço inicial
	div t4, t4, t5		//Corrige valor dos bytes
	sub t3, t4, t3		//t3 guarda a distancia da borda direita ate o veiculo

	//Retorna a valor a ser somado em x para realizar o movimento no registrador a0
	blt t2, t3, right
	blt t3, t2, left
	li a0, 0 
	ret 
	left:
		li a0, -1
		ret
	right:
		li a0, 1
		ret

//Função para imprimir nova posição do veiculo 
print_value:
	//Modifica position no .data para imprimir valores
	li t0, 10		//Usado na conversão
	la t2, position	//Salva endereço de position do .data

	//X assume no maximo o valor 64, verifica somente dois caracteres
	lw a0, x
	rem t1, a0, t0  //t1=a0%t0
  	addi t1, t1, 48 //Converte em ascii
	sb t1, 8(t2)	//Modifica digito menos significativo da coordenada x na position

	div a0, a0, t0
	rem t1, a0, t0  //t1=a0%t0
	addi t1, t1, 48 //Converte em ascii
	sb t1, 7(t2)	//Modifica segundo digito menos significativo da coordenada x na position

	//Y pode assumir valores de ate 4 caracteres
	lw a0, y
	rem t1, a0, t0  //t1=a0%t0
  	addi t1, t1, 48 //Converte em ascii
	sb t1, 13(t2)	//Modifica digito menos significativo da coordenada y na position

	div a0, a0, t0
	rem t1, a0, t0  //t1=a0%t0
	addi t1, t1, 48 //Converte em ascii
	sb t1, 12(t2)	//Modifica segundo digito menos significativo da coordenada y na position

	div a0, a0, t0
	rem t1, a0, t0  //t1=a0%t0
	addi t1, t1, 48 //Converte em ascii
	sb t1, 11(t2)	//Modifica terceiro digito menos significativo da coordenada y na position

	div a0, a0, t0
	rem t1, a0, t0  //t1=a0%t0
	addi t1, t1, 48 //Converte em ascii
	sb t1, 10(t2)	//Modifica quarto digito menos significativo da coordenada y na position

	//Define parametros para impressão
  	li a0, 1		//Valor do file descriptor (stdout)
	la a1, position  	//Aponta para position
	li a2, 15   	 	//Numero de bytes a serem impressos	
	li a7, 64   		//64 para escrita
	ecall       		//Chama o sistema

	ret
