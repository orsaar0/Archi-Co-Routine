global droneFunc
extern resume
extern COs
extern N
extern int_format
extern printf
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
    push ebp
    mov ebp, esp
    printInt 50
    mov esp, ebp
    pop ebp
    moveSchedulerToEbx
    call resume
