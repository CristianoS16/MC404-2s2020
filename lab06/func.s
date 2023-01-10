.data 
fim_de_linha: .asciz "\n"

.text
  .align 1
  .globl _start

_start:  

  # //Guarda valor 2 em int
  # li a4, 2
  # addi a4, a4, 48
  # .common int, 4, 2
  # sw a4, int, t0

  # //Usada para verificar se de fato o valor 2 esta em int
  # lw a5, int  

  # //Imprime o valor 2 no terminal
  # li a0, 1    //Valor do file descriptor (stdout)
  # la a1, int  //Aponta para mensagem inicial
  # li a2, 4    //Numero de bytes a serem escritos
  # li a7, 64   //64 para escrita
  # ecall

  # //Imprime fim de linha
  # li a0, 1
  # la a1, fim_de_linha 
  # li a2, 1      
  # li a7, 64
  # ecall         

  # li a0, 0 # exit code
  # li a7, 93 # syscall exit
  # ecall

#   li a0, -1
#   li a1, 3
#   jal pow //-1

#   li a1, 4
#   li a0, -1
#   jal pow //1

#   li a1, 5
#   li a0, 2
#   jal pow   //32

#   //pow aparetemente funciona 

  mv a0, a0
  mv a0, a0

  li a0, 5
  jal fat //120

  li a0, 3
  jal fat //6

  li a0, 1
  jal fat //1

  li a0, 0 
  jal fat //1

  li a0, 7 
  jal fat //5040

  li a0, 12
  jal fat

#   //Aparentemente fat funcionar

#   mv a0, a0
#   mv a0, a0


#   li a3, 3
#   li t0, 5
#   li t1, 1
#   fcvt.s.w f4, t1
#   fcvt.s.w f3, t0
#   fdiv.s f0, f4, f3 //f0=1/5
#   jal pow_float
#   //0,2^3=0,008

#   li a3, 2
#   li t0, 3
#   li t1, 1
#   fcvt.s.w f4, t1
#   fcvt.s.w f3, t0
#   fdiv.s f0, f4, f3 //f0=1/3
#   jal pow_float
#   //0,111

#   li a3, 3
#   li t0, 2
#   li t1, 1
#   fcvt.s.w f4, t1
#   fcvt.s.w f3, t0
#   fdiv.s f0, f4, f3 //f0=1/2
#   jal pow_float
#   //0,125


# //Função para calcular potencia, a0**a1, retorna em a0
# pow:
#   li t0, 1
#   mv t1, a0
#   //Numero elevado a 0
#   bne a1, zero, 1f
#   li a0, 1 
#   ret
#   //Numero elevado a 1
#   1:
#     bne a1, t0, 2f
#     ret
#   //Caso padrão
#   2:
#     mul a0, a0, t1
#     addi t0, t0, 1
#     blt t0, a1, 1b

#     mv a4, a0

#   addi sp, sp, -4
#   sw a4, 0(sp)



#   addi sp, sp, 4

#   ecall       //Chama o sistema



#     ret

# //Função para calcular potencia com float, recebe f0 e a3, retorna em f0
# pow_float:
#   li t0, 1
#   fmv.s f4, f0//fadd.s t1, f0, zero//mv t1, f0  //Usando f3 pq t1 nao vai
#   bne a3, zero, 1f
#   //addi t0, t0, 1//li f0, 1
#   fcvt.s.w f0, t0
#   ret
#   1:
#     bne a3, t0, 1f
#     ret
#   1:
#     fmul.s f0, f0, f4
#     addi t0, t0, 1
#     blt t0, a3, 1b
#   ret
  
# //Função para calcular o fatoria de um numero, numero em a0
# fat:
#   mv t0, a0            //Copia o valor de a0 para t0
#   li t1, 2
#   bge t0, t1, 1f
#   li a0, 1
#   ret   
#   1:
#     addi t0, t0, -1     //Decrementa t0
#     mul a0, a0, t0      //Faz a multiplicação de n*n-1*n-2.... 
#     bge t0, t1, 1b    //Verifica condição de parada
#   ret
//Fat float
//Função para calcular o fatoria de um numero, numero em a0
fat:
  li t0, 0
  fcvt.s.w f10, t0
  addi t0, t0, 1
  fcvt.s.w f11, t0

  fcvt.s.w f7, a0   //f7 assume lugar de a0
  fmv.s f10, f7      //f10 assume lugar de t0
  mv t0, a0         //Copia o valor de a0 para t0
  li t1, 2
  //fcvt.s.w f11, t1    
  //fsub.s f11, f11, f11 //f11 = 1

  bge t0, t1, 1f
  li a0, 1
  fcvt.s.w f7, a0
  ret   
  1:
    addi t0, t0, -1     //Decrementa t0
    fsub.s f10, f10, f11   //Decrementa f10
    //mul a0, a0, t0      //Faz a multiplicação de n*n-1*n-2.... 
    fmul.s f7, f7, f10     //Faz a multiplicação de n*n-1*n-2.... 
    bge t0, t1, 1b    //Verifica condição de parada
  ret
  