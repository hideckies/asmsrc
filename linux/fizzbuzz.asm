;
; FizzBuzz
;
; Build:
;   nasm -f elf64 -o fizzbuzz.o fizzbuzz.asm
;   ld -o fizzbuzz fizzbuzz.o -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
;
extern printf

section .data
    fizz db "Fizz", 0x0A
    fizz_len equ $ - fizz
    buzz db "Buzz", 0x0A
    buzz_len equ $ - buzz
    fizzbuzz db "FizzBuzz", 0x0A
    fizzbuzz_len equ $ - fizzbuzz
    fmt db "%d", 0x0A

section .text
    global _start

_start:
    xor rsi, rsi        ; Initialize counter.
    
loop:
    inc rsi             ; Increment counter.
    cmp rsi, 101        ; If it reached 101, exit the program.
    je exit

    push rsi            ; Save counter temporarily

    ; If the counter is multiple of 15, print "FizzBuzz"
    mov rcx, 15         ; Set divisor
    call divide
    test rdx, rdx       ; Check if the remainder (rdx) is 0
    jz print_fizzbuzz
    ; Else if the counter is multiple of 3, print "Fizz"
    mov rcx, 3          ; Set divisor
    call divide
    test rdx, rdx       ; Check if the remainder (rdx) is 0
    jz print_fizz
    ; Else if the counter is multiple of 5, print "Buzz"
    mov rcx, 5          ; Set divisor
    call divide
    test rdx, rdx       ; Check if the remainder (rdx) is 0
    jz print_buzz
    ; Else, print counter
    jmp print_counter

divide:
    ; rax / rcx = rax (remainder: rdx)
    mov rax, rsi        ; Set divident (counter: rsi)
    xor rdx, rdx        ; Clear rdx
    div rcx             ; Divide (rax/rcx)
    ret

print_fizzbuzz:
    mov rax, 1          ; sys_write (1)
    mov rdi, 1          ; stdout (1)
    mov rsi, fizzbuzz
    mov rdx, fizzbuzz_len
    syscall
    pop rsi
    jmp loop

print_fizz:
    mov rax, 1          ; sys_write (1)
    mov rdi, 1          ; stdout (1)
    mov rsi, fizz
    mov rdx, fizz_len
    syscall
    pop rsi
    jmp loop

print_buzz:
    mov rax, 1          ; sys_write (1)
    mov rdi, 1          ; stdout (1)
    mov rsi, buzz
    mov rdx, buzz_len
    syscall
    pop rsi
    jmp loop

print_counter:
    ; For simplicity, use printf instead of sys_write.
    ; printf(const char *format-string, argument-list)
    mov rdi, fmt        ; The 1st argument
                        ; The 2nd argument is already set (rsi = counter)
    xor rax, rax        ; Clear rax for stack alignment.
    call printf
    pop rsi
    jmp loop

exit:
    mov rax, 60         ; sys_exit (60)
    xor rdi, rdi        ; Status code 0
    syscall
