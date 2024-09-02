%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <string.h>
#include <math.h>
int yystopparser=0;
FILE  *yyin;

  int yyerror();
  int yylex();

/* --- Tabla de simbolos --- */
typedef struct
{
        char *nombre;
        char *tipo;
        union Valor{
                int valor_int;
                double valor_double;
                char *valor_str;
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


void crearTablaTS();
int insertarTS(const char*, const char*, const char*, int, double);
t_data* crearDatos(const char*, const char*, const char*, int, double);
void guardarTS();
t_tabla tablaTS;

int cantid = 0;
char mensajes[100];

typedef struct{
  char cadena[40];
}t_nombresId;

t_nombresId t_ids[10];
int i=0;

char tipo_dato[10];

char nombre_id[20];
int constante_aux_int;
float constante_aux_float;
char constante_aux_string[40];
char aux_string[40];


%}

%union {
int tipo_int;
double tipo_double;
char *tipo_str;
}

%start programa
%token <tipo_str>ID
%token <tipo_int>CTE_INT
%token <tipo_double>CTE_FLOAT
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

// TODO: validar tipos de datos
// TODO: ver como guardar tabla simbolos

programa: instrucciones{
  guardarTS();
  printf(" FIN\n");
}
;

instrucciones: 
            sentencia {printf(" INSTRUCCIONES ES SENTENCIA\n");}
          | instrucciones sentencia 
;

sentencia:  	   
	asignacion {printf("ASIGNACION\n");}
  | bloque_asig {printf(" BLOQUE ASIG\n");} 
  | mientras {printf("MIENTRAS\n");} 
  | si {printf("SI\n");} 
  | leer {printf("LEER\n");}
  | escribir {printf("ESCRIBIR\n");}
  | triangulos {printf("TRIANGULOS\n");}
  | ultimos {printf("SUMAR ULTIMOS\n");}
	;

si: 
  IF PA condicion PC LA instrucciones LC {printf("ES CONDICION\n");}
  | IF PA condicion PC LA instrucciones LC ELSE LA instrucciones LC {printf("ES CONDICION SINO \n");}
;

bloque_asig:
INIT LA lista_asignacion LC {printf("BLOQUE ASIGNACION\n");}
;

lista_asignacion : 
          lista_variables asig_tipo {
                  for(i=0;i<cantid;i++)
													{
														if(insertarTS(t_ids[i].cadena, tipo_dato, "", 0, 0) != 0) //solo se guarda la primer ocurrencia
														{
															sprintf(mensajes, "%s%s%s", "Error: la variable '", t_ids[i].cadena, "' ya fue declarada");
															yyerror();
														}
													}
													cantid=0;
          }
          | lista_asignacion lista_variables asig_tipo{
            for(i=0;i<cantid;i++)
													{
														if(insertarTS(t_ids[i].cadena, tipo_dato, "", 0, 0) != 0)
														{
															sprintf(mensajes, "%s%s%s", "Error: la variable '", t_ids[i].cadena, "' ya fue declarada");
															yyerror();
														}
													}
													cantid=0;
          }
;

lista_variables: lista_variables COMA ID {
                    printf("ES UNA LISTA DE VARIABLES\n");
                    strcpy(t_ids[cantid].cadena,$3);
                    cantid++;
                }
                 | ID {
                    printf("ES UNA VARIABLE\n");
                    strcpy(t_ids[cantid].cadena,$1);
                    cantid++;
                 }

asig_tipo: 
      DP TIPO_S{
        strcpy(tipo_dato,"STRING");
      }
    | DP TIPO_F{
        strcpy(tipo_dato,"FLOAT");
      } 
    | DP TIPO_I{
        strcpy(tipo_dato,"INTEGER");
    }
;

asignacion: 
    id OP_AS expresion {
        printf("    ID = Expresion es ASIGNACION\n");
      }
	  ;

id:
  ID{
        strcpy(nombre_id,$1);
  }
;

// TO-DO REVISAR

expresion:
   termino {printf("Termino es Expresion\n");}
	 | expresion OP_SUM termino {printf("    Expresion+Termino es Expresion\n");}
	 | expresion OP_RES termino {printf("    Expresion-Termino es Expresion\n");}
	 ;
   
mientras:
  WHILE PA condicion PC LA instrucciones LC {
    printf("ES UN MIENTRAS\n");
  }
;

condicion:
  OP_NOT comparacion
  | condicion OP_OR comparacion 
  | condicion OP_AND comparacion 
  | comparacion
;

comparacion: 
    expresion operador_comparacion expresion 
    | PA condicion PC
    ;

operador_comparacion:
  OP_MAYOR 
  | OP_MAYORI 
  | OP_MEN 
  | OP_MENI 
  | OP_IGUAL 
  | OP_NOT_IGUAL
;

termino: 
       factor {printf("Factor es Termino\n");}
       |termino OP_MUL factor {printf("Termino*Factor es Termino\n");}
       |termino OP_DIV factor {printf("Termino/Factor es Termino\n");}
       ;

factor: 
      ID {
        printf("ID es Factor \n");
      }
      | CTE_STRING {
        printf("ES CONSTANTE STRING\n");
        strcpy(constante_aux_string,$1);
        if(insertarTS(nombre_id, "CTE_STR", $1, 0, 0.0) != 0) //solo se guarda la primer ocurrencia
				{
					sprintf(mensajes, "%s%s%s", "Error: la variable '", t_ids[i].cadena, "' ya fue declarada");
					yyerror();
				}
      }
      | CTE_INT {
        printf("ES CONSTANTE INT\n");
        constante_aux_int=$1;
        if(insertarTS(nombre_id, "CTE_INT", "", $1, 0.0) != 0) //solo se guarda la primer ocurrencia
				{
					sprintf(mensajes, "%s%s%s", "Error: la variable '", t_ids[i].cadena, "' ya fue declarada");
					yyerror();
				}
      }
      | CTE_FLOAT {
        printf("ES CONSTANTE FLOAT\n");
        constante_aux_float=$1;
        if(insertarTS(nombre_id, "CTE_FLOAT", "", 0, $1) != 0) //solo se guarda la primer ocurrencia
				{
					sprintf(mensajes, "%s%s%s", "Error: la variable '", t_ids[i].cadena, "' ya fue declarada");
					yyerror();
				}
      }
	    | PA expresion PC {printf("Expresion entre parentesis es Factor\n");}
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
        crearTablaTS();
        yyparse();
        
    }
	fclose(yyin);
        return 0;
}
int yyerror(void)
     {
       printf("Error Sintactico\n");
	 exit (1);
     }

int insertarTS(const char *nombre,const char *tipo, const char* valString, int valInt, double valDouble)
{
    t_simbolo *tabla = tablaTS.primero;
    char nombreCTE[32] = "_";
    strcat(nombreCTE, nombre);
    
    while(tabla)
    {
	if(strcmp(tabla->data.nombre, nombre) == 0 || strcmp(tabla->data.nombre, nombreCTE) == 0)
    {
            return 1;
    }
        else if(strcmp(tabla->data.tipo, "CTE_STR") == 0)
        {
            if(strcmp(tabla->data.valor.valor_str, valString) == 0)
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
    data = crearDatos(nombre, tipo, valString, valInt, valDouble);
    
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

    if(tablaTS.primero == NULL)
    {
        tablaTS.primero = nuevo;
    }
    else
    {
        tabla->next = nuevo;
    }

    return 0;
}


t_data* crearDatos(const char *nombre, const char *tipo, const char* valString, int valInt, double valDouble)
{
    char full[50] = "_";
    char aux[20];

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
            data->valor.valor_str = (char*)malloc(sizeof(char) * strlen(valString) +1);
            data->nombre = (char*)malloc(sizeof(char) * (strlen(valString) + 1));
            strcat(full, nombre);
            strcpy(data->nombre, full);    
            strcpy(data->valor.valor_str, valString);
        }
        if(strcmp(tipo, "CTE_FLOAT") == 0)
        {
            sprintf(aux, "%s", nombre);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));

            strcpy(data->nombre, full);
            data->valor.valor_double = valDouble;
        }
        if(strcmp(tipo, "CTE_INT") == 0)
        {
            sprintf(aux, "%s", nombre);
            strcat(full, aux);
            data->nombre = (char*)malloc(sizeof(char) * strlen(full));
            strcpy(data->nombre, full);
            data->valor.valor_int = valInt;
        }
        return data;
    }
    return NULL;
}

void guardarTS()
{
    FILE* arch;
    if((arch = fopen("ts.txt", "wt")) == NULL)
    {
            printf("\nNo se pudo crear la tabla de simbolos.\n\n");
            return;
    }
    else if(tablaTS.primero == NULL)
            return;
    
    fprintf(arch, "%-30s%-30s%-40s%-30s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");

    t_simbolo *aux;
    t_simbolo *tabla = tablaTS.primero;
    char linea[100];

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
            sprintf(linea, "%-30s%-30s%-40d%s\n", aux->data.nombre, "", aux->data.valor.valor_int, "");
        }
        else if(strcmp(aux->data.tipo, "FLOAT") ==0)
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_FLOAT") == 0)
        {
            sprintf(linea, "%-30s%-30s%-40f%s\n", aux->data.nombre, "", aux->data.valor.valor_double, "");
        }
        else if(strcmp(aux->data.tipo, "STRING") == 0)
        {
            sprintf(linea, "%-30s%-30s%-40s%s\n", aux->data.nombre, aux->data.tipo, "--", "");
        }
        else if(strcmp(aux->data.tipo, "CTE_STR") == 0)
        {
            strncpy(aux_string, aux->data.valor.valor_str + 1, strlen(aux->data.valor.valor_str)-2);
            sprintf(linea, "%-30s%-30s%-40s%-d\n", aux->data.nombre, "", aux_string, strlen(aux->data.valor.valor_str) -2);
        }
        fprintf(arch, "%s", linea);
        free(aux);
    }
    fclose(arch); 
}

void crearTablaTS()
{
    tablaTS.primero = NULL;
}