//Cristiano Sampaio Pinheiro RA:256352

.text
  .align 1
  .globl _start

_start:  
    //Define parametros para movimentar o veiculo
    li a0, 4500 //Tempo que o carro deve se mover
    li a1, 1    //Direção do movimento
    li a2, 0    //Sentido do movimento
    li a7, 2100 //2100 para mover o veiculo
    ecall       //Chama o sistema
    
    li a0, 1000 //Tempo que o carro deve se mover
    li a2, -1024//Sentido do movimento
    ecall       //Chama o sistema

    li a0, 2000 //Tempo que o carro deve se mover
    li a2, 0    //Sentido do movimento
    ecall       //Chama o sistema

    //Finaliza codigo
    li a0, 0 # exit code
    li a7, 93 # syscall exit
    ecall