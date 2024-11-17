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
_A2                  db		 "A2", '$', 2 dup (?)
_ELSE                db		 "ELSE", '$', 4 dup (?)
_2.60                dd		 2.60                          
_not_like_us         db		 "not_like_us", '$', 11 dup (?)

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
JNE ETIQ_IF12
FLD 4
FSTP intAsig1
FLD "A2"
FSTP cadena1
JMP ETIQ_IF19
ETIQ_IF12
FLD "ELSE"
FSTP cadena1
FLD 2.6
FSTP floatAsig1
ETIQ_IF19
FLD "not_like_us"
FSTP cadena1

mov ax,4c00h
int 21h
End