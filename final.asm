include macros2.asm
include number.asm
.MODEL LARGE
.STACK 200h
.386
.DATA

floatAsig1           dd		 ?
intAsig1             dd		 ?
a5                   dd		 ?
cadena1              dd		 ?
a2                   dd		 ?
_1                   dd		 1                             
_addddd              db		 "addddd", '$', 6 dup (?)
_2_60                dd		 2.60                          
aux_exp1             dd		 ?
aux_exp2             dd		 ?
aux_exp3             dd		 ?
_Escaleno            db		 "Escaleno", '$', 8 dup (?)
_Isosceles           db		 "Isosceles", '$', 9 dup (?)
_Equilatero          db		 "Equilatero", '$', 10 dup (?)

.CODE
START:

	MOV EAX,@DATA
	MOV DS,EAX
	MOV ES,EAX

	getString cadena1
ET_LEER1:
	displayString cadena1
	newLine 1
	FLD a5
	FLD _1
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNE ETIQ_IF8
	displayString _addddd
	newLine 1
ETIQ_IF8:
	FLD _2.6
	FSTP a2
	FLD aux_exp1
	FSTP floatAsig1
	FLD aux_exp2
	FSTP floatAsig1
	FLD aux_exp3
	FSTP floatAsig1
	FLD aux_exp2
	FLD floatAsig1
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNE TRI_1
	FLD aux_exp3
	FLD aux_exp3
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNE TRI_2
	FLD floatAsig1
	FSTP floatAsig1
	JMP FIN_TRI
TRI_2:
	FLD floatAsig1
	FSTP floatAsig1
	JMP FIN_TRI
TRI_1:
	FLD aux_exp3
	FLD aux_exp3
	FXCH
	FCOM
	FSTSW AX
	SAHF
	FLD floatAsig1
	FSTP floatAsig1
FIN_TRI:

FFREE
mov ax,4c00h
int 21h
End START