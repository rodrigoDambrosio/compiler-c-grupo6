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
void apilar(Pila* pila, void* dato, size_t tamano);
void* desapilar(Pila* pila);
int check_esta_vacia(Pila* pila);
void destruir_pila(Pila* pila);

#endif

