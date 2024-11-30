;
; Get the message length dynamically and print it
;
; Build:
;   nasm -f elf64 -o stdout2.o stdout2.asm
;   ld -o stdout2 stdout2.o
;
section .data
    msg db "Hello, World!", 0x0A, 0 ; Add newline (0x0A)

section .text
    global _start

_start:
    call print_message
    call exit
    
print_message:
    mov rsi, msg    ; Set the message.
    mov rdx, 0      ; Initialize the string length.
    ; Get the message length.
.get_strlen:
    mov al, byte [rsi + rdx]
    test al, al
    jz .done_strlen
    inc rdx
    jmp .get_strlen
    ; Now we have the message length so call sys_write.
.done_strlen:
    mov rax, 1  ; sys_write (1)
    mov rdi, 1  ; stdout (1)
    syscall
    ret

exit:
    mov rax, 60     ; sys_exit (60)
    xor rdi, rdi    ; Status code 0
    syscall         ; Invoke
