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
x                    dd		 ?
a2                   dd		 ?
b3                   dd		 ?
y                    dd		 ?
a                    dd		 ?
e                    dd		 ?
_hola                db		 "hola", '$', 4 dup (?)

.CODE
START:

	MOV EAX,@DATA
	MOV DS,EAX
	MOV ES,EAX

	FLD _"hola"
	FSTP cadena1

FFREE
mov ax,4c00h
int 21h
End START