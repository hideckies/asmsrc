;
; Spawns Calculator via WinExec, not used a constant string value in .data section.
;
; Build:
;   nasm -f win64 -o exec_calc2.o exec_calc2.asm
;   x86_64-w64-mingw32-ld -o exec_calc2.exe exec_calc2.o -lkernel32
;
extern WinExec      ; exists in kernel32.dll
extern ExitProcess  ; exists in kernel32.dll

section .text
    global main

main:
    sub rsp, 8                      ; Align the stack to a multiple of 16 bit.

    ; WinExec(LPCSTR lpCmdLine, UINT uCmdShow)
    xor edx, edx                    ; uCmdShow = SW_HIDE (0)
    push rax                        ; Push null-terminator onto the stack.
    mov rax, 0x6578652e636c6163     ; 'exe.clac' (little-endian)
    push rax                        ; Push the ASCII hex onto the stack.
    mov rcx, rsp                    ; lpCmdLine = 'calc.exe', 0
    call WinExec
    
    ; ExitProcess(UINT uExitCode)
    xor ecx, ecx                    ; uExitCode = 0
    call ExitProcess
