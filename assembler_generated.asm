include macros2.asm
include number.asm
.MODEL LARGE
.STACK 200h
.386
.DATA

floatAsig1           dd		 ?
intAsig1             dd		 ?
cadena1              dd		 ?
a2                   dd		 ?
_4                   dd		 4                             

.CODE
MOV EAX,@DATA
MOV DS,EAX
MOV ES,EAX;


START:

InicioMientras1:
FLD intAsig1
FLD intAsig1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JNE ETIQ_CICLO10
FLD 4
FSTP intAsig1
JMP InicioMientras1
ETIQ_CICLO10:
FFREE

mov ax,4c00h
int 21h
End START