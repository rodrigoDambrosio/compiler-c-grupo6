%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "y.tab.h"

#define MAX_STRING 40
#define MAX_INTEGER 65535
#define COTA_INFERIOR_FLOAT pow(-1.17549,-38)
#define COTA_SUPERIOR_FLOAT pow(3.40282,38)

FILE  *yyin;
int   yyval;
char  *yyltext;

void validacion_string(char[]);
void validacion_integer(int);
void validacion_float(float);

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
DIGITO	    [0-9]
LETRA		[a-zA-Z]
CTE_STRING  \"[^\"]+[{DIGITO}|{LETRA}]*[^\"]+\"
CTE_FLOAT 	{DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}*
CTE_INT  	{DIGITO}+
ID			{LETRA}({LETRA}|{DIGITO})*
OP_AS   	":="
OP_SUM		"+"
OP_MUL      "*"
OP_RES		"-"
OP_DIV      "/"
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
OP_IGUAL     "=="
OP_NOT_IGUAL "!="
IGUAL        "="
CA           "["
CC           "]"
COMA         ","
PTO_COMA     ";"

%%

{INIT}          {printf("\nINIT: %s\n", yytext);return INIT;}
{TIPO_F}        {printf("\nTIPO_F: %s\n", yytext);return TIPO_F;}
{TIPO_I}        {printf("\nTIPO_I: %s\n", yytext);return TIPO_I;}
{TIPO_S}        {printf("\nTIPO_S: %s\n", yytext);return TIPO_S;}
{WHILE}         {printf("\nCICLO: %s\n", yytext);return WHILE;}
{ESCRIBIR}      {printf("\nESCRIBIR: %s\n", yytext);return ESCRIBIR;}
{LEER}          {printf("\nLEER: %s\n", yytext);return LEER;}
{SUM_ULT}       {printf("\nSUMAR ULTIMOS: %s\n", yytext);return SUM_ULT;}
{TRIANG}        {printf("\nTRIANGULO: %s\n", yytext);return TRIANG;}
{CTE_STRING}	{
                    yylval.tipo_str = yytext;
                    validacion_string(yytext); 
                    printf("\nCTE STRING: %s\n", yytext); 
                    return CTE_STRING;
                }
{CTE_FLOAT}	    {
                    yylval.tipo_float = atof(yytext);
                    validacion_float(atof(yytext));
                    printf("\nCTE FLOAT: %s\n", yytext);
                    return CTE_FLOAT;
                }    	
{CTE_INT}	    {
                    yylval.tipo_int = atoi(yytext);
                    validacion_integer(atoi(yytext));
                    printf("\nCTE INT: %s\n", yytext);
                    return CTE_INT;
                } 
{OP_NOT}        {printf("\nNOT: %s\n", yytext);return OP_NOT;}
{OP_SUM}		{printf("\nSuma: %s\n", yytext);return OP_SUM;}
{OP_AS}			{printf("\nAsignacion: %s\n", yytext);return OP_AS;}
{DP}            {printf("\nDP: %s\n", yytext);return DP;}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		{printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);return OP_DIV;}
{PA}			{printf("\nParAbre: %s\n", yytext);return PA;}
{PC}			{printf("\nParCierra: %s\n", yytext);return PC;}
{LA}			{printf("\nLlaveAbre: %s\n", yytext);return LA;}
{LC}			{printf("\nLlaveCierra: %s\n", yytext);return LC;}
{COMENTARIO}    {printf("\nCOMENTARIO: %s\n", yytext);}
{IF}            {printf("\nIF: %s\n", yytext);return IF;}
{ELSE}          {printf("\nELSE: %s\n", yytext);return ELSE;}
{OP_MAYOR}      {printf("\nOP_MAYOR: %s\n", yytext);return OP_MAYOR;}
{OP_MEN}        {printf("\nOP_MEN: %s\n", yytext);return OP_MEN;}
{OP_MAYORI}     {printf("\nOP_MAYOR IGUAL: %s\n", yytext);return OP_MAYORI;}
{OP_MENI}       {printf("\nOP_MENOR IGUAL: %s\n", yytext);return OP_MENI;}
{OP_IGUAL}      {printf("\nOP_IGUAL: %s\n", yytext);return OP_IGUAL;}
{OP_NOT_IGUAL}  {printf("\nOP_NOT_IGUAL: %s\n", yytext);return OP_NOT_IGUAL;}
{OP_AND}        {printf("\nAND: %s\n", yytext);return OP_AND;}
{OP_OR}         {printf("\nOR: %s\n", yytext);return OP_OR;}
{CA}            {printf("\nCORCHETE ABRE: %s\n", yytext);return CA;}
{CC}            {printf("\nCORCHETE CIERRA: %s\n", yytext);return CC;}
{COMA}          {printf("\nCOMA: %s\n", yytext);return COMA;}
{PTO_COMA}      {printf("\nPTO_COMA: %s\n", yytext);return PTO_COMA;}
{IGUAL}         {printf("\nIGUAL: %s\n", yytext);return IGUAL;}
{ID}			{
                    yylval.tipo_str = strdup(yytext);
                    printf("\nIdentificador: %s\n", yytext);
                    return ID;
                }


"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}
%%

/*
    Funciones para validar los tipos de datos
*/

void validacion_string(char cadena[])
{
    int largo = strlen(cadena);
    if(largo > MAX_STRING)
    {
        printf("ERROR: Rango de string excedido en linea %d. Se permite un maximo de %d caracteres \n", yylineno, MAX_STRING);
        yyerror();
    }
}

void validacion_float(float numero)
{   
    if (numero > COTA_SUPERIOR_FLOAT || numero < COTA_INFERIOR_FLOAT)
    {
        printf("ERROR: Rango de float excedido. Se permite float de 32 bits.\n");
        yyerror();
    } 

}

void validacion_integer(int numero)
{
    if(numero > MAX_INTEGER)
    {
        printf("\n ERROR: Valor de int excedido, el mayor posible es %d \n", MAX_INTEGER);
        yyerror();
    }
}