;
; User Input & Stdout
;
; Build:
;   nasm -f elf64 -o input_stdout.o input_stdout.asm
;   ld -o input_stdout input_stdout.o
; 
section .bss
    buffer resb 64  ; Buffer for storing user input

section .data
    prompt db "Input: "
    prompt_len equ $ - prompt

section .text
    global _start

_start:
    ; Prompt
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Receives user input
    mov rax, 0      ; sys_read
    mov rdi, 0      ; stdin
    mov rsi, buffer
    mov rdx, 64     ; max bytes for buffer
    syscall

    ; Stores the number of bytes read to RCX
    mov rcx, rax

    ; Displays the user input
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, buffer
    mov rdx, rcx    ; the number of bytes read
    syscall
    
    ; Exit
    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; status code 0
    syscall
