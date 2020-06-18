section	.rodata         ;constats
    int_format: db "%d", 10, 0	; format string
    float_format: db "%2f",10,0
    hexa_format: db "%X",10,0
    argc_unmached: db "ERROR- 5 args is needed",10,0
    STKSIZE equ 16*1024 
    CODEP equ 0 ; offset of pointer to co-routine function in co-routine struct
    SPP equ 4 ; offset of pointer to co-routine stack in co-routine struct 
section .data           ; inisiliazed vars
section .bss            ; uninitilaized vars
    N: resd 1       ;number of drones
    R: resd 1       ;number of full scheduler cycles between each elimination
    K: resd 1       ;how many drone steps between game board printings
    d: resq 1       ;maximum distance that allows to destroy a target
    seed: resd 1    ;seed for initialization of LFSR shift register
    drones: resd 1  ;drones database
    COs: resd 1     ;co-routine array
    CURR: resd 1
    SPT: resd 1 ; temporary stack pointer
    SPMAIN: resd 1 ; stack pointer of main
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
    ;%1 is a pointer to the float
    pushad
    push dword [d+4]
    push dword [d]
    push float_format
    call printf
    add esp, 12
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
%macro myMalloc 1
    ;ret value in eax
    push ebx
    push ecx
    push edx              
    push dword %1
    call malloc
    add esp, 4
    pop edx
    pop ecx
    pop ebx
%endmacro
%macro myCalloc 2
    ;%1 num of units ;%2 size of unit
    ;ret value in eax
    push ebx
    push ecx
    push edx              
    push dword %2
    push dword %1
    call calloc
    add esp, 8
    pop edx
    pop ecx
    pop ebx
%endmacro
%macro myFree 1
    ;ret value in eax
    push ebx
    push ecx
    push edx              
    push dword %1
    call free
    add esp, 4
    pop edx
    pop ecx
    pop ebx
%endmacro
%define EXIT_SUCCESS 0
%define SIGEXIT 1
%define BOARDSIZE 100
%define X 0
%define Y 4
%define angle 8
%define speed 16
%define score 20
%define active 24
%define droneSize 28
global main
global random
global myexit
global startFunc
global endFunc
global printInt
global int_format
extern malloc 
extern calloc 
extern free 
extern sscanf
extern printf
extern droneFunc
extern targetFunc
extern printerFunc
extern schedulerFunc


section .text
main:
    mov eax, [esp+4]            ; argc
    cmp eax, 6                  ; argc ?== 6 (filename + 5 args)
    je .parseArgs
    errorExit argc_unmached
    .parseArgs:
    mov eax, [esp+8]            ;eax <- argv
    mov ebx, [eax+4]            ;ebx <- argv[1]
    my_sscanf1 ebx, int_format, N
    mov ebx, [eax+8]            ;ebx <- argv[2]
    my_sscanf1 ebx, int_format, R
    mov ebx, [eax+12]            ;ebx <- argv[3]
    my_sscanf1 ebx, int_format, K
    mov ebx, [eax+16]            ;ebx <- argv[4]
    my_sscanf1 ebx, int_format, d
    fild dword [d]               ;convert to float
    fstp qword [d]
    mov ebx, [eax+20]            ;ebx <- argv[5]
    my_sscanf1 ebx, int_format, seed
    ;###### malloc drones data base#######
    myCalloc [N], droneSize
    mov [drones], eax
    ;###### malloc co-rutine database#######
    mov ecx, [N]
    add ecx, 3          
    myCalloc ecx, 8     ;each CO has 4 bytes points to STACK and 4 bytes points function
    mov [COs], eax
    .allocateStackLoop: ;ecx is index
    mov ebx, [COs]
    myMalloc STKSIZE
    add eax, STKSIZE
    mov [ebx+ 8*(ecx-1)+SPP], eax   ;put the ball in the sal
    mov [ebx+ 8*(ecx-1)+CODEP], dword droneFunc   ;a temppurery function addressד
    loop .allocateStackLoop, ecx
    ;###########place target,printer, schduler in place######
    ;COs[N]<-target; COs[N+1]<-printer ;COs[N+2]<-scheduler
    mov ecx, [N]
    mov [ebx+ 8*ecx+CODEP], dword targetFunc   ;a temppurery function addressד
    inc ecx
    mov [ebx+ 8*ecx+CODEP], dword printerFunc   ;a temppurery function addressד
    inc ecx
    mov [ebx+ 8*ecx+CODEP], dword schedulerFunc   ;a temppurery function addressד
    ;####### initCOs ######
    mov ecx, [N]
    add ecx, 3
    .initLoop:
    mov  ebx, ecx   ;this line and the line below is just becuse i couldnt do "push (ecx-1)""
    dec ebx
    push  ebx   ;push co's index
    call initCo    
    add esp, 4  ;silent pop
    loop .initLoop, ecx

    ;debuging<
    mov ecx, [N]
    add ecx,2
    mov eax, [COs]
    call [eax + 8*ecx+CODEP]
    ;debuging>
    

myexit:
exit EXIT_SUCCESS

initCo: ;gets one argument which is CO index
    startFunc 0
    mov ebx, [COs]
    mov eax, [ebp+8]    ;eax <- co-routine ID number
    mov edx, 8
    mul edx
    add ebx, eax    ;ebx <- co's struct
    mov eax, ebx +CODEP ;eax <- func first instruction
    mov [SPT], esp      ;backup main's esp
    mov esp, [ebx+SPP]  ;esp <- co's stack position
    push eax            ;save func pointer on co's stack
    pushfd
    pushad
    mov [ebx+SPP], esp  ;save co's new stack postion
    mov esp, [SPT]      ;restore main's stack pointer
    endFunc 0
    
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
    mov [seed], ax
    printHexa eax
    endFunc 0
