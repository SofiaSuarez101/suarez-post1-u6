 instrucciones · ASM
; lab6_instrucciones.asm - Demostracion de categorias de instrucciones x86
; Compilar: nasm -f bin lab6_instrucciones.asm -o lab6_instrucciones.com
 
        org 100h                ; offset de inicio para archivos .COM
        cpu 186                 ; permite SHL/ROL con contador inmediato > 1
 
; -- Datos --------------------------------------------------------------
        jmp inicio              ; saltar sobre los datos al codigo
valor_a     dw 45               ; primer operando
valor_b     dw 12               ; segundo operando
resultado   dw 0                ; almacena resultado
contador    db 5                ; contador de bucle
mascara     db 0Fh              ; mascara de 4 bits bajos
 
; -- Codigo -------------------------------------------------------------
inicio:
 
; -- BLOQUE 1: Transferencia de datos -----------------------------------
        mov ax, [valor_a]       ; AX = 45 (contenido de valor_a)
        mov bx, [valor_b]       ; BX = 12 (contenido de valor_b)
        mov cx, ax              ; CX = AX = 45
        mov dx, bx              ; DX = BX = 12
 
        lea si, [valor_a]       ; SI = direccion de valor_a (no su valor)
        mov ax, [si]            ; AX = mem[SI] = 45 (indirecto via SI)
 
        xchg cx, dx             ; CX=12, DX=45
        xchg cx, dx             ; restaurar: CX=45, DX=12
 
        push ax                 ; guarda AX=45 en pila
        mov ax, 0FFFFh          ; modifica AX temporalmente
        pop ax                  ; restaura AX=45
 
; -- BLOQUE 2: Operaciones aritmeticas ----------------------------------
        mov ax, [valor_a]       ; AX = 45
        add ax, [valor_b]       ; AX = 57 (ZF=0, CF=0, OF=0)
        mov [resultado], ax     ; guarda 57 en memoria
 
        mov ax, [valor_b]       ; AX = 12
        sub ax, [valor_a]       ; AX = -33 (SF=1, CF=1, OF=0)
 
        mov ax, [valor_a]       ; AX = 45
        inc ax                  ; AX = 46
        dec ax                  ; AX = 45
 
        mov al, 10              ; AL = 10
        mov bl, 7               ; BL = 7
        mul bl                  ; AX = AL * BL = 70
 
        mov ax, 100             ; AX = 100
        mov bl, 7               ; BL = 7
        div bl                  ; AL = 14 (cociente), AH = 2 (resto)
 
; -- BLOQUE 3: Operaciones logicas --------------------------------------
        mov al, 0B7h            ; AL = 1011 0111b
        and al, [mascara]       ; AL = 07h (conserva 4 bits bajos)
 
        mov al, 0B7h            ; restaurar AL
        or  al, 0F0h            ; AL = F7h (activa los 4 bits altos)
 
        mov al, 0AAh            ; AL = 1010 1010b
        xor al, 0FFh            ; AL = 55h (inversion de bits)
 
        xor bx, bx              ; BX = 0 (forma estandar de poner a cero)
 
        mov al, 0B7h
        test al, 01h            ; ZF=0 porque bit 0 = 1; AL no cambia
 
        mov al, 08h             ; AL = 8
        shl al, 2               ; AL = 32 = 20h (multiplicar por 4)
        shr al, 1               ; AL = 16 = 10h (dividir entre 2)
 
; -- BLOQUE 4: Control de flujo -----------------------------------------
        mov ax, [valor_a]       ; AX = 45
        cmp ax, [valor_b]       ; 45 - 12 = 33
        jg  .mayor              ; salta si AX > valor_b (con signo)
        je  .igual              ; salta si AX == valor_b
        xor cx, cx              ; caso menor: CX = 0
        jmp .fin_cmp
.mayor:
        mov cx, 1               ; CX = 1: valor_a > valor_b
        jmp .fin_cmp
.igual:
        mov cx, 2               ; CX = 2: igualdad
.fin_cmp:
 
        ; Bucle: suma acumulada de 1 a 5 (resultado esperado: 15)
        xor ax, ax              ; AX = 0 (acumulador)
        mov cx, 5               ; CX = contador del bucle
        mov bx, 1               ; BX = valor inicial a sumar
.bucle_suma:
        add ax, bx              ; AX += BX
        inc bx                  ; BX++
        loop .bucle_suma        ; DEC CX; si CX != 0 salta
        ; AX = 15
; -- BLOQUE 4: Control de flujo -----------------------------------------
        mov ax, [valor_a]       ; AX = 45
        cmp ax, [valor_b]       ; 45 - 12 = 33
        jg  .mayor              ; salta si AX > valor_b (con signo)
        je  .igual              ; salta si AX == valor_b
        xor cx, cx              ; caso menor: CX = 0
        jmp .fin_cmp
.mayor:
        mov cx, 1               ; CX = 1: valor_a > valor_b
        jmp .fin_cmp
.igual:
        mov cx, 2               ; CX = 2: igualdad
.fin_cmp:

        ; Bucle: suma acumulada de 1 a 5 (resultado esperado: 15)
        xor ax, ax              ; AX = 0 (acumulador)
        mov cx, 5               ; CX = contador del bucle
        mov bx, 1               ; BX = valor inicial a sumar
.bucle_suma:
        add ax, bx              ; AX += BX
        inc bx                  ; BX++
        loop .bucle_suma        ; DEC CX; si CX != 0 salta
        ; AX = 15

; -- BLOQUE 5: Rotacion - ROL/ROR frente a SHL/SHR ----------------------
        mov al, 81h             ; AL = 1000 0001b

        mov bl, al              ; copia del valor original
        shl bl, 1               ; BL = 02h, CF=1 (bit 7 perdido)

        mov cl, al
        rol cl, 1               ; CL = 03h, CF=1 (bit 7 pasa al bit 0)

        mov dl, al
        shr dl, 1               ; DL = 40h, CF=1 (bit 0 perdido)

        mov bh, al
        ror bh, 1               ; BH = C0h, CF=1 (bit 0 pasa al bit 7)

        mov al, 0A5h            ; AL = 1010 0101b
        rol al, 4               ; AL = 5Ah (nibbles intercambiados)

; -- Fin del programa ---------------------------------------------------
        int 20h                 ; retornar a DOS