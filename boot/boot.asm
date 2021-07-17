%define segment		0x0
%define init_stack 	0x7C00
%define bpb_size	0x21			; BIOS Parameter Block size

CODE_SEG	equ	gdt_code - gdt_start
DATA_SEG	equ gdt_data - gdt_start


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

	sti								; enable interrupts
; -------------------------------
	
	mov			si, stage1msg
	call		print16

; -------------------------------

.load_protected:
	cli
	lgdt[gdt_descriptor]
	mov			eax, cr0
	or			eax, 0x1
	mov			cr0, eax
	jmp			CODE_SEG:load32

print16:
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

[bits 32]
load32:
	mov			ax, DATA_SEG
	mov			ds, ax
	mov			es, ax
	mov			fs, ax
	mov			gs, ax
	mov			ss, ax
	mov			ebp, 0x00200000
	mov			esp, ebp

; enable A20 gate

	in 			al, 0x92
	or			al, 0x2
	out			0x92, al

; halt

	jmp 		$


times	510-($-$$) db 0
dw		0xAA55

