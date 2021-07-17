%define segment		0x0
%define init_stack 	0x7C00
%define bpb_size	0x21			; BIOS Parameter Block size

	org 	0x7C00
	bits 	16

bpb:								; Bios parameter Block
	jmp short 	start
	nop
	times bpb_size db 0

start:
	jmp			segment:main

main:		
	cli								; clear interrupts
	
	mov 		bx, segment  	    ; adjust segments
	mov 		es, bx
	mov	 		ds, bx
	mov 		ss, bx				; zero stack segment
	mov			sp, init_stack	 	; set stack pointer

	sti							; enable interrupts
; -------------------------------
	
	mov			si, stage1msg
	call		print

; -------------------------------

	jmp			$

print:
	xor 		bx, bx
	mov			ah, 0x0E
.loop:
	lodsb
	cmp			al, 0
	je			.end
	int			0x10
	jmp			.loop
.end:
	ret

gdt_start:
gdt_null:
	dd 0x0
	dd 0x0
gdt_code:			; cs registor should point to gdt_code
	dw 0xFFFF		; segment limit first 0-15 bits
	dw 0x0			; base 0-15 bits
	db 0x0			; base 16-23 bits
	db 10011010b	; access byte
	db 11001111b 	; bit flags
	db 0x0			; base 24-31 bits
gdt_data:			; register ds, es, fs, gs, ss 
	dw 0xFFFF		; segment limit first 0-15 bits
	dw 0x0			; base 0-15 bits
	db 0x0			; base 16-23 bits
	db 10010010b	; access byte
	db 11001111b 	; bit flags
	db 0x0			; base 24-31 bits
gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_start - 1 ; size of GDT table
	dd gdt_start



stage1msg:		db "stage 1", 13, 10, 0

times	510-($-$$) db 0
dw		0xAA55

