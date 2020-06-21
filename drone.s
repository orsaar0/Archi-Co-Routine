global droneFunc
extern seed
extern MAXINT
extern random
extern BOARDSIZE
extern resume
extern COs
extern N
extern float_format
extern int_format
extern printf
extern drones
extern CURRDRONE
extern mayDestroy
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
%macro checkBorders 2
    fld qword [%1]
    fld dword [%2]
    fcomip
    jb %%sub
    fld dword [zero]
    fcomip
    ja %%add
    jmp %%good
    
    %%sub:
        fsub dword [%2]
        jmp %%good
    %%add:
        fadd dword [%2]
    %%good:
        fstp qword [%1]

%endmacro
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
section .data
one_eighty: dd 180.0
hundred: dd 100.0
zero: dd 0.0
twenty: dd 20.0
ten: dd 10.0
sixty: dd 60.0
hundred_twenty: dd 120.0
one: dd 1.0
_360: dd 360.0
section .bss
delta_angle: resq 1
delta_speed: resq 1
section .text
droneFunc:
    finit
; set random delta angle
    pushad
    call random
    popad
    fild dword [seed]
    fild dword [MAXINT]
    fdivp
    fmul dword [hundred_twenty]
    fld dword [sixty]
    fsubp
    fstp qword [delta_angle]

; set random delta speed
    pushad
    call random
    popad
    fild dword [seed]
    fild dword [MAXINT]
    fdivp
    fmul dword [twenty]
    fld dword [ten]
    fsubp
    fstp qword [delta_speed]
    
; get curr drone ptr -> ebx
    ; printInt [CURRDRONE]
    mov ebx, [drones]
    mov eax, [CURRDRONE]
    mov edx, droneSize
    mul edx         ;currdrone id * dronesize
    add ebx, eax    ;ebx<-drones[i]

; calc new position
    finit
    fld qword [ebx+angle]
    fldpi
    fmulp
    fld dword [one_eighty]
    fdivp
    fsincos                 ; st(1) <- sin(angle), s(0) <- cos(angle)
    fld qword [ebx+speed]
    fmulp                   ; st(0) <- speed*(cos(angle))
    fld qword [ebx+X]
    faddp                   ; st(0) <- currX + speed*(cos(angle))
    fstp qword [ebx+X]
    checkBorders ebx+X, hundred

    ;debug
    ; printFloat ebx+X

    fld qword [ebx+speed]
    fmulp                   ; st(0) <- speed*(sin(angle))
    fld qword [ebx+Y]
    faddp                   ; st(0) <- currY + speed*(sin(angle))  
    fstp qword [ebx+Y]
    checkBorders ebx+Y, hundred

    ;debug
    ; printFloat ebx+Y

; calc new speed
    fld qword [ebx+speed]
    fld qword [delta_speed]
    faddp
    fstp qword [ebx+speed]
    checkBorders ebx+speed, hundred

    ;debug
    ; printFloat delta_speed
    ; printFloat ebx+speed

; calc new angle
    fld qword [ebx+angle]
    fld qword [delta_angle]
    faddp
    fstp qword [ebx+angle]
    checkBorders ebx+angle, _360

    ;debug
    ; printFloat delta_angle
    ; printFloat ebx+angle

.loop:
    finit
; get curr drone ptr -> ebx
    ; printInt [CURRDRONE]
    mov ebx, [drones]
    mov eax, [CURRDRONE]
    mov edx, droneSize
    mul edx         ;currdrone id * dronesize
    add ebx, eax    ;ebx<-drones[i]
; may destroy
    push ebx
    push dword [ebx+Y+4]
    push dword [ebx+Y]
    push dword [ebx+X+4]
    push dword [ebx+X]
    call mayDestroy
    add esp, 16
    pop ebx
    
    ; printInt eax
    cmp eax, 1
    jl .no_score
    inc dword [ebx+score]
    
    
    push ebx
    ; call target CO
        mov eax, [N]
        mov edx, 8
        mul edx         ;eax <- co's 8*ID
        mov ebx, [COs]
        add ebx, eax    ;ebx <- COs[i]
        call resume
    pop ebx

.no_score:
; set random delta angle
    pushad
    call random
    popad
    fild dword [seed]
    fild dword [MAXINT]
    fdivp
    fmul dword [hundred_twenty]
    fld dword [sixty]
    fsubp
    fstp qword [delta_angle]

; set random delta speed
    pushad
    call random
    popad
    fild dword [seed]
    fild dword [MAXINT]
    fdivp
    fmul dword [twenty]
    fld dword [ten]
    fsubp
    fstp qword [delta_speed]    


; calc new position
    finit
    fld qword [ebx+angle]
    fldpi
    fmulp
    fld dword [one_eighty]
    fdivp
    fsincos                 ; st(1) <- sin(angle), s(0) <- cos(angle)
    fld qword [ebx+speed]
    fmulp                   ; st(0) <- speed*(cos(angle))
    fld qword [ebx+X]
    faddp                   ; st(0) <- currX + speed*(cos(angle))
    fstp qword [ebx+X]
    checkBorders ebx+X, hundred

    ;debug
    ; printFloat ebx+X

    fld qword [ebx+speed]
    fmulp                   ; st(0) <- speed*(sin(angle))
    fld qword [ebx+Y]
    faddp                   ; st(0) <- currY + speed*(sin(angle))  
    fstp qword [ebx+Y]
    checkBorders ebx+Y, hundred

    ;debug
    ; printFloat ebx+Y

; calc new speed
    fld qword [ebx+speed]
    fld qword [delta_speed]
    faddp
    fstp qword [ebx+speed]
    checkBorders ebx+speed, hundred

    ;debug
    ; printFloat delta_speed
    ; printFloat ebx+speed

; calc new angle
    fld qword [ebx+angle]
    fld qword [delta_angle]
    faddp
    fstp qword [ebx+angle]
    checkBorders ebx+angle, _360

    ;debug
    ; printFloat delta_angle
    ; printFloat ebx+angle
moveSchedulerToEbx
call resume
jmp .loop

