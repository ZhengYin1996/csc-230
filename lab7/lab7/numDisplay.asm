#define LCD_LIBONLY
; Written by Victoria Li
; The topic is provided by Mr. Jason Corless
.include "lcd.asm"

.cseg

	call lcd_init			; call lcd_init to initialize the LCD
	
	;if time permit, change it from void display_num() to 
	;                               void display_num( int num) to  
	call display_num

lp:	jmp lp

display_num:
	.def dividend=r0
	.def divisor=r1
	.def quotient=r2
	.def tempt=r21
	.def char0=r3
	;preserve the values of the registers
	push dividend
	push divisor
	push quotient
	push tempt
	push char0
	push r31
	push r30

	call lcd_clr

	;store '0' in char0
	ldi tempt, '0'
	mov char0, tempt
	;Z points to first character of num in SRAM
	ldi r31, high(num)
	ldi r30, low(num)
	adiw r31:r30, 3 ;Z points to null character
	clr tempt 
	st Z, tempt ;set the last character to null
	sbiw r31:r30, 1 ;Z points the last digit location

	;initialize values for dividend, divisor
	ldi tempt, 255
	mov dividend, tempt
	ldi tempt, 10
	mov divisor, tempt
	
	clr quotient
	digit2str:
		cp dividend, divisor
		brlo finish
		division:
			inc quotient
			sub dividend, divisor
			cp dividend, divisor
			brsh division
		;change unsigned integer to character integer
		add dividend, char0
		st Z, dividend;store digits in reverse order
		sbiw r31:r30, 1 ;Z points to previous digit
		mov dividend, quotient
		clr quotient
		jmp digit2str
	finish:
	add dividend, char0
	st Z, dividend ;store the most significant digit
	
	;Now set the cursor at the desired location by specifying the row and column number
	;hint call lcd_gotoxy
	;write your code here

	;now display the digits, hint call lcd_puts
	;push argument - string address for display
	;write your code here


	;restore the values of the registers
	pop r30
	pop r31
	pop char0
	pop tempt
	pop quotient
	pop divisor
	pop dividend
	ret
	.undef dividend
	.undef divisor
	.undef quotient
	.undef tempt
	.undef char0

.dseg

num: 	.byte 4
