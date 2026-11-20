; lab6_factorial.asm - Variante del bucle del Bloque 4: factorial de 5
; Reemplaza ADD por MUL. En lab6_instrucciones.asm este bloque sustituye
; al bucle .bucle_suma. Resultado esperado: AX = 120 (0078h).
; Compilar: nasm -f bin lab6_factorial.asm -o lab6_factorial.com

        org 100h

        mov ax, 1               ; AX = 1 (acumulador del producto)
        mov cx, 5               ; CX = 5 iteraciones
        mov bx, 1               ; BX = multiplicador inicial
.bucle_fact:
        mul bx                  ; DX:AX = AX * BX
        inc bx                  ; BX++ (siguiente factor)
        loop .bucle_fact        ; DEC CX; si CX != 0 salta
        ; AX = 1*1*2*3*4*5 = 120

        int 20h                 ; retornar a DOS