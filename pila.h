#ifndef PILA_H
#define PILA_H
#include <stddef.h>

typedef struct Nodo{
    void* dato;
    struct Nodo* sig;
}Nodo;

typedef struct pila
{
    Nodo* tope;
}Pila;

Pila* crear_pila();
int apilar(Pila* pila, void* dato, size_t tamano);
void* desapilar(Pila* pila);
int es_pila_vacia(Pila* pila);
void destruir_pila(Pila* pila);
int ver_tope_pila(Pila* pila); // Se usa para debug
#endif

