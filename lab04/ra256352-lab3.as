#Cristiano Sampaio Pinheiro RA:256352
.org 0x000
comeco:                 #Subtrai 1 do tamanho do vetor para percorre-lo
    LOAD M(tamanho)
    SUB M(um)
    STOR M(tamanho)
laco:           
    LOAD M(vet1)        #Carrega enderreço do inicio do vetor 1
    ADD M(contador)     #Soma o contador para encontrar a posição atual do vetor
    STA M(mul1)         #Modifica enderreço da instrução mul1
    LOAD M(vet2)        #Carrega enderreço do inicio do vetor 2
    ADD M(contador)     #Soma o contador para encontrar a posição atual do vetor
    STA M(mul2)         #Modifica enderreço da instrução mul2
    mul1:               #Multiplica numeros para fazer o produto escalar
        LOAD MQ, M(0x000)
    mul2:
        MUL M(0x000)
    LOAD MQ
    ADD M(produto_escalar)      #Adiciona o valor anterior do produto escalar ao encontrado 
    STOR M(produto_escalar)     #Sobrescreve o valor do produto escalar
atualiza_contador:    
    LOAD M(contador)
    ADD M(um)
    STOR M(contador)
#Verifica condição de parada do laço
    LOAD M(tamanho)
    SUB M(contador)
    JUMP+ M(laco)
fim:
    LOAD M(produto_escalar)     #Coloca o produto escalar em AC
    JUMP M(1024)                #Salta para uma posição invalida

.org 0x097
produto_escalar: .word 0000000000
um: .word 0000000001
contador: .word 0000000000
.org 1021
tamanho: .skip 1 
vet1: .skip 1
vet2: .skip 1
