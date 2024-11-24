include macros2.asm
include number.asm
.MODEL LARGE
.STACK 200h
.386
.DATA
MAXTEXTSIZE equ 200

floatAsig1           dd      ?
floatAsig2           dd      ?
float1               dd      ?
float2               dd      ?
intAsig1             dd      ?
intAsig2             dd      ?
base                 dd      ?
var1                 dd      ?
cadena1              dd      ?
cadena2              dd      ?
entero1              dd      ?
entero2              dd      ?
c                    dd      ?
x                    dd      ?
a2                   dd      ?
b3                   dd      ?
y                    dd      ?
a                    dd      ?
e                    dd      ?
_0_00                dd      0.00                          
_0                   dd      0                             
aux_exp1             dd      ?
_1                   dd      1                             
aux_exp2             dd      ?
_2                   dd      2                             
aux_exp3             dd      ?
_3                   dd      3                             
_Escaleno            db      "Escaleno", '$', 8 dup (?)
_Isosceles           db      "Isosceles", '$', 9 dup (?)
_Equilatero          db      "Equilatero", '$', 10 dup (?)

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

FFREE
mov ax,4c00h
int 21h
End START