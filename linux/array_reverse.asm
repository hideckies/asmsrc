;
; Reverse array
;
; Build:
;   nasm -f elf64 -o array_reverse.o array_reverse.asm
;   ld -o array_reverse array_reverse.o
;
section .data
    array db 1, 2, 3, 4, 5, 6
    array_len equ $ - array
    msg db "Reversed array: ", 0
    msg_len equ $ - msg
    sep db ", ", 0
    sep_len equ $ - sep
    newline db 0x0A, 0
    newline_len equ $ - newline

section .bss
    buffer resb 20  ; For display the reversed array

section .text
    global _start

_start:
    ; Reverse the array
    mov rbx, 0              ; The first index of the array.
    mov rcx, array_len
    dec rcx                 ; The last index of the array.

reverse_loop:
    ; Trade each item of arrays
    mov al, [array + rbx]   ; al = array[rbx]
    mov dl, [array + rcx]   ; dl = array[rcx]
    mov [array + rbx], dl   ; array[rbx] = dl
    mov [array + rcx], al   ; array[rcx] = al
    ; Proceed to the next index
    inc rbx
    dec rcx
    cmp rbx, rcx
    jle reverse_loop

print_result:
    ; Print the message
    mov rax, 1              ; sys_write (1)
    mov rdi, 1              ; stdout (1)
    lea rsi, [msg]
    mov rdx, msg_len
    syscall

    ; Print the reversed array
    mov rbx, 0              ; The first index of the array
print_array:
    mov al, [array + rbx]   ; al = array[rbx]
    call itoa
    mov rax, 1              ; sys_write (1)
    mov rdi, 1              ; stdout (1)
    mov rdx, 1              ; buffer length (always 1)
    syscall

    ; Proceed to the next index.
    inc rbx
    cmp rbx, array_len
    jl print_separator

    ; Print newline at the end.
    mov rax, 1              ; sys_write(1)
    mov rdi, 1              ; stdout (1)
    lea rsi, [newline]
    mov rdx, newline_len
    syscall

    ; Exit
    mov rax, 60             ; sys_exit (60)
    xor rdi, rdi            ; status code 0
    syscall

print_separator:
    ; Print seperator (, )
    mov rax, 1              ; sys_write(1)
    mov rdi, 1              ; stdout (1)
    lea rsi, [sep]
    mov rdx, sep_len
    syscall
    jmp print_array

; Convert number to string
itoa:
    mov rcx, 10
    lea rdi, [buffer + 19]  ; Set the last position of buffer
    mov byte [rdi], 0       ; null-terminator
.convert_loop:
    xor rdx, rdx
    div rcx                 ; rax / 10 = rax (remainder: rdx)
    add dl, '0'             ; Add '0' to the remainder
    dec rdi                 ; Proceed to the next character of the buffer.
    mov [rdi], dl           ; Store to buffer.
    test rax, rax           ; If rax is 0, exit the loop.
    jnz .convert_loop

    mov rsi, rdi            ; 
    ret
