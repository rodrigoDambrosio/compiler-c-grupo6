#include <stdlib.h>
#include <string.h>
#include "pila.h"

#define SUCCESS 1
// Crear una nueva pila vacía
Pila* crear_pila() 
{
    Pila* pila = (Pila*)malloc(sizeof(Pila));
    pila->tope = NULL;
    return pila;
}

// Apilar un dato en la pila (genérico)
int apilar(Pila* pila, void* dato, size_t tamano) 
{
    Nodo* nuevo_nodo = (Nodo*)malloc(sizeof(Nodo));
    nuevo_nodo->dato = malloc(tamano);
    memcpy(nuevo_nodo->dato, dato, tamano); // Copia los datos en la pila
    nuevo_nodo->sig = pila->tope;
    pila->tope = nuevo_nodo;

    return SUCCESS;
}

// Desapilar un dato de la pila
void* desapilar(Pila* pila) 
{
    if (es_pila_vacia(pila)) 
    {
        return NULL; // Pila vacía
    }
    Nodo* nodo_a_eliminar = pila->tope;
    void* dato = nodo_a_eliminar->dato;
    pila->tope = nodo_a_eliminar->sig;
    free(nodo_a_eliminar);
    return dato; // Devuelve el dato
}

int es_pila_vacia(Pila* pila) {
    return pila->tope == NULL;
}

void destruir_pila(Pila* pila) 
{
    while (!es_pila_vacia(pila)) 
    {
        void* dato = desapilar(pila);
        free(dato);
    }
    free(pila);
}

int ver_tope_pila(Pila* pila)
{
    if(es_pila_vacia(pila)){
        return -1;
    }
    return (int)pila->tope->dato;
}