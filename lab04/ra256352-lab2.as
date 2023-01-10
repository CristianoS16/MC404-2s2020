#Cristiano Sampaio Pinheiro RA:256352
.org 0x000
comeco:
    LOAD MQ, M(gravidade)   #Carrega o valor da gravidade no registrador MQ
    MUL M(distancia)        #Faz a multiplicação da gravidade pela distancia
    LOAD MQ                 #Transfere o resultado para AC
    STOR M(gx)              #Salva o resultado em gx 
    RSH                     #Divide o resultado(gx) por 2
    STOR M(k)               #Salva o resultado em k
laco:
    LOAD M(gx)              #Carrega o valor de gx em AC
    DIV M(k)                #Divide gx por k
    LOAD MQ                 #Transfere o resultado para AC
    ADD M(k)                #Soma k ao resultado, ficando k+(gx)/k
    RSH                     #Divide o resultado por 2
    STOR M(k)               #Sobrescreve k com o novo resultado
atualiza_contador:
    LOAD M(contador)
    SUB M(um)
    STOR M(contador)
    
    JUMP+ M(laco)           #Verifica condição de parada do laço
fim:
    LOAD M(k)               #Coloca o valor encontrado para velocidade em AC
    JUMP M(1024)            #Salta para uma posição invalida
    
.org 0x110
distancia:  .skip 1
gravidade:  .word 0000000010
contador:   .word 0000000009
um:         .word 0000000001
gx:         .skip 1
k:          .skip 1
