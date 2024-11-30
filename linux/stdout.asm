;
; Print a message
;
; Build:
;   nasm -f elf64 -o stdout.o stdout.asm
;   ld -o stdout stdout.o
;
section .data
    msg db "Hello, World!", 0x0A ; Add newline (0x0A) at the end.
    len equ $ - msg

section .text
    global _start

_start:
    ; Print message
    mov rax, 1      ; sys_write (1)
    mov rdi, 1      ; stdout (1)
    mov rsi, msg    ; Set the address of the message.
    mov rdx, len    ; Set the message length
    syscall         ; Invoke
    
    ; sys_exit
    mov rax, 60     ; sys_exit (60)
    xor rdi, rdi    ; Set status code 0
    syscall         ; Invoke
    