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
_ACA                 db		 "ACA", '$', 16 dup (?)
_ACA                 db		 "A2A", '$', 4 dup (?)

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
JMP ETIQ_IF12
FLD "ACA
FSTP cadena1
FLD "A2"
FSTP cadena1

mov ax,4c00h
int 21h
End