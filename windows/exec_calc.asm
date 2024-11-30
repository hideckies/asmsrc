;
; Spawns Calculator via WinExec
;
; Build:
;   nasm -f win64 -o exec_calc.o exec_calc.asm
;   x86_64-w64-mingw32-ld -o exec_calc.exe exec_calc.o -lkernel32
;
extern WinExec      ; exists in kernel32.dll
extern ExitProcess  ; exists in kernel32.dll

section .data
    cmd db 'calc.exe', 0

section .text
    global main

main:
    sub rsp, 8                      ; Align the stack to a multiple of 16 bit.

    ; WinExec(LPCSTR lpCmdLine, UINT uCmdShow)
    xor edx, edx                    ; uCmdShow = SW_HIDE (0)
    lea rcx, [rel cmd]             ; lpCmdLine = <cmd>
    call WinExec
    
    ; ExitProcess(UINT uExitCode)
    xor ecx, ecx                    ; uExitCode = 0
    call ExitProcess
