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
_3                   dd		 3                             
_aaaaaaaaaaa         db		 "aaaaaaaaaaa", '$', 11 dup (?)
_8                   dd		 8                             
_agoraaa             db		 "agoraaa", '$', 7 dup (?)
_MIAUMIAU            db		 "MIAUMIAU", '$', 8 dup (?)

.CODE
START:

	MOV EAX,@DATA
	MOV DS,EAX
	MOV ES,EAX

	FLD _6
	FSTP intAsig1
	FLD intAsig1
	FLD _3
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JAE ETIQ_IF12
	displayString _aaaaaaaaaaa
	newLine 1
	FLD _8
	FSTP intAsig1
ETIQ_IF12:
	FLD intAsig1
	FLD _8
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JB ETIQ_IF18
	displayString _agoraaa
	newLine 1
ETIQ_IF18:
	displayString _MIAUMIAU
	newLine 1

FFREE
mov ax,4c00h
int 21h
End START