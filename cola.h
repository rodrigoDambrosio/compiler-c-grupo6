#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define minimo(X,Y) ((X) <= (Y) ? (X) : (Y))

/* ESTRUCTURA COLA */ 

// TODO: Separarlo con el .c

typedef struct cNodo
{
    void *infoC;
    unsigned tamInfoC;
    struct cNodo *sigC;
} tNodo_c;

typedef struct
{
    tNodo_c *priC,
          *ultC;
} t_cola;


void crear_cola(t_cola *c);
int cola_llena(const t_cola *c,unsigned cantBytes);
int poner_en_cola(t_cola *c, const void *d, unsigned cantBytes);
void vaciar_cola(t_cola *c);
int ver_primer_cola(const t_cola *c, void *d, unsigned cantBytes);
int cola_vacia (const t_cola *c);
int sacar_de_cola(t_cola *c, void *d, unsigned cantBytes);

/* Funciones de cola */

void crear_cola(t_cola *c)
{
    c->priC = NULL;
    c->ultC = NULL;
}

int cola_llena(const t_cola *c,unsigned cantBytes)
{
    tNodo_c *aux = (tNodo_c *)malloc(sizeof(tNodo_c));
    void *infoC = malloc(cantBytes);
    free(aux);
    free(infoC);
    return aux == NULL|| infoC == NULL;
}

int poner_en_cola(t_cola *c, const void *d, unsigned cantBytes)
{
    tNodo_c *nue = (tNodo_c *) malloc(sizeof(tNodo_c));

    if(nue == NULL || (nue->infoC = malloc(cantBytes))== NULL)
    {
        free(nue);
        return 0;
    }

    memcpy(nue->infoC,d, cantBytes);
    
    nue->tamInfoC = cantBytes;
    nue->sigC = NULL;
    if(c->ultC)
        c->ultC->sigC = nue;
    else
        c->priC = nue;
    c->ultC = nue;
    return 1;
}

void vaciar_cola(t_cola *c)
{
    tNodo_c *aux;
    while(c->priC)
    {
        aux = c->priC;
        c->priC = aux->sigC;
        free(aux->sigC);
        free(aux);
    }
    c->ultC = NULL;
}

int ver_primer_cola(const t_cola *c, void *d, unsigned cantBytes)
{
    if(c->priC == NULL)
        return 0;
    memcpy(d, c->priC->infoC,minimo(cantBytes, c->priC->tamInfoC));
    return 1;
}

int cola_vacia (const t_cola *c)
{
    return c->priC ==NULL;
}

int sacar_de_cola(t_cola *c, void *d, unsigned cantBytes)
{
    tNodo_c *elim = c->priC;
    if(elim == NULL)
        return 0;
    c->priC = elim->sigC;

    memcpy(d,elim->infoC,minimo( elim->tamInfoC, cantBytes));

    free(elim->infoC);
    free(elim);
    if(c->priC == NULL)
        c->ultC = NULL;
    return 1;
}
