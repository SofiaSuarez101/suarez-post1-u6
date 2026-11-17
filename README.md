# Post-contenido U6 — Instrucciones y Direccionamiento en NASM sobre DOSBox

**Asignatura:** Arquitectura de Computadores · Unidad 6
**Repositorio:** `apellido-post1-u6`
**Herramientas:** DOSBox 0.74+, NASM 2.11+, DEBUG

Este repositorio contiene las dos partes del laboratorio: `lab6_instrucciones.asm` (Parte 1) y `lab6_modos.asm` (Parte 2). Ambos se compilan con `nasm -f bin archivo.asm -o archivo.com`.

> Las capturas se guardan en `capturas/` con los nombres indicados en cada checkpoint.

---

# PARTE 1 — Programa de Instrucciones Mixtas

## 1. Descripción de los bloques

El programa es un `.COM` (`org 100h`) que salta sobre sus datos (`jmp inicio`) y ejecuta cinco bloques en secuencia, terminando con `INT 20h`.

| Bloque | Categoría        | Propósito                                                                                       | Registros usados   |
| ------ | ---------------- | ----------------------------------------------------------------------------------------------- | ------------------ |
| 1      | Transferencia    | `MOV` memoria→registro y registro→registro, `LEA` (dirección vs. contenido), `XCHG`, `PUSH/POP` | AX, BX, CX, DX, SI |
| 2      | Aritmética       | `ADD`, `SUB`, `INC/DEC`, `MUL`, `DIV` y su efecto en flags                                      | AX, BX, AL, BL     |
| 3      | Lógica           | `AND` (limpiar), `OR` (activar), `XOR` (invertir / poner a cero), `TEST`, `SHL/SHR`             | AL, BX             |
| 4      | Control de flujo | `CMP` + `JG/JE` (if/else) y bucle con `LOOP` que suma 1..5                                      | AX, BX, CX         |
| 5      | Rotación         | Contraste `SHL`/`ROL` y `SHR`/`ROR` sobre AL=81h; intercambio de nibbles con `ROL al,4`         | AL, BL, CL, DL, BH |

## 2. Registros y flags observados (DEBUG)

| Instrucción                | Resultado               | CF           | ZF  | SF  | OF  |
| -------------------------- | ----------------------- | ------------ | --- | --- | --- |
| `ADD ax,[valor_b]`         | AX = 57 (0039h)         | 0            | 0   | 0   | 0   |
| `SUB ax,[valor_a]` (12−45) | AX = FFDFh (−33)        | 1 (préstamo) | 0   | 1   | 0   |
| `AND al,[mascara]`         | AL = 07h                | 0            | 0   | 0   | 0   |
| `TEST al,01h` (AL=B7h)     | AL sigue en B7h         | 0            | 0   | 0   | 0   |
| `CMP ax,[valor_b]` (45−12) | AX intacto, resta = 33  | 0            | 0   | 0   | 0   |
| Fin de `.bucle_suma`       | AX = 15 (000Fh), CX = 0 | —            | —   | —   | —   |

Otros valores: `MUL bl` → AX = 70 (46h); `DIV bl` → AL = 14 (0Eh), AH = 2; `XOR al,0FFh` sobre AAh → 55h.

**Bloque 5 (rotación), AL = 81h:**

| Instrucción           | Resultado                             | CF  |
| --------------------- | ------------------------------------- | --- |
| `SHL bl,1`            | BL = 02h (bit 7 perdido)              | 1   |
| `ROL cl,1`            | CL = 03h (bit 7 reinsertado en bit 0) | 1   |
| `SHR dl,1`            | DL = 40h (bit 0 perdido)              | 1   |
| `ROR bh,1`            | BH = C0h (bit 0 reinsertado en bit 7) | 1   |
| `ROL al,4` (AL = A5h) | AL = 5Ah (nibbles intercambiados)     | —   |

## 3. Variante factorial (Checkpoint 3)

El bucle de suma se reemplazó por un factorial de 5. Se inicializa `AX = 1`, `CX = 5`, `BX = 1`, y en cada iteración se ejecuta `MUL bx` (DX:AX = AX·BX), luego `INC bx` y `LOOP`. La secuencia de AX es 1, 2, 6, 24, 120, así que al terminar `AX = 120` (0078h). `MUL` sobrescribe DX con la parte alta del producto, pero como el resultado cabe en 16 bits DX queda en 0. El cambio se registró en un commit separado.

```nasm
        mov ax, 1           ; acumulador del factorial
        mov cx, 5           ; 5 iteraciones
        mov bx, 1           ; multiplicador inicial
.bucle_fact:
        mul bx              ; DX:AX = AX * BX
        inc bx
        loop .bucle_fact    ; AX = 120 al terminar
```

## 4. Checkpoints y capturas

| Checkpoint | Evidencia                                                   | Archivo                           |
| ---------- | ----------------------------------------------------------- | --------------------------------- |
| 1          | Compilación sin errores ni advertencias                     | `capturas/p1_cp1_compilacion.png` |
| 2          | Traza con flags de ADD, SUB, AND, TEST, CMP; AX=57 tras ADD | `capturas/p1_cp2_flags.png`       |
| 2          | AX=15 al final del bucle                                    | `capturas/p1_cp2_ax15.png`        |
| 3          | Variante factorial (commit separado)                        | historial de commits              |
| 4          | Bloque 5: CF=1 y BL=02h, CL=03h, DL=40h, BH=C0h, AL=5Ah     | `capturas/p1_cp4_rotacion.png`    |
| 5          | Decisiones técnicas (secciones 5 y 6)                       | este README                       |

## 5. Decisión técnica 1 — ¿SHL/SHR o ROL/ROR?

SHL/SHR son la opción correcta cuando la manipulación es aritmética: desplazar a la izquierda multiplica por 2^n y a la derecha divide entre 2^n, y en ambos casos el bit que sale del registro no aporta nada al resultado numérico, por lo que descartarlo es el comportamiento deseado (como en el Bloque 3, donde 8 << 2 = 32). ROL/ROR son preferibles cuando la información no debe perderse: intercambio de nibbles, cifrado por rotación o checksums circulares. Con AL = 81h, tras `SHL al,1` el bit 7 original (1) sale del registro y solo queda visible en CF, mientras AL queda en 02h; tras `ROL al,1` ese mismo bit reaparece como el nuevo bit 0 y AL vale 03h, además de CF=1. Esa diferencia determina qué instrucción conviene. SHL nunca podría intercambiar los nibbles de un byte: cada desplazamiento introduce ceros por la derecha y descarta bits por la izquierda, de modo que el nibble alto original se destruye y ningún `OR` posterior puede recuperarlo, porque la información ya no está en el registro. `ROL al,4` lo logra en una instrucción porque nada se descarta, solo se reubica.

## 6. Decisión técnica 2 — ¿LOOP o DEC/JNZ?

LOOP combina en una sola instrucción el decremento de CX y el salto si CX ≠ 0, lo que hace el código más compacto (un byte de opcode más desplazamiento, frente a dos instrucciones) y expresa con claridad la intención de "repetir CX veces". Sin embargo, escribir menos instrucciones no implica gastar menos ciclos: cada instrucción tiene su propio costo de decodificación y ejecución según la microarquitectura. En el 8086 original LOOP era ligeramente más rápida que DEC+JNZ, pero en procesadores posteriores (desde el 286, y de forma muy marcada en los modernos) LOOP se implementa con microcódigo y tarda más ciclos que la pareja DEC/JNZ, que los procesadores actuales ejecutan de forma muy eficiente e incluso fusionan (macro-fusion). Por eso el conteo de líneas de código fuente no es un indicador confiable del tiempo real. Para el bucle de 5 iteraciones del Bloque 4 la diferencia es despreciable, imperceptible para cualquier usuario. Si el mismo bucle se ejecutara millones de veces dentro de un programa mayor, la diferencia acumulada sí sería relevante y convendría usar DEC/JNZ.

---
