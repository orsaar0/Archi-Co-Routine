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
section .text
global droneFunc
droneFunc:
push ebp
mov ebp, esp
printInt 50
mov esp, ebp
pop ebp
ret
