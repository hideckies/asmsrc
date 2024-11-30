;
; Counts numbers while sleeping
;
; Build:
;   nasm -f win64 -o sleep_count.o sleep_count.asm
;   x86_64-w64-mingw32-ld -o sleep_count.exe sleep_count.o -lkernel32 -lmsvcrt
;
extern Sleep    ; exists in kernel32.dll
extern printf   ; exists in msvcrt.dll

section .data
    fmt db "%d", 0x0A, 0
    sleep_time equ 1000 ; Sleep time in milliseconds
    max_cnt equ 5       ; The max count

section .text
    global main

main:
    ; Set count
    mov rsi, max_cnt

sleep_loop:
    ; Display the count
    ; printf(const char *format-string, argument-list)
    mov rdx, rsi        ; argument-list = <count>
    lea rcx, [rel fmt]  ; format-string = <fmt>
    call printf

    ; Sleep 1 second
    ; Sleep(DWORD dwMilliseconds)
    mov rcx, sleep_time
    call Sleep

    dec rsi     ; Decrease the count.

    ; Keep sleeping until the count reaches 0
    cmp rsi, 0
    jne sleep_loop

    ret