/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 */

package com.mycompany.organizacion;

import java.util.Random;
import java.util.Scanner;

public class Organizacion {

    private static final int TOTAL_CASILLAS = 12;
    private static final int TOTAL_CHACALES = 4;
    private static final int TOTAL_TESOROS = 8;
    private static final int TESOROS_PARA_GANAR = 4;
    private static final int DINERO_POR_TESORO = 100;

    private static char[] tablero = new char[TOTAL_CASILLAS];
    private static boolean[] descubiertas = new boolean[TOTAL_CASILLAS];
    private static int tesorosEncontrados = 0;
    private static int chacalesEncontrados = 0;
    private static int dineroGanado = 0;

    public static void main(String[] args) {
        inicializarTablero();
        Scanner scanner = new Scanner(System.in);
        Random random = new Random();
        int intentos = 0;
        int[] ultimosTresNumeros = new int[3];

        while (true) {
            mostrarTablero();
            System.out.println("Dinero ganado: $" + dineroGanado);
            System.out.println("Chacales encontrados: " + chacalesEncontrados);
            System.out.println("Tesoros encontrados: " + tesorosEncontrados);

            System.out.print("\n¿Quieres seguir jugando? (si/no): ");
            String respuesta = scanner.next();
            if (respuesta.equalsIgnoreCase("no")) {
                break;
            }

            int casilla = random.nextInt(TOTAL_CASILLAS);
            System.out.println("Número aleatorio generado: " + (casilla + 1));

            // Validación de tres números seguidos iguales
            ultimosTresNumeros[0] = ultimosTresNumeros[1];
            ultimosTresNumeros[1] = ultimosTresNumeros[2];
            ultimosTresNumeros[2] = casilla;

            if (ultimosTresNumeros[0] == ultimosTresNumeros[1] && ultimosTresNumeros[1] == ultimosTresNumeros[2]) {
                System.out.println("¡Perdiste! Tres números seguidos iguales.");
                break;
            }

            if (descubiertas[casilla]) {
                intentos++;
                if (intentos == 3) {
                    System.out.println("¡Perdiste! Tres intentos seguidos en casillas descubiertas.");
                    break;
                }
                continue;
            }

            descubiertas[casilla] = true;
            intentos = 0;

            if (tablero[casilla] == 'T') {
                tesorosEncontrados++;
                dineroGanado += DINERO_POR_TESORO;
                System.out.println("¡Encontraste un tesoro!");
            } else {
                chacalesEncontrados++;
                System.out.println("¡Encontraste un chacal!");
            }

            if (tesorosEncontrados == TESOROS_PARA_GANAR) {
                System.out.println("¡Ganaste el juego! Encontraste los 4 tesoros.");
                break;
            }

            if (chacalesEncontrados == TOTAL_CHACALES) {
                System.out.println("¡Perdiste el juego! Encontraste los 4 chacales.");
                break;
            }
        }

        mostrarResultados();
        scanner.close();
    }

    private static void inicializarTablero() {
        for (int i = 0; i < TOTAL_TESOROS; i++) {
            tablero[i] = 'T';
        }
        for (int i = TOTAL_TESOROS; i < TOTAL_CASILLAS; i++) {
            tablero[i] = 'C';
        }
        Random random = new Random();
        for (int i = 0; i < TOTAL_CASILLAS; i++) {
            int j = random.nextInt(TOTAL_CASILLAS);
            char temp = tablero[i];
            tablero[i] = tablero[j];
            tablero[j] = temp;
        }
    }

    private static void mostrarTablero() {
        System.out.print("Tablero: ");
        for (int i = 0; i < TOTAL_CASILLAS; i++) {
            if (descubiertas[i]) {
                System.out.print(tablero[i] + " ");
            } else {
                System.out.print("? ");
            }
        }
        System.out.println();
    }

    private static void mostrarResultados() {
        System.out.println("Juego terminado.");
        System.out.println("Chacales encontrados: "+ chacalesEncontrados);
        System.out.println("Tesoros encontrados: " + tesorosEncontrados);
        System.out.println("Dinero acumulado: $" + dineroGanado);
    }
}