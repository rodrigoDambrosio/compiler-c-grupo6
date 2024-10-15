#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pila.h"
#include "cola.h"

#define RUTA_ARCHIVO_INTERMEDIA "intermediate-code.txt"
#define LONG_ELEMENTOS_TERCETO 20

#define LONG_TERCETO 40 
#define LONG_ID 40

FILE * fpIntermedia;
t_cola  colaTercetos;

Pila* pilaNroTerceto;
int tercetosCreados=1;

typedef struct
{
    int numTerceto;
    char posUno[LONG_ELEMENTOS_TERCETO];
    char posDos[LONG_ELEMENTOS_TERCETO];
    char posTres[LONG_ELEMENTOS_TERCETO];
}t_Terceto;

// TODO: Separarlo con el .c

int abrir_archivo_intermedia();
void escribir_tercetos_intermedia();
int crear_terceto(char *c1, char*c2 ,char *c3,int nroT);
int apilar_nro_terceto(int  nroTerceto);
int desapilar_nro_terceto();
void escribir_terceto_actual_en_anterior(int tercetoAEscribir,int tercetoBuscado);

int abrir_archivo_intermedia(){
    fpIntermedia = fopen(RUTA_ARCHIVO_INTERMEDIA,"wt");
    if(!fpIntermedia)
    {
        printf("Error de apertura del archivo de intermedia");
        return 0;
    }
    return 1;
}

void escribir_tercetos_intermedia()
{
    while(!cola_vacia(&colaTercetos)){
      
        t_Terceto t;
        sacar_de_cola(&colaTercetos,&t,sizeof(t_Terceto));
        
        printf("Terceto nro : [%d] ( %s ; %s ; %s ) \n",t.numTerceto,t.posUno,t.posDos,t.posTres);
   
        fprintf(fpIntermedia,"[%d] ( %s ; %s ; %s ) \n",t.numTerceto,t.posUno,t.posDos,t.posTres);
    }
}


int crear_terceto(char *c1, char*c2 ,char *c3,int nroT) // Devuelve el nro del actual
{
    t_Terceto tercetos;
    tercetosCreados++;
    tercetos.numTerceto = nroT;
    strcpy(tercetos.posUno,c1);
    strcpy(tercetos.posDos,c2);
    strcpy(tercetos.posTres,c3);
  
    // printf("%d Se guarda en la cola %s,%s,%s \n",nroT,tercetos.posUno,tercetos.posDos,tercetos.posTres);
    poner_en_cola(&colaTercetos,&tercetos,sizeof(tercetos));
    return nroT;
}


int apilar_nro_terceto(int  nroTerceto)
{
    char nroTercetoString [50];
    sprintf(nroTercetoString,"[%d]",nroTerceto);
    // printf("Apile %d %s \n",nroTerceto,nroTercetoString);
    return apilar(pilaNroTerceto, nroTercetoString, sizeof(nroTercetoString));
}

int desapilar_nro_terceto()
{   
    char * nroTerceto = (char *) desapilar(pilaNroTerceto);
    char  subtext [strlen(nroTerceto-2)];
    strncpy(subtext,&nroTerceto[1],strlen(nroTerceto)-1);
    int nroDesapilado = atoi(subtext);
    // if(nroDesapilado < 0)
    // {
    //     return -1;
    // }
    return nroDesapilado;
}

void escribir_terceto_actual_en_anterior(int tercetoAEscribir,int tercetoBuscado)
{
    t_cola  aux;
    crear_cola(&aux);
    t_Terceto terceto;

    while(!cola_vacia(&colaTercetos))
    {
        sacar_de_cola(&colaTercetos,&terceto,sizeof(terceto));

        if(terceto.numTerceto == tercetoBuscado){
                char nueComponente [LONG_TERCETO];
                sprintf( nueComponente, "[%d]",tercetoAEscribir);
                strcpy(terceto.posTres, nueComponente);
        }
        poner_en_cola(&aux,&terceto,sizeof(terceto));
    }
     colaTercetos=aux;
}