[bits 16]
[org 0]

jmp 0x07c0:code16
code16:

mov ax,cs
mov ds,ax

mov cx,1999
clear_start:
push cx
mov al,' '
mov bp,.cont
jmp putchar
.cont:
pop cx
loop clear_start

mov bp,.end
jmp flush_buffer
.end:
jmp $

; INPUT: bx
; DESTROY: ax,dx,
set_cursor_position:
mov al,0x0f
mov dx,0x03d4
out dx,al

mov ax,bx
mov dx,0x03d5
out dx,al

mov al,0x0e
mov dx,0x03d4
out dx,al

mov ax,bx
shr ax,8
mov dx,0x03d5
out dx,al

jmp bp

; DESTROY: ax,si,es,di,cx,bx,dx
flush_buffer:

mov ax,buffer
mov si,ax
mov ax,0xb800
mov es,ax
mov ax,[cursorPosition]
shl ax,1
mov di,ax
mov cx,[stringLength]

mov ah,characterColor
flush_buffer_start:

lodsb
stosw
loop flush_buffer_start
flush_buffer_end:
mov bx,[cursorPosition]
add bx,[stringLength]
mov [cursorPosition],bx
mov [stringLength],word 0	; Czyszcze bufor
push bp
mov bp,.end
jmp set_cursor_position
.end:
pop bp
jmp bp

; INPUT ax
; DESTROY ax,si,es,di,cx,bx,dx
print:
mov si,ax
mov ax,ds
mov es,ax
mov ax,buffer
add ax,[stringLength]
mov di,ax

print_start:
lodsb
test al,al
jz print_end
cmp word [stringLength], bufferSize
jne print_continue
push si
push es
push ax
push bp
mov bp,.end1
jmp flush_buffer
.end1:
pop bp
pop ax
pop es
pop si
mov di,buffer
print_continue:
inc word [stringLength]
stosb
jmp print_start

print_end:
jmp bp

; INPUT: al
; DESTROY: ax,si,es,di,cx,bx,dx
putchar:
mov ah,characterColor
cmp word [stringLength], bufferSize
jne .flush_end

push ax
push bp
mov bp,.end1
jmp flush_buffer
.end1:
pop bp
pop ax
.flush_end:
mov bx,0x07c0
mov es,bx
mov bx,buffer
add bx,[stringLength]
mov di,bx
stosw
inc word [stringLength]

jmp bp

characterColor	equ 15
cursorPosition: dw 0		; Pierwszy wolny znak na ekranie
stringLength:   dw 0		; D³ugoœæ napisu w buforze
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; w polach powy¿ej s¹ zapisywane z³e wartoœci pod wp³ywem funkcji print
buffer:
times 510-($-$$) db 0
dw 0xaa55
bufferSize EQU	$-buffer
