;
; Opens MessageBoxA.
;
; Build:
;   nasm -f win64 -o messageboxa.o messageboxa.asm
;   x86_64-w64-mingw32-ld -o messageboxa.exe messageboxa.o -lkernel32 -luser32
;
; Resources:
;   - https://gist.github.com/totekuh/d4dd6a4d4c30fc4798caa78a116faaf6
;   - https://www.davidgrantham.com/nasm-messagebox64/
;
extern MessageBoxA  ; exists in user32.dll
extern ExitProcess  ; exists in kernel32.dll

section .data
    ; The arguments for MessageBoxA
    caption db "Greetings", 0
    text db "Hello, World!", 0
    mb_ok equ 0

section .text
    global main

main:
    sub rsp, 8                  ; Align the stack to a multiple of 16 bit.
    sub rsp, 32                 ; 32 bytes of shadow space

    ; MessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType)
    mov r9d, mb_ok              ; uType = MB_OK
    lea r8, [rel caption]       ; lpCaption = <caption>
    lea rdx, [rel text]         ; lpText = <text>
    xor rcx, rcx                ; hWnd = NULL
    call MessageBoxA

    add rsp, 32                 ; Remove the 32 bytes.

    ; ExitProcess(UINT uExitCode)
    xor ecx, ecx                ; uExitCode = 0
    call ExitProcess
