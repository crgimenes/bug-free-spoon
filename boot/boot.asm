%define segment		0x7C0
%define init_stack 	segment*0x10
%define bpb_size	0x21			; BIOS Parameter Block size

	org 	0
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
	mov	 		ds, bx
	mov 		es, bx
	mov			sp, init_stack	 	; set stack pointer
	xor 		bx, bx
	mov 		ss, bx				; zero stack segment

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

stage1msg:		db "stage 1", 13, 10, 0

times	510-($-$$) db 0
dw		0xAA55

