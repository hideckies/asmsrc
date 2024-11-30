;
; User Input & Stdout for Loop
;
; Build:
;   nasm -f elf64 -o input_stdout_loop.o input_stdout_loop.asm
;   ld -o input_stdout_loop input_stdout_loop.o
;
section .bss
    buffer resb 256

section .data
    prompt db "Input: "
    prompt_len equ $ - prompt

section .text
    global _start

_start:
    ; Prompt
    mov rax, 1  ; sys_write
    mov rdi, 1  ; stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

input_loop:
    ; Receives user input
    mov rax, 0  ; sys_read (0)
    mov rdi, 0  ; stdin (0)
    mov rsi, buffer
    mov rdx, 256
    syscall

    ; Stores the number of bytes read to RCX
    mov rcx, rax

    ; If the input is empty, exit the program
    cmp rcx, 0
    je exit

    ; Displays the received text
    mov rax, 1  ; sys_write (1)
    mov rdi, 1  ; stdout (1)
    mov rsi, buffer
    mov rdx, rcx    ; the number of bytes read
    syscall
    
    ; Input again.
    jmp input_loop

exit:
    mov rax, 60     ; sys_exit (60)
    xor rdi, rdi    ; status code 0
    syscall