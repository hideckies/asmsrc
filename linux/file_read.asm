;
; Read file content and output it
;
; Build:
;   nasm -f elf64 -o file_read.o file_read.asm
;   ld -o file_read file_read.o
;
section .data
    filepath db "/tmp/example.txt", 0   ; File path to read

section .bss
    buffer resb 1024                    ; Buffer for storing the file contents

section .text
    global _start

_start:
    ; Open file
    mov rax, 2              ; sys_open (2)
    mov rdi, filepath       ; Set file path
    mov rsi, 0              ; O_RDONLY (0)
    mov rdx, 0              ; mode (ignore)
    syscall

    ; Store the file descriptor
    mov rdi, rax

    ; Initialize the offset for the buffer pointer (and buffer length when printing).
    xor rbx, rbx

; Read file until EOF
read_loop:
    ; Read buffer
    mov rax, 0              ; sys_read (0)
                            ; The file descriptor (rdi) is already set.
    lea rsi, [buffer+rbx]   ; The pointer to buffer (+ the current position) to read
    mov rdx, 1024           ; The buffer length
    syscall

    ; If the read bytes size is 0, finish reading
    test rax, rax
    jz finish

    add rbx, rax            ; Add the read bytes size to the offset.

    jmp read_loop

finish:
    ; Close file
    mov rax, 3              ; sys_close (3)
                            ; The file descriptor (rdi) is already set.
    syscall

    ; Print the contents
    mov rax, 1              ; sys_write (1)
    mov rdi, 1              ; stdout (1)
    lea rsi, buffer
    mov rdx, rbx            ; Buffer length
    syscall

    ; Exit
    mov rax, 60             ; sys_exit (60)
    xor rdi, rdi            ; Status code 0
    syscall
