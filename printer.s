global printerFunc
extern targetX
extern targetY
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
printFormat: db "[%d]: %2f, %2f, %2f, %2f, %d, %d",10,0
printerFunc:
        mov ecx, [N]
        .printDronesLoop:
        mov eax, ecx
        dec eax
        mov edx , droneSize
        mul edx
        mov ebx, [drones]
        add ebx, eax    ;ebx<- drones[i]
        pushad
        push dword [ebx+active]
        push dword [ebx+score]
        push dword [ebx+speed +4]
        push dword [ebx+speed]
        push dword [ebx+angle +4]
        push dword [ebx+angle]
        push dword [ebx+Y +4]
        push dword [ebx+Y]
        push dword [ebx+X +4]
        push dword [ebx+X]
        push dword ecx
        push dword printFormat
        call printf
        add esp, 48
        popad
        ; printFloat ebx+X
        ; printFloat ebx+Y
        ; printFloat ebx+angle
        ; printFloat ebx+speed
        ; printInt [ebx+score]     
        ; printInt [ebx+active]
        ; loop .activeLoop, ecx
        dec ecx
        cmp ecx, 0
        jne .printDronesLoop
    moveSchedulerToEbx
    call resume
    jmp printerFunc
