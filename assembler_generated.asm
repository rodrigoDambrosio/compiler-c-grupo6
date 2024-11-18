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
_6                   dd		 6                             
_holaaaaa            db		 "holaaaaa", '$', 8 dup (?)

.CODE
MOV EAX,@DATA
MOV DS,EAX
MOV ES,EAX;


START:

FLD _6
FSTP intAsig1
FLD _6
FLD intAsig1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JNE ETIQ_IF9
MOV AX, @DATA
MOV DS, AX
MOV ES, AX
LEA DX, _holaaaaa
MOV AH, 09h
INT 21h
ETIQ_IF9:

mov ax,4c00h
int 21h
End START