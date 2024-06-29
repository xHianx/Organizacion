.data
tablero: .space 12
descubiertas: .space 12
ultimosTresNumeros: .space 12

mensaje_inicio: .asciiz "¿Quieres empezar a girar la ruleta? (si/no): "
mensaje_continuar: .asciiz "¿Quieres seguir jugando? (si/no): "
mensaje_tablero: .asciiz "Tablero: "
mensaje_tesoro: .asciiz "¡Encontraste un tesoro!\n"
mensaje_chacal: .asciiz "¡Encontraste un chacal!\n"
mensaje_ganar: .asciiz "¡Ganaste el juego! Encontraste los 4 tesoros.\n"
mensaje_perder: .asciiz "¡Perdiste el juego! Encontraste los 4 chacales.\n"
mensaje_tres_iguales: .asciiz "¡Tres números seguidos iguales! Has perdido el juego.\n"
mensaje_descubierta: .asciiz "Ya descubriste esta casilla, intenta otra.\n"
mensaje_resultados: .asciiz "Juego terminado.\n"
mensaje_chacales: .asciiz "Chacales encontrados: "
mensaje_tesoros: .asciiz "Tesoros encontrados: "
mensaje_dinero: .asciiz "Dinero ganado: $"
espacio: .asciiz " "
dinero: .word 0
tesoros: .word 0
chacales: .word 0
respuesta: .space 10

.text
.globl main

main:
    jal inicializarTablero
    li $t8, 1         # primerIntento
    li $t4, 0         # intentos
    li $t5, -1        # ultimosTresNumeros[0]
    li $t6, -1        # ultimosTresNumeros[1]
    li $t7, -1        # ultimosTresNumeros[2]

game_loop:
    jal mostrarTablero
    jal mostrarEstadisticas

    beq $t8, 1, primer_intento
    la $a0, mensaje_continuar
    j obtener_respuesta
primer_intento:
    la $a0, mensaje_inicio
    li $t8, 0

obtener_respuesta:
    li $v0, 4
    syscall
    li $v0, 8
    la $a0, respuesta
    li $a1, 10
    syscall

    la $t0, respuesta
    lb $t1, 0($t0)
    li $t2, 'n'
    beq $t1, $t2, end_game_loop

    # Generar número aleatorio y mostrarlo
    li $a1, 12         # Límite superior del rango para syscall 42
    li $v0, 42
    syscall
    move $t1, $a0      # Guardar el valor generado
    addi $t1, $t1, 1   # Ajustar el número para que esté entre 1 y 12
    move $a0, $t1
    li $v0, 1
    syscall

    # Actualizar ultimosTresNumeros
    move $t5, $t6
    move $t6, $t7
    move $t7, $t1

    beq $t5, $t6, check_numbers_equal
    j valid_number
check_numbers_equal:
    beq $t6, $t7, end_game_equal_numbers
valid_number:

    # Check if the cell was already discovered
    lb $t2, descubiertas($t1)
    beqz $t2, mark_discovered
    addi $t4, $t4, 1
    bne $t4, 3, game_loop
    j end_game_discovered

mark_discovered:
    sb $zero, descubiertas($t1)
    li $t4, 0

    # Check if it's a treasure or a chacal
    lb $t2, tablero($t1)
    li $t3, 'T'
    beq $t2, $t3, found_treasure
    jal found_chacal
    j check_end_game

found_treasure:
    lw $t0, tesoros
    addi $t0, $t0, 1  # tesorosEncontrados++
    sw $t0, tesoros
    lw $t1, dinero
    addi $t1, $t1, 100 # dineroGanado += 100
    sw $t1, dinero
    la $a0, mensaje_tesoro
    li $v0, 4
    syscall
    j check_end_game

found_chacal:
    lw $t0, chacales
    addi $t0, $t0, 1  # chacalesEncontrados++
    sw $t0, chacales
    la $a0, mensaje_chacal
    li $v0, 4
    syscall

check_end_game:
    lw $t0, tesoros
    li $t1, 4
    beq $t0, $t1, end_game_win

    lw $t0, chacales
    li $t1, 4
    beq $t0, $t1, end_game_lose

    j game_loop

end_game_equal_numbers:
    la $a0, mensaje_tres_iguales
    li $v0, 4
    syscall
    j end_game

end_game_discovered:
    la $a0, mensaje_descubierta
    li $v0, 4
    syscall
    j end_game

end_game_win:
    la $a0, mensaje_ganar
    li $v0, 4
    syscall
    j end_game

end_game_lose:
    la $a0, mensaje_perder
    li $v0, 4
    syscall
    j end_game

end_game_loop:
    jal mostrarResultados
    j exit

end_game:
    jal mostrarResultados
    j exit

mostrarEstadisticas:
    la $a0, mensaje_dinero
    li $v0, 4
    syscall
    lw $a0, dinero
    li $v0, 1
    syscall
    la $a0, espacio
    li $v0, 4
    syscall

    la $a0, mensaje_chacales
    li $v0, 4
    syscall
    lw $a0, chacales
    li $v0, 1
    syscall
    la $a0, espacio
    li $v0, 4
    syscall

    la $a0, mensaje_tesoros
    li $v0, 4
    syscall
    lw $a0, tesoros
    li $v0, 1
    syscall
    la $a0, espacio
    li $v0, 4
    syscall

    jr $ra

mostrarTablero:
    la $a0, mensaje_tablero
    li $v0, 4
    syscall

    # Imprimir el estado del tablero
    li $t0, 0
mostrar_loop:
    bge $t0, 12, fin_mostrar
    lb $t1, descubiertas($t0)
    beqz $t1, print_unknown
    lb $a0, tablero($t0)
    j print_char
print_unknown:
    li $a0, '?'
print_char:
    li $v0, 11
    syscall
    li $a0, ' '
    li $v0, 11
    syscall
    addi $t0, $t0, 1
    j mostrar_loop
fin_mostrar:
    li $a0, '\n'
    li $v0, 11
    syscall
    jr $ra

mostrarResultados:
    la $a0, mensaje_resultados
    li $v0, 4
    syscall

    la $a0, mensaje_chacales
    li $v0, 4
    syscall
    lw $a0, chacales
    li $v0, 1
    syscall

    la $a0, mensaje_tesoros
    li $v0, 4
    syscall
    lw $a0, tesoros
    li $v0, 1
    syscall

    la $a0, mensaje_dinero
    li $v0, 4
    syscall
    lw $a0, dinero
    li $v0, 1
    syscall

    jr $ra

inicializarTablero:
    # Inicializar tablero con 'T'
    li $t0, 0
    li $t1, 'T'
loop_init_tesoros:
    bge $t0, 8, fin_init_tesoros
    sb $t1, tablero($t0)
    addi $t0, $t0, 1
    j loop_init_tesoros
fin_init_tesoros:

    # Inicializar tablero con 'C'
    li $t1, 'C'
loop_init_chacales:
    bge $t0, 12, fin_init_chacales
    sb $t1, tablero($t0)
    addi $t0, $t0, 1
    j loop_init_chacales
fin_init_chacales:

    # Barajar el tablero
    li $t2, 12  # TOTAL_CASILLAS
    li $t3, 0
shuffle_loop:
    bge $t3, 12, fin_shuffle
    li $a1, 12         # Límite superior del rango para syscall 42
    li $v0, 42         # Random number syscall
    syscall
    rem $t4, $v0, $t2  # j = rand() % 12
    mul $t5, $t4, 1
    lb $t6, tablero($t3)   # temp = tablero[i]
    lb $t7, tablero($t5)   # tablero[i] = tablero[j]
    sb $t7, tablero($t3)
    sb $t6, tablero($t5)   # tablero[j] = temp
    addi $t3, $t3, 1
    j shuffle_loop
fin_shuffle:
    jr $ra

exit:
    li $v0, 10
    syscall
