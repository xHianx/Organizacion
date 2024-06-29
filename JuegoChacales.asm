.data
tablero: .space 12
descubiertas: .space 12
ultimosTresNumeros: .space 3
contadorNumeros: .space 12  # Contadores para números del 1 al 12
mensaje_error: .asciiz "\n Solo se acepta (s/n) como respuesta: "
mensaje_inicio: .asciiz "\n¿Quieres empezar a girar la ruleta? (s/n): "
mensaje_continuar: .asciiz "\n¿Quieres seguir jugando? (s/n): "
mensaje_tablero: .asciiz "Tablero: \n"
mensaje_tesoro: .asciiz "\n¡Encontraste un tesoro!\n"
mensaje_chacal: .asciiz "\n¡Encontraste un chacal!\n"
mensaje_ganar: .asciiz "\n¡Ganaste el juego! Encontraste los 4 tesoros.\n"
mensaje_perder_chacales: .asciiz "\n¡Perdiste el juego! Encontraste los 4 chacales.\n"
mensaje_perder_tres_iguales: .asciiz "\n¡Perdiste el juego! Tres veces el mismo número.\n"
mensaje_descubierta: .asciiz "\nYa descubriste esta casilla, intenta otra.\n"
mensaje_resultados: .asciiz "\nJuego terminado.\n"
mensaje_chacales: .asciiz "\nChacales encontrados: "
mensaje_tesoros: .asciiz "\nTesoros encontrados: "
mensaje_dinero: .asciiz "\nDinero ganado: $"
mensaje_numero_aleatorio: .asciiz "\nEl numero aleatorio que se genero es: "
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
    li $t9, 's'
    beq $t1, $t2, end_game_loop
    beq $t1, $t9, comenzar_juego
    la $a2, mensaje_continuar
    j obtener_respuesta
#    bne $t1, $t2, mensaje_continuar
#   bne $t1, $t9, mensaje_continuar
comenzar_juego:
    # Generar número aleatorio y mostrarlo
    li $a1, 12         # Límite superior del rango para syscall 42
    li $v0, 42
    syscall
    move $t1, $a0      # Guardar el valor generado
    addi $t1, $t1, 1   # Ajustar el número para que esté entre 1 y 12

    # Mostrar mensaje del número aleatorio
    la $a0, mensaje_numero_aleatorio
    li $v0, 4
    syscall

    # Mostrar el número generado
    move $a0, $t1
    li $v0, 1
    syscall

    # Incrementar el contador del número generado
    subi $t3, $t1, 1  # Ajustar índice para contadorNumeros
    lb $t4, contadorNumeros($t3)
    addi $t4, $t4, 1
    sb $t4, contadorNumeros($t3)

    # Verificar si el número ha salido tres veces
    li $t5, 3
    beq $t4, $t5, end_game_equal_numbers

    # Verificar si la casilla ya fue descubierta
    subi $t1, $t1, 1  # Ajustar índice para descubiertas y tablero
    lb $t2, descubiertas($t1)
    bnez $t2, end_game_discovered

    # Marcar la casilla como descubierta
    li $t3, 1
    sb $t3, descubiertas($t1)

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
    beq $t0, $t1, end_game_lose_chacales

    j game_loop

end_game_equal_numbers:
    # Si se encuentran tres veces el mismo número, se pierde el juego y se reinicia el dinero ganado
    sw $zero, dinero
    la $a0, mensaje_perder_tres_iguales
    li $v0, 4
    syscall
    j end_game

end_game_discovered:
    la $a0, mensaje_descubierta
    li $v0, 4
    syscall
    j game_loop

end_game_win:
    la $a0, mensaje_ganar
    li $v0, 4
    syscall
    j end_game

end_game_lose_chacales:
    # Si se encuentran los 4 chacales, se pierde el juego y se reinicia el dinero ganado
    sw $zero, dinero
    la $a0, mensaje_perder_chacales
    li $v0, 4
    syscall
    j end_game

end_game_loop:
    jal mostrarTablero  # Mostrar el tablero actualizado
    jal mostrarResultados
    j exit

end_game:
    jal mostrarTablero  # Mostrar el tablero actualizado
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
