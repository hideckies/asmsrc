;
; Get system time and print it
;
; Build:
;   nasm -f elf64 -o systemtime.o systemtime.asm
;   ld -o systemtime systemtime.o
;

section .data
    msg db "System time in seconds: ", 0
    msg_len equ $ - msg
    newline db 0x0A, 0
    newline_len equ $ - newline

section .bss
    timespec resq 2         ; The timespec struct for storing system time.
    buffer resb 20          ; The buffer for stdout

section .text
    global _start

_start:
    ; Get system time
    mov rax, 228            ; clock_gettime (228)
    mov rdi, 0              ; CLOCK_REALTIME (0)
    lea rsi, [timespec]     ; Pointer to the timespec struct
    syscall

    ; Convert timespec to string and store it to buffer.
    mov rbx, [timespec]
    jmp itoa

; Print the system time in seconds
print_systemtime:
    ; Print "System time in seconds: "
    mov rax, 1              ; sys_write (1)
    mov rdi, 1              ; stdout (1)
    lea rsi, [msg]
    mov rdx, msg_len
    syscall
    ; Print the actual system time
    mov rax, 1              ; sys_write (1)
    mov rdi, 1              ; stdout (1)
    lea rsi, [buffer]
    syscall
    ; Print newline
    mov rax, 1              ; sys_write (1)
    mov rdi, 1              ; stdout (1)
    lea rsi, [newline]
    mov rdx, newline_len
    syscall

; Exit the program
exit:
    mov rax, 60             ; sys_exit (60)
    xor rdi, rdi            ; status code 0
    syscall

; Convert number to string
itoa:
    ; Divide the systemtime in seconds by 10
    mov rax, rbx            ; Set the systemtime number to rax (divident)
    mov rcx, 10             ; For decimal representation.
    lea rdi, [buffer + 19]  ; Set the last position of the buffer for loop.
    mov byte [rdi], 0       ; null-terminator at the end of the buffer.
.convert_loop:
    xor rdx, rdx
    div rcx                 ; rax / 10 = rax (remainder: rdx)
    add dl, '0'             ; Add '0' to the remainder
    dec rdi                 ; Proceed to the next character of the buffer.
    mov [rdi], dl           ; Store to buffer.
    test rax, rax           ; If rax is 0, exit the loop.
    jnz .convert_loop

    ; mov rsi, rdi            ; Set the start address of the buffer.
    jmp print_systemtime
