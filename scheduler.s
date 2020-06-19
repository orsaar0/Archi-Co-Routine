extern int_format
extern printf
extern resume
extern endCo
extern N
extern COs
extern CURRDRONE
global schedulerFunc
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
    printInt 0
    mov ecx , [N]
    .loopCOs:
        mov ebx, [COs]
        mov eax, ecx    ;eax <- co-routine ID number
        dec eax         ;eax <- (ID-1) because arrays
        mov [CURRDRONE], eax ;[CURRDRONE]<- curr drone ID
        mov edx, 8
        mul edx         ;;eax <- co's 8*ID
        add ebx, eax    ;ebx <- co's struct
        call resume
        loop .loopCOs, ecx
    jmp endCo

