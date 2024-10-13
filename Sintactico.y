%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <string.h>
#include <math.h>
#include "pila.c"
#include "pila.h"
#include "tercetos.h"

int yystopparser=0;
FILE  *yyin;

  int yyerror();
  int yylex();
  extern char* yytext;

tCola  colaTercetos;
/* --- Estructura de la tabla de simbolos --- */

typedef struct
{
        char *nombre;
        char *tipo;
        union Valor{
                int valor_var_int;
                float valor_var_float;
                char *valor_var_str;
        }valor;
        int longitud;
}t_data;

typedef struct s_simbolo
{
        t_data data;
        struct s_simbolo *next;
}t_simbolo;


typedef struct
{
        t_simbolo *primero;
}t_tabla;

typedef struct{
  char cadena[40];
}t_nombresId;


//Para la intermedia 
///indices
int     sentInd=0,
        prgInd=0,
        asignacionInd=0,
        expInd=0,
        termInd=0,
        bloqueInd = 0,
        comparacionInd = 0,
        condicionInd = 0,
        siInd=0,
        mientrasInd=0,
        factInd=0;
       
char comparador[4];

// SACAR O RENOMBRAR ESTO
int test_int=0;

// Declaracion funciones
void crear_tabla_simbolos();
int insertar_tabla_simbolos(const char*, const char*, const char*, int, float);
t_data* crearDatos(const char*, const char*, const char*, int, float);
void guardar_tabla_simbolos();
char* agregarCorchetes(const char* cadena);
t_tabla tabla_simbolos;

// Declaracion variables

Pila* pilaExpresion;
Pila* pilaTermino;
Pila* pilaFactor;
Pila * pilaVariables;
Pila * pilaComparacion;


int i=0;
int test_if_else=0;
int aux_comp=0;
char* dato_tope;
char tipo_dato[10];
int cant_id = 0;
char nombre_id[20];
int constante_aux_int;
float constante_aux_float;
char constante_aux_string[40];
char aux_string[40];
t_nombresId t_ids[10];
t_Terceto terceto_test;
%}

%union {
int tipo_int;
float tipo_float;
char *tipo_str;
}

%start programa
%token <tipo_str>ID
%token <tipo_int>CTE_INT
%token <tipo_float>CTE_FLOAT
%token <tipo_str>CTE_STRING
%token OP_AS
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
%token PA
%token PC
%token LA
%token LC
%token WHILE
%token IF
%token ELSE
%token OP_MAYOR
%token OP_MEN
%token TIPO_F
%token TIPO_I
%token TIPO_S
%token INIT
%token DP
%token LEER
%token ESCRIBIR
%token OP_AND
%token OP_OR
%token OP_NOT
%token OP_IGUAL
%token OP_NOT_IGUAL
%token CA
%token CC
%token SUM_ULT
%token TRIANG
%token OP_MAYORI
%token OP_MENI
%token COMA
%token PTO_COMA
%token IGUAL
%%

programa: 
 bloque_asig instrucciones{
                  guardar_tabla_simbolos();
                  printf("LAS INSTRUCCIONES SON UN PROGRAMA\n");
                }
 | instrucciones{
                  guardar_tabla_simbolos();
                  printf("LAS INSTRUCCIONES SON UN PROGRAMA\n");
                  sentInd=prgInd;
                }             
;

instrucciones: 
            sentencia {printf(" INSTRUCCIONES ES SENTENCIA\n");}
          | instrucciones sentencia {printf(" INSTRUCCIONES Y SENTENCIA ES PROGRAMA\n");}
;

sentencia:  	   
	asignacion    {printf("SENTENCIA ES ASIGNACION\n"); sentInd=asignacionInd;}
  | mientras    {printf("SENTENCIA ES MIENTRAS\n"); sentInd=mientrasInd;} 
  | si          {printf("SENTENCIA ES SI/SI SINO\n"); sentInd=siInd;} 
  | leer        {printf("SENTENCIA ES LEER\n");}
  | escribir    {printf("SENTENCIA ES ESCRIBIR\n");}
  | triangulos  {printf("SENTENCIA ES TRIANGULOS\n");}
  | ultimos     {printf("SENTENCIA ES SUMAR ULTIMOS\n");}
	;

bloque_asig:
INIT LA lista_asignacion LC {printf("BLOQUE ASIGNACION\n"); }
;

lista_asignacion : 
          lista_variables asig_tipo 
          {
                  for(i=0;i<cant_id;i++)
									{
									  insertar_tabla_simbolos(t_ids[i].cadena, tipo_dato, "", 0, 0);
									}
									cant_id=0;
          }
          | lista_asignacion lista_variables asig_tipo
            {
              for(i=0;i<cant_id;i++)
              {
                insertar_tabla_simbolos(t_ids[i].cadena, tipo_dato, "", 0, 0);
              }
              cant_id=0;
					  }
										
;

lista_variables: lista_variables COMA ID
                {
                    printf("ES UNA LISTA DE VARIABLES\n");
                    strcpy(t_ids[cant_id].cadena,$3);
                    cant_id++;

                    crearTerceto(yytext,"_","_",tercetosCreados);
                    apilar(pilaVariables, $3, sizeof($3));
                }
                | ID
                {
                    printf("ES UNA VARIABLE\n");
                    strcpy(t_ids[cant_id].cadena,$1);
                    cant_id++;

                    crearTerceto(yytext,"_","_",tercetosCreados);
                    apilar(pilaVariables, $1, sizeof($1));
                }

asig_tipo: 
    DP TIPO_S
    {
        strcpy(tipo_dato,"STRING");
    }
    | DP TIPO_F
    {
        strcpy(tipo_dato,"FLOAT");
    } 
    | DP TIPO_I
    {
        strcpy(tipo_dato,"INTEGER");
    }
;

si: 
  IF PA condicion PC LA instrucciones LC 
  {
    printf("ES CONDICION SI\n");
    while(!es_pila_vacia(pilaComparacion))
    {
        char* t = (char *) desapilar(pilaComparacion);
        escribirTercetoActualEnAnterior(tercetosCreados,atoi(t));
    }
  }
  | IF PA condicion PC LA instrucciones LC 
  {
    // Apilo la posicion actual porque cuando reconozco todo, es cuando voy a saber a donde saltar
    printf("************************************* \n \n \n ACA RECONOCI QUE TENGO UNA INSTRUCCION DENTRO DE LA PARTE IF");
    // TODO: Poner un nombre descriptivo
    test_if_else = tercetosCreados;
    printf("\n \n \n ACA SETEO EL NRO EN EL IF %d \n \n \n",test_if_else);

  }
  ELSE LA instrucciones LC 
  {
    printf("ES CONDICION SINO \n");
     while(!es_pila_vacia(pilaComparacion))
     {
        dato_tope = (char *) desapilar(pilaComparacion);
        printf("--------- que hay en tope pila %s\n", dato_tope);
        escribirTercetoActualEnAnterior(test_if_else,atoi(dato_tope));
        test_int =atoi(dato_tope);
     }
          printf("************************************* \n \n \n ACA RECONOCI TODO EL IF ELSE \n \n \n");
          printf("\n \n \n ESTO ES EL NRO DEL TERCETO DEL IF - %d - AHORA LO VOY A LLENAR con el salto al else - %d - \n \n \n",test_int, tercetosCreados);
          printf("\n \n \n ESTO ES EL TERCETO ACTUAL? %d \n \n \n",tercetosCreados);
  }
;

mientras:
  WHILE PA 
  {
    // Creo este terceto que va a ser el inicial al que va a retornar si la condicion se sigue cumpliendo
    mientrasInd = crearTerceto("InicioMientras","_","_",tercetosCreados); 
    apilarNroTerceto(mientrasInd); // Lo apilo para despues tenerlo para el branch incondicional
  } condicion PC 
  {
      // Aca cuando es un OR o AND me esta faltando escribir el nro de terceto del salto de la primera condicion?
  }
  LA instrucciones LC 
  {
    // Aca ya se cuantos tercetos tengo que dejar
    int t = desapilarNroTerceto(); // Aca debería tener el nro del terceto inicial del while
    char auxT [LONG_TERCETO]; 
    escribirTercetoActualEnAnterior(tercetosCreados+1,t);
    t = desapilarNroTerceto(); 
    sprintf(auxT,"[%d]",mientrasInd);
    crearTerceto("BI","_",auxT,tercetosCreados); // Este es el salto incondicional para ir al principio y checkear la condicion de nuevo
    printf("\n\n\n ---------- Voy a escribir en --> %d el valor ---> %d" , aux_comp, tercetosCreados);
    escribirTercetoActualEnAnterior(tercetosCreados,aux_comp);
    printf("ES UN MIENTRAS\n");
  }
;

condicion:
  
  comparacion 
  {
    condicionInd = comparacionInd;
  }
  | 
  OP_NOT comparacion
  {
    char comparacionAux [LONG_TERCETO];
    sprintf(comparacionAux, "[%d]", comparacionInd);
    condicionInd = crearTerceto("OP_NOT", comparacionAux,"_",tercetosCreados );
  }
  | 
  condicion OP_OR comparacion 
  {
    char condicionAux [LONG_TERCETO];
    char comparacionAux [LONG_TERCETO];
    sprintf(condicionAux,"[%d]",condicionInd);
    sprintf(comparacionAux, "[%d]", comparacionInd);
    condicionInd = crearTerceto("OP_OR", condicionAux , comparacionAux,tercetosCreados );
  }
  | 
  condicion OP_AND comparacion 
  {
    char condicionAux [LONG_TERCETO];
    char comparacionAux [LONG_TERCETO];
    sprintf(condicionAux,"[%d]",condicionInd );
    sprintf(comparacionAux, "[%d]", comparacionInd);
    condicionInd = crearTerceto("OP_AND", condicionAux , comparacionAux,tercetosCreados );
  }
;

comparacion: 
    expresion operador_comparacion expresion 
      {
                char* exp1 = (char*) desapilar(pilaExpresion);
                char* exp2 = (char*) desapilar(pilaExpresion);
                // printf ("A ver la comparacion %s %s \n",exp1, exp2);
                comparacionInd=crearTerceto("CMP",agregarCorchetes(exp1),agregarCorchetes(exp2),tercetosCreados);
                printf("\n \n \n ACA RECONOZCO UNA PARTE DE LA COMPARACION nro ind de donde hay que guardar la celda del salto %d \n \n \n",condicionInd+1);
                aux_comp = condicionInd+1;
                // Guardo este nro de terceto para despues actualizarlo mas adelante con el nro del salto al final de toda la condicion
                int t = crearTerceto(comparador,"_","_" ,tercetosCreados);
                printf("\n \n \n ACA RECONOZCO UNA PARTE DE LA COMPARACION nro ind de donde hay que guardar la celda del salto %d \n \n \n",t);
                apilarNroTerceto(t);
                char tString [10];
                itoa(t,tString,10);
                apilar(pilaComparacion,tString,sizeof(tString));
    }
    // | PA condicion PC
;

operador_comparacion:
  OP_MAYOR {strcpy(comparador, "BLE");}
  | OP_MAYORI {strcpy(comparador, "BLT");};
  | OP_MEN {strcpy(comparador, "BGE");}
  | OP_MENI {strcpy(comparador,"BGT");}
  | OP_IGUAL {strcpy(comparador, "BNE");}
  // | OP_NOT_IGUAL {strcpy(comparador, "BNE");}

;

asignacion: 
    id OP_AS expresion 
    {
        printf("    ID = Expresion es ASIGNACION\n");
          char auxAsig[LONG_TERCETO];
          char auxInd[LONG_TERCETO];
          sprintf(auxInd,"[%d]",expInd );
          sprintf(auxAsig,"[%d]",asignacionInd);
          asignacionInd = crearTerceto("OP_ASIG",auxAsig,auxInd,tercetosCreados);
    }
	  ;

// TO-DO REVISAR

id:
  ID
  {
    strcpy(nombre_id,$1);
    asignacionInd = crearTerceto(nombre_id,"_","_",tercetosCreados);
  }
;


expresion:
   termino 
   {
            printf("Termino es Expresion\n");
            expInd = termInd;
            char expIndString [10];
            itoa(expInd,expIndString,10);
            apilar(pilaExpresion,expIndString,sizeof(expIndString)); 
    }
	 | expresion OP_SUM termino {
        printf("    Expresion+Termino es Expresion\n");
        char auxTer[LONG_TERCETO];
        char auxExp[LONG_TERCETO];
        sprintf(auxTer,"[%d]",termInd);
        sprintf(auxExp,"[%d]",expInd);
        expInd = crearTerceto("OP_SUM",auxExp,auxTer,tercetosCreados);
        char expIndString [10];
        itoa(expInd,expIndString,10);
        apilar(pilaExpresion,expIndString,sizeof(expIndString)); 
    }

	 | expresion OP_RES termino {
        printf("    Expresion-Termino es Expresion\n");
        char auxTer[LONG_TERCETO];
        char auxExp[LONG_TERCETO];
        sprintf(auxTer,"[%d]",termInd);
        sprintf(auxExp,"[%d]",expInd);
        expInd = crearTerceto("OP_RES",auxExp,auxTer,tercetosCreados);
        char expIndString [10];
        itoa(expInd,expIndString,10);
        apilar(pilaExpresion,expIndString,sizeof(expIndString)); 
    }
	 ;
   
termino: 
       factor 
       {
        printf("Factor es Termino\n");
        termInd = factInd;
        char termIndString [10];
        itoa(expInd,termIndString,10);
        apilar(pilaTermino,termIndString, sizeof(termIndString));
       }
       |termino OP_MUL factor 
       {
        printf("Termino*Factor es Termino\n");
        char auxTer[LONG_TERCETO];
        char auxFac[LONG_TERCETO];
        sprintf(auxTer,"[%d]",termInd);
        sprintf(auxFac,"[%d]",factInd);
        termInd = crearTerceto("OP_MUL",auxTer,auxFac,tercetosCreados);
        char termIndString [10];
        itoa(termInd,termIndString,10);
        apilar(pilaTermino,termIndString, sizeof(termIndString));
       }
       |termino OP_DIV factor 
       {
        printf("Termino/Factor es Termino\n");
        char auxTer[LONG_TERCETO];
        char auxFac[LONG_TERCETO];
        sprintf(auxTer,"[%d]",termInd);
        sprintf(auxFac,"[%d]",factInd);
        termInd = crearTerceto("OP_DIV",auxTer,auxFac,tercetosCreados);
        char termIndString [10];
        itoa(termInd,termIndString,10);
        apilar(pilaTermino,termIndString, sizeof(termIndString));
       }
       ;

factor: 
      ID 
      {
        printf("ID es Factor \n");
        factInd = crearTerceto(yytext,"_","_",tercetosCreados);
        char factIndString [10];
        itoa(termInd,factIndString,10);
        apilar(pilaFactor,factIndString,sizeof(factIndString));
      }
      | CTE_STRING 
      {
        printf("ES CONSTANTE STRING\n");
        strcpy(constante_aux_string,$1);
        
        factInd = crearTerceto(yytext,"_","_",tercetosCreados);
        char factIndString [10];
        itoa(termInd,factIndString,10);
        apilar(pilaFactor,factIndString,sizeof(factIndString));

        insertar_tabla_simbolos(nombre_id, "CTE_STR", $1, 0, 0.0);
      }
      | CTE_INT 
      {
        printf("ES CONSTANTE INT\n");
        constante_aux_int=$1;

        factInd = crearTerceto(yytext,"_","_",tercetosCreados);
        char factIndString [10];
        itoa(termInd,factIndString,10);
        apilar(pilaFactor,factIndString,sizeof(factIndString));
       
        insertar_tabla_simbolos(nombre_id, "CTE_INT", "", $1, 0.0);
      }
      | CTE_FLOAT 
      {
        printf("ES CONSTANTE FLOAT\n");
        constante_aux_float=$1;
        
        factInd = crearTerceto(yytext,"_","_",tercetosCreados);
        char factIndString [10];
        itoa(termInd,factIndString,10);
        apilar(pilaFactor,factIndString,sizeof(factIndString));

        insertar_tabla_simbolos(nombre_id, "CTE_FLOAT", "", 0, $1);
      }
	    | PA expresion PC 
      {
        printf("Expresion entre parentesis es Factor\n");
        factInd = expInd;
        char factIndString [10];
        itoa(termInd,factIndString,10);
        apilar(pilaFactor,factIndString,sizeof(factIndString));
      }
     	;

leer : 
     LEER PA ID PC {printf("ES LEER\n");}
;

escribir:
    ESCRIBIR PA CTE_STRING PC   {printf("ES ESCRIBIR CONSTANTE\n");}
    | ESCRIBIR PA ID PC         {printf("ES ESCRIBIR ID\n");}

ultimos: 
    ID IGUAL SUM_ULT PA CTE_INT PTO_COMA CA lista_num CC PC  {printf("ES SUMAR ULTIMOS\n");}
;

lista_num: lista_num COMA num 
           | num
;

num: CTE_INT | CTE_FLOAT 
;

triangulos:
           ID IGUAL TRIANG PA expresion COMA expresion COMA expresion PC  {printf("ES TRIANGULOS\n");}
;

%%

int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
       
    }
    else
    { 
        crear_tabla_simbolos();
        pilaExpresion = crear_pila();
        pilaTermino = crear_pila();
        pilaFactor = crear_pila();
        pilaVariables = crear_pila();
        pilaComparacion = crear_pila();
        pilaNroTerceto = crear_pila();

        crearCola(&colaTercetos);

        abrirArchivoIntermedia();
        yyparse();
      
        //Generacion de intermedia
        escribirTercetosEnIntermedia();

        fclose(fpIntermedia);

        
    }
  fclose(yyin);
  return 0;
}

int yyerror(void)
{
  printf("\n ********* Error Sintáctico ********* \n");
  exit (1);
}

int insertar_tabla_simbolos(const char *nombre,const char *tipo, 
                            const char* valor_string, int valor_var_int, 
                            float valor_var_float)
{
    t_simbolo *tabla = tabla_simbolos.primero;
    char nombreCTE[32] = "_";
    strcat(nombreCTE, nombre);
    while(tabla)
    { 
      // Para evitar repetidos / actualizar asignaciones
      if(strcmp(tabla->data.nombre, nombre) == 0 || strcmp(tabla->data.nombre, nombreCTE) == 0)
      {
          if (strcmp(tipo, "CTE_STR") == 0)
            {
                strcpy(tabla->data.valor.valor_var_str, valor_string);
            }
            else if (strcmp(tipo, "CTE_INT") == 0)
            {
                tabla->data.valor.valor_var_int = valor_var_int;
            }
            else if (strcmp(tipo, "CTE_FLOAT") == 0)
            {
                tabla->data.valor.valor_var_float = valor_var_float;
            }
            return 1;
      }    
      if(strcmp(tabla->data.tipo, "CTE_STR") == 0)
      {
            if(strcmp(tabla->data.valor.valor_var_str, valor_string) == 0)
            {
                return 1;
            }
      }
      if(tabla->next == NULL)
        {
            break;
        }
        tabla = tabla->next;
    }

    t_data *data = (t_data*)malloc(sizeof(t_data));
    data = crearDatos(nombre, tipo, valor_string, valor_var_int, valor_var_float);

    if(data == NULL)
    {
        return 1;
    }
   
    t_simbolo* nuevo = (t_simbolo*)malloc(sizeof(t_simbolo));

    if(nuevo == NULL)
    {   
        return 2;
    }

    nuevo->data = *data;
    nuevo->next = NULL;

    if(tabla_simbolos.primero == NULL)
    {
        tabla_simbolos.primero = nuevo;
    }
    else
    {
        tabla->next = nuevo;
    }

    return 0;
}


t_data* crearDatos(const char *nombre, const char *tipo, 
                  const char* valString, int valor_var_int, 
                  float valor_var_float)
{
    char full[50] = "_";
    char aux[20];
    char nombre_str[50];

    t_data *data = (t_data*)calloc(1, sizeof(t_data));
    if(data == NULL)
    {
        return NULL;
    }

    data->tipo = (char*)malloc(sizeof(char) * (strlen(tipo) + 1));
    strcpy(data->tipo, tipo);

    if(strcmp(tipo, "STRING")==0 || strcmp(tipo, "INTEGER")==0 || strcmp(tipo, "FLOAT")==0)
    {
        data->nombre = (char*)malloc(sizeof(char) * (strlen(nombre) + 1));
        strcpy(data->nombre, nombre);
        return data;
    }
    else
    {      
        if(strcmp(tipo, "CTE_STR") == 0)
        {
            data->valor.valor_var_str = (char*)malloc(sizeof(char) * strlen(valString) + 1);
            data->nombre = (char*)malloc(sizeof(char) * (strlen(valString) + 1));
            strcat(full, valString);
            strcpy(data->nombre, full);    
            strcpy(data->valor.valor_var_str, valString);
        }
        if(strcmp(tipo, "CTE_FLOAT") == 0)
        {
            sprintf(aux, "%.2f", valor_var_float);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));
            strcpy(data->nombre, full);
            data->valor.valor_var_float = valor_var_float;
        }
        if(strcmp(tipo, "CTE_INT") == 0)
        {
            sprintf(aux, "%d", valor_var_int);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));
            strcpy(data->nombre, full);
            data->valor.valor_var_int = valor_var_int;
        }
        return data;
    }
    return NULL;
}

void guardar_tabla_simbolos()
{
    FILE* arch;
    if((arch = fopen("symbol-table.txt", "wt")) == NULL)
    {
            printf("\nNo se pudo crear la tabla de simbolos.\n\n");
            return;
    }
    else if(tabla_simbolos.primero == NULL)
            return;
    
    fprintf(arch, "%-30s%-30s%-40s%-30s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");

    t_simbolo *aux;
    t_simbolo *tabla = tabla_simbolos.primero;
    char linea[100];
    char full[30] = "_";

    while(tabla)
    {
        aux = tabla;
        tabla = tabla->next;

        if(strcmp(aux->data.tipo, "INTEGER") == 0) 
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_INT") == 0)
        {
            // sprintf(linea, "%-30s%-30s%-40d%s\n", aux->data.nombre, "", aux->data.valor.valor_var_int, "");
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, "", "", "");
        }
        else if(strcmp(aux->data.tipo, "FLOAT") ==0)
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_FLOAT") == 0)
        {
            // sprintf(linea, "%-30s%-30s%-40f%s\n", aux->data.nombre, "", aux->data.valor.valor_var_float, "");
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, "", "", "");
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0)
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_STR") == 0)
        {
            strncpy(aux_string, aux->data.valor.valor_var_str +1, strlen(aux->data.valor.valor_var_str)-2);
            strcat(full,aux_string);
            // sprintf(linea, "%-30s%-30s%-40s%-d\n", aux->data.nombre, "", aux_string, strlen(aux->data.valor.valor_var_str) -2);
            sprintf(linea, "%-30s%-30s%-40s%-s\n", full, "", "", "");
        }
        fprintf(arch, "%s", linea);
        free(aux);
    }
    fclose(arch); 
}

void crear_tabla_simbolos()
{
    tabla_simbolos.primero = NULL;
}

char* agregarCorchetes(const char* cadena) 
{
    int longitud = strlen(cadena);
    char* resultado = (char*)malloc(longitud + 3);
    
    if (resultado == NULL) 
    {
        printf("Error al asignar memoria\n");
        exit(1);
    }

    resultado[0] = '[';                   
    strcpy(resultado + 1, cadena);         
    resultado[longitud + 1] = ']';         
    resultado[longitud + 2] = '\0'; 
    
    return resultado;
}