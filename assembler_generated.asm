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
_2                   dd		 2                             
_final_de            db		 "final_de", '$', 8 dup (?)

.CODE
MOV EAX,@DATA
MOV DS,EAX
MOV ES,EAX;

FLD intAsig1
FLD intAsig1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JNE ETIQ_IF9
FLD 4
FSTP intAsig1
JMP ETIQ_IF15
ETIQ_IF9:
FLD intAsig1
FLD 2
FADD
FSTP intAsig1
ETIQ_IF15:
InicioMientras16
FLD intAsig1
FLD intAsig1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JNE ETIQ_CICLO25
FLD 4
FSTP intAsig1
JMP [16]
ETIQ_CICLO25:
FFREE
FLD "final_de"
FSTP cadena1

mov ax,4c00h
int 21h
End