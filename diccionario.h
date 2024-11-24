#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct 
{
    char nombre[50];  // Nombre de la variable o constante
    int posicion;             // Posición en el terceto
} EntradaDiccionario;

typedef struct 
{
    EntradaDiccionario *entradas; // Array dinámico de entradas
    int cantidad;                 // Número actual de entradas
    int capacidad;                // Capacidad máxima actual
} Diccionario;

const char* buscar_nombre(Diccionario *dic, int posicion);
void inicializar_diccionario(Diccionario *dic);
void agregar_entrada(Diccionario *dic, const char *nombre, int posicion);
void agregar_entrada(Diccionario *dic, const char *nombre, int posicion);
void liberar_diccionario(Diccionario *dic);
int buscar_posicion(Diccionario *dic, const char *nombre);


// Inicializa el diccionario
void inicializar_diccionario(Diccionario *dic)
{
    dic->cantidad = 0;
    dic->capacidad = 10; // Capacidad inicial
    dic->entradas = malloc(dic->capacidad * sizeof(EntradaDiccionario));
    if (!dic->entradas) 
    {
        perror("Error al inicializar el diccionario");
        exit(1);
    }
}

// Agrega una nueva entrada al diccionario
void agregar_entrada(Diccionario *dic, const char *nombre, int posicion) 
{
    if (dic->cantidad == dic->capacidad) 
    {
        dic->capacidad *= 2;
        dic->entradas = realloc(dic->entradas, dic->capacidad * sizeof(EntradaDiccionario));
        if (!dic->entradas) {
            perror("Error al redimensionar el diccionario");
            exit(1);
        }
    }
    // Agregar la nueva entrada
    strcpy(dic->entradas[dic->cantidad].nombre, nombre);
    dic->entradas[dic->cantidad].posicion = posicion;
    dic->cantidad++;

    // printf("EL DIC QUEDO\n");
    // printf("NOMBRE %s\n",dic->entradas[dic->cantidad-1].nombre );
    // printf("POS %d vino por par la pos %d\n",dic->entradas[dic->cantidad-1].posicion, posicion);
}

// Busca una entrada en el diccionario por nombre
int buscar_posicion(Diccionario *dic, const char *nombre) 
{
    int i = 0;
    for ( i =0 ; i < dic->cantidad; i++) {
        if (strcmp(dic->entradas[i].nombre, nombre) == 0) {
            return dic->entradas[i].posicion; // Retorna la posición del terceto
        }
    }
    return -1; // No encontrado
}

// Libera la memoria del diccionario
void liberar_diccionario(Diccionario *dic) 
{
    free(dic->entradas);
    dic->entradas = NULL;
    dic->cantidad = 0;
    dic->capacidad = 0;
}
// Busca una entrada en el diccionario por posición
const char* buscar_nombre(Diccionario *dic, int posicion) 
{
    int i =0;
    for ( i = 0; i < dic->cantidad; i++) 
    {
        if (dic->entradas[i].posicion == posicion) 
        {
            return dic->entradas[i].nombre; // Retorna el nombre de la variable
        }
    }
    // printf("NO ENCONTRE %d", posicion);
    // getchar();
    return NULL; // No encontrado
}

void eliminar_corchetes(const char *cadena, char *resultado)
{
    int longitud = strlen(cadena);

    if (cadena[0] == '[' && cadena[longitud - 1] == ']' && longitud > 2) 
    {
        strncpy(resultado, cadena + 1, longitud - 2); 
        resultado[longitud - 2] = '\0';              
    } 
    else 
    {
        strcpy(resultado, cadena); 
    }
}