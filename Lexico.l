%{
#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);

%}

%option noyywrap  
%option yylineno 

WHILE       "mientras"
IF          "si"
ELSE        "sino"
INIT        "init"
TIPO_F      "Float"
TIPO_I      "Int"
TIPO_S      "String"
LEER        "leer"
ESCRIBIR    "escribir"
SUM_ULT     "sumaLosUltimos"
TRIANG      "triangulo"

DIGITO			[0-9]
LETRA			[a-zA-Z]

CTE		        {DIGITO}+
CONS_STR  		\"({LETRA}|{DIGITO})({LETRA}|{DIGITO}|" ")\"
CONS_FLOAT 		{DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}*
CONS_INT  		{DIGITO}+
ID			{LETRA}({LETRA}|{DIGITO})*
OP_AS   		":""="
OP_SUM		        "+"
OP_MUL                  "*"
OP_RES		        "-"
OP_DIV                  "/"
PA			"("
PC			")"
DP          ":"
LA          "{"
LC          "}"
COMENTARIO  "*-"(.*?)"-*"
OP_MAYOR    ">"
OP_MEN      "<"  
OP_MAYORI    ">="
OP_MENI      "<="   
OP_AND       "AND"
OP_OR        "OR"
OP_NOT       "NOT"
CA           "["
CC           "]"
%%

{CTE}			{printf("\nConstante: %s\n", yytext);return CTE;}
{ID}			{printf("\nIdentificador: %s\n", yytext);return ID;}
{OP_SUM}		{printf("\nSuma: %s\n", yytext);return OP_SUM;}
{OP_AS}			{printf("\nAsignacion: %s\n", yytext);return OP_AS;}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		{printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);return OP_DIV;}
{PA}			{printf("\nParAbre: %s\n", yytext);return PA;}
{PC}			{printf("\nParCierra: %s\n", yytext);return PC;}
{LA}			{printf("\nLlaveAbre: %s\n", yytext);return LA;}
{LC}			{printf("\nLlaveCierra: %s\n", yytext);return LC;}
{COMENTARIO}    {printf("\nCOMENTARIO: %s\n", yytext);}
{CONS_STR}	    {printf("\nCTE STR: %s\n", yytext);return CONS_STR;}
{CONS_FLOAT}	{printf("\nCTE FLOAT: %s\n", yytext);return CONS_FLOAT;}    	
{WHILE}         {printf("\nCICLO: %s\n", yytext);return WHILE;}
{IF}            {printf("\nIF: %s\n", yytext);return IF;}
{ELSE}          {printf("\nELSE: %s\n", yytext);return ELSE;}
{OP_MAYOR}      {printf("\nOP_MAYOR: %s\n", yytext);return OP_MAYOR;}
{OP_MEN}        {printf("\nOP_MEN: %s\n", yytext);return OP_MEN;}
{OP_MAYORI}     {printf("\nOP_MAYOR IGUAL: %s\n", yytext);return OP_MAYORI;}
{OP_MENI}       {printf("\nOP_MENOR IGUAL: %s\n", yytext);return OP_MENI;}
{TIPO_F}        {printf("\nTIPO_F: %s\n", yytext);return TIPO_F;}
{TIPO_I}        {printf("\nTIPO_I: %s\n", yytext);return TIPO_I;}
{TIPO_S}        {printf("\nTIPO_S: %s\n", yytext);return TIPO_S;}
{INIT}          {printf("\nINIT: %s\n", yytext);return INIT;}
{DP}            {printf("\nDP: %s\n", yytext);return DP;}
{LEER}          {printf("\nLEER: %s\n", yytext);return LEER;}
{ESCRIBIR}      {printf("\nESCRIBIR: %s\n", yytext);return ESCRIBIR;}
{OP_AND}        {printf("\nAND: %s\n", yytext);return OP_AND;}
{OP_OR}         {printf("\nOR: %s\n", yytext);return OP_OR;}
{OP_NOT}        {printf("\nNOT: %s\n", yytext);return OP_NOT;}
{CA}            {printf("\nCORCHETE ABRE: %s\n", yytext);return CA;}
{CC}            {printf("\nCORCHETE CIERRA: %s\n", yytext);return CC;}
{SUM_ULT}       {printf("\nSUMAR ULTIMOS: %s\n", yytext);return SUM_ULT;}
{TRIANG}        {printf("\nTRIANGULO: %s\n", yytext);return TRIANG;}


"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}


