include macros2.asm
include number.asm
.MODEL LARGE
.STACK 200h
.386
.DATA

floatAsig1           dd		 ?
floatAsig2           dd		 ?
float1               dd		 ?
float2               dd		 ?
intAsig1             dd		 ?
intAsig2             dd		 ?
base                 dd		 ?
var1                 dd		 ?
cadena1              dd		 ?
cadena2              dd		 ?
entero1              dd		 ?
entero2              dd		 ?
c                    dd		 ?
a2                   dd		 ?
b3                   dd		 ?
y                    dd		 ?
a                    dd		 ?
x                    dd		 ?
e                    dd		 ?
_34                  dd		 34                            
_3                   dd		 3                             
_500                 dd		 500                           
_2_50                dd		 2.50                          
_antes_if            db		 "antes_if", '$', 8 dup (?)
_1                   dd		 1                             
_en_el_if            db		 "en_el_if", '$', 8 dup (?)
_0                   dd		 0                             
_no_cumple           db		 "no_cumple", '$', 9 dup (?)
_sino_esto           db		 "sino_esto", '$', 9 dup (?)
_2                   dd		 2                             
_escribir_algo_2_veces db		 "escribir_algo_2_veces", '$', 21 dup (?)

.CODE
START:

	MOV EAX,@DATA
	MOV DS,EAX
	MOV ES,EAX

	FLD _3
	FLD _34
	FMUL
	FSTP intAsig2
	FLD intAsig2
	FLD _500
	FADD
	FSTP intAsig1
	FLD _2.5
	FSTP floatAsig1
	displayString _antes_if
	newLine 1
	FLD intAsig1
	FLD _1
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNA ETIQ_IF20
	displayString _en_el_if
	newLine 1
ETIQ_IF20:
	FLD intAsig2
	FLD _0
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNE ETIQ_IF27
	displayString _no_cumple
	newLine 1
	JMP ETIQ_IF29
ETIQ_IF27:
	displayString _sino_esto
	newLine 1
ETIQ_IF29:
	FLD _0
	FSTP c
InicioMientras33:
	FLD c
	FLD _2
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JAE ETIQ_CICLO46
	displayString _escribir_algo_2_veces
	newLine 1
	getString cadena1
ET_LEER1:
	FLD _1
	FLD c
	FADD
	FSTP c
	JMP InicioMientras33
ETIQ_CICLO46:
FFREE

FFREE
mov ax,4c00h
int 21h
End START