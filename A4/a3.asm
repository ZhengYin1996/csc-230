#define LCD_LIBONLY
.include "lcd.asm"

.cseg
	ldi r21, 0x87
	sts ADCSRA, r21
	ldi r21, 0x40
	sts ADMUX, r21
	call lcd_init			; call lcd_init to Initialize the LCD
	call lcd_clr
	call init_strings
	call init_pointer
do:
	call clear_line1
	call clear_line2
	call display_strings
	call copy_line1
	call copy_line2
	call display_strings
	call check_button
	cpi r24, 0x10
	breq change_line
	cpi r24, 0x02
	breq stop
	cpi r24, 0x01
	breq right_button
	cpi r24, 0x08
	breq left_button
	
	ldi r20, 0x20
	
hui:
	call delay
	jmp do

lp:	jmp lp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

stop:
	ldi r20, 5
	call delay
	call check_button
	cpi r24, 0x04
	brne stop
	rjmp do

right_button:
	ldi r20, 0x07
	rjmp hui
left_button:
	ldi r20, 0x40
	rjmp hui

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

change_line:
	ldi r20, 20
	call delay
	call display_strings1
	call check_button
	cpi r24, 0x04
	breq change_line1
	rjmp change_line

change_line1:
	clr r24
	rjmp do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	pop r16
	ret

display_strings:

	; This subroutine sets the position the next
	; character will be output on the lcd
	;
	; The first parameter pushed on the stack is the Y position
	; 
	; The second parameter pushed on the stack is the X position
	; 
	; This call moves the cursor to the top left (ie. 0,0)

	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	pop r16
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

display_strings1:

	; This subroutine sets the position the next
	; character will be output on the lcd
	;
	; The first parameter pushed on the stack is the Y position
	; 
	; The second parameter pushed on the stack is the X position
	; 
	; This call moves the cursor to the top left (ie. 0,0)

	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	pop r16
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_pointer:
	push r16
	ldi r16, low(msg1)
	sts l1ptr, r16
	ldi r16, high(msg1)
	sts l1ptr+1, r16

	ldi r16, low(msg2)
	sts l2ptr, r16
	ldi r16, high(msg2)
	sts l2ptr+1, r16
	pop r16
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clear_line1:	push YH
				push YL
				push r17
				ldi r17, 16
				ldi YL, low(line1)
				ldi YH, high(line1)
	
	

go:				ldi r16, ' '
				st Y+, r16
				dec r17
				tst r17
				breq go1
				jmp go

go1:			
				ldi r16, 0
				st Y+, r16
				pop r17
				pop YL
				pop YH
				ret
clear_line2:	push YH
				push YL
				push r17
				ldi r17, 16
				ldi YL, low(line2)
				ldi YH, high(line2)
	
go2:			ldi r16, ' '
				st Y+, r16
				dec r17
				tst r17
				breq go3
				jmp go2

go3:			
				ldi r16, 0
				st Y+, r16
				pop r17
				pop YL
				pop YH
				ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

copy_line1:
	push XH
	push XL
	push YH
	push YL
	push r17
	push r16
	push r18
	push r19
	ldi r17, 1
	ldi XL, low(line1)
	ldi XH, high(line1)
	lds YL, l1ptr
	lds YH, l1ptr + 1
	ld r18, Y			
	tst r18				
	breq wrap_y1		
gogo:
	ld r19, Y			
	tst r19				
	breq wrap_y2		
back:	
	ld r16, Y+
	st X+, r16
	inc r17
	cpi r17,17
	breq finishh
	jmp gogo

finishh:
	lds YL, l1ptr
	lds YH, l1ptr + 1
	adiw YL:YH, 1
	sts l1ptr, YL
	sts l1ptr + 1, YH
	pop r19
	pop r18
	pop r16
	pop r17
	pop YL
	pop YH
	pop XL
	pop XH
	ret

wrap_y1:
	ldi r16, low(msg1)		
	sts l1ptr, r16			
	ldi r16, high(msg1)		
	sts l1ptr+1, r16		
	lds YL, l1ptr			
	lds YH, l1ptr + 1		
	jmp gogo				

wrap_y2:
	ldi YL, low(msg1)
	ldi YH, high(msg1)
	jmp back

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

copy_line2:
	push XH
	push XL
	push YH
	push YL
	push r17
	push r16
	ldi r17, 1
	ldi XL, low(line2)
	ldi XH, high(line2)
	lds YL, l2ptr		
	lds YH, l2ptr + 1	
	ld r18, Y			
	tst r18				
	breq wrap_y3		
gogo1:
	ld r19, Y			
	tst r19				
	breq wrap_y4		
back1:
	ld r16, Y+
	st X+, r16
	inc r17
	cpi r17,17
	breq finishh1
	jmp gogo1

finishh1:
	lds YL, l2ptr
	lds YH, l2ptr + 1
	adiw YL:YH, 1
	sts l2ptr, YL
	sts l2ptr + 1, YH
	pop r16
	pop r17
	pop YL
	pop YH
	pop XL
	pop XH
	ret
wrap_y3:
	ldi r16, low(msg2)		
	sts l2ptr, r16			
	ldi r16, high(msg2)		
	sts l2ptr+1, r16		
	lds YL, l2ptr			
	lds YH, l2ptr + 1		
	jmp gogo1				

wrap_y4:
	ldi YL, low(msg2)		
	ldi YH, high(msg2)		
	jmp back1				

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

delay:	

del1:		nop
		ldi r21,0xFF
del2:		nop
		ldi r22, 0xFF
del3:		nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret


msg1_p:	.db "This is the message on the first line. Here it goes. ", 0	
msg2_p: .db "--- buy --- more --- pop --- buy ", 0

check_button:
		push r16
		push r17
		
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value

		lds r16, ADCL
		lds r17, ADCH

		cpi r17, 3			;  if > 0x3E8, no button pressed 
		brne bsk1		    ;  
		cpi r16, 0xE8		; 
		brsh bsk_done		; 
bsk1:	tst r17				; if ADCH is 0, might be right or up  
		brne bsk2			; 
		cpi r16, 0x32		; < 0x32 is right
		brsh bsk3
		ldi r24, 0x01		; right button
		rjmp bsk_done
bsk3:	cpi r16, 0xC3		
		brsh bsk4	
		ldi r24, 0x02		; up			
		rjmp bsk_done
bsk4:	ldi r24, 0x04		; down (can happen in two tests)
		rjmp bsk_done
bsk2:	cpi r17, 0x01		; could be up,down, left or select
		brne bsk5
		cpi r16, 0x7c		; 
		brsh bsk7
		ldi r24, 0x04		; other possiblity for down
		rjmp bsk_done
bsk7:	ldi r24, 0x08		; left
		rjmp bsk_done
bsk5:	cpi r17, 0x02
		brne bsk6
		cpi r16, 0x2b
		brsh bsk6
		ldi r24, 0x08
		rjmp bsk_done
bsk6:	ldi r24, 0x10
bsk_done:
		pop r17
		pop r16
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
; *****  !!!!WARNING!!!!  *****
; Do NOT put a .org directive here.  The
; LCD library does that for you.
; *****  !!!!WARNING!!!!  *****
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 200
msg2:	.byte 200

; These strings contain the 16 characters to be displayed on the LCD
; Each time through the loop, the pointers l1ptr and l2ptr are incremented
; and then 16 characters are copied into these memory locations
line1: .byte 17
line2: .byte 17

; These keep track of where in the string each line currently is
l1ptr: .byte 2
l2ptr: .byte 2

