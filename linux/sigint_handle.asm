;
; Handle SIGINT (Ctrl+C)
;
; Build:
;   nasm -f elf64 -o sigint_handle.o sigint_handle.asm
;   ld -o sigint_handle sigint_handle.o
;
; Resources:
;   - https://github.com/g0kkk/SignalHandler/blob/master/64bit.asm
;
struc sigaction
    .sa_handler     resq 1
    .sa_flags       resq 1
    .sa_restorer    resq 1
    .sa_mask        resq 1
endstruc

section .data
    msg db "SIGINT received", 0x0A, 0
    msg_len equ $ - msg

section .bss
    act resb sigaction_size

section .text
    global _start

_start:
    ; Initialize act
    mov qword [act + sigaction.sa_handler], handler
    mov [act + sigaction.sa_flags], dword 0x04000000    ; SA_RESTORER
    mov qword [act + sigaction.sa_restorer], restorer

    ; Set SIGINT handle action
    ; Ref: https://manpages.debian.org/testing/linux-manual-4.8/sys_rt_sigaction.9.en.html
    mov rax, 13     ; sys_rt_sigaction (13)
    mov rdi, 2      ; SIGINT (2)
    mov rsi, act    ; sigaction struct
    mov rdx, 0x00   ; the previous sigaction (null)
    mov r10, 0x08   ; sigsetsize
    syscall

    ; Pause until SIGINT received
    mov rax, 34     ; sys_pause (34)
    syscall

    ; Exit
    mov rax, 60     ; sys_exit (60)
    xor rdi, rdi
    syscall

handler:
    ; Print message when receiving SIGINT
    mov rax, 1      ; sys_write (1)
    mov rdi, 1      ; stdout (1)
    mov rsi, msg
    mov rdx, msg_len
    syscall
    ret

restorer:
    ; Return from the signal handler
    mov rax, 15 ; sys_rt_sigreturn (15)
    syscall
