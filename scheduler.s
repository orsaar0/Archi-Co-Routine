extern int_format
extern printf
extern resume
extern endCo
extern N
extern K
extern R
extern COs
extern CURRDRONE
extern drones
extern numOfActiveDrones
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
section .data
looserIndex: dd -1
looserScore: dd 2147483647 ; maxint
section .rodata:
winnerFormat: db "The Winner is: %d",10,0
section .text
schedulerFunc:
    .scheduler_loop:
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
        add ebx, eax        ;ebx<- drones[i]
        mov eax , [ebx+active]
        cmp eax, 0
        je .droneNotActive ;I need this!!
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
        add ebx, eax    ;ebx <-COs[i]
        call resume
        .droneNotActive:

    ; ;####Printer#####
    ;     mov eax, [i]
    ;     mov edx,0
    ;     mov ebx, [K]
    ;     div ebx     ;edx<- i%K
    ;     cmp edx, 0
    ;     jne .noTimeToPrint
    ;     mov ebx, [COs]
    ;     mov eax, [N]        ;eax        <- curr drone ID
    ;     inc eax             ;eax <N+1
    ;     mov ecx, 8
    ;     mul ecx         ;eax <- co's 8*ID
    ;     add ebx, eax    ;ebx <- COs[printer]
    ;     call resume
    ;     .noTimeToPrint:

    ;#####elimination####
        mov eax, [i]
        mov edx, 0
        mov ebx, [N]
        div ebx     ;edx<- i%N ;eax<-i/N
        cmp edx, 0
        jne .noTimeForElimination
        mov ebx, [R]
        div ebx     ;rdx<- (i/N)%R
        cmp edx, 0
        jne .noTimeForElimination
            mov ecx, [N]
            .LooserLoop:
            mov eax, ecx
            dec eax
            mov edx , droneSize
            mul edx
            mov ebx, [drones]
            add ebx, eax    ; ebx<- drones[i]
            mov eax, [ebx+active]
            cmp eax, 0
            je .endloop
            mov eax, [looserScore]
            cmp eax, [ebx+score]    ;is oldscore bigger than curr score?
            jg .newLooser
            jmp .endloop
            .newLooser:
                mov eax, [ebx+score]
                mov [looserScore], eax
                mov eax, ecx
                dec eax
                mov [looserIndex], eax
            .endloop:
                dec ecx
                cmp ecx, 0
                jg .LooserLoop
            ;kick out the looser
                ; printInt [looserIndex] ;debug
                mov eax, [looserIndex]
                mov edx , droneSize
                mul edx
                mov ebx, [drones]
                add ebx, eax    ; ebx<- drones[looserIndex]
                mov [ebx+active], dword 0   ;drones[looserIndex][active] <- false
                dec dword [numOfActiveDrones]
                mov [looserScore], dword 2147483647
                mov [looserIndex], dword -1
        .noTimeForElimination:

    ;#####ENDGAME#######
        mov eax, [numOfActiveDrones]
        cmp eax, 1
        je .endgame
        jmp .loopmanager
        .endgame:
            mov ecx, [N]
            .loopOfDoom:
            mov eax, ecx
            dec eax
            mov edx , droneSize
            mul edx
            mov ebx, [drones]
            add ebx, eax    ; ebx<- drones[i]
            mov eax, [ebx+active]
            cmp eax, 1
            jne .notwinner
            pushad
            push ecx
            push winnerFormat
            call printf
            add esp, 8
            popad

        ;     ;debug<
                mov ebx, [COs]
                mov eax, [N]        ;eax        <- curr drone ID
                inc eax             ;eax <N+1
                mov ecx, 8
                mul ecx         ;eax <- co's 8*ID
                add ebx, eax    ;ebx <- COs[printer]
                call resume
        ;     ;debug>

            jmp endCo
            .notwinner:
            dec ecx
            cmp ecx, 0
            jg .loopOfDoom
    ;###loop manager####
        .loopmanager:
        inc dword [i]
        ; cmp [i], dword 100
        jmp .scheduler_loop


