section	.rodata         ;constats
    int_format: db "%d", 10, 0	; format string
    float_format: db "%f",10,0
    hexa_format: db "%X",10,0
    argc_unmached: db "ERROR- 5 args is needed",10,0

section .data           ; inisiliazed vars
section .bss            ; uninitilaized vars
    N: resd 1       ;number of drones
    R: resd 1       ;number of full scheduler cycles between each elimination
    K: resd 1       ;how many drone steps between game board printings
    d: resd 1       ;maximum distance that allows to destroy a target
    seed: resd 1    ;seed for initialization of LFSR shift register


%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro
%macro  exit 1
	syscall1 SIGEXIT, %1
%endmacro
%macro errorExit 1
    push dword %1
    call printf
    exit -1
%endmacro
%macro my_sscanf1 3 
    pushad
    ;%1 == format ;%2 == read to
    push dword %3
    push dword %2
    push dword %1
    call sscanf
    add esp, 12
    popad
%endmacro
%macro printInt 1
    pushad
    push dword %1
    push int_format
    call printf
    add esp, 8
    popad
%endmacro
%macro printFloat 1
    pushad
    push dword %1
    push float_format
    call printf
    add esp, 8
    popad
%endmacro
%macro printHexa 1
    pushad
    push dword %1
    push hexa_format
    call printf
    add esp, 8
    popad
%endmacro
%macro startFunc 1
    push ebp
    mov ebp, esp
    sub esp, %1
%endmacro
%macro endFunc 1
    add esp, %1
    mov esp, ebp
    pop ebp
    ret
%endmacro
%define EXIT_SUCCESS 0
%define SIGEXIT 1
global main
global random
global myexit
extern malloc 
extern calloc 
extern free 
extern sscanf
extern printf



section .text
main:
    mov eax, [esp+4]            ; argc
    cmp eax, 6                  ; argc ?== 6 (filename + 5 args)
    je .parseargs
    errorExit argc_unmached
    .parseargs:
    mov eax, [esp+8]            ;eax <- argv
    mov ebx, [eax+4]            ;ebx <- argv[1]
    my_sscanf1 ebx, int_format, N
    mov ebx, [eax+8]            ;ebx <- argv[2]
    my_sscanf1 ebx, int_format, R
    mov ebx, [eax+12]            ;ebx <- argv[3]
    my_sscanf1 ebx, int_format, K
    mov ebx, [eax+16]            ;ebx <- argv[4]
    my_sscanf1 ebx, float_format, d
    mov ebx, [eax+20]            ;ebx <- argv[5]
    my_sscanf1 ebx, int_format, seed
    ;debug<
    ; mov ecx, [N]
    ; printInt ecx
    mov ecx, [d]
    printFloat ecx
    call random
    ;>debug
myexit:
exit EXIT_SUCCESS

random:
    ;ax holds old number, ecx is an index, ebx is mask, edx accumlate xors
    startFunc 0
    mov eax, 0
    mov ax ,[seed]
    mov ecx, 16
    .shift:
    mov bx, 1       ;00...0001
    and bx, ax      ;mask
    mov dx, bx      
    mov bx, 4       ;00...0100
    and bx, ax      ;mask
    shr bx, 2       ;put in lsb
    xor dx, bx
    mov bx, 8       ;00...1000
    and bx, ax      ;mask
    shr bx, 3       ;put in lsb
    xor dx, bx
    mov bx, 32      ;0...100000
    and bx, ax      ;mask
    shr bx, 5       ;put in lsb
    xor dx, bx
    ;put the ball in the sal
    shl dx, 15
    shr ax, 1
    or  ax, dx
    loop .shift, ecx
    endFunc 0
