;
; Write to file
;
; Build:
;   nasm -f elf64 -o file_write.o file_write.asm
;   ld -o file_write file_write.o
;
; Resources:
;   - https://gist.github.com/armicron/e891709ce8893df2fd5fc74c846dcf20
;
section .data
    filepath db "/tmp/example.txt", 0
    msg db "Hello, World!", 0x0A
    msg_len equ $ - msg

section .text
    global _start

_start:
    ; Open a file.
    mov rax, 2          ; sys_open (2)
    mov rdi, filepath   ; Set filename
    mov rsi, 0o102      ; O_CREATE (0o100) | O_RDWR (0o2)
    mov rdx, 0o644      ; mode (rw-r--r--)
    syscall

    ; Store the file descriptor to RDI that will be used for syscalls later.
    mov rdi, rax

    ; Write file.
    mov rax, 1          ; sys_write (1)
    mov rsi, msg        ; Set the message address
    mov rdx, msg_len    ; Set the message length
    syscall

    ; Close file.
    mov rax, 3          ; sys_close (3)
                        ; The file handle (rdi) is already set.
    syscall

    ; Exit
    mov rax, 60         ; sys_exit (60)
    xor rdi, rdi        ; Status code 0
    syscall
