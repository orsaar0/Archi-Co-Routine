global droneFunc
extern seed
; extern MAXINT
extern random
extern resume
extern COs
extern N
extern int_format
extern printf
extern drones
extern CURRDRONE
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
%macro moveSchedulerToEbx 0
    mov ebx, [COs]
        mov eax, [N]  
        add eax, 2         ;eax <- SchedulerID
        mov edx, 8
        mul edx         ;;eax <- co's 8*ID
        add ebx, eax    ;ebx <- co's struct
%endmacro
section .text
droneFunc:
    printInt [CURRDRONE]
    mov ebx, [drones]
    mov eax, [CURRDRONE]
    mov edx, droneSize
    mul edx         ;currdrone id * dronesize
    add ebx, eax    ;ebx<-drones[i]


    mov eax , [ebx+X]
    mov eax , [ebx+Y]
    mov eax , [ebx+active]


    ; printInt eax



    ; init X,Y, speed, angle
    ; X
    ; call random         ; eax <-  new [seed]
    ; fild dword eax      ;convert to float
    ; fstp qword [X]

    ; call random
    ; fild dword eax      ;convert to float
    ; fstp qword [Y]
    ; call random
    ; fild dword eax      ;convert to float
    ; fstp qword [speed]

    .loop:

    
    moveSchedulerToEbx
    call resume
    jmp droneFunc