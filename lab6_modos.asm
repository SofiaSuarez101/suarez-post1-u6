; lab6_modos.asm - Demostracion de modos de direccionamiento x86
; Compilar: nasm -f bin lab6_modos.asm -o lab6_modos.com -l lab6_modos.com

org 100h

; -- Datos de prueba ----------------------------------------------------
        jmp inicio

array       dw 10, 20, 30, 40, 50       ; array de 5 enteros de 16 bits

nota1       dw 85                       ; "struct" estudiante: offset 0
nota2       dw 73                       ; offset 2
promedio    dw 0                        ; offset 4

var_x       dw 0FFFFh                   ; variable para direccionamiento directo

tabla_hex   db 30h,31h,32h,33h,34h,35h,36h,37h
            db 38h,39h,41h,42h,43h,44h,45h,46h

; matriz de 3 filas x 3 columnas de enteros de 16 bits
matriz      dw 1, 2, 3
            dw 4, 5, 6
            dw 7, 8, 9

inicio:

; -- MODO 1: INMEDIATO --------------------------------------------------
; El operando es una constante dentro de la instruccion (no hay [ ])
        mov ax, 100             ; AX = 100 (inmediato decimal)
        mov bx, 0A5h            ; BX = A5h (inmediato hexadecimal)
        add cx, 55              ; CX += 55
        and dx, 00FFh           ; DX AND mascara inmediata

; -- MODO 2: DIRECTO ----------------------------------------------------
; La direccion del operando esta fija en la instruccion
        mov ax, [var_x]         ; AX = mem[var_x] = FFFFh
        mov bx, [array]         ; BX = mem[array] = 10
        mov cx, [nota1]         ; CX = mem[nota1] = 85
        mov word [var_x], 0     ; mem[var_x] = 0 (escritura directa)

; -- MODO 3: INDIRECTO POR REGISTRO -------------------------------------
; El registro contiene la direccion; el puntero puede cambiar en ejecucion
        mov si, nota1           ; SI = direccion de nota1 (no su valor)
        mov ax, [si]            ; AX = mem[SI] = 85 (0055h)

        mov si, nota2           ; SI = direccion de nota2
        mov bx, [si]            ; BX = mem[SI] = 73 (0049h)

        add ax, bx              ; AX = 158
        shr ax, 1               ; AX = 79 (promedio)
        mov si, promedio        ; SI = direccion de promedio
        mov [si], ax            ; mem[promedio] = 79 (004Fh)

; -- MODO 4: INDEXADO (BASE + INDICE + DESPLAZAMIENTO) ------------------
; EA = BX + SI. Acceso a array[2] = 30
        mov bx, array           ; BX = direccion base del array
        mov si, 4               ; SI = 2 * sizeof(word) = 4
        mov ax, [bx + si]       ; AX = array[2] = 30

        ; Suma de todos los elementos del array (orden normal)
        xor ax, ax              ; AX = 0 (acumulador)
        mov bx, array           ; BX = direccion base
        mov cx, 5               ; CX = numero de elementos
        xor si, si              ; SI = 0 (indice en bytes)
.bucle_array:
        add ax, [bx + si]       ; AX += array[SI/2]
        add si, 2               ; avanzar un word
        loop .bucle_array       ; AX = 150 (0096h)

        ; Extension: recorrido inverso (array[4] -> array[0])
        xor ax, ax              ; AX = 0
        mov bx, array           ; BX = direccion base
        mov cx, 5               ; CX = numero de elementos
        mov si, 8               ; SI = 4 * 2 = indice de array[4]
.bucle_inverso:
        add ax, [bx + si]       ; AX += array[SI/2]
        sub si, 2               ; retroceder un word
        loop .bucle_inverso     ; AX = 150 (0096h)

        ; Campos del "struct" con desplazamiento fijo
        mov bx, nota1           ; BX = base del struct
        mov ax, [bx]            ; AX = nota1 = 85 (offset 0)
        mov cx, [bx + 2]        ; CX = nota2 = 73 (offset 2)
        mov dx, [bx + 4]        ; DX = promedio = 79 (offset 4)


; -- Fin del programa ---------------------------------------------------
        int 20h                 ; retornar a DOS