#include <stdlib.h>
#include <string.h>
#include "pila.h"

// Crear una nueva pila vacía
Pila* crear_pila() 
{
    Pila* pila = (Pila*)malloc(sizeof(Pila));
    pila->tope = NULL;
    return pila;
}

// Apilar un dato en la pila (genérico)
void apilar(Pila* pila, void* dato, size_t tamano) 
{
    Nodo* nuevo_nodo = (Nodo*)malloc(sizeof(Nodo));
    nuevo_nodo->dato = malloc(tamano);
    memcpy(nuevo_nodo->dato, dato, tamano); // Copia los datos en la pila
    nuevo_nodo->sig = pila->tope;
    pila->tope = nuevo_nodo;
}

// Desapilar un dato de la pila
void* desapilar(Pila* pila) 
{
    if (check_esta_vacia(pila)) 
    {
        return NULL; // Pila vacía
    }
    Nodo* nodo_a_eliminar = pila->tope;
    void* dato = nodo_a_eliminar->dato;
    pila->tope = nodo_a_eliminar->sig;
    free(nodo_a_eliminar);
    return dato; // Devuelve el dato
}

int check_esta_vacia(Pila* pila) {
    return pila->tope == NULL;
}

void destruir_pila(Pila* pila) 
{
    while (!check_esta_vacia(pila)) 
    {
        void* dato = desapilar(pila);
        free(dato);
    }
    free(pila);
}