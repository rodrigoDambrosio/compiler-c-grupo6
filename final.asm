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
_2                   dd      2                             
_5                   dd      5                             
_0                   dd      0                             
_x_mayor_a_0         db      "x_mayor_a_0", '$', 11 dup (?)

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

    FLD _2
    FSTP x
    FLD _5
    FSTP intAsig2
    FLD x
    FLD _2
    FCOM
    FXCH
    FSTSW AX
    SAHF
    JE CUERPO_IF15
    FLD intAsig2
    FLD _0
    FCOM
    FXCH
    FSTSW AX
    SAHF
    JNE ETIQ_IF17
CUERPO_IF15:
    displayString _x_mayor_a_0
    newLine 1
ETIQ_IF17:

FFREE
mov ax,4c00h
int 21h
End START