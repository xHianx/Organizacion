.data
    board: .space 12       # Tablero con 12 casillas
    discovered: .space 12  # Estado de las casillas descubiertas (0 no descubierta, 1 descubierta)
    chacales: .word 4      # Número de chacales
    tesoros: .word 8       # Número de tesoros
    money: .word 0         # Dinero ganado
    chacales_found: .word 0 # Chacales encontrados
    discovered_count: .word 0 # Contador de casillas descubiertas
    random_count: .word 0  # Contador de números aleatorios repetidos
    previous_random: .word -1 # Almacena el número aleatorio anterior
    money_msg: .asciiz "Dinero ganado: $"

.text
.globl main

main:
    # Inicializar el tablero
    jal initialize_board

game_loop:
    # Mostrar el estado del tablero
    jal display_board
    # Generar un número aleatorio
    jal generate_random_number
    # Verificar si el número se ha generado tres veces seguidas
    jal check_random_count
    # Descubrir la casilla
    jal discover_tile
    # Verificar si el jugador ganó o perdió
    jal check_game_status
    # Preguntar al jugador si desea continuar o retirarse
    jal ask_continue
    # Repetir el ciclo del juego
    j game_loop
initialize_board:
    # Inicializar el generador de números aleatorios
    li $t0, 12      # Número de casillas en el tablero
    li $t1, 4       # Número de chacales a colocar
    li $t2, 8       # Número de tesoros a colocar

    # Inicializar el tablero con ceros (vacío)
    la $t3, board
    li $t4, 0
    li $t5, 12      # Contador de casillas
init_loop:
    sw $t4, 0($t3)
    addi $t3, $t3, 4
    addi $t5, $t5, -1
    bnez $t5, init_loop

    # Colocar chacales en el tablero
place_chacales:
    li $v0, 42      # Syscall para random
    syscall
    rem $t6, $a0, $t0   # $t6 = random % 12
    la $t7, board
    sll $t6, $t6, 2
    add $t7, $t7, $t6
    lw $t8, 0($t7)
    bnez $t8, place_chacales  # Reintentar si la casilla ya está ocupada
    li $t9, -1       # Representación de un chacal
    sw $t9, 0($t7)
    addi $t1, $t1, -1
    bnez $t1, place_chacales

    # Colocar tesoros en el tablero
place_tesoros:
    li $v0, 42      # Syscall para random
    syscall
    rem $t6, $a0, $t0   # $t6 = random % 12
    la $t7, board
    sll $t6, $t6, 2
    add $t7, $t7, $t6
    lw $t8, 0($t7)
    bnez $t8, place_tesoros  # Reintentar si la casilla ya está ocupada
    li $t9, 1        # Representación de un tesoro
    sw $t9, 0($t7)
    addi $t2, $t2, -1
    bnez $t2, place_tesoros

    jr $ra

    display_board:
    la $t0, board         # Apuntador al tablero
    la $t1, discovered    # Apuntador al estado de casillas descubiertas
    li $t2, 0             # Índice del tablero
    li $t3, 12            # Número de casillas

    display_loop:
    lw $t4, 0($t1)        # Cargar el estado de la casilla (descubierta o no)
    lw $t5, 0($t0)        # Cargar el contenido de la casilla (chacal, tesoro, vacío)
    beq $t4, 0, display_hidden

    # Mostrar casilla descubierta
    beq $t5, -1, display_chacal
    beq $t5, 1, display_tesoro
    j display_empty

    display_hidden:
    # Mostrar casilla oculta
    li $v0, 4
    la $a0, hidden_msg
    syscall
    j next_tile

    display_chacal:
    # Mostrar chacal
    li $v0, 4
    la $a0, chacal_msg
    syscall
    j next_tile

    display_tesoro:
    # Mostrar tesoro
    li $v0, 4
    la $a0, tesoro_msg
    syscall
    j next_tile

    display_empty:
    # Mostrar casilla vacía
    li $v0, 4
    la $a0, empty_msg
    syscall

    next_tile:
    addi $t0, $t0, 4      # Siguiente casilla del tablero
    addi $t1, $t1, 4      # Siguiente estado de casilla
    addi $t2, $t2, 1
    blt $t2, $t3, display_loop

    # Mostrar el dinero ganado
    li $v0, 4
    la $a0, money_msg
    syscall
    lw $a0, money
    li $v0, 1
    syscall

    # Mostrar los chacales encontrados
    li $v0, 4
    la $a0, chacales_found_msg
    syscall
    lw $a0, chacales_found
    li $v0, 1
    syscall

    jr $ra

.data
hidden_msg: .asciiz " [*] "
chacal_msg: .asciiz " [C] "
tesoro_msg: .asciiz " [T] "
empty_msg: .asciiz " [ ] "
#money_msg: .asciiz "\nDinero ganado: $"
chacales_found_msg: .asciiz "\nChacales encontrados: "


generate_random_number:
    li $v0, 42      # Syscall para random
    syscall
    rem $a0, $a0, 12 # Generar número aleatorio entre 0 y 11
    addi $a0, $a0, 1 # Ajustar a rango de 1 a 12
    lw $t0, previous_random
    beq $a0, $t0, increment_random_count
    li $t1, 1
    sw $t1, random_count
    sw $a0, previous_random
    jr $ra

increment_random_count:
    lw $t1, random_count
    addi $t1, $t1, 1
    sw $t1, random_count
    jr $ra

check_random_count:
    lw $t1, random_count
    li $t2, 3
    bne $t1, $t2, end_check_random_count
    jal player_lost
    j end_check_random_count

end_check_random_count:
    jr $ra

discover_tile:
    lw $t0, board
    sll $a0, $a0, 2
    add $t0, $t0, $a0
    lw $t1, 0($t0)
    bnez $t1, end_discover_tile
    sw $t1, discovered
    lw $t2, discovered_count
    addi $t2, $t2, 1
    sw $t2, discovered_count
    li $t3, 0
    sw $t3, random_count
    j end_discover_tile

end_discover_tile:
    jr $ra

check_game_status:
    lw $t0, chacales_found
    lw $t1, discovered_count
    
    # Verificar si el jugador ha encontrado 4 tesoros
    li $t2, 4
    beq $t1, $t2, player_won
    
    # Verificar si el jugador ha encontrado todos los chacales
    li $t3, 4
    beq $t0, $t3, player_lost
    
    # Continuar el juego
    jr $ra

player_won:
    # Mostrar mensaje de victoria
    li $v0, 4
    la $a0, win_msg
    syscall
    
    # Mostrar el dinero ganado
    li $v0, 4
    la $a0, money_msg
    syscall
    lw $a0, money
    li $v0, 1
    syscall
    
    # Terminar el programa
    li $v0, 10
    syscall

player_lost:
    # Mostrar mensaje de derrota
    li $v0, 4
    la $a0, lose_msg
    syscall
    
    # Mostrar el dinero ganado
    li $v0, 4
    la $a0, money_msg
    syscall
    lw $a0, money
    li $v0, 1
    syscall
    
    # Terminar el programa
    li $v0, 10
    syscall

.data
win_msg: .asciiz "\\n¡Ganaste! Has encontrado 4 tesoros.\\n"
lose_msg: .asciiz "\\nPerdiste. Has encontrado todos los chacales.\\n"

ask_continue:
    # Mostrar mensaje preguntando al jugador si desea continuar
    li $v0, 4
    la $a0, continue_msg
    syscall

    # Leer la respuesta del jugador (1 para continuar, 0 para retirarse)
    li $v0, 5
    syscall
    move $t0, $v0

    # Verificar la respuesta del jugador
    beq $t0, 1, continue_game
    beq $t0, 0, end_game

continue_game:
    # Continuar el juego
    jr $ra

end_game:
    # Mostrar mensaje de retiro
    li $v0, 4
    la $a0, quit_msg
    syscall
    
    # Mostrar el dinero ganado
    li $v0, 4
    la $a0, money_msg
    syscall
    lw $a0, money
    li $v0, 1
    syscall

    # Terminar el programa
    li $v0, 10
    syscall

.data
continue_msg: .asciiz "\\n¿Deseas continuar jugando? (1 para Sí, 0 para No): "
quit_msg: .asciiz "\\nTe has retirado del juego.\\n"
