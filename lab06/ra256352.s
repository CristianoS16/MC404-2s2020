.text
  .align 1
  .globl _start

_start:  

  # Converte angulo inteiro para radianos e coloca em f0
  jal funcao_pegar_angulo
  # Utilizado para calcular a série
  jal funcao_calcula_serie
  # Transforma um PF para inteiro, onde a0 contem o sinal, a1 a parte inteira e a2 a parte fracionaria (truncada com 3 casas decimais)
  jal funcao_float_para_inteiro
  # Imprime o resultado de a0, a1 e a2 na tela
  jal funcao_imprime
  
  li a0, 0 # exit code
  li a7, 93 # syscall exit
  ecall
  
//Função para calcular potencia, a0**a1, retorna em a0
pow:
  li t5, 1
  mv t6, a0
  //Numero elevado a 0
  bne a1, zero, 1f
  li a0, 1 
  ret
  //Numero elevado a 1
  1:
    bne a1, t5, 2f
    ret
  //Caso padrão
  2:
    mul a0, a0, t6
    addi t5, t5, 1
    blt t5, a1, 1b
    ret

//Função para calcular potencia com float, recebe f0 e a3, retorna em f0
pow_float:
  li t5, 1
  fmv.s f0, f6
  fmv.s f4, f0
  bne a3, zero, 1f
  fcvt.s.w f0, t5
  ret
  1:
    bne a3, t5, 1f
    ret
  1:
    fmul.s f0, f0, f4
    addi t5, t5, 1
    blt t5, a3, 1b
  ret
  
//Função para calcular o fatoria de um numero, numero em a0
fat:
  li t5, 0
  fcvt.s.w f10, t5
  addi t5, t5, 1
  fcvt.s.w f11, t5

  fcvt.s.w f7, a0    //f7 assume lugar de a0
  fmv.s f10, f7      //f10 assume lugar de t5
  mv t5, a0          //Copia o valor de a0 para t5
  li t1, 2

  bge t5, t1, 1f
  li a0, 1
  fcvt.s.w f7, a0
  ret   
  1:
    addi t5, t5, -1        //Decrementa t5
    fsub.s f10, f10, f11   //Decrementa f10
    fmul.s f7, f7, f10     //Faz a multiplicação de n*n-1*n-2.... 
    bge t5, t1, 1b         //Verifica condição de parada
  ret
  

funcao_calcula_serie:
  addi sp, sp, -8
  sw ra, 0(sp)
  sw s0, 4(sp)
  addi s0, sp, 8
  
  # Neste ponto o registrador f0 contem o valor de angle em radianos
  # *********************************************
  //Calcula a serie
  fmv.s f6, f0     //Copia valor para f6

  li a1, 0         //a1 contador -->n
  li t0, -1        //t0 contem -1
  li t1, 2         //t1 contem 2
  li t2, 10        //numero de interações a serem feitas
  fcvt.s.w f1, a1
  fcvt.s.w f2, a1

  laco:
    mv a0, t0
    //Chama pow para fazer a0**a1 -> (-1)**cont
    jal pow
    mv a2, a0       //a2 = (-1)**cont

    //Calcula 2n+1
    mul a3, t1, a1    //2n
    addi a3, a3, 1    //a3 = 2n+1
    mv a0, a3         //a0=a3 = 2n+1

    //Chama fat para fazer o fatorial de (2n+1)

    jal fat         //Devolve valor em f7

    //Colocar em f's para realizar divisão não inteira
    fcvt.s.w f4, a2  //f4 recebe a2 para realizar divisão

    fdiv.s f3, f4, f7    //f3 = [(-1)**cont]/(2n+1)!

    //chama pow_float para fazer potencia do numero ponto flutuante em f0 por a3(2n+1)  

    jal pow_float

    fmul.s f1, f0, f3      //faz (x**(2n+1))*[(-1)**cont]/(2n+1)!
    fadd.s f2, f2, f1      //Vai juntando tudo em f2

    addi a1, a1, 1         //Incrementa contador

    bne a1, t2, laco       //Verifica condição de parada
    fmv.s f0, f2           //Transfere resultado para f0
  # *********************************************

  lw ra, 0(sp)
  lw s0, 4(sp)
  addi sp, sp, 8
  jr ra

funcao_imprime:
  addi sp, sp, -8
  sw ra, 0(sp)
  sw s0, 4(sp)
  addi s0, sp, 8
  
  # Neste ponto os registradores contem:
  #   a0 -> valor 0 se f0 for positivo e !=0 caso contratio
  #   a1 -> Parte inteira de f0
  #   a2 -> Parte fracionaria de f0 (truncada com 3 casas decimais, i.e. 0 a 999)
  # **************************************
  .data 
  sen:.asciz "SENO: "
 
  positivo: .asciz "+"

  negativo: .asciz "-"

  ponto: .asciz "."
    
  fim_de_linha: .asciz "\n"

  .text
  //Salva valores recebidos em outros registradores para poder definir parametros para impressão
  mv a3, a0    //a3=sinal
  mv a4, a1    //a4=parte inteira
  mv a5, a2    //a5=parte fracionaria

  //Define parametros para impressão
  li a0, 1    //Valor do file descriptor (stdout)
  la a1, sen  //Aponta para mensagem inicial
  li a2, 6    //Numero de bytes a serem escritos
  li a7, 64   //64 para escrita
  ecall       //Chama o sistema

  //Verifica se o numero é positivo ou negativo e imprime
  li a0, 1
  li a2, 1           //Numero de bytes a serem escritos
  bne a3, zero, 1f   //se a3!=0 salta para 1
  la a1, positivo    //se a3==0 então numero positivo
  ecall              //Chama sistema
  j 2f
  1:
    la a1, negativo  //se a3!=0  então numero negativo
    ecall            //Chama sistema
  2:
  //Imprime um caracter da parte inteira, não é necessario alterar a2
  li a2, 4
  addi a4, a4, 48    //Passa numero para ascii
  addi sp, sp, -4    //Salva valor na pilha
  sw a4, 0(sp)
  mv a1, sp          //Aponta para imprimir numero na pilha
  ecall              //Chama sistema
  addi sp, sp, 4

  //Imprime ponto
  li a0, 1
  li a2, 1
  la a1, ponto  //a1 recebe endereço do ponto a ser impresso
  ecall         //Chama sistema
  
  //Imprime 3 caracteres da parte fracionaria
  li t0, 10
  rem t1, a5, t0  //t1=a5%t0
  addi t2, t1, 48 //Conlova em ascii

  addi sp, sp, -4    //Salva valor na pilha
  sw t2, 0(sp)

  div a5, a5, t0
  rem t1, a5, t0  //t1=a5%t0
  addi t2, t1, 48 //Conlova em ascii

  addi sp, sp, -4    //Salva valor na pilha
  sw t2, 0(sp)

  div a5, a5, t0
  rem t1, a5, t0  //t1=a5%t0
  addi t2, t1, 48 //Conlova em ascii

  addi sp, sp, -4    //Salva valor na pilha
  sw t2, 0(sp)
  mv a1, sp          //Aponta para imprimir numero na pilha
  
  li a2, 1          //Numero de bytes a serem escritos
  li a0, 1
  ecall              //Chama sistema

  addi sp, sp, 4
  mv a1, sp 
  ecall

  addi sp, sp, 4
  mv a1, sp
  ecall

  addi sp, sp, 4

  //Imprime fim de linha
  li a0, 1
  li a2, 1      //Numero de bytes a serem escritos
  li a7, 64
  la a1, fim_de_linha //a1 recebe endereço do fim de linha
  ecall         //Chama sistema

  li a0, 0 # exit code
  li a7, 93 # syscall exit
  _end:
    ecall

  # **************************************
  
  lw ra, 0(sp)
  lw s0, 4(sp)
  addi sp, sp, 8
  jr ra

  
funcao_pegar_angulo:
  addi sp, sp, -8
  sw ra, 0(sp)
  sw s0, 4(sp)
  addi s0, sp, 8
  
  # load angle value to a0
  lw a0, angle
  # convert angle to float and put in f0
  fcvt.s.w f0, a0
  # load pi address to a0
  la a0, .float_pi
  # load float_pi value (from a0 address) into f1
  flw f1, 0(a0)
  # load value 180 into a0
  li a0, 180
  # convert 180 to float and put in f2
  fcvt.s.w f2, a0

  # f0 -> angle, f1 -> pi, f2 -> 180
  # Now, put angle in radians (angle*pi/180)
  # f0 = angle * pi
  fmul.s f0, f0, f1
  # f0 = f0 / 180
  fdiv.s f0, f0, f2
  
  lw ra, 0(sp)
  lw s0, 4(sp)
  addi sp, sp, 8
  jr ra
  
funcao_float_para_inteiro:
  addi sp, sp, -8
  sw ra, 0(sp)
  sw s0, 4(sp)
  addi s0, sp, 8
  
  # Get signal
  li a0, 0
  fcvt.s.w f1, a0
  flt.s a0, f0, f1
  
  # Drop float signal
  fabs.s f0, f0
  
  # Truncate integer part
  fcvt.s.w f1, a0
  fadd.s f1, f1, f0
  jal funcao_truncar_float
  fcvt.w.s a1, f0
  
  # Truncate float part with 3 decimal places
  fsub.s f1, f1, f0
  li a3, 1000
  fcvt.s.w f2, a3
  fmul.s f0, f1, f2
  jal funcao_truncar_float
  fcvt.w.s a2, f0
  li a3, 1000
  rem a2, a2, a3
  
  lw ra, 0(sp)
  lw s0, 4(sp)
  addi sp, sp, 8
  jr ra
  
funcao_truncar_float:
  addi sp, sp, -8
  sw ra, 0(sp)
  sw s0, 4(sp)
  addi s0, sp, 8
  
  fmv.x.w a5, f0
  li a3, 22
  srai a4, a5,0x17
  andi a4, a4, 255
  addi a4, a4, -127
  addi a2, a5, 0
  blt a3, a4, .funcao_truncar_float_continue
  lui a5, 0x80000
  and a5, a5, a2
  bltz a4, .funcao_truncar_float_continue
  lui a5, 0x800
  addi a5, a5, -1
  sra a5, a5, a4
  not a5, a5
  and a5, a5, a2
.funcao_truncar_float_continue:
  fmv.w.x f0, a5
  
  lw ra, 0(sp)
  lw s0, 4(sp)
  addi sp, sp, 8
  jr ra
  
  
# Additional data variables
.align  4
.data
  angle:
    .word 45
  .float_pi:
    .word 0x40490fdb

