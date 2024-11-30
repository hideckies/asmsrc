;
; Remove a file
;
; Build:
;   nasm -f elf64 -o file_remove.o file_remove.asm
;   ld -o file_remove file_remove.o
;
section .data
    filepath db "/tmp/example.txt", 0 ; File path to remove

section .text
    global _start

_start:
    ; Remove file
    mov rax, 87         ; sys_unlink (87)
    lea rdi, filepath
    syscall

    ; Exit
    mov rax, 60         ; sys_exit (60)
    xor rdi, rdi        ; Status code 0
    syscall
