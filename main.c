#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <string.h>

#define TOTAL_CASILLAS 12
#define TOTAL_CHACALES 4
#define TOTAL_TESOROS 8
#define TESOROS_PARA_GANAR 4
#define DINERO_POR_TESORO 100

char tablero[TOTAL_CASILLAS];
bool descubiertas[TOTAL_CASILLAS];
int tesorosEncontrados = 0;
int chacalesEncontrados = 0;
int dineroGanado = 0;

void inicializarTablero() {
    for (int i = 0; i < TOTAL_TESOROS; i++) {
        tablero[i] = 'T';
    }
    for (int i = TOTAL_TESOROS; i < TOTAL_CASILLAS; i++) {
        tablero[i] = 'C';
    }
    srand(time(NULL));
    for (int i = 0; i < TOTAL_CASILLAS; i++) {
        int j = rand() % TOTAL_CASILLAS;
        char temp = tablero[i];
        tablero[i] = tablero[j];
        tablero[j] = temp;
    }
}

void mostrarTablero() {
    printf("Tablero: ");
    for (int i = 0; i < TOTAL_CASILLAS; i++) {
        if (descubiertas[i]) {
            printf("%c ", tablero[i]);
        } else {
            printf("? ");
        }
    }
    printf("\n");
}

void mostrarResultados() {
    printf("Juego terminado.\n");
    printf("Chacales encontrados: %d\n", chacalesEncontrados);
    printf("Tesoros encontrados: %d\n", tesorosEncontrados);
    printf("Dinero acumulado: $%d\n", dineroGanado);
}

bool obtenerRespuestaValida(char *mensaje) {
    char respuesta[10];  // Aumentamos el tamaño del buffer
    while (true) {
        printf("%s", mensaje);
        scanf("%9s", respuesta);  // Limitamos la lectura a los primeros 9 caracteres
        if (strcmp(respuesta, "si") == 0 || strcmp(respuesta, "no") == 0) {
            return strcmp(respuesta, "si") == 0;
        } else {
            printf("Respuesta inválida. Por favor, responde con 'si' o 'no'.\n");
        }
    }
}

int main() {
    inicializarTablero();
    int ultimosTresNumeros[3] = { -1, -1, -1 };
    int intentos = 0;
    bool primerIntento = true;

    while (true) {
        mostrarTablero();
        printf("Dinero ganado: $%d\n", dineroGanado);
        printf("Chacales encontrados: %d\n", chacalesEncontrados);
        printf("Tesoros encontrados: %d\n", tesorosEncontrados);

        if (primerIntento) {
            if (!obtenerRespuestaValida("\n¿Quieres empezar a girar la ruleta? (si/no): ")) {
                break;
            }
            primerIntento = false;
        } else {
            if (!obtenerRespuestaValida("\n¿Quieres seguir jugando? (si/no): ")) {
                break;
            }
        }

        int casilla = rand() % TOTAL_CASILLAS;
        printf("Número aleatorio generado: %d\n", casilla + 1);

        // Validación de tres números seguidos iguales
        ultimosTresNumeros[0] = ultimosTresNumeros[1];
        ultimosTresNumeros[1] = ultimosTresNumeros[2];
        ultimosTresNumeros[2] = casilla;

        if (ultimosTresNumeros[0] == ultimosTresNumeros[1] && ultimosTresNumeros[1] == ultimosTresNumeros[2]) {
            printf("¡Tres números seguidos iguales! Has perdido el juego.\n");
            break;
        }

        if (descubiertas[casilla]) {
            printf("Ya descubriste esta casilla, intenta otra.\n");
            intentos++;
            if (intentos == 3) {
                printf("Has hecho 3 intentos seguidos en casillas descubiertas. Fin del juego.\n");
                break;
            }
            continue;
        }

        descubiertas[casilla] = true;
        intentos = 0;

        if (tablero[casilla] == 'T') {
            tesorosEncontrados++;
            dineroGanado += DINERO_POR_TESORO;
            printf("¡Encontraste un tesoro!\n");
        } else {
            chacalesEncontrados++;
            printf("¡Encontraste un chacal!\n");
        }

        if (tesorosEncontrados == TESOROS_PARA_GANAR) {
            printf("¡Ganaste el juego! Encontraste los 4 tesoros.\n");
            break;
        }

        if (chacalesEncontrados == TOTAL_CHACALES) {
            printf("¡Perdiste el juego! Encontraste los 4 chacales.\n");
            break;
        }
    }

    mostrarResultados();
    return 0;
}
