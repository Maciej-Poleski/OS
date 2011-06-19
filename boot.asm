[bits 16]




jmp $
db "Hello World",0

times 510-($-$$) db 0
dw 0xaa55
