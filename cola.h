#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define minimo(X,Y) ((X) <= (Y) ? (X) : (Y))

/////////ESTRUCTURA COLA ////////////
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
} tCola;


void crearCola(tCola *c);
int colaLlena(const tCola *c,unsigned cantBytes);
int ponerEnCola(tCola *c, const void *d, unsigned cantBytes);
void vaciaCola(tCola *c);
int verPrimeroCola(const tCola *c, void *d, unsigned cantBytes);
int colaVacia (const tCola *c);
int sacarDeCola(tCola *c, void *d, unsigned cantBytes);

///////////COLA/////////////

void crearCola(tCola *c)
{
    c->priC = NULL;
    c->ultC = NULL;

}

int colaLlena(const tCola *c,unsigned cantBytes)
{
    tNodo_c *aux = (tNodo_c *)malloc(sizeof(tNodo_c));
    void *infoC = malloc(cantBytes);
    free(aux);
    free(infoC);
    return aux == NULL|| infoC == NULL;
}

int ponerEnCola(tCola *c, const void *d, unsigned cantBytes)
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

void vaciaCola(tCola *c)
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

int verPrimeroCola(const tCola *c, void *d, unsigned cantBytes)
{
    if(c->priC == NULL)
        return 0;
    memcpy(d, c->priC->infoC,minimo(cantBytes, c->priC->tamInfoC));
    return 1;

}

int colaVacia (const tCola *c)
{
    return c->priC ==NULL;
}

int sacarDeCola(tCola *c, void *d, unsigned cantBytes)
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
