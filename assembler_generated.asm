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
cadena1              db		 ?                             , '$', 14 dup (?)
cadena2              db		 ?                             , '$', 14 dup (?)
entero1              dd		 ?
entero2              dd		 ?
c                    dd		 ?
a2                   dd		 ?
b3                   dd		 ?
y                    dd		 ?
a                    dd		 ?
x                    dd		 ?
e                    dd		 ?
_4                   dd		 ?
_3                   dd		 ?
_4                   dd		 ?
_5                   dd		 ?
_6                   dd		 ?

.CODE
MOV EAX,@DATA
MOV DS,EAX
MOV ES,EAX;

FLD intAsig2
FLD intAsig1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JNE [8]
FLD 4
FSTP intAsig1
FLD 3.4
FSTP a2
FLD 4.4
FSTP a2
FLD 5.4
FSTP a2
FLD 6.4
FSTP a2

mov ax,4c00h
int 21h
End