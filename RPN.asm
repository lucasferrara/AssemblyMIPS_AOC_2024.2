.data
pilha: .space 84  # Reserva espaco para a pilha com 84 bytes
entrada: .asciiz "Insira a expressao em Notacao Polonesa Reversa: "  # Mensagem para o usuario
resultado: .asciiz "Resultado = "  # Mensagem para exibir o resultado
inputBuffer: .space 100  # Buffer para armazenar a entrada do usuario

.text
.globl main
main:
    li $s1, 0   # Inicializa $s1 com 0 (contador de elementos na pilha)
    li $t7, 0   # Inicializa $t7 com 0 (ponteiro para a pilha)

    # Exibe a mensagem para o usuario inserir a expressao
    li $v0, 4
    la $a0, entrada
    syscall

    # Le a entrada do usuario e armazena em inputBuffer
    li $v0, 8
    la $a0, inputBuffer
    li $a1, 100
    syscall

    li $t1, 0  # Inicializa $t1 com 0 (indice para percorrer a entrada)

process_input:
    lb $t0, inputBuffer($t1)  # Carrega o byte atual da entrada em $t0
    addi $t1, $t1, 1  # Incrementa o indice para o proximo byte
    beq $t0, 32, process_input  # Se for espaco (ASCII 32), ignora e continua
    beq $t0, 0, encerraDoWhile  # Se for o caractere nulo (fim da string), encerra
    blt $t0, 48, verificaOperador  # Se for menor que '0', verifica se eh um operador (todos estao abaixo na tabela ascII)
    li $t2, 0  # Inicializa $t2 com 0 (para armazenar o numero convertido)

converteNum:
    mul $t2, $t2, 10  # Multiplica o numero atual por 10 (para deslocar digitos)
    sub $t0, $t0, 48  # Converte o caractere ASCII para o valor numerico
    add $t2, $t2, $t0  # Adiciona o valor numerico ao numero atual
    lb $t0, inputBuffer($t1)  # Carrega o proximo byte da entrada
    addi $t1, $t1, 1  # Incrementa o indice pra poxima
    blt $t0, 48, encerraConverte  # Se nao for um digito, encerra a conversao
    bgt $t0, 57, encerraConverte  # Se nao for um digito, encerra a conversao
    j converteNum  # Continua a conversao do numero

encerraConverte:
    jal push  # Empilha o numero convertido
    j process_input  # Volta para processar o proximo caractere

verificaOperador:
    beq $t0, 43, if_body  # Se for '+', vai para if_body
    beq $t0, 45, if_body  # Se for '-', vai para if_body
    beq $t0, 42, if_body  # Se for '*', vai para if_body
    beq $t0, 47, if_body  # Se for '/', vai para if_body

    j process_input  # Se nao for nenhum dos acima, continua processando

if_body:
    jal pop  # Desempilha o primeiro operando
    move $t4, $v0  # Armazena o valor em $t4
    jal pop  # Desempilha o segundo operando
    move $t3, $v0  # Armazena o valor em $t3
    jal calc  # Realiza o calculo com os operandos
    move $t2, $v0  # Armazena o resultado em $t2
    jal push  # Empilha o resultado
    j process_input  # Volta para processar o proximo caractere

encerraDoWhile:
    beq $s1, 1, exibeResultado  # Se houver apenas um elemento na pilha, exibe o resultado
    li $v0, 4
    la $a0, resultado
    syscall  # Exibe a mensagem "Resultado = "
    lw $t6, pilha($zero)  # Carrega o resultado da pilha
    li $v0, 1
    move $a0, $t6
    syscall  # Exibe o resultado
    j encerra  # Encerra o programa

exibeResultado:
    li $v0, 4
    la $a0, resultado
    syscall  # Exibe a mensagem "Resultado = "
    lw $t6, pilha($zero)  # Carrega o resultado da pilha
    li $v0, 1
    move $a0, $t6
    syscall  # Exibe o resultado
    j encerra  # Encerra o programa

encerra:
    li $v0, 10
    syscall  # Encerra o programa

push:
    sw $t2, pilha($t7)  # Armazena o valor de $t2 na pilha
    addi $t7, $t7, 4  # Incrementa o ponteiro da pilha
    addi $s1, $s1, 1  # Incrementa o contador de elementos na pilha
    jr $ra  # Retorna para o endereco de chamada

pop:
    addi $t7, $t7, -4  # Decrementa o ponteiro da pilha
    lw $v0, pilha($t7)  # Carrega o valor da pilha em $v0
    addi $s1, $s1, -1  # Decrementa o contador de elementos na pilha
    jr $ra  # Retorna para o endereco de chamada

calc:
    beq $t0, 43, soma  # Se for '+', vai para soma
    beq $t0, 45, subtrai  # Se for '-', vai para subtrai
    beq $t0, 42, multiplica  # Se for '*', vai para multiplica
    beq $t0, 47, divide  # Se for '/', vai para divide
    jr $ra  # Retorna para o endereco de chamada

soma:
    add $t5, $t3, $t4  # Soma os operandos
    move $v0, $t5  # Armazena o resultado em $v0
    jr $ra  # Retorna para o endereco de chamada

subtrai:
    sub $t5, $t3, $t4  # Subtrai os operandos
    move $v0, $t5  # Armazena o resultado em $v0
    jr $ra  # Retorna para o endereco de chamada

multiplica:
    mul $t5, $t3, $t4  # Multiplica os operandos
    move $v0, $t5  # Armazena o resultado em $v0
    jr $ra  # Retorna para o endereco de chamada

divide:
    div $t5, $t3, $t4  # Divide os operandos
    move $v0, $t5  # Armazena o resultado em $v0
    jr $ra  # Retorna para o endereco de chamada