%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <string.h>
#include <math.h>
#include "pila.c"
#include "pila.h"
#include "tercetos.h"

#define T_ENTERO 10
#define T_FLOAT 20
#define T_STRING 30

int yystopparser=0;
FILE  *yyin;

  int yyerror();
  int yylex();
  int yyerror_message(char* mensaje_error);
  extern char* yytext;

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

int tipo_factor = -1;
int tipo_expresion = -1;
int tipo_termino = -1;
int tipo_expresion_izq =-1;
int tipo_asig_u =-1;
// Declaracion funciones
void crear_tabla_simbolos();
int insertar_tabla_simbolos(const char*, const char*, const char*, int, float);
t_data* crearDatos(const char*, const char*, const char*, int, float);
void guardar_tabla_simbolos();
char* agregarCorchetes(const char* cadena);
t_tabla tabla_simbolos;
char* validar_ts(const char *nombre,const char *tipo, 
                            const char* valor_string, int valor_var_int, 
                            float valor_var_float);
int verificar_si_ya_existe_en_ts(const char *nombre);
const char * check_tipo_variable_ts(const char *nombre,const char *tipo, 
const char* valor_string, int valor_var_int, 
float valor_var_float);
int verificar_si_falta_en_ts(const char *nombre);
const char * check_tipo_define(int tipo_int);

// Declaracion variables

Pila* pilaExpresion;
Pila* pilaTermino;
Pila* pilaFactor;
// Pila * pilaVariables;
Pila * pilaComparacion;
Pila* pilaSumarUltimos;

int i=0;
int aux_terceto_if_else=0;
int aux_comp=0;
char* dato_tope;
char tipo_dato[10];
int cant_id = 0;
char nombre_id[20];
int constante_aux_int=0;
float constante_aux_float;
char constante_aux_string[40];
char aux_string[40];
char aux_tipo_validacion_ts[15];
char aux_tipo_validacion_termino_ts[15];
char aux_tipo_validacion_expresion_ts[15];
int aux_id_ultimos=0;
int nro_terceto_aux_ultimos=0;
int aux_exp1=0,
 aux_exp2=0,
 aux_exp3=0;
// Indices usados para los tercetos
int     sentenciaIndice=0,
        programaIndice=0,
        asignacionInd=0,
        expresionInd=0,
        terminoInd=0,
        bloqueInd = 0,
        comparacionInd = 0,
        condicionInd = 0,
        siInd = 0,
        mientrasInd = 0,
        ultInd = 0,
        instruccionInd= 0,
        leerIndice = 0,
        escribirIndice = 0,
        factorIndice = 0;

int flag_tipos = 0;
int triangulos_id_aux =0;
int indTriangExp1=0;
int indTriangExp2=0;
int indTriangExp3=0;
int indTriang=0;
int saltoFinElse = 0;
int auxPrimerLado = 0, 
auxSegundoLado = 0, 
auxTercerLado = 0;
char comparador[4];
char ultimoTipo[15]="PRI";

// int test_int=0;
int ultimos_pivote_aux=0;
int contador_elementos_sumar_ult = 0;
t_nombresId t_ids[10];
t_Terceto terceto_test;
t_cola  colaTercetos;

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
                  programaIndice=sentenciaIndice;
                  printf("LAS INSTRUCCIONES SON UN PROGRAMA\n");
                }
 | instrucciones{
                  guardar_tabla_simbolos();
                  printf("LAS INSTRUCCIONES SON UN PROGRAMA\n");
                  programaIndice=sentenciaIndice;
                }             
;

instrucciones: 
            sentencia {printf(" INSTRUCCIONES ES SENTENCIA\n"); instruccionInd = sentenciaIndice;}
          | instrucciones sentencia {printf(" INSTRUCCIONES Y SENTENCIA ES PROGRAMA\n"); instruccionInd = sentenciaIndice;}
;

sentencia:  	   
	asignacion    {printf("SENTENCIA ES ASIGNACION\n"); sentenciaIndice=asignacionInd;}
  | mientras    {printf("SENTENCIA ES MIENTRAS\n"); sentenciaIndice=mientrasInd;} 
  | si          {printf("SENTENCIA ES SI/SI SINO\n"); sentenciaIndice=siInd;} 
  | leer        {printf("SENTENCIA ES LEER\n"); sentenciaIndice = leerIndice;}
  | escribir    {printf("SENTENCIA ES ESCRIBIR\n"); sentenciaIndice = escribirIndice;}
  | triangulos  {printf("SENTENCIA ES TRIANGULOS\n"); sentenciaIndice = indTriang;}
  | ultimos     {printf("SENTENCIA ES SUMAR ULTIMOS\n"); sentenciaIndice = ultInd;}
	;

bloque_asig:
INIT LA lista_asignacion LC {printf("BLOQUE ASIGNACION\n"); }
;

lista_asignacion : 
          lista_variables asig_tipo 
          {
                  for(i=0;i<cant_id;i++)
									{
                    printf("VARIABLE :::::: %s \n\n\n\n",t_ids[i].cadena);
                    verificar_si_ya_existe_en_ts(t_ids[i].cadena);    
									  insertar_tabla_simbolos(t_ids[i].cadena, tipo_dato, "", 0, 0);
									}
									cant_id=0;
          }
          | lista_asignacion lista_variables asig_tipo
            {
              for(i=0;i<cant_id;i++)
              {
                verificar_si_ya_existe_en_ts(t_ids[i].cadena);    
                insertar_tabla_simbolos(t_ids[i].cadena, tipo_dato, "", 0, 0);
              }
              cant_id=0;
					  }
										
;

lista_variables: lista_variables COMA ID
                {
                    strcpy(t_ids[cant_id].cadena,$3);
                    cant_id++;
                    // crear_terceto(yytext,"_","_",tercetosCreados);
                    // apilar(pilaVariables, $3, sizeof($3));
                    printf("ES UNA LISTA DE VARIABLES\n");
                }
                | ID
                {
                    printf("ES UNA VARIABLE\n");
                    strcpy(t_ids[cant_id].cadena,$1);
                    cant_id++;
                    // crear_terceto(yytext,"_","_",tercetosCreados);
                    // apilar(pilaVariables, $1, sizeof($1));
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
        escribir_terceto_actual_en_anterior(tercetosCreados,atoi(t));
    }
  }
  | IF PA condicion PC LA instrucciones LC 
  {
    // Apilo la posicion actual porque cuando reconozco todo, es cuando voy a saber a donde saltar
    // printf("************************************* \n \n \n ACA RECONOCI QUE TENGO UNA INSTRUCCION DENTRO DE LA PARTE IF");
    // printf("\n \n \n ACA SETEO EL NRO EN EL IF %d \n \n \n",aux_terceto_if_else);
    saltoFinElse = crear_terceto("BI","_","_",tercetosCreados);
    aux_terceto_if_else = tercetosCreados;
  }
  ELSE LA instrucciones LC 
  {
    printf("ES CONDICION SINO \n");
     while(!es_pila_vacia(pilaComparacion))
     {
        dato_tope = (char *) desapilar(pilaComparacion);
        // printf("tope pila ------> %s\n", dato_tope);
        escribir_terceto_actual_en_anterior(aux_terceto_if_else,atoi(dato_tope));
        // test_int =atoi(dato_tope);
     }
          // printf("************************************* \n \n \n ACA RECONOCI TODO EL IF ELSE \n \n \n");
          // printf("\n \n \n ESTO ES EL NRO DEL TERCETO DEL IF - %d - AHORA LO VOY A LLENAR con el salto al else - %d - \n \n \n",test_int, tercetosCreados);
          // printf("\n \n \n ESTO ES EL TERCETO ACTUAL %d \n \n \n",tercetosCreados);

      escribir_terceto_actual_en_anterior(tercetosCreados,saltoFinElse);
  }
;

mientras:
  WHILE PA 
  {
    // Creo este terceto que va a ser el inicial al que va a retornar si la condicion se sigue cumpliendo
    mientrasInd = crear_terceto("InicioMientras","_","_",tercetosCreados); 
    apilar_nro_terceto(mientrasInd); // Lo apilo para despues tenerlo para el branch incondicional
  } condicion PC 
  {
      // Aca cuando es un OR o AND me esta faltando escribir el nro de terceto del salto de la primera condicion?
  }
  LA instrucciones LC 
  {
    // Aca ya se cuantos tercetos tengo que dejar
    int t = desapilar_nro_terceto(); // Aca debería tener el nro del terceto inicial del while
    char auxT [LONG_TERCETO]; 
    escribir_terceto_actual_en_anterior(tercetosCreados+1,t);
    t = desapilar_nro_terceto(); 
    sprintf(auxT,"[%d]",mientrasInd);
    crear_terceto("BI","_",auxT,tercetosCreados); // Este es el salto incondicional para ir al principio y checkear la condicion de nuevo
    // printf("\n\n\n ---------- Voy a escribir en --> %d el valor ---> %d" , aux_comp, tercetosCreados);
    escribir_terceto_actual_en_anterior(tercetosCreados,aux_comp);
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
    condicionInd = crear_terceto("NOT", comparacionAux,"_",tercetosCreados );
  }
  | 
  condicion OP_OR comparacion 
  {
    char condicionAux [LONG_TERCETO];
    char comparacionAux [LONG_TERCETO];
    sprintf(condicionAux,"[%d]",condicionInd);
    sprintf(comparacionAux, "[%d]", comparacionInd);
    condicionInd = crear_terceto("OR", condicionAux , comparacionAux,tercetosCreados );
  }
  | 
  condicion OP_AND comparacion 
  {
    char condicionAux [LONG_TERCETO];
    char comparacionAux [LONG_TERCETO];
    sprintf(condicionAux,"[%d]",condicionInd );
    sprintf(comparacionAux, "[%d]", comparacionInd);
    condicionInd = crear_terceto("AND", condicionAux , comparacionAux,tercetosCreados );
  }
;

comparacion: 
    expresion operador_comparacion {tipo_expresion_izq = tipo_expresion; } expresion 
      {
                int tipo_expresion_derecha = tipo_expresion;
                if(tipo_expresion_izq != tipo_expresion_derecha)
                {
                  printf("\nSe esta queriendo comparar un %s a la izquierda con un %s a la derecha\n", check_tipo_define(tipo_expresion_izq),check_tipo_define(tipo_expresion_derecha));
                  yyerror_message("Error de tipos");
                }
                char* exp1 = (char*) desapilar(pilaExpresion);
                char* exp2 = (char*) desapilar(pilaExpresion);
                // printf ("A ver la comparacion %s %s \n",exp1, exp2);
                comparacionInd=crear_terceto("CMP",agregarCorchetes(exp1),agregarCorchetes(exp2),tercetosCreados);
                // printf("\n \n \n ACA RECONOZCO UNA PARTE DE LA COMPARACION nro ind de donde hay que guardar la celda del salto %d \n \n \n",condicionInd+1);
                aux_comp = condicionInd+1;
                // Guardo este nro de terceto para despues actualizarlo mas adelante con el nro del salto al final de toda la condicion
                int t = crear_terceto(comparador,"_","_" ,tercetosCreados);
                // printf("\n \n \n ACA RECONOZCO UNA PARTE DE LA COMPARACION nro ind de donde hay que guardar la celda del salto %d \n \n \n",t);
                apilar_nro_terceto(t);
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
          sprintf(auxInd,"[%d]",expresionInd );
          sprintf(auxAsig,"[%d]",asignacionInd);
          asignacionInd = crear_terceto(":=",auxAsig,auxInd,tercetosCreados);
          // TODO tengo que averiguar de que tipo es la expresion esta, por ahora lo voy a usar para ver si la variable existe
          
          if(strcmp("INTEGER",aux_tipo_validacion_ts)==0){
                tipo_asig_u = T_ENTERO;
          }
          else if(strcmp("FLOAT",aux_tipo_validacion_ts)==0){
                tipo_asig_u = T_FLOAT;
          }
          else if(strcmp("STRING",aux_tipo_validacion_ts)==0){
                tipo_asig_u = T_STRING;
          }
          // printf("\n\n El tipo de la asig es %d el otro de EXP %d el tip ode TS es %s \n",tipo_asig_u,tipo_expresion,aux_tipo_validacion_ts);
          if(tipo_expresion != tipo_asig_u ){
            printf("\n\nEl ID %s tiene un tipo %s que no es compatible en la asignacion\n\n",nombre_id,aux_tipo_validacion_ts);
            yyerror_message("Error de tipos en la asignacion");
          }
          // else{
          //               printf("OK \n\n\n");

          // }
    }
	  ;

// TO-DO REVISAR

id:
  ID
  {
    strcpy(nombre_id,$1);
    strcpy(aux_tipo_validacion_ts, check_tipo_variable_ts($1, "_", "", 0, 0)); // Se verifica si el id que se quiere asignar esta en tabla de simbolos
    asignacionInd = crear_terceto(nombre_id,"_","_",tercetosCreados);
  }
;


expresion:
   termino 
   {
      printf("Termino es Expresion\n");
      expresionInd = terminoInd;
      char expresionIndString [10];
      itoa(expresionInd,expresionIndString,10);
      apilar(pilaExpresion,expresionIndString,sizeof(expresionIndString));
      tipo_expresion = tipo_termino; 
    }
	 | expresion OP_SUM termino 
   {
        if(tipo_expresion != tipo_termino)
        {
           printf("\nSe esta queriendo sumar un %s con un %s\n", check_tipo_define(tipo_expresion),check_tipo_define(tipo_termino));
           yyerror_message("Error de tipos");
        }
        printf("    Expresion+Termino es Expresion\n");
        char auxTer[LONG_TERCETO];
        char auxExp[LONG_TERCETO];
        sprintf(auxTer,"[%d]",terminoInd);
        sprintf(auxExp,"[%d]",expresionInd);
        expresionInd = crear_terceto("+",auxExp,auxTer,tercetosCreados);
        char expresionIndString [10];
        itoa(expresionInd,expresionIndString,10);
        apilar(pilaExpresion,expresionIndString,sizeof(expresionIndString)); 
    }

	 | expresion OP_RES termino 
   {
        if(tipo_expresion != tipo_termino)
        {
          printf("\nSe esta queriendo restar un %s con un %s\n", check_tipo_define(tipo_expresion),check_tipo_define(tipo_termino));
          yyerror_message("Error de tipos");
        }
        printf("    Expresion-Termino es Expresion\n");
        char auxTer[LONG_TERCETO];
        char auxExp[LONG_TERCETO];
        sprintf(auxTer,"[%d]",terminoInd);
        sprintf(auxExp,"[%d]",expresionInd);
        expresionInd = crear_terceto("-",auxExp,auxTer,tercetosCreados);
        char expresionIndString [10];
        itoa(expresionInd,expresionIndString,10);
        apilar(pilaExpresion,expresionIndString,sizeof(expresionIndString)); 
    }
	 ;
   
termino: 
       factor 
       {
        printf("Factor es Termino\n");
        terminoInd = factorIndice;
        char terminoIndString [10];
        itoa(expresionInd,terminoIndString,10);
        apilar(pilaTermino,terminoIndString, sizeof(terminoIndString));
        tipo_termino = tipo_factor;
       }
       |termino OP_MUL factor 
       {
        if(tipo_termino != tipo_factor)
        {
           printf("\nSe esta queriendo multiplicar un %s con un %s\n", check_tipo_define(tipo_termino),check_tipo_define(tipo_factor));
           yyerror_message("Error de tipos");
        }
        // else
        // {
        //             // printf("OOOOOOOK %s \n\n\n", check_tipo_define(tipo_termino));
        // }
        printf("Termino*Factor es Termino\n");
        char auxTer[LONG_TERCETO];
        char auxFac[LONG_TERCETO];
        sprintf(auxTer,"[%d]",terminoInd);
        sprintf(auxFac,"[%d]",factorIndice);
        terminoInd = crear_terceto("*",auxTer,auxFac,tercetosCreados);
        char terminoIndString [10];
        itoa(terminoInd,terminoIndString,10);
        apilar(pilaTermino,terminoIndString, sizeof(terminoIndString));
       }
       |termino OP_DIV factor 
       {
        if(tipo_termino != tipo_factor)
        {
           printf("\nSe esta queriendo dividir un %s con un %s\n", check_tipo_define(tipo_termino),check_tipo_define(tipo_factor));
           yyerror_message("Error de tipos");
        }
        // Esto lo agregue por probar algo nuevo, se puede sacar, si se quiere usar habria que mejorar detalles
        // if(constante_aux_int == 0)
        // {
        //   yyerror_message("Error, se esta queriendo dividir por 0");
        // }
        // Es solo para validar eso, no se pide especifico
        printf("Termino/Factor es Termino\n");
        char auxTer[LONG_TERCETO];
        char auxFac[LONG_TERCETO];
        sprintf(auxTer,"[%d]",terminoInd);
        sprintf(auxFac,"[%d]",factorIndice);
        terminoInd = crear_terceto("/",auxTer,auxFac,tercetosCreados);
        char terminoIndString [10];
        itoa(terminoInd,terminoIndString,10);
        apilar(pilaTermino,terminoIndString, sizeof(terminoIndString));
       }
       ;

factor: 
      ID 
      {
        printf("ID es Factor \n");
        // validar_ts(yytext, "FLOAT", "", 0, 0); // Se verifica si el id que se quiere asignar esta en tabla de simbolos
        char tipo_id_aux_factor[15];
        strcpy(tipo_id_aux_factor, check_tipo_variable_ts($1, "_", "", 0, 0));
        if(strcmp("INTEGER" , tipo_id_aux_factor) == 0)
        {
          tipo_factor = T_ENTERO;
        }
        else if(strcmp("FLOAT" , tipo_id_aux_factor) == 0)
        {
          tipo_factor = T_FLOAT;
        }
        else if(strcmp("STRING" , tipo_id_aux_factor) == 0)
        {
          tipo_factor = T_STRING;
        }
        factorIndice = crear_terceto(yytext,"_","_",tercetosCreados);
        char factorIndiceString [10];
        itoa(terminoInd,factorIndiceString,10);
        apilar(pilaFactor,factorIndiceString,sizeof(factorIndiceString));
      }
      | CTE_STRING 
      {
        printf("ES CONSTANTE STRING\n");

        tipo_factor = T_STRING;
        strcpy(constante_aux_string,$1);
        
        char nuevaCadena[31];       
        nuevaCadena[0] = '_';
        nuevaCadena[1] = '\0'; 
        strncat(nuevaCadena, $1, sizeof(nuevaCadena) - 2);
        // printf("********  Cadena final: %s\n", nuevaCadena);
        
        factorIndice = crear_terceto(yytext,"_","_",tercetosCreados);
        char factorIndiceString [10];
        itoa(terminoInd,factorIndiceString,10);
        apilar(pilaFactor,factorIndiceString,sizeof(factorIndiceString));
        // Checkear si la variable a donde se asigna es tambien string
        // printf("\n\n\n ++++ nombre_id %s ----- valor %s \n\n",nuevaCadena, $1);
        insertar_tabla_simbolos(nuevaCadena, "CTE_STR", $1, 0, 0.0);
      }
      | CTE_INT 
      {
        printf("ES CONSTANTE INT\n");
        constante_aux_int=$1;
                  // printf("\n\n\n - %s QUEDO COMO PRIMER TIPO  \n\n\n",ultimoTipo);
        tipo_factor = T_ENTERO;

        factorIndice = crear_terceto(yytext,"_","_",tercetosCreados);
        char factorIndiceString [10];
        itoa(terminoInd,factorIndiceString,10);
        apilar(pilaFactor,factorIndiceString,sizeof(factorIndiceString));
        
        char cte_int_nombre_aux [60];
        sprintf(cte_int_nombre_aux,"_%d",$1);

        insertar_tabla_simbolos(cte_int_nombre_aux, "CTE_INT", "", $1, 0.0);
      }
      | CTE_FLOAT 
      {
        printf("ES CONSTANTE FLOAT\n");
        constante_aux_float=$1;
        tipo_factor = T_FLOAT;

        factorIndice = crear_terceto(yytext,"_","_",tercetosCreados);
        char factorIndiceString [10];
        itoa(terminoInd,factorIndiceString,10);
        apilar(pilaFactor,factorIndiceString,sizeof(factorIndiceString));

        char cte_float_nombre_aux [60];
        sprintf(cte_float_nombre_aux,"_%.2f",$1);
        insertar_tabla_simbolos(cte_float_nombre_aux, "CTE_FLOAT", "", 0, $1);
      }
	    | PA expresion PC 
      {
        printf("Expresion entre parentesis es Factor\n");
        factorIndice = expresionInd;
        char factorIndiceString [10];
        itoa(terminoInd,factorIndiceString,10);
        apilar(pilaFactor,factorIndiceString,sizeof(factorIndiceString));
      }
     	;

leer : 
     LEER PA ID PC 
     {
        verificar_si_falta_en_ts($3);
        leerIndice = crear_terceto("LEER", $3, "_", tercetosCreados);
        // printf("\n\n\n *** Se ejecuta LEER con la variable: %s\n", $3);
        // insertar_tabla_simbolos($3, "CTE_STR", $3, 1, 0); // SE MANDA POR AHORA CON ESTE TIPO, PODRIA SER CUALQUIERA
        printf("ES LEER\n");
     }
     
;

escribir:
    ESCRIBIR PA CTE_STRING {
      escribirIndice = crear_terceto("ESCRIBIR", $3, "_", tercetosCreados);
      // printf("\n\n\n *** Se ejecuta ESCRIBIR con la CTE: %s \n", $3);
      // insertar_tabla_simbolos($3, "CTE_STR", $3, 1, 0); // SE MANDA POR AHORA CON ESTE TIPO, PODRIA SER CUALQUIERA
    }PC 
    
    | ESCRIBIR PA ID PC
    {
      verificar_si_falta_en_ts($3);
      escribirIndice = crear_terceto("ESCRIBIR", $3, "_", tercetosCreados);
      // printf("\n\n\n *** Se ejecuta ESCRIBIR con la variable: %s \n", $3);
      // insertar_tabla_simbolos($3, "CTE_STR", $3, 2, 0); // SE MANDA POR AHORA CON ESTE TIPO, PODRIA SER CUALQUIERA
    }
;

ultimos: 
    ID IGUAL SUM_ULT 
    {
       ultInd = crear_terceto($1,"_","_",tercetosCreados);
       validar_ts($1, "FLOAT", "", 0, 0); // Se verifica si el id que se quiere asignar esta en tabla de simbolos
       aux_id_ultimos = ultInd;
    } 
    PA CTE_INT 
    {
      // para validar si pivot > 0 para retornar 0
       ultimos_pivote_aux = atoi(yytext);
    } 
    PTO_COMA CA lista_num CC PC  
    {
      // Aca me voy a fijar si el tamaño del pivot es valido
      // printf("\n\n ****** EL CONTADOR DE ELEMENTOS DIO: %d *******\n\n", contador_elementos_sumar_ult);
       int cantidad_elementos_restantes = contador_elementos_sumar_ult - ultimos_pivote_aux;
      //  printf("\n\n ****** PIVOTE: %d *******\n\n", ultimos_pivote_aux);
       if(ultimos_pivote_aux < 0 || cantidad_elementos_restantes <= 0)
       {
        int tercetoIdAux= ultInd;
        char auxUltId[LONG_TERCETO];
        char auxCero[LONG_TERCETO];
        ultInd = crear_terceto("0","_","_",tercetosCreados);
        sprintf(auxUltId,"[%d]",tercetoIdAux);
        sprintf(auxCero,"[%d]",ultInd);
        ultInd = crear_terceto(":=", auxUltId,auxCero,tercetosCreados);
       }
       else
       {
      int tercetoAux = crear_terceto("aux", "_", "_", tercetosCreados);
      insertar_tabla_simbolos("aux", "FLOAT", "", 0, 0); // Se agrega var auxiliar en tabla de simbolos se usa para assembler
      int ceroAux = crear_terceto("0", "_", "_", tercetosCreados);
      nro_terceto_aux_ultimos = tercetoAux;
      char auxUltId[LONG_TERCETO];
      char auxCero[LONG_TERCETO];

      sprintf(auxUltId,"[%d]",tercetoAux);
      sprintf(auxCero,"[%d]",ceroAux);

      ultInd = crear_terceto(":=", auxUltId, auxCero, tercetosCreados);
   
      int jUltimos;
      char* auxTerceto;
      char auxDesapilado[LONG_TERCETO];
        for(jUltimos = 0; jUltimos< ultimos_pivote_aux  ; jUltimos++)
        {
          auxTerceto = (char*) desapilar(pilaSumarUltimos);
          // printf("\n %s ------------------------------------ \n", auxTerceto);
          ultInd = crear_terceto(auxTerceto, "_", "_", tercetosCreados);

          char ultIndChar [10];
          sprintf(ultIndChar,"[%d]",ultInd);
          ultInd = crear_terceto("+", auxUltId, ultIndChar, tercetosCreados);

          char aux_ult_asig [10];
          sprintf(aux_ult_asig,"[%d]",ultInd);
          ultInd = crear_terceto(":=", auxUltId, aux_ult_asig, tercetosCreados);
        }    
      }
      // Asignacion final del aux al ID inicial de la sentencia
      char id_string_aux [10];
      sprintf(id_string_aux,"[%d]",aux_id_ultimos);

      char aux_ultima_asig_string [10];
      sprintf(aux_ultima_asig_string,"[%d]",nro_terceto_aux_ultimos);

      ultInd = crear_terceto(":=", id_string_aux, aux_ultima_asig_string, tercetosCreados);
      printf("ES SUMAR ULTIMOS\n");
    }
;

lista_num: lista_num COMA num 
           | num
;

num: 
  CTE_INT 
    {
    // Voy a apilar el nro y voy a sumar a un contador
    // printf("\n\n\n NUM ->>>>>>>  %d",$1);
    int auxiliar_numero= $1;
    char factorIndiceString [10];
    apilar(pilaSumarUltimos,itoa(auxiliar_numero,factorIndiceString,10),sizeof(factorIndiceString));
    contador_elementos_sumar_ult++;
    } 
  | CTE_FLOAT 
    {
    // Voy a apilar el nro y voy a sumar a un contador
    // printf("\n\n\n NUM ->>>>>>>  %f",$1);
    float auxiliar_numero= $1;
    char str[10]; 
    sprintf(str, "%.2f", auxiliar_numero); 
    apilar(pilaSumarUltimos,str,sizeof(str));
    contador_elementos_sumar_ult++;
    }
;

triangulos:
           ID IGUAL TRIANG PA 
           {
              triangulos_id_aux = crear_terceto($1,"_","_",tercetosCreados);
              validar_ts($1, "FLOAT", "", 0, 0); // Se verifica si el id que se quiere asignar esta en tabla de simbolos
           }  
           expresion 
           {
            aux_exp1 = crear_terceto("aux_exp1","","",tercetosCreados);
            insertar_tabla_simbolos("aux_exp1", "FLOAT", "", 0, 0);
            // printf("\n\n\n ************************** EXP %d ", expresionInd);
            char aux_exp_c[LONG_TERCETO];
            char aux_ind_exp[LONG_TERCETO];
            sprintf(aux_exp_c,"[%d]",aux_exp1);
            sprintf(aux_ind_exp,"[%d]",expresionInd);
            indTriangExp1= crear_terceto(":=",aux_exp_c,aux_ind_exp,tercetosCreados);
           }
           COMA expresion
           {
            aux_exp2 = crear_terceto("aux_exp2","","",tercetosCreados);
            insertar_tabla_simbolos("aux_exp2", "FLOAT", "", 0, 0);
            // printf("\n\n\n ************************** EXP %d ", expresionInd);
            char aux_exp_c[LONG_TERCETO];
            char aux_ind_exp[LONG_TERCETO];
            sprintf(aux_exp_c,"[%d]",aux_exp2);
            sprintf(aux_ind_exp,"[%d]",expresionInd);
            indTriangExp2= crear_terceto(":=",aux_exp_c,aux_ind_exp,tercetosCreados);
           } 
           COMA expresion
           {
            aux_exp3 = crear_terceto("aux_exp3","","",tercetosCreados);
            insertar_tabla_simbolos("aux_exp3", "FLOAT", "", 0, 0);
            // printf("\n\n\n ************************** EXP %d ", expresionInd);
            char aux_exp_c[LONG_TERCETO];
            char aux_ind_exp[LONG_TERCETO];
            sprintf(aux_exp_c,"[%d]",aux_exp3);
            sprintf(aux_ind_exp,"[%d]",expresionInd);
            indTriangExp3= crear_terceto(":=",aux_exp_c,aux_ind_exp,tercetosCreados);
           } 
           PC  
           {
            // printf("\n\n\n 1: %d \n 2: %d \n 3: %d",indTriangExp1,indTriangExp2,indTriangExp3);
            char auxUno[LONG_TERCETO];
            char auxDos[LONG_TERCETO];
            char auxTres[LONG_TERCETO];
            char auxIdTriang[LONG_TERCETO];

            sprintf(auxUno,"[%d]",indTriangExp1);
            sprintf(auxDos,"[%d]",indTriangExp2);
            sprintf(auxTres,"[%d]",indTriangExp3);

            indTriang = crear_terceto("CMP",auxDos,auxUno,tercetosCreados);
            int primerSaltoBNE = crear_terceto("BNE","_","_" ,tercetosCreados);
            escribir_terceto_actual_en_anterior(primerSaltoBNE+7, primerSaltoBNE); // Siempre el siguente CMP va a ser en +7

            // printf("\n\n ************* anterior:%d siguiente:%d \n \n ",a-1,a+4);

            indTriang = crear_terceto("CMP",auxTres,auxUno,tercetosCreados);
            int segundoSaltoBNE = crear_terceto("BNE","_","_" ,tercetosCreados);
            escribir_terceto_actual_en_anterior(segundoSaltoBNE+3, segundoSaltoBNE); // Escribo a donde salta si a=b pero a!=c (isosceles)

            sprintf(auxIdTriang,"[%d]",triangulos_id_aux);

            crear_terceto(":=",auxIdTriang,"\"Equilatero\"" ,tercetosCreados);

            char auxBi[LONG_TERCETO];

            sprintf(auxBi,"[%d]",tercetosCreados+6);

            crear_terceto("BI","_",auxBi,tercetosCreados);

            // Salto al final que ya se cuanto es
            crear_terceto(":=",auxIdTriang,"\"Isosceles\"" ,tercetosCreados);
            sprintf(auxBi,"[%d]",tercetosCreados+4);

            crear_terceto("BI","_",auxBi,tercetosCreados);
            // Salto el caso escaleno
            // Comparo a y c
            // Si son iguales tengo que volver al tecerto de isosceles, caso contrario es escaleno a!=b!=c
            indTriang = crear_terceto("CMP",auxTres,auxUno,tercetosCreados);
            sprintf(auxBi,"[%d]",tercetosCreados-3);
            crear_terceto("BE","_",auxBi ,tercetosCreados); // En caso de que sea igual eso indicaria que es isosceles
            crear_terceto(":=",auxIdTriang,"\"Escaleno\"" ,tercetosCreados); // En caso contrario son todos distintos entonces es escaleno
            
            printf("ES TRIANGULOS\n");
           }
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
        // pilaVariables = crear_pila();
        pilaComparacion = crear_pila();
        pilaNroTerceto = crear_pila();
        pilaSumarUltimos = crear_pila();

        crear_cola(&colaTercetos);
        
        yyparse();
             
        //Generacion de intermedia
        abrir_archivo_intermedia();
        escribir_tercetos_intermedia();
        fclose(fpIntermedia);

        generar_assembler();
    }
  fclose(yyin);
  return 0;
}

int yyerror(void)
{
  printf("\n ********* Error Sintactico ********* \n");
  exit (1);
}

int yyerror_message(char* mensaje_error)
{
  printf("\n ********* %s ********* \n",mensaje_error);
  exit (1);
}

int insertar_tabla_simbolos(const char *nombre,const char *tipo, 
                            const char* valor_string, int valor_var_int, 
                            float valor_var_float)
{
    t_simbolo *tabla = tabla_simbolos.primero;
    char nombreCTE[32] = "_";
    strcat(nombreCTE, nombre);
    // printf("\n\n\n\n\n VOY A INSERTAR ->>>>>>>>: %s -------  %s ************  %s ------------- %d ------------- %f \n\n\n\n",nombre,tipo,valor_string,valor_var_int,valor_var_float);

    while(tabla)
    { 
      // Para evitar repetidos / actualizar asignaciones
      if(strcmp(tabla->data.nombre, nombre) == 0 || strcmp(tabla->data.nombre, nombreCTE) == 0)
      {
          // if (strcmp(tipo, "CTE_STR") == 0)
          //   {
          //       strcpy(tabla->data.valor.valor_var_str, valor_string);
          //   }
          //   else if (strcmp(tipo, "CTE_INT") == 0)
          //   {
          //       tabla->data.valor.valor_var_int = valor_var_int;
          //   }
          //   else if (strcmp(tipo, "CTE_FLOAT") == 0)
          //   {
          //       tabla->data.valor.valor_var_float = valor_var_float;
          //   }
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

int verificar_si_ya_existe_en_ts(const char *nombre)
{
  t_simbolo *tabla = tabla_simbolos.primero;
  while(tabla)
    { 
        // printf("\n\n\n\n\n +++++++++++ VALIDO SI     %s         ESTA EN TS       +++++++++++++++++++ \n\n\n\n\n\n\n\n\n",nombre );
        if(strcmp(tabla->data.nombre, nombre) == 0)
        {
          // Esto significa que ya fue declara previamente
          printf("La variable %s ya fue previamente declarada \n", nombre);
          yyerror_message("VARIABLE PREVIAMENTE DECLARADA");
        }
      if(tabla->next == NULL)
      {
        break;
      }
      tabla = tabla->next;
    }
  return 0;
}

int verificar_si_falta_en_ts(const char *nombre)
{
  t_simbolo *tabla = tabla_simbolos.primero;
  while(tabla)
    { 
        // printf("\n\n\n\n\n +++++++++++ VALIDO SI     %s         ESTA EN TS       +++++++++++++++++++ \n\n\n\n\n\n\n\n\n",nombre );
        if(strcmp(tabla->data.nombre, nombre) == 0)
        {
          // Esto significa que ya fue declara previamente
          printf("La variable %s ya fue previamente declarada \n", nombre);
          return 0;
        }
      if(tabla->next == NULL)
      {
        break;
      }
      tabla = tabla->next;
    }
    printf("La variable %s NO fue previamente declarada \n", nombre);
    yyerror_message("La variable no fue declarada previamente y se esta usando");
}

char* validar_ts(const char *nombre,const char *tipo, 
                            const char* valor_string, int valor_var_int, 
                            float valor_var_float)
{    

  t_simbolo *tabla = tabla_simbolos.primero;

  while(tabla)
  { 
      // printf("\n\n\n\n\n +++++++++++ VALIDO SI     %s         ESTA EN TS       +++++++++++++++++++ \n\n\n\n\n\n\n\n\n",nombre );
      if(strcmp(tabla->data.nombre, nombre) == 0)
      {
          // printf("\n\n\n\n\n VARIABLE DECLARADA \n\n\n\n\n\n\n\n");
          // Ahora hay que ver si el tipo es el correcto
          if(strcmp(tabla->data.tipo,tipo) != 0) 
          {
            printf("El tipo de dato %s de la variable - %s - no coincide con el tipo %s esperado", nombre , tabla->data.tipo,tipo);
            yyerror_message("ERROR DE TIPOS");
          }
          return NULL;
      }    
      if(tabla->next == NULL)
      {
        break;
      }
      tabla = tabla->next;
  }
  printf("\nLa variable %s no fue declarada previamente \n", nombre);
  yyerror_message("ERROR VARIABLE NO DECLARADA");
  return NULL;
}

const char * check_tipo_variable_ts(const char *nombre,const char *tipo, 
                            const char* valor_string, int valor_var_int, 
                            float valor_var_float)
{    

  t_simbolo *tabla = tabla_simbolos.primero;

  while(tabla)
  { 
      // printf("\n\n\n\n\n +++++++++++ VALIDO SI     %s         ESTA EN TS       +++++++++++++++++++ \n\n\n\n\n\n\n\n\n",nombre );
      if(strcmp(tabla->data.nombre, nombre) == 0)
      {
          // printf("\n\n\n\n\n VARIABLE DECLARADA \n\n\n\n\n\n\n\n");
          return tabla->data.tipo;
      }    
      if(tabla->next == NULL)
      {
        break;
      }
      tabla = tabla->next;
  }
  printf("\nLa variable %s no fue declarada previamente \n", nombre);
  yyerror_message("Variable no declarada");
  return "";
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

            char aux_valor_float_ts[30];
            data->valor.valor_var_str = (char*)malloc(sizeof(char) * strlen(aux_valor_float_ts) +1);
            sprintf(aux_valor_float_ts,"%.2f",valor_var_float);

            strcpy(data->valor.valor_var_str, aux_valor_float_ts);
        }
        if(strcmp(tipo, "CTE_INT") == 0)
        {
            sprintf(aux, "%d", valor_var_int);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));
            strcpy(data->nombre, full);
            data->valor.valor_var_int = valor_var_int;

            char aux_int[30];
            data->valor.valor_var_str = (char*)malloc(sizeof(char) * strlen(aux_int) + 1);
            sprintf(aux_int,"%d",valor_var_int);
            strcpy(data->valor.valor_var_str, aux_int);
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
        // if(aux->next == NULL)
        // {
        //   break;
        // }
        tabla = tabla->next;

        if(strcmp(aux->data.tipo, "INTEGER") == 0) 
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_INT") == 0)
        {
            // sprintf(linea, "%-30s%-30s%-40d%s\n", aux->data.nombre, "", aux->data.valor.valor_var_int, "");
            // sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, "", "", "");
            sprintf(linea, "%-30s%-30s%-40s%d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_var_str, strlen(aux->data.valor.valor_var_str));
        }
        else if(strcmp(aux->data.tipo, "FLOAT") ==0)
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_FLOAT") == 0)
        {
            // sprintf(linea, "%-30s%-30s%-40f%s\n", aux->data.nombre, "", aux->data.valor.valor_var_float, "");
            sprintf(linea, "%-30s%-30s%-40s%d\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_var_str, 5);                               
            //  printf("\n\n\n\n\n ACAAAAAAAA %s",aux->data.nombre);
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
            // sprintf(linea, "%-30s%-30s%-40s%-s\n", full, "", "", "");
            sprintf(linea, "%-30s%-30s%-40s%-d\n", full, aux->data.tipo, aux_string, strlen(aux->data.valor.valor_var_str));
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

const char * check_tipo_define(int tipo_int)
{
  switch(tipo_int)
  {
    case 10:
      return "ENTERO";
    case 20:
      return "FLOAT";
    case 30:
      return "STRING";
    default:
      return "";
  }
}
void generar_assembler();
void trim_end(char * str);

void generar_assembler()
{
    FILE* arch_inter;
    FILE* arch_tabla;
    FILE* arch_asse;
    char idWhile[200];
    int contWhile=0;
    arch_inter = fopen("intermediate-code.txt","rt");
    arch_tabla = fopen("symbol-table.txt","rt");
    arch_asse = fopen("assembler_generated.asm","wt");
    if(!arch_asse )
    {
        printf("Error en el archivo de assembler");
        return;
    }
    if( !arch_tabla )
    {
        printf("Error en la apertura de la tabla de simbolos");
        return;
    }
    if( !arch_inter)
    {
        printf("Error en la apertura del archivo intermedia");
        return;
    }
    Pila p_ass;
    Pila p_while;
    crear_pila(&p_ass);
    crear_pila(&p_while);
    fprintf(arch_asse,  "include macros2.asm\n");
    fprintf(arch_asse,  "include number.asm\n");
    fprintf(arch_asse, ".MODEL LARGE\n.STACK 200h\n.386\n.DATA\n\n");
    //Bajo tabla de simbolos en Assembler
    char linea[1000];
    fgets(linea, sizeof(linea), arch_tabla); // Para que se saltee la primera linea de la tabla de simbolos
    while(fgets(linea, sizeof(linea),arch_tabla))
    {
        printf("LA LINEA TIENE %s \n\n\n", linea);
        char nombre[30];
        char tipo[30];
        char valor[40];
        
        strncpy(nombre, linea, 30);
        trim_end(nombre);
        // nombre[30] = '\0';  // Asegurar que la cadena termine con '\0'
        // printf("EL NOMBRE QUE QUEDA ES %s * \n\n\n", nombre);
        
        // Copiar los siguientes 30 caracteres a variable2
        strncpy(tipo, linea + 30, 30);
        // tipo[30] = '\0'; 
        printf("EL TIPO QUE QUEDA ES %s * \n\n\n", tipo);
        strncpy(valor, linea + 60, 40);
        // valor[40] = '\0';
        printf("DATO: Nombre ***** %s ***** Tipo ***** %s ***** Valor ***** %s ***** \n",nombre,tipo,valor);
        if(strstr(tipo,"STRING") != NULL)
        {
          if(valor[0] =='-')
          {
              valor[0] = '?';
              valor[1] = '\0';   
          }
          fprintf(arch_asse,"%-20s db\t\t %-30s, \'$\', %s dup (?)\n",nombre,valor,"14");
        }
        else // todo VER COMO HAGO CON EL VALOR DE LAS CTES
        {
            if(strcmp(tipo,"FLOAT")==0 && strcmp(tipo,"INTEGER")==0 && strcmp(tipo,"STRING")==0)
            {
                  if( strlen(valor)>1 && valor[0] =='-')
                  {
                      valor[0] = '?';
                      valor[1] = '\0';
                  }
                  fprintf(arch_asse,"%-20s dd\t\t %-30s\n",nombre,valor);
            }
            else{
                if( strlen(valor)>1 && valor[0] =='-')
                {
                    valor[0] = '?';
                    valor[1] = '\0';
                }
                fprintf(arch_asse,"%-20s dd\t\t ?\n",nombre,valor);
            }
           
        }
    }
    
    fprintf(arch_asse,  "\n.CODE");
    fprintf(arch_asse,  "\nMOV EAX,@DATA");
    fprintf(arch_asse,  "\nMOV DS,EAX");
    fprintf(arch_asse,  "\nMOV ES,EAX;\n\n");
    char st[40];
    int operacion = 0;
    char et[10];

    while(fgets(linea, sizeof(linea),arch_inter))
    {
      char numTerceto[40];
      //int numTerceto;
      char posUno[40];
      char posDos[40];
      char posTres[40];
      printf("Linea de intermedia %s\n",linea);
        
      // sscanf(linea,"[%s] ( %s ; %s ; %s )",numTerceto,posUno,posDos,posTres);
      sscanf(linea, "%s ( %s ; %s ; %s )", numTerceto, posUno, posDos, posTres);
      // printf("TERCETO %s %s %s %s \n",numTerceto,posUno,posDos,posTres);
      if( strncmp(posUno,"CMP",4) != 0  && (posDos[0]  == '_')  &&  (posTres[0] == '_') )
      {
        printf("ANTES ENTRE ACA \n\n");
        apilar(&p_ass, posUno, sizeof(posUno));
      }
      if(strcmp(":=",posUno) == 0 )
      {
        printf("ST TIENE :::::::: %s \n\n",st);
        strcpy(st, desapilar(&p_ass));
        printf("ST TIENE AHORA :::::::: %s \n\n",st);

        if(operacion == 0)
        {
          fprintf(arch_asse,"FLD %s\n",st);  
          strcpy(st, desapilar(&p_ass));
        }
        fprintf(arch_asse,"FSTP %s\n",st);  
        operacion = 0;   
      }
      if(strcmp("+",posUno) == 0 ){
          strcpy(st, desapilar(&p_ass));   
          fprintf(arch_asse,"FLD %s\n",st);
          strcpy(st, desapilar(&p_ass));   
          fprintf(arch_asse,"FLD %s\n",st);
          fprintf(arch_asse,"FADD\n");
          operacion = 1;
      }
      
      if(strcmp("-",posUno) == 0 )
      {
          strcpy(st, desapilar(&p_ass));      
          fprintf(arch_asse,"FLD %s\n",st);
          strcpy(st, desapilar(&p_ass));      
          fprintf(arch_asse,"FLD %s\n",st);
          fprintf(arch_asse,"FSUB\n");
          operacion = 1;
      }
    
      if(strcmp("/",posUno) == 0 )
      {
          strcpy(st, desapilar(&p_ass));      
          fprintf(arch_asse,"FLD %s\n",st);
          strcpy(st, desapilar(&p_ass));      
          fprintf(arch_asse,"FLD %s\n",st);
          fprintf(arch_asse,"FDIV\n");
          operacion = 1;
      }
    
      if(strcmp("*",posUno) == 0 )
      {
          strcpy(st, desapilar(&p_ass));      
          fprintf(arch_asse,"FLD %s\n",st);
            strcpy(st, desapilar(&p_ass));      
          fprintf(arch_asse,"FLD %s\n",st);
          fprintf(arch_asse,"FMUL\n");
          operacion = 1;
      }
      if(strcmp("CMP",posUno) == 0 )
      {
          strcpy(st, desapilar(&p_ass)); 
          fprintf(arch_asse,"FLD %s\n",st);
            strcpy(st, desapilar(&p_ass));      
          fprintf(arch_asse,"FLD %s\n",st); 
          fprintf(arch_asse,"FXCH\n"); 
          fprintf(arch_asse,"FCOM\n");
          fprintf(arch_asse,"FSTSW AX\n");
          fprintf(arch_asse,"SAHF\n");
          fprintf(arch_asse,"FFREE\n");
      }
      if(strcmp ("BLE",posUno)==0) 
      {
        sscanf(posTres,"%[^ ]",et);
        fprintf(arch_asse,"JNA %s\n",et);
      }
      if(strcmp ("BNE",posUno)==0)
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(arch_asse,"JNE %s\n",et);
      }
      if(strcmp ("BLT",posUno)==0) 
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(arch_asse,"JB %s\n",et);
      }
      if(strcmp ("BGT",posUno)==0) 
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(arch_asse,"JA %s\n",et);
      }
      if(strcmp ("BGE",posUno)==0) 
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(arch_asse,"JAE %s\n",et);
      }
          
      if(strcmp ("BEQ",posUno)==0) 
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(arch_asse,"JE %s\n",et);
      }
      if(strcmp("BI", posUno) == 0)
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(arch_asse,"JMP %s\n",et);
      }

      if(strncmp(posUno,"ETIQ_IF",7) == 0 ){
          fprintf(arch_asse,"%s\n",posUno);
      }

      /*
      //TODO TAG ESCRIBIR Y LEER, VER COMO RESOLVER LOS SALTOS CONDICIONALES Y POR QUE NO FUNCIONA LO DE TRIANGULOS Y SUMAULTIMOS
      //Pasaje de etiquetas en assembler
      
      // if(strncmp(posUno,"ETIQ_IF",7) == 0 ){
      //     fprintf(arch_asse,"%s\n",posUno);
      // }
      if(strncmp(posUno,"ETIQ_ELSE",9) == 0 ){
          fprintf(arch_asse,"%s\n",posUno);
      }
      if(strncmp(posUno,"InicioCiclo",11) == 0 ){
          fprintf(arch_asse,"%s\n",posUno);
      }
      if(strncmp(posUno,"ETIQ_CICLO",7) == 0 ){
          fprintf(arch_asse,"%s\n",posUno);
          fprintf(arch_asse,"FFREE\n");
      }
      */
      printf("\n\n ****************************  Aca?       **************************************\n\n");
    }
    printf("\n\n ****************************  SALI      **************************************\n\n");
    fprintf(arch_asse,  "\nmov ax,4c00h");
    fprintf(arch_asse,  "\nint 21h");
    fprintf(arch_asse,  "\nEnd");
    fclose(arch_inter);
    fclose(arch_tabla);
    fclose(arch_asse);
}

void trim_end(char * str)
{
    int index, i;

    /* Set default index */
    index = -1;
        // printf("la cosa es !!!!!!!! %s \n\n ", str);

    /* Find last index of non-white space character */
    i = 0;
    while(isalpha(str[i]) || str[i] == '_' || isalnum(str[i]) )
    {
        printf("LA LETRA ES %c \n\n ", str[i]);
        if(str[i] != ' ' && str[i] != '\t' && str[i] != '\n')
        {
            index= i;
        }

        i++;
    }

    /* Mark next character to last non-white space character as NULL */
    str[index + 1] = '\0';
    printf("\n\n EL STRING QUEDA  %s * \n\n\n",str);
}