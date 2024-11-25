%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <string.h>
#include <math.h>
#include "pila.c"
#include "pila.h"
#include "tercetos.h"
#include "diccionario.h"

#define T_ENTERO 10
#define T_FLOAT 20
#define T_STRING 30
#define TRUE 1
#define FALSE 0

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

// Declaracion funciones
void crear_tabla_simbolos();
int insertar_tabla_simbolos(const char*, const char*, const char*, int, float);
t_data* crearDatos(const char*, const char*, const char*, int, float);
void guardar_tabla_simbolos();
char* validar_ts_int_o_float(const char *nombre);
char* agregar_corchetes(const char* cadena);
t_tabla tabla_simbolos;
char* validar_ts(const char *nombre,const char *tipo);
int verificar_si_ya_existe_en_ts(const char *nombre);
const char * check_tipo_variable_ts(const char *nombre);
int verificar_si_falta_en_ts(const char *nombre);
const char * check_tipo_define(int tipo_int);
void escribir_terceto_actual_en_anterior_con_tag(int tercetoAEscribir,int tercetoBuscado,char * etiqueta);
void eliminar_corchetes(const char *cadena, char *resultado);
int check_es_cte_string_o_string_ts(const char *nombre);
void liberar_memoria_tabla_simbolos();
const char * check_es_cte(const char *nombre);
void sacar_comillas_dobles(char *str);
int check_es_cte_columna_valor(const char *nombre);
void generar_assembler();
void trim_end(char * str);
void reemplazar_puntos_por_guion_bajo(char* str);

// Declaracion variables

Pila* pilaExpresion;
Pila* pilaTermino;
Pila* pilaFactor;
Pila * pilaComparacion;
Pila* pilaSumarUltimos;

int i;
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
char tri_id_save[40];
int aux_id_ultimos=0;
int nro_terceto_aux_ultimos=0;
int aux_exp1=0,
 aux_exp2=0,
 aux_exp3=0;
int auxExp_triang1;
int auxExp_triang2;
int auxExp_triang3;
int tipo_factor = -1;
int tipo_expresion = -1;
int tipo_termino = -1;
int tipo_expresion_izq =-1;
int tipo_asig_u =-1;
int contador_leer= 1;
int eraOr = 0;
int et_inicio_while_count =1;
int et_ultimos_contador = 1;
int fue_not;
char aux_et_inicio[50]; 
char check_es_cte_aux[50];
char aux_exp_c2[LONG_TERCETO];
char aux_ind_exp2[LONG_TERCETO];
int nro_terceto_or_primer_comp=0;
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
int contador_et_escribir = 1;
char comparador[4];

int ultimos_pivote_aux=0;
int contador_elementos_sumar_ult = 1;
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
                    printf("ES UNA LISTA DE VARIABLES\n");
                }
                | ID
                {
                    printf("ES UNA VARIABLE\n");
                    strcpy(t_ids[cant_id].cadena,$1);
                    cant_id++;
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
    int es_primer_comp =1 ;
    int prox_condicion_invierte =0;
    printf("ES CONDICION SI\n");
    while(!es_pila_vacia(pilaComparacion))
    {
        char* nro_terc_desapilado = (char *) desapilar(pilaComparacion);
        //escribir_terceto_actual_en_anterior(tercetosCreados,atoi(t));
        //Cambio ET
        if(eraOr == 1)
        {
            prox_condicion_invierte=1;
            eraOr=0;
        }
        if(fue_not == 1)
        {
            eraOr=1;
            escribir_terceto_actual_en_anterior_con_tag(tercetosCreados,atoi(nro_terc_desapilado),"ETIQ_IF");
            eraOr=0;
        }
        else if(es_primer_comp == 2 && prox_condicion_invierte== 1)
        {
           getchar();
           eraOr=1;
           escribir_terceto_actual_en_anterior_con_tag(condicionInd,atoi(nro_terc_desapilado),"CUERPO_IF");
        }
        else
        {
          escribir_terceto_actual_en_anterior_con_tag(tercetosCreados,atoi(nro_terc_desapilado),"ETIQ_IF");
        }
        es_primer_comp++;
    }
    prox_condicion_invierte=0;
    eraOr = 0;
    fue_not =0 ;
    es_primer_comp= 0;
    char resultado[50]; 
    sprintf(resultado, "ETIQ_IF%d", tercetosCreados);
    crear_terceto(resultado,"_","_",tercetosCreados);

  }
  // IF ELSE
  | IF PA condicion PC LA instrucciones LC 
  {
    // Apilo la posicion actual porque cuando reconozco todo, es cuando voy a saber a donde saltar
    // printf("************************************* \n \n \n ACA RECONOCI QUE TENGO UNA INSTRUCCION DENTRO DE LA PARTE IF");

    saltoFinElse = crear_terceto("BI","_","_",tercetosCreados);
    // DEBERIA SER ASI
    // [8] ( BI ; _ ; [12] ) 
    // [8] ( BI ; _ ; ETIF12 ) 
    // Se a donde saltar al final del else
    aux_terceto_if_else = tercetosCreados;
  }
  ELSE 
  {
    char resultado[50]; 
    sprintf(resultado, "ETIQ_IF%d", aux_terceto_if_else);
    crear_terceto(resultado,"_","_",tercetosCreados);
  } 
  LA instrucciones LC 
  {
    printf("ES CONDICION SINO \n");
     while(!es_pila_vacia(pilaComparacion))
     {
        dato_tope = (char *) desapilar(pilaComparacion);
        // escribir_terceto_actual_en_anterior(aux_terceto_if_else,atoi(dato_tope));
        // int tercetoAEscribir,int tercetoBuscado
        
        // void escribir_terceto_actual_en_anterior_con_tag(int tercetoAEscribir,int tercetoBuscado,char * etiqueta);
        escribir_terceto_actual_en_anterior_con_tag(aux_terceto_if_else,atoi(dato_tope), "ETIQ_IF");

        // saltoFinElse = crear_terceto("BI","_","_",tercetosCreados);

      }
          // printf("************************************* \n \n \n ACA RECONOCI TODO EL IF ELSE \n \n \n");
          // printf("\n \n \n ESTO ES EL NRO DEL TERCETO DEL IF - %d - AHORA LO VOY A LLENAR con el salto al else - %d - \n \n \n",test_int, tercetosCreados);
          // printf("\n \n \n ESTO ES EL TERCETO ACTUAL %d \n \n \n",tercetosCreados);

      escribir_terceto_actual_en_anterior_con_tag(tercetosCreados,saltoFinElse, "ETIQ_IF");
      
      char resultado[50]; 
      // printf("\n\n RECONOCI TODO EL ELSE Y ESTOY EN %d", tercetosCreados);
      // getchar();
      sprintf(resultado, "ETIQ_IF%d", tercetosCreados);
      crear_terceto(resultado,"_","_",tercetosCreados);
      // escribir_terceto_actual_en_anterior(tercetosCreados,saltoFinElse);
  }
;

mientras:
  WHILE PA 
  {
    // Creo este terceto que va a ser el inicial al que va a retornar si la condicion se sigue cumpliendo
    // char et_inicio[50]; 
    sprintf(aux_et_inicio, "InicioMientras%d", tercetosCreados);
    mientrasInd = crear_terceto(aux_et_inicio,"_","_",tercetosCreados);
    et_inicio_while_count++; 
    apilar_nro_terceto(mientrasInd); // Lo apilo para despues tenerlo para el branch incondicional
  } condicion PC LA instrucciones LC // Aca cuando es un OR o AND me esta faltando escribir el nro de terceto del salto de la primera condicion?
  {
    // Aca ya se cuantos tercetos tengo que dejar
    int t = desapilar_nro_terceto(); // Aca debería tener el nro del terceto inicial del while
    char auxT [LONG_TERCETO]; 
    // escribir_terceto_actual_en_anterior(tercetosCreados+1,t);
    escribir_terceto_actual_en_anterior_con_tag(tercetosCreados+1,t,"ETIQ_CICLO");
    t = desapilar_nro_terceto(); 
   
    // sprintf(auxT,"[%d]",mientrasInd);
    crear_terceto("BI","_",aux_et_inicio,tercetosCreados); // Este es el salto incondicional para ir al principio y checkear la condicion de nuevo

    // sprintf(auxT,"[%d]",mientrasInd);
    // crear_terceto("BI","_",auxT,tercetosCreados); Este es el salto incondicional para ir al principio y checkear la condicion de nuevo
    // printf("\n\n\n ---------- Voy a escribir en --> %d el valor ---> %d" , aux_comp, tercetosCreados);
    // escribir_terceto_actual_en_anterior(tercetosCreados,aux_comp);
    char resultado[50]; 
    sprintf(resultado, "ETIQ_CICLO%d", tercetosCreados);
    mientrasInd=crear_terceto(resultado,"_","_",tercetosCreados);
    printf("ES UN MIENTRAS\n");
    printf("\n RESULTADO %s \n\n",resultado);
    // crear_terceto(resultado,"","",tercetosCreados);
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
    fue_not = 1;
    char comparacionAux [LONG_TERCETO];
    sprintf(comparacionAux, "[%d]", comparacionInd);
    condicionInd = crear_terceto("NOT", comparacionAux,"_",tercetosCreados );
  }
  | 
  condicion { eraOr =1; } OP_OR comparacion 
  {
    char condicionAux [LONG_TERCETO];
    sprintf(condicionAux, "CUERPO_IF%d", tercetosCreados);
    condicionInd = crear_terceto(condicionAux, "_" ,"_",tercetosCreados ); // este pasa a ser una etiqueta para el primer salto
    // tengo que guardar la pos del primer salto
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
    expresion operador_comparacion { tipo_expresion_izq = tipo_expresion; } expresion 
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
        comparacionInd=crear_terceto("CMP",agregar_corchetes(exp1),agregar_corchetes(exp2),tercetosCreados);
        aux_comp = condicionInd+1;
        int t = crear_terceto(comparador,"_","_" ,tercetosCreados);
        apilar_nro_terceto(t);
        char tString [10];
        itoa(t,tString,10);
        apilar(pilaComparacion,tString,sizeof(tString));      
    }
    // | PA condicion PC
;

operador_comparacion:
  OP_MAYOR    {strcpy(comparador, "BLE");}
  | OP_MAYORI {strcpy(comparador, "BLT");};
  | OP_MEN    {strcpy(comparador, "BGE");}
  | OP_MENI   {strcpy(comparador,"BGT");}
  | OP_IGUAL  {strcpy(comparador, "BNE");}
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
          
          if(strcmp("INTEGER",aux_tipo_validacion_ts)==0){
                tipo_asig_u = T_ENTERO;
          }
          else if(strcmp("FLOAT",aux_tipo_validacion_ts)==0){
                tipo_asig_u = T_FLOAT;
          }
          else if(strcmp("STRING",aux_tipo_validacion_ts)==0){
                tipo_asig_u = T_STRING;
          }
          if(tipo_expresion != tipo_asig_u )
          {
            printf("\n\nEl ID %s tiene un tipo %s que no es compatible en la asignacion\n\n",nombre_id,aux_tipo_validacion_ts);
            yyerror_message("Error de tipos en la asignacion");
          }
    }
	  ;

// TO-DO REVISAR

id:
  ID
  {
    strcpy(nombre_id,$1);
    strcpy(aux_tipo_validacion_ts, check_tipo_variable_ts($1)); // Se verifica si el id que se quiere asignar esta en tabla de simbolos
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
        char tipo_id_aux_factor[15];
        strcpy(tipo_id_aux_factor, check_tipo_variable_ts($1));
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
        
        factorIndice = crear_terceto(yytext,"_","_",tercetosCreados);
        char factorIndiceString [10];
        itoa(terminoInd,factorIndiceString,10);
        apilar(pilaFactor,factorIndiceString,sizeof(factorIndiceString));
        insertar_tabla_simbolos(nuevaCadena, "CTE_STR", $1, 0, 0.0);
      }
      | CTE_INT 
      {
        printf("ES CONSTANTE INT\n");
        constante_aux_int=$1;
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

        char num_con_formato[25];
        sprintf(num_con_formato,"%.2f",constante_aux_float);

        factorIndice = crear_terceto(num_con_formato,"_","_",tercetosCreados);
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
        char et_leer_aux[25];
        sprintf(et_leer_aux,"ET_LEER%d",contador_leer);
        contador_leer++;
        leerIndice = crear_terceto(et_leer_aux, $3, "_", tercetosCreados);
        printf("\n\n\n *** Se ejecuta LEER con la variable: %s\n", $3);
     }
     
;

escribir:
    ESCRIBIR PA CTE_STRING 
    {
      char et_escribir_aux[25];
      sprintf(et_escribir_aux,"ET_ESCRIBIR%d",contador_et_escribir);
      contador_et_escribir++;
      escribirIndice = crear_terceto(et_escribir_aux, $3, "_", tercetosCreados);
      printf("\n\n\n *** Se ejecuta ESCRIBIR con la CTE: %s \n", $3);
      insertar_tabla_simbolos($3, "CTE_STR", $3, 1, 0);
    }
    PC 
    | ESCRIBIR PA ID PC
    {
      verificar_si_falta_en_ts($3);
      char et_escribir_aux[25];
      sprintf(et_escribir_aux,"ET_ESCRIBIR%d",contador_et_escribir);
      contador_et_escribir++;
      escribirIndice = crear_terceto(et_escribir_aux, $3, "_", tercetosCreados);
      printf("\n\n\n *** Se ejecuta ESCRIBIR con la variable: %s \n", $3);
    }
;

ultimos: 
    ID IGUAL SUM_ULT 
    {
       ultInd = crear_terceto($1,"_","_",tercetosCreados);
       validar_ts_int_o_float($1); // verif en ts
       aux_id_ultimos = ultInd;
       insertar_tabla_simbolos("_0", "CTE_INT", "", 0, 0.0);
       insertar_tabla_simbolos("_0.0", "CTE_FLOAT", "", 0, 0.0);
       insertar_tabla_simbolos("aux_ult", "FLOAT", "", 0, 0); // Se agrega var auxiliar en tabla de simbolos se usa para assembler
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
          int tercetoAux = crear_terceto("aux_ult", "_", "_", tercetosCreados);
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
            ultInd = crear_terceto(auxTerceto, "_", "_", tercetosCreados);

            char ultIndChar [10];
            sprintf(ultIndChar,"[%d]",ultInd);
            ultInd = crear_terceto("+", auxUltId, ultIndChar, tercetosCreados);

            // char aux_ult_asig [10]; Esto me genera una de mas, meh para assembler
            // sprintf(aux_ult_asig,"[%d]",ultInd);
            // ultInd = crear_terceto(":=", auxUltId, aux_ult_asig, tercetosCreados);
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
      char str[10]; 
      sprintf(str, "%d", $1); 
      insertar_tabla_simbolos(str, "CTE_INT", "", $1, 0.0);
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
      reemplazar_puntos_por_guion_bajo(str);
      insertar_tabla_simbolos(str, "CTE_FLOAT", "", 0, $1);
    }
;

triangulos:
           ID IGUAL TRIANG PA 
           {
              strcpy(tri_id_save,$1);
              // triangulos_id_aux = crear_terceto($1,"_","_",tercetosCreados);
              validar_ts($1, "STRING"); // Se verifica si el id que se quiere asignar esta en tabla de simbolos
              insertar_tabla_simbolos("_0.0", "CTE_FLOAT", "0", 0.0, 0); // Lo agrego por si falla alguna funcion de TS, lo voy a usar mas adelante
              insertar_tabla_simbolos("0", "CTE_INT", "0", 0, 0); // Lo agrego por si falla alguna funcion de TS, lo voy a usar mas adelante
              char str_aux_ini[40];
              char str_aux_ini_cero[40];
              auxExp_triang1 = crear_terceto("aux_exp1","_","_",tercetosCreados);
              int ini_cero = crear_terceto("0","_","_",tercetosCreados);
              sprintf(str_aux_ini,"[%d]",auxExp_triang1);
              sprintf(str_aux_ini_cero,"[%d]",ini_cero);
              crear_terceto(":=",str_aux_ini_cero,str_aux_ini,tercetosCreados);
              insertar_tabla_simbolos("aux_exp1", "FLOAT", "", 0, 0);
           }  
           expresion 
           {
            // printf("\n\n\n ************************** EXP %d ", expresionInd);
            char aux_exp_c[LONG_TERCETO];
            char aux_ind_exp[LONG_TERCETO];
            sprintf(aux_exp_c,"[%d]",auxExp_triang1);
            sprintf(aux_ind_exp,"[%d]",expresionInd);
            indTriangExp1= crear_terceto(":=",aux_ind_exp,aux_exp_c,tercetosCreados);
            auxExp_triang2 = crear_terceto("aux_exp2","_","_",tercetosCreados);
            insertar_tabla_simbolos("aux_exp2", "FLOAT", "", 0, 0);
           }
           COMA expresion // LA 2DA
           {
            sprintf(aux_exp_c2,"[%d]",auxExp_triang2);
            sprintf(aux_ind_exp2,"[%d]",expresionInd);
            indTriangExp2= crear_terceto(":=",aux_ind_exp2,aux_exp_c2,tercetosCreados);
            auxExp_triang3 = crear_terceto("aux_exp3","_","_",tercetosCreados);
            insertar_tabla_simbolos("aux_exp3", "FLOAT", "", 0, 0);
           } 
           COMA expresion // LA 3ERA
           {
            // printf("\n\n\n ************************** EXP %d ", expresionInd);
            char aux_exp_c[LONG_TERCETO];
            char aux_ind_exp[LONG_TERCETO];
            sprintf(aux_exp_c,"[%d]",auxExp_triang3);
            sprintf(aux_ind_exp,"[%d]",expresionInd);
            indTriangExp3= crear_terceto(":=",aux_ind_exp,aux_exp_c,tercetosCreados);
           } 
           PC  
           {
            // printf("\n\n\n 1: %d \n 2: %d \n 3: %d",indTriangExp1,indTriangExp2,indTriangExp3);
            char auxUno[LONG_TERCETO];
            char auxDos[LONG_TERCETO];
            char auxTres[LONG_TERCETO];
            char auxIdTriang[LONG_TERCETO];

            sprintf(auxUno,"[%d]",auxExp_triang1); //auxExp1
            sprintf(auxDos,"[%d]",auxExp_triang2); //auxExp2
            sprintf(auxTres,"[%d]",auxExp_triang3); //auxExp3
            char et_triang[25];
            // indTriang = crear_terceto("CMP",auxDos,auxUno,tercetosCreados);
            // int primerSaltoBNE = crear_terceto("BNE","_","_" ,tercetosCreados);
            // escribir_terceto_actual_en_anterior(primerSaltoBNE+7, primerSaltoBNE);  Siempre el siguente CMP va a ser en +7
            indTriang = crear_terceto("CMP",auxUno,auxDos,tercetosCreados);
            int primerSaltoBNE = crear_terceto("BNE","_","TRI_1" ,tercetosCreados);
            // escribir_terceto_actual_en_anterior(primerSaltoBNE+7, primerSaltoBNE);  Siempre el siguente CMP va a ser en +7

            indTriang = crear_terceto("CMP",auxTres,auxUno,tercetosCreados);
            // ACA HAY QUE SALTAR A ANTES DE ISOCELES
            int segundoSaltoBNE = crear_terceto("BNE","_","TRI_2" ,tercetosCreados);
            // escribir_terceto_actual_en_anterior(segundoSaltoBNE+3, segundoSaltoBNE);  Escribo a donde salta si a=b pero a!=c (isosceles)
                        
            int equi_nro =crear_terceto("\"Equilatero\"","_","_" ,tercetosCreados);

            triangulos_id_aux = crear_terceto(tri_id_save,"_","_",tercetosCreados);
            sprintf(auxIdTriang,"[%d]",triangulos_id_aux);
            
            char equi_terceto_string[50];
            sprintf(equi_terceto_string,"[%d]",equi_nro);

            crear_terceto(":=",auxIdTriang,equi_terceto_string ,tercetosCreados);

            char auxBi[LONG_TERCETO];

            sprintf(auxBi,"[%d]",tercetosCreados+6);

            crear_terceto("BI","_","FIN_TRI",tercetosCreados);

            crear_terceto("TRI_2","_","_" ,tercetosCreados);
            char iso_terceto_string[50];
            int iso_nro =crear_terceto("\"Isosceles\"","_","_" ,tercetosCreados);

            sprintf(iso_terceto_string,"[%d]",iso_nro);
            crear_terceto(":=",auxIdTriang ,iso_terceto_string ,tercetosCreados);
            sprintf(auxBi,"[%d]",tercetosCreados+4);

            crear_terceto("BI","_","FIN_TRI",tercetosCreados);
            // Salto el caso escaleno
            // Comparo a y c
            // Si son iguales tengo que volver al tecerto de isosceles, caso contrario es escaleno a!=b!=c
            // ACA ESTARIA LA PRIMERA ET
            crear_terceto("TRI_1","_","_" ,tercetosCreados);
            // indTriang = crear_terceto("CMP",auxTres,auxUno,tercetosCreados);
            sprintf(auxBi,"[%d]",tercetosCreados-3);
            crear_terceto("BE","_","TRI_2" ,tercetosCreados); // En caso de que sea igual eso indicaria que es isosceles
            
            
            char esca_terceto_string[50];
            int esca_nro =crear_terceto("\"Escaleno\"","_","_" ,tercetosCreados);

            sprintf(esca_terceto_string,"[%d]",esca_nro);
            
            crear_terceto(":=",auxIdTriang,esca_terceto_string ,tercetosCreados); // En caso contrario son todos distintos entonces es escaleno
            crear_terceto("FIN_TRI","_","_" ,tercetosCreados);
            
            insertar_tabla_simbolos("_Escaleno", "CTE_STR", "\"Escaleno\"", 0, 0.0);
            insertar_tabla_simbolos("_Isosceles", "CTE_STR", "\"Isosceles\"", 0, 0.0);
            insertar_tabla_simbolos("_Equilatero", "CTE_STR","\"Equilatero\"", 0, 0.0);

            printf("ES TRIANGULOS\n");
           }
;
%%

//////////////////////////////////// FUNCIONES ////////////////////////////////////////////////

/**************
**** MAIN *****
***************/

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
        pilaComparacion = crear_pila();
        pilaNroTerceto = crear_pila();
        pilaSumarUltimos = crear_pila();

        crear_cola(&colaTercetos);
        
        yyparse();
             
        //Generacion de intermedia
        abrir_archivo_intermedia();
        escribir_tercetos_intermedia();
        fclose(fpIntermedia);

        //Assembler
        generar_assembler();
        liberar_memoria_tabla_simbolos();
  }
  fclose(yyin);
  return 0;
}

/***************************
**** FUNCIONES ERRORES *****
****************************/

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

/***************************
**** TABLA DE SIMBOLOS *****
****************************/

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
      if(strcmp(tabla->data.nombre, nombre) == 0)
      {
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
      if(strcmp(tabla->data.nombre, nombre) == 0)
      {
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

char* validar_ts(const char *nombre,const char *tipo)
{    

  t_simbolo *tabla = tabla_simbolos.primero;

  while(tabla)
  { 
      if(strcmp(tabla->data.nombre, nombre) == 0)
      {
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

char* validar_ts_int_o_float(const char *nombre)
{    

  t_simbolo *tabla = tabla_simbolos.primero;

  while(tabla)
  { 
      if(strcmp(tabla->data.nombre, nombre) == 0)
      {
          if(strcmp(tabla->data.tipo,"STRING") == 0 )
          {
            printf("La variable %s no es de tipo entero o float, el comando ultimos espera ser asignado a un float o entero ", nombre);
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

const char * check_tipo_variable_ts(const char *nombre)
{    

  t_simbolo *tabla = tabla_simbolos.primero;

  while(tabla)
  { 
      if(strcmp(tabla->data.nombre, nombre) == 0)
      {
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

int check_es_cte_columna_valor(const char *nombre)
{
  t_simbolo *tabla = tabla_simbolos.primero;
  while(tabla)
  { 
      if(tabla->data.valor.valor_var_str != NULL && strcmp(tabla->data.valor.valor_var_str, nombre) == 0)
      {
          return TRUE;
      }    
      if(tabla->next == NULL)
      {
        break;
      }
      tabla = tabla->next;
  }
  return FALSE;
} 

int check_es_cte_string_o_string_ts(const char *nombre)
{
  t_simbolo *tabla = tabla_simbolos.primero;
  while(tabla)
  { 
      if(strcmp(tabla->data.nombre, nombre) == 0 
      && (strcmp(tabla->data.tipo, "STRING") == 0 || strcmp(tabla->data.tipo, "CTE_STRING") == 0 ))
      {
          return TRUE;
      }    
      if(tabla->next == NULL)
      {
        break;
      }
      tabla = tabla->next;
  }
  return FALSE;
} 

const char * check_es_cte(const char *nombre)
{    

  t_simbolo *tabla = tabla_simbolos.primero;
  while(tabla)
  { 
      if(strcmp(tabla->data.nombre, nombre) == 0)
      {
          return tabla->data.nombre;
      }    
      if(tabla->next == NULL)
      {
        break;
      }
      tabla = tabla->next;
  }
  sprintf(check_es_cte_aux, "_%s", nombre);
  return check_es_cte_aux;
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
    {        
      return;
    }
    fprintf(arch, "%-30s%-30s%-40s%-30s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");

    t_simbolo *aux;
    t_simbolo *tabla = tabla_simbolos.primero;
    char linea[200];
    char full[40] = "_";
    int vino_cero = 0;
    while(tabla)
    {
        aux = tabla;
        // if(aux->next == NULL)
        // {
        //   break;
        // }
        tabla = tabla->next;
        // printf("vino guardando ts -%s-",aux->data.nombre); revisar 57
        // getchar();
        if(strcmp(aux->data.tipo, "INTEGER") == 0) 
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_INT") == 0)
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_var_str, aux->data.valor.valor_var_int);
        }
        else if(strcmp(aux->data.tipo, "FLOAT") ==0)
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_FLOAT") == 0)
        {
          reemplazar_puntos_por_guion_bajo(aux->data.nombre);
          if(strcmp(aux->data.valor.valor_var_str,"0.00")==0)
          {
            strcpy(aux->data.valor.valor_var_str,"0.0");
            if(vino_cero==0)
            {
              sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_var_str, aux->data.valor.valor_var_str);                              
            }
            vino_cero=1; // se puede mejorar
          }
          else
          {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, aux->data.valor.valor_var_str, aux->data.valor.valor_var_str);                              
          }
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0)
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_STR") == 0)
        {
            memset(aux_string, 0 , sizeof(aux_string));
            strncpy(aux_string, aux->data.valor.valor_var_str +1, strlen(aux->data.valor.valor_var_str)-2);
            char resultado[50]; 
            sprintf(resultado, "_%s", aux_string);
            reemplazar_puntos_por_guion_bajo(resultado);
            sprintf(linea, "%-30s%-30s%-40s%-d\n", resultado, aux->data.tipo, aux_string, strlen(aux_string));
        }
        fprintf(arch, "%s", linea);
        // free(aux); me conviene tener la tabla de simbolos en memoria para despues
    }
    fclose(arch); 
}

void liberar_memoria_tabla_simbolos()
{
    if(tabla_simbolos.primero == NULL)
    {        
      return;
    }

    t_simbolo *aux;
    t_simbolo *tabla = tabla_simbolos.primero;

    while(tabla)
    {
        aux = tabla;
        tabla = tabla->next;
        free(aux); 
    }
}

void crear_tabla_simbolos()
{
    tabla_simbolos.primero = NULL;
}

/*****************
**** HELPERS *****
******************/

char* agregar_corchetes(const char* cadena) 
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

void sacar_comillas_dobles(char *str) 
{
    int len = strlen(str);

    if (len >= 2 && str[0] == '"' && str[len - 1] == '"') 
    {
        memmove(str, str + 1, len - 1);
        str[len - 2] = '\0';
    }
}

void reemplazar_puntos_por_guion_bajo(char* str) 
{
    int i;
    for (i = 0; i < strlen(str); i++) 
    {
        if (str[i] == '.') 
        {
            str[i] = '_';
        }
    }
}
/*******************
**** ASSEMBLER *****
********************/

void generar_assembler()
{
    FILE* file_intermediate_code;
    FILE* file_symbol_table;
    FILE* file_assembler;
    file_intermediate_code = fopen("intermediate-code.txt","rt");
    file_symbol_table = fopen("symbol-table.txt","rt");
    file_assembler = fopen("final.asm","wt");
    
    if(!file_assembler)
    {
        printf("Error en el archivo de assembler");
        return;
    }
    if(!file_symbol_table)
    {
        printf("Error en la apertura de la tabla de simbolos");
        return;
    }
    if(!file_intermediate_code)
    {
        printf("Error en la apertura del archivo intermedia");
        return;
    }

    Pila p_ass;
    Pila p_while;
    crear_pila(&p_ass);
    crear_pila(&p_while);
    fprintf(file_assembler,  "include macros2.asm\n");
    fprintf(file_assembler,  "include number.asm\n");
    fprintf(file_assembler, ".MODEL LARGE\n.STACK 200h\n.386\n.DATA\nMAXTEXTSIZE equ 200\n\n");
    char linea[1000];
    fgets(linea, sizeof(linea), file_symbol_table); // Skipeo el encabezado
    while(fgets(linea, sizeof(linea),file_symbol_table))
    {
        char nombre[30];
        char tipo[30];
        char valor[40];
        char longitud[30];
        strncpy(nombre, linea, 30);
        trim_end(nombre);        

        strncpy(tipo, linea + 30, 30);
        trim_end(tipo);

        strncpy(valor, linea + 60, 40);
        trim_end(valor); // TODO: cadenas tipo "hola como estas" check

        strncpy(longitud, linea + 100, 10);
        trim_end(longitud);
        char valor_ant[50];
        // printf("\nDATO: Nombre ***** %s ***** \n",nombre);
        // printf("\nDATO: Tipo ***** %s ***** \n",tipo);
        // printf("\nDATO: ***** Valor ***** %s ***** \n",valor);
        // printf("\nDATO: ***** LONGITUD ***** %s ***** \n",longitud);

        if(strcmp(tipo,"CTE_STR") == 0)
        {
          if(valor[0] =='-')
          {
              valor[0] = '?';
              valor[1] = '\0';   
          }
          fprintf(file_assembler,"%-20s db\t\t \"%s\", \'$\', %s dup (?)\n",nombre,valor,longitud);
        }
        else
        {
            if(strcmp(tipo,"CTE_FLOAT")==0 || strcmp(tipo,"CTE_INT")==0)
            {
                if( strlen(valor)>1 && valor[0] =='-')
                {
                    valor[0] = '?';
                    valor[1] = '\0';
                }
                if(strcmp(tipo,"CTE_FLOAT")==0 && strcmp(valor,"0.00")==0)
                {
                    strcpy(valor,"0.0");
                }
                // printf("valor %s valor ant %s",valor,valor_ant);
                // getchar();
                if(strcmp(valor,valor_ant) != 0 )
                {
                  fprintf(file_assembler,"%-20s dd\t\t %-30s\n",nombre,valor);
                }
                strcpy(valor_ant,valor); // revisar estos casos, con esto zafa pero debe haber alguna mejor manera
            }
            else
            {
                if( strlen(valor)>1 && valor[0] =='-')
                {
                    valor[0] = '?';
                    valor[1] = '\0';
                }
                fprintf(file_assembler,"%-20s dd\t\t ?\n",nombre,valor);
            }
        }
    }
    
    fprintf(file_assembler, "\n.CODE");
    
    fprintf(file_assembler, "\nstrlen proc\n");
    fprintf(file_assembler, "\tmov bx, 0\n");
    fprintf(file_assembler, "\tstrLoop:\n");
    fprintf(file_assembler, "\t\tcmp BYTE PTR [si+bx],'$'\n");
    fprintf(file_assembler, "\t\tje strend\n");
    fprintf(file_assembler, "\t\tinc bx\n");
    fprintf(file_assembler, "\t\tjmp strLoop\n");
    fprintf(file_assembler, "\tstrend:\n");
    fprintf(file_assembler, "\t\tret\n");
    fprintf(file_assembler, "strlen endp\n");
    fprintf(file_assembler, "assignString proc\n");
    fprintf(file_assembler, "\tcall strlen\n");
    fprintf(file_assembler, "\tcmp bx , MAXTEXTSIZE\n");
    fprintf(file_assembler, "\tjle assignStringSizeOk\n");
    fprintf(file_assembler, "\tmov bx , MAXTEXTSIZE\n");
    fprintf(file_assembler, "\tassignStringSizeOk:\n");
    fprintf(file_assembler, "\tmov cx , bx\n");
    fprintf(file_assembler, "\tcld\n");
    fprintf(file_assembler, "\trep movsb\n");
    fprintf(file_assembler, "\tmov al , '$'\n");
    fprintf(file_assembler, "\tmov byte ptr[di],al\n");
    fprintf(file_assembler, "\tret\n");
    fprintf(file_assembler, "assignString endp\n");

    fprintf(file_assembler,  "\nSTART:\n");
    fprintf(file_assembler,  "\n\tMOV EAX,@DATA");
    fprintf(file_assembler,  "\n\tMOV DS,EAX");
    fprintf(file_assembler,  "\n\tMOV ES,EAX\n\n");

    char st[40];
    int operacion = 0;
    char et[10];
    Diccionario dic;
    inicializar_diccionario(&dic);
    while(fgets(linea, sizeof(linea),file_intermediate_code))
    {
      char numTerceto[40];
      char posUno[40];
      char posDos[40];
      char posTres[40];
      char aux_check_operador[50]; 
      printf("Linea de intermedia %s\n",linea);
      sscanf(linea, "%s ( %s ; %s ; %s )", numTerceto, posUno, posDos, posTres);
      if( strncmp(posUno,"CMP",4) != 0  && (posDos[0]  == '_')  &&  (posTres[0] == '_') 
      && strncmp(posUno,"TRI",3) != 0 && strncmp(posUno,"FIN_TRI",7) != 0 && strncmp(posUno,"ET",2) != 0 )
      {
        char numTercetoSinC[10];
        eliminar_corchetes(numTerceto,numTercetoSinC);
        // reemplazar_puntos_por_guion_bajo(posUno);
        agregar_entrada(&dic,posUno,atoi(numTercetoSinC));
        apilar(&p_ass, posUno, sizeof(posUno));
      }
      if(strcmp(":=",posUno) == 0 )
      {
        if(!es_pila_vacia(&p_ass))
        {
            strcpy(st, desapilar(&p_ass));
        }
        else
        {
            char numTercetoSinC[10];
            eliminar_corchetes(posDos,numTercetoSinC);
            strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
        }
        if(st[0]=='\"' || check_es_cte_string_o_string_ts(st)) // ENTONCES TENGO QUE ASIGNAR UN STRING
        {
          char op1[15];
          char op2[15];
          char var1[15];
          char var2[15];

          eliminar_corchetes(posDos,op1);
          strcpy(var1,buscar_nombre(&dic,atoi(op1)));
          eliminar_corchetes(posTres,op2);
          strcpy(var2,buscar_nombre(&dic,atoi(op2)));
          sacar_comillas_dobles(var1);
          sacar_comillas_dobles(var2);
          fprintf(file_assembler,"\tMOV si, OFFSET _%s\n",var2);// cte
          fprintf(file_assembler,"\tMOV di, OFFSET %s\n",var1); // var
          fprintf(file_assembler,"\tCALL assignString\n");
        }
        else // no es string uso assembler comun
        {
          if(operacion == 0)
          {
            strcpy(aux_check_operador, check_es_cte(st));
            reemplazar_puntos_por_guion_bajo(aux_check_operador);
            fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);  
            if(!es_pila_vacia(&p_ass))
            {
                strcpy(st, desapilar(&p_ass));
            }
            else
            {
                char numTercetoSinC[10];
                eliminar_corchetes(posTres,numTercetoSinC);
                strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
            }
          }
          strcpy(aux_check_operador, check_es_cte(st));
          reemplazar_puntos_por_guion_bajo(aux_check_operador);
          fprintf(file_assembler,"\tFSTP %s\n",aux_check_operador);  
          operacion = 0; 
        }
      }
      if(strcmp("+",posUno) == 0 )
      {
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posDos,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }
          strcpy(aux_check_operador, check_es_cte(st)); 
          reemplazar_puntos_por_guion_bajo(aux_check_operador);
          fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posTres,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }
          strcpy(aux_check_operador, check_es_cte(st));  
          reemplazar_puntos_por_guion_bajo(aux_check_operador);
          fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);
          fprintf(file_assembler,"\tFADD\n");
          operacion = 1;
      }
      if(strcmp("-",posUno) == 0 )
      {
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posDos,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }
          strcpy(aux_check_operador, check_es_cte(st));
          reemplazar_puntos_por_guion_bajo(aux_check_operador); 
          fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posTres,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }
          strcpy(aux_check_operador, check_es_cte(st)); 
          reemplazar_puntos_por_guion_bajo(aux_check_operador);          
          fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);
          fprintf(file_assembler,"\tFSUB\n");
          operacion = 1;
      }
      if(strcmp("/",posUno) == 0 )
      {
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posDos,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          } 
          strcpy(aux_check_operador, check_es_cte(st));     
          reemplazar_puntos_por_guion_bajo(aux_check_operador);    
          fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posTres,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }  
          strcpy(aux_check_operador, check_es_cte(st));
          reemplazar_puntos_por_guion_bajo(aux_check_operador);      
          fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);
          fprintf(file_assembler,"\tFDIV\n");
          operacion = 1;
      }
      if(strcmp("*",posUno) == 0 )
      {
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posDos,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }
          strcpy(aux_check_operador, check_es_cte(st));
          reemplazar_puntos_por_guion_bajo(aux_check_operador);      
          fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posTres,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }
          strcpy(aux_check_operador, check_es_cte(st));
          reemplazar_puntos_por_guion_bajo(aux_check_operador);      
          fprintf(file_assembler,"\tFLD %s\n",aux_check_operador);
          fprintf(file_assembler,"\tFMUL\n");
          operacion = 1;
      }
      if(strcmp("CMP",posUno) == 0 ) 
      {
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
              char numTercetoSinC[10];
              eliminar_corchetes(posDos,numTercetoSinC);
              strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }
          strcpy(aux_check_operador, check_es_cte(st));
          char comp_aux_der[15];
          reemplazar_puntos_por_guion_bajo(aux_check_operador);      
          sprintf(comp_aux_der,"\tFLD %s\n",aux_check_operador);
          if(!es_pila_vacia(&p_ass))
          {
              strcpy(st, desapilar(&p_ass));
          }
          else
          {
            char numTercetoSinC[10];
            eliminar_corchetes(posTres,numTercetoSinC); // creo que seria mejor el pos3
            strcpy(st,buscar_nombre(&dic,atoi(numTercetoSinC)));
          }      
          strcpy(aux_check_operador, check_es_cte(st));
          char comp_aux_izq[15];
          reemplazar_puntos_por_guion_bajo(aux_check_operador);      
          sprintf(comp_aux_izq,"\tFLD %s\n",aux_check_operador); 
          fprintf(file_assembler,"%s",comp_aux_izq);
          fprintf(file_assembler,"%s",comp_aux_der);
          fprintf(file_assembler,"\tFXCH\n"); 
          fprintf(file_assembler,"\tFCOM\n");
          fprintf(file_assembler,"\tFSTSW AX\n");
          fprintf(file_assembler,"\tSAHF\n");
      }
      if(strcmp ("BLE",posUno)==0) 
      {
        sscanf(posTres,"%[^ ]",et);
        fprintf(file_assembler,"\tJNA %s\n",et);
      }
      if(strcmp ("BNE",posUno)==0)
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(file_assembler,"\tJNE %s\n",et);
      }
      if(strcmp ("BLT",posUno)==0) 
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(file_assembler,"\tJB %s\n",et);
      }
      if(strcmp ("BGT",posUno)==0) 
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(file_assembler,"\tJA %s\n",et);
      }
      if(strcmp ("BGE",posUno)==0) 
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(file_assembler,"\tJAE %s\n",et);
      }
      if(strcmp ("BEQ",posUno)==0) 
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(file_assembler,"\tJE %s\n",et);
      }
      if(strcmp("BI", posUno) == 0)
      {
          sscanf(posTres,"%[^ ]",et);
          fprintf(file_assembler,"\tJMP %s\n",et);
      }
      if(strncmp(posUno,"ETIQ_IF",7) == 0 )
      {
          fprintf(file_assembler,"%s:\n",posUno);
      }
      if(strncmp(posUno,"InicioMientras",14) == 0 )
      {
          fprintf(file_assembler,"%s:\n",posUno);
      }
      if(strncmp(posUno,"ETIQ_CICLO",7) == 0 )
      {
          fprintf(file_assembler,"%s:\n",posUno);
          fprintf(file_assembler,"FFREE\n");
      }
      if(strncmp(posUno,"TRI",3) == 0 )
      {
          fprintf(file_assembler,"%s:\n",posUno);
      }
      if(strncmp(posUno,"FIN_TRI",3) == 0 )
      {
          fprintf(file_assembler,"%s:\n",posUno);
      }
      if(strncmp(posUno,"CUERPO",6) == 0 )
      {
          fprintf(file_assembler,"%s:\n",posUno);
      }
       if(strncmp(posUno,"ET_LEER",7) == 0 )
      {
        char tipo_id_aux_factor[15];
        strcpy(tipo_id_aux_factor,check_tipo_variable_ts(posDos));
        if(strcmp("INTEGER" , tipo_id_aux_factor) == 0)
        {
          fprintf(file_assembler,"\tGetInteger %s\n",posDos);
        }
        else if(strcmp("FLOAT" , tipo_id_aux_factor) == 0)
        {
          fprintf(file_assembler,"\tGetFloat %s\n",posDos);
        }
        else if(strcmp("STRING" , tipo_id_aux_factor) == 0)
        {
          fprintf(file_assembler,"\tgetString %s\n",posDos);
        }
        fprintf(file_assembler,"%s:\n",posUno);
      }
      if(strncmp(posUno,"ET_ESCRIBIR",11) == 0 )
      {
        if(check_es_cte_columna_valor(posDos) == TRUE)
        {
          char aux_valor[50];
          strcpy(aux_valor,posDos);
          aux_valor[0] = '_';
          aux_valor[strlen(aux_valor)-1] = '\0';
          fprintf(file_assembler,"\tdisplayString %s\n",aux_valor);
        }
        else // es id
        { 
          char aux_valor[50];
          strcpy(aux_valor,check_tipo_variable_ts(posDos));
          if(strcmp("INTEGER",aux_valor)==0)
          {
            fprintf(file_assembler,"\tDisplayInteger %s\n",posDos);
          }
          else if(strcmp("FLOAT",aux_valor)==0)
          {
            fprintf(file_assembler,"\tDisplayFloat %s\n",posDos);
          }
          else if(strcmp("STRING",aux_valor)==0)
          {
            fprintf(file_assembler,"\tdisplayString %s\n",posDos);
          }
        }
        fprintf(file_assembler,"\tnewLine 1\n");

      }
    }
    fprintf(file_assembler,"\nFFREE");
    fprintf(file_assembler,"\nmov ax,4c00h");
    fprintf(file_assembler,"\nint 21h");
    fprintf(file_assembler,"\nEnd START");
    fclose(file_intermediate_code);
    fclose(file_symbol_table);
    fclose(file_assembler);
}

void trim_end(char * str)
{
    int index, i;
    index = -1;
    i = 0;
    while(isalpha(str[i]) || str[i] == '_' || isalnum(str[i]) || str[i] == '.' )
    {
        if(str[i] != ' ' && str[i] != '\t' && str[i] != '\n')
        {
            index= i;
        }
        i++;
    }
    str[index + 1] = '\0';
}

void escribir_terceto_actual_en_anterior_con_tag(int tercetoAEscribir,int tercetoBuscado,char * etiqueta)
{
    t_cola  aux;
    crear_cola(&aux);
    t_Terceto terceto;
    while(!cola_vacia(&colaTercetos))
    {
        sacar_de_cola(&colaTercetos,&terceto,sizeof(terceto));
        if(terceto.numTerceto == tercetoBuscado)
        {
            int flag = 0;
            if(eraOr == 1)
            {
                if(strcmp ("BNE",terceto.posUno)==0 && flag != 1) 
                {
                  flag = 1;
                  strcpy(terceto.posUno, "BEQ\0");              
                }                        
                if(strcmp ("BLT",terceto.posUno)==0 && flag != 1) 
                {
                  flag = 1;
                  strcpy(terceto.posUno, "BGE\0");        
                }
                if(strcmp ("BLE",terceto.posUno)==0  && flag != 1) 
                {
                  strcpy(terceto.posUno, "BGT\0");        
                  flag = 1;
                }
                if(strcmp ("BGT",terceto.posUno)==0  && flag != 1) 
                {
                  strcpy(terceto.posUno, "BLE\0");        
                  flag = 1;
                }       
                if(strcmp ("BGE",terceto.posUno)==0  && flag != 1) 
                {
                  strcpy(terceto.posUno, "BLT\0"); 
                  flag = 1;                                  
                }
                if(strcmp ("BEQ",terceto.posUno)==0  && flag != 1) 
                {
                  strcpy(terceto.posUno, "BNE\0");
                  flag = 1;                                
                }
            }
            char nueComponente [LONG_TERCETO];
            sprintf( nueComponente, "%s%d",etiqueta,tercetoAEscribir);
            strcpy(terceto.posTres, nueComponente);
        }
        poner_en_cola(&aux,&terceto,sizeof(terceto));
    }
    colaTercetos=aux;
}