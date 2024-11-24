include macros2.asm
include number.asm
.MODEL LARGE
.STACK 200h
.386
.DATA
MAXTEXTSIZE equ 200

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
_34                  dd		 34                            
_3                   dd		 3                             
_500                 dd		 500                           
_2_50                dd		 2.50                          
_antes_if            db		 "antes_if", '$', 8 dup (?)
_0                   dd		 0                             
_0_00                dd		 0.0                           
aux_ult              dd		 ?
_28                  dd		 28                            
_13_50               dd		 13.50                         
_4                   dd		 4                             
_5_50                dd		 5.50                          
_17                  dd		 17                            
_57                  dd		 57                            
aux_exp1             dd		 ?
_1                   dd		 1                             
aux_exp2             dd		 ?
_2                   dd		 2                             
aux_exp3             dd		 ?
_Escaleno            db		 "Escaleno", '$', 8 dup (?)
_Isosceles           db		 "Isosceles", '$', 9 dup (?)
_Equilatero          db		 "Equilatero", '$', 10 dup (?)
_x_mayor_a_0         db		 "x_mayor_a_0", '$', 11 dup (?)
_en_el_if            db		 "en_el_if", '$', 8 dup (?)
_lo_puse_en_0        db		 "lo_puse_en_0", '$', 12 dup (?)
_sino_esto           db		 "sino_esto", '$', 9 dup (?)
_escribir_algo_2_veces db		 "escribir_algo_2_veces", '$', 21 dup (?)

.CODE
strlen proc
	mov bx, 0
	strLoop:
		cmp BYTE PTR [si+bx],'$'
		je strend
		inc bx
		jmp strLoop
	strend:
		ret
strlen endp
assignString proc
	call strlen
	cmp bx , MAXTEXTSIZE
	jle assignStringSizeOk
	mov bx , MAXTEXTSIZE
	assignStringSizeOk:
	mov cx , bx
	cld
	rep movsb
	mov al , '$'
	mov byte ptr[di],al
	ret
assignString endp

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
	FLD _2_50
	FSTP floatAsig1
	displayString _antes_if
	newLine 1
	FLD _0
	FSTP aux_ult
	FLD _57
	FLD x
	FADD
	FLD _17
	FLD _17
	FADD
	FLD _5_50
	FLD _5_50
	FADD
	FLD _4
	FLD _4
	FADD
	FSTP x
	FLD _0
	FSTP aux_exp1
	FLD _1
	FSTP aux_exp1
	FLD _2
	FSTP aux_exp2
	FLD _3
	FSTP aux_exp3
	FLD aux_exp2
	FLD aux_exp1
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNE TRI_1
	FLD aux_exp1
	FLD aux_exp3
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNE TRI_2
	MOV si, OFFSET _Equilatero
	MOV di, OFFSET cadena1
	CALL assignString
	JMP FIN_TRI
TRI_2:
	MOV si, OFFSET _Isosceles
	MOV di, OFFSET cadena1
	CALL assignString
	JMP FIN_TRI
TRI_1:
	MOV si, OFFSET _Escaleno
	MOV di, OFFSET cadena1
	CALL assignString
FIN_TRI:
	displayString cadena1
	newLine 1
	FLD x
	FLD _0
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNA ETIQ_IF62
	displayString _x_mayor_a_0
	newLine 1
ETIQ_IF62:
	FLD intAsig1
	FLD _1
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNA ETIQ_IF71
	displayString _en_el_if
	newLine 1
	FLD _0
	FSTP intAsig2
ETIQ_IF71:
	FLD intAsig2
	FLD _0
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JNE ETIQ_IF78
	displayString _lo_puse_en_0
	newLine 1
	JMP ETIQ_IF80
ETIQ_IF78:
	displayString _sino_esto
	newLine 1
ETIQ_IF80:
	FLD _0
	FSTP c
InicioMientras84:
	FLD c
	FLD _2
	FXCH
	FCOM
	FSTSW AX
	SAHF
	JAE ETIQ_CICLO97
	displayString _escribir_algo_2_veces
	newLine 1
	getString cadena1
ET_LEER1:
	FLD _1
	FLD c
	FADD
	FSTP c
	JMP InicioMientras84
ETIQ_CICLO97:
FFREE

FFREE
mov ax,4c00h
int 21h
End START