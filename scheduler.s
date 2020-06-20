extern int_format
extern printf
extern resume
extern endCo
extern N
extern K
extern COs
extern CURRDRONE
extern drones
global schedulerFunc
section .data
    i: dd 0
%define X 0
%define Y 8
%define angle 16
%define speed 24
%define score 32
%define active 36
%define droneSize 40
%define MAXINT 65535
%macro printInt 1
    pushad
    push dword %1
    push int_format
    call printf
    add esp, 8
    popad
%endmacro
section .text
schedulerFunc:
    .sch_loop:
        ;#### DRONES ####
        mov eax, [i]
        mov edx,0
        mov ebx, [N]
        div ebx     ;edx<- i%N (it's realy edx belive me)
        ; printInt edx
        ;get activnes of drone (be careful not to override edx)
        mov eax, edx        ;eax <- drones id
        mov ebx, [drones]   ;ebx <- drones array
        mov ecx, droneSize  
        mul ecx             ;eax<- currdrone-id * dronesize
        add ebx, eax        ;ebx<- pointer to right struct
        mov eax , [ebx+active]
        cmp eax, 0
        je .droneNotActive ;i need this!!
        .isActive:
        ;calc [i]%n again
        mov eax, [i]
        mov edx,0
        mov ebx, [N]
        div ebx     ;edx<- i%N (it's realy edx belive me)
        mov ebx, [COs]
        mov eax, edx        ;eax        <- curr drone ID
        mov [CURRDRONE], edx   ;[CURRDRONE]<- curr drone ID
        mov ecx, 8
        mul ecx         ;eax <- co's 8*ID
        add ebx, eax    ;ebx <- co's struct
        call resume
        .droneNotActive:

        ;####Printer#####
        mov eax, [i]
        mov edx,0
        mov ebx, [K]
        div ebx     ;edx<- i%N (it's realy edx belive me)
        cmp edx, 0
        jne .noTimeToPrint
        mov ebx, [COs]
        mov eax, [N]        ;eax        <- curr drone ID
        inc eax
        mov ecx, 8
        mul ecx         ;eax <- co's 8*ID
        add ebx, eax    ;ebx <- co's struct
        call resume
        .noTimeToPrint:



        ;###loop manager####
        inc dword [i]
        cmp [i], dword 15
        jl .sch_loop


    jmp endCo

