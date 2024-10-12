#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pila.h"
#include "cola.h"

#define INTERMEDIA_TXT "intermedia.txt"
#define ELEMENTOS_TERCETO 20

#define LONG_TERCETO 30 
#define LONG_ID 30

FILE * fpIntermedia;
tCola  colaTercetos;

Pila* pilaNroTerceto;
int tercetosCreados=1;

typedef struct
{
    int numTerceto;
    char posUno[ELEMENTOS_TERCETO];
    char posDos[ELEMENTOS_TERCETO];
    char posTres[ELEMENTOS_TERCETO];
}t_Terceto;


int abrirIntermedia();
void escribirTercetosEnIntermedia();
int crearTerceto(char *c1, char*c2 ,char *c3,int nroT);
int apilarNroTerceto(int  nroTerceto);
int desapilarNroTerceto();
void escribirTercetoActualEnAnterior(int tercetoAEscribir,int tercetoBuscado);



int abrirIntermedia(){
    fpIntermedia = fopen(INTERMEDIA_TXT,"wt");
    if(!fpIntermedia)
    {
        printf("Error de apertura del archivo de la tabla de simbolos");
        return 0;
    }
    return 1;
}

void escribirTercetosEnIntermedia()
{
    while(!colaVacia(&colaTercetos)){
      
        t_Terceto t;
        sacarDeCola(&colaTercetos,&t,sizeof(t_Terceto));
        printf("Valores de la intermedia[%d] ( %s ; %s ; %s ) \n",t.numTerceto,t.posUno,t.posDos,t.posTres);
   
        fprintf(fpIntermedia,"[%d] ( %s ; %s ; %s ) \n",t.numTerceto,t.posUno,t.posDos,t.posTres);
    }
}


int crearTerceto(char *c1, char*c2 ,char *c3,int nroT){
    
    t_Terceto tercetos;
    tercetosCreados++;
    tercetos.numTerceto = nroT;
    strcpy(tercetos.posUno,c1);
    strcpy(tercetos.posDos,c2);
    strcpy(tercetos.posTres,c3);
  
    printf("%d Se pone en cola %s,%s,%s \n",nroT,tercetos.posUno,tercetos.posDos,tercetos.posTres);
    ponerEnCola(&colaTercetos,&tercetos,sizeof(tercetos));
    return nroT;
}


int apilarNroTerceto(int  nroTerceto)
{
    char nroTercetoString [50];
    sprintf(nroTercetoString,"[%d]",nroTerceto);
    printf("A ver que apila %d %s \n",nroTerceto,nroTercetoString);
    return apilar(pilaNroTerceto, nroTercetoString, sizeof(nroTercetoString));
    //return pushStack(&pilaNroTerceto,nroTercetoString);

}

int desapilarNroTerceto()
{   
    char * nroTerceto = (char *) desapilar(pilaNroTerceto);
    char  subtext [strlen(nroTerceto-2)];
    strncpy(subtext,&nroTerceto[1],strlen(nroTerceto)-1);
    printf("A ver que tiene subtext %s\n",subtext);
    return atoi(subtext);
}


void escribirTercetoActualEnAnterior(int tercetoAEscribir,int tercetoBuscado) // 42 26 -- 22
{
    tCola  aux;
    crearCola(&aux);
    t_Terceto terceto;

    while(!colaVacia(&colaTercetos))
    {
        sacarDeCola(&colaTercetos,&terceto,sizeof(terceto));
       

        if(terceto.numTerceto == tercetoBuscado){
                char nueComponente [LONG_TERCETO];
                sprintf( nueComponente, "[%d]",tercetoAEscribir);
                strcpy(terceto.posTres, nueComponente);
        }
        ponerEnCola(&aux,&terceto,sizeof(terceto));
    }
    
     colaTercetos=aux;

}