global targetFunc
global mayDestroy
extern targetX
extern targetY
extern resume
extern COs
extern N
extern d
extern int_format
extern printf
extern drones
extern CURRDRONE
extern random
extern MAXINT
extern BOARDSIZE
extern seed
extern float_format
%macro printFloat 1
    ;%1 is a pointer to the float
    pushad
    push dword [%1+4]
    push dword [%1]
    push float_format
    call printf
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
section .text
SPP equ 4           ; offset of pointer to co-routine stack in co-routine struct 
targetFunc:
    call random
    fild dword [seed]
    fild dword [MAXINT]
    fdivp
    fimul dword [BOARDSIZE]
    fstp qword [targetX]
    call random
    fild dword [seed]
    fild dword [MAXINT]
    fdivp
    fimul dword [BOARDSIZE]
    fstp qword [targetY]
    
    ;debug
    ; printFloat targetX
    ; printFloat targetY

    ;return control to current drone
    mov eax, [CURRDRONE]
    mov edx, 8
    mul edx         ;eax <- co's 8*ID
    mov ebx, [COs]
    add ebx, eax    ;ebx <- COs[i]
    call resume
    jmp targetFunc

mayDestroy:
    push ebp
    mov ebp, esp
    mov eax, 0

    fld qword [ebp+8]       ; X point
    fld qword [targetX]
    fsubp                   ; X - targetX
    fsqrt                   ; ST(0) <- (X-targetX)^2
    fld qword [ebp+16]      ; Y point
    fld qword [targetY]
    fsubp                   ; Y - targetY
    fsqrt                   ; ST(0) <- (Y-targetY)^2, ST(1) <- (X-targetX)^2
    faddp                   ; ST(0) <- (Y-targetY)^2 + (X-targetX)^2
    fld qword [d]           
    fsqrt                   ; ST(0) <- d^2, ST(1) <- (Y-targetY)^2 + (X-targetX)^2
    fcomip
    ja .cant_destroy
    

    inc eax
    .cant_destroy:
    mov esp, ebp
    pop ebp
    ret