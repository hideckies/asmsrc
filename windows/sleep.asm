;
; Sleeps N seconds
;
; Build:
;   nasm -f win64 -o sleep.o sleep.asm
;   x86_64-w64-mingw32-ld -o sleep.exe sleep.o -lkernel32 -lmsvcrt
;
extern Sleep    ; exists in kernel32.dll
extern printf   ; exists in msvcrt.dll

section .data
    msg_start db "Start", 0x0A, 0
    msg_finish db "Finish", 0x0A, 0
    sleep_time equ 5000 ; Sleep time in milliseconds

section .text
    global main

main:
    sub rsp, 8  ; Align the stack to a multiple of 16 bit.

    ; Display "Start"
    ; printf(const char *format-string, argument-list)
    xor rdx, rdx                ; argument-list = null
    lea rcx, [rel msg_start]    ; *format-string = <msg_start>
    call printf

    ; Sleep 5 seconds
    ; Sleep(DWORD dwMilliseconds)
    mov rcx, sleep_time
    call Sleep

    ; Display "Stop"
    ; printf(const char *format-string, argument-list)
    xor rdx, rdx                ; argument-list = null
    lea rcx, [rel msg_finish]   ; *format-string = <msg_finish>
    call printf

    ret
    