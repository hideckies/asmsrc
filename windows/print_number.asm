;
; Prints an arithmetic result
;
; Build:
;   nasm -f win64 -o print_number.o print_number.asm
;   x86_64-w64-mingw32-ld -o print_number.exe print_number.o -lmsvcrt
;
extern printf   ; exists in msvcrt.dll

section .data
    fmt db "Result: %d", 0x0A, 0

section .text
    global main

main:
    ; Add numbers
    mov rax, 5
    mov rdx, 10
    add rdx, rax        ; this result (RDX) is the 2nd argument of printf

    ; Print the result
    ; printf(const char *format-string, argument-list)
    lea rcx, [rel fmt]  ; the 1st argument of printf
    call printf

    ret