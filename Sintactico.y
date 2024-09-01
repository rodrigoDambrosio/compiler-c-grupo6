// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

  int yyerror();
  int yylex();


%}

%token CTE
%token ID
%token OP_AS
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
%token PA
%token PC
%token LA
%token LC
%token CTE_STRING
%token CTE_FLOAT
%token CTE_INT
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

programa: instrucciones
;

instrucciones: sentencia 
               | instrucciones sentencia
;

sentencia:  	   
	asignacion {printf(" FIN\n");} 
  | bloque_asig {printf(" BLOQUE ASIG\n");} 
  | mientras {printf("MIENTRAS\n");} 
  | si {printf("SI\n");} 
  | leer 
  | escribir 
  | triangulos 
  | ultimos
	;



si: 
  IF PA condicion PC LA programa LC 
  | IF PA condicion PC LA programa LC ELSE LA programa LC;
;

bloque_asig:
INIT LA lista_asignacion LC {printf("    BLOQUE VAR\n");}
;

lista_asignacion : lista_variables asig_tipo 
                   | lista_asignacion lista_variables asig_tipo
;

lista_variables: lista_variables COMA ID
                 | ID

asig_tipo: DP TIPO_S | DP TIPO_F | DP TIPO_I
;

asignacion: 
    ID OP_AS expresion {printf("    ID = Expresion es ASIGNACION\n");}
	  ;

expresion:
   termino {printf("    Termino es Expresion\n");}
	 | expresion OP_SUM termino {printf("    Expresion+Termino es Expresion\n");}
	 | expresion OP_RES termino {printf("    Expresion-Termino es Expresion\n");}
	 ;
   
mientras:
  WHILE PA condicion PC LA programa LC
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
       factor {printf("    Factor es Termino\n");}
       |termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
       |termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
       ;

factor: 
      ID {printf("    ID es Factor \n");}
      | CTE_STRING
      | CTE {printf("    CTE es Factor\n");}
      | CTE_INT
      | CTE_FLOAT
	    | PA expresion PC {printf("    Expresion entre parentesis es Factor\n");}
     	;

leer : 
     LEER PA ID PC
;

escribir:
    ESCRIBIR PA CTE_STRING PC 
    | ESCRIBIR PA ID PC

ultimos: 
    ID IGUAL SUM_ULT PA CTE_INT PTO_COMA CA lista_num CC PC
;

lista_num: lista_num COMA num 
           | num
;

num: CTE_INT | CTE_FLOAT 
  ;

triangulos:
ID IGUAL TRIANG PA expresion COMA expresion COMA expresion PC
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

