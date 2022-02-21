#define LCD_LIBONLY
.include "lcd.asm"

.def ZERO = r20
.def ONE = r21

.equ A = 13
.equ C = 17
.equ SEED = 19

.cseg

    ldi ZERO, 0
    ldi ONE, 1

    ;initialization (comment this code because it conflicts with the driver of LCD,
	;turning off the background light of LCD)
	call lcd_init

    ldi r16, SEED

repeat:
    rcall rand				;generate random value
	rcall led				;illuminate LEDs
	;rcall itoa_binary		;show binary string
	;rcall itoa_decimal		;show decimal string
	;rcall show_binary_str	;show binary string
	;rcall show_decimal_str	;show decimal string
    rcall delay				;delay 1 second
	
    rjmp repeat

;description: ; generate a random number in range 0~63
;input: R16 - seed or previous random number
;output:R16 - new random number 
rand:
		push r17
		push r0
		ldi r17, A
		mul r16, r17
		movw r16,r0
		ldi r17, C
		add r16, r17
		andi r16, 0b00111111
		mov r0, r16
		pop r0
		pop r17
		ret

;description: ; illuminate LEDs
;input: R16 - controlling value
;output:none
led:	

		push r16
		push r23
		push r22
		push r0

		ldi r23, 0x00
		ldi r22, 0x00
		mov r0,r16
		andi r16, 0b00100000
		brne first
		mov r16,r0
ones:	andi r16, 0b00010000
		brne second
		mov r16,r0
two:	andi r16, 0b00001000
		brne third
		mov r16,r0
three:	andi r16, 0b00000100
		brne fourth
		mov r16,r0
four:	andi r16, 0b00000010
		brne fifth
		mov r16,r0
five:	andi r16, 0b00000001
		brne sixth
		mov r16,r0
		jmp end

first:	ori r23,0b00000010
		mov r16,r0
		jmp ones
second: ori r23,0b00001000
		mov r16,r0
		
		jmp two
third:	ori r22,0b00000010
		mov r16,r0
		jmp three
fourth: ori r22,0b00001000
		mov r16,r0
		jmp four
fifth:	ori r22,0b00100000
		mov r16,r0
		jmp five
sixth:	ori r22,0b10000000
		mov r16,r0
		
		jmp end

end:    out PORTB,r23
		sts PORTL,r22
		clr r22
		clr r23
		pop r0
		pop r22
		pop r23
		pop r16
		ret


;description: convert a value to binary string
;input: R16 - the value
;output: "bstr" in data memory
itoa_binary:
		ldi YL, low(bstr)
		ldi YH, high(bstr)
		push r6
		push r16
		push r17
		ldi r17,'0'
		adiw Y, 6
		mov r6,r16
		andi r16, 0b00000001
		brne b_first
		mov r16,r6
b_ones:	ldi r17,'0'
		andi r16, 0b00000010
		brne b_second
		mov r16,r6
b_two:	ldi r17,'0'
		andi r16, 0b00000100
		brne b_third
		mov r16,r6
b_three:ldi r17,'0'	
		andi r16, 0b00001000
		brne b_fourth
		mov r16,r6
b_four:	ldi r17,'0'
		andi r16, 0b00010000
		brne b_fifth
		mov r16,r6
b_five:	ldi r17,'0'
		andi r16, 0b00100000
		brne b_sixth
		mov r16,r6

b_first:
		ldi r17,'1'
		st Y,r17
		sbiw r27:r26, 1
		mov r16,r6
		jmp ones
b_second:
		ldi r17,'1'
		st Y,r17
		sbiw r27:r26, 1
		mov r16,r6
		jmp two
b_third:
		ldi r17,'1'
		st Y,r17
		sbiw r27:r26, 1
		mov r16,r6
		jmp three
b_fourth:
		ldi r17,'1'
		st Y,r17
		sbiw r27:r26, 1
		mov r16,r6
		jmp four
b_fifth:
		ldi r17,'1'
		st Y,r17
		sbiw r27:r26, 1
		mov r16,r6
		jmp five
b_sixth:
		ldi r17,'1'
		st Y,r17
		sbiw r27:r26, 1
		mov r16,r6

		pop r17
		pop r16
		pop r6
		ret
	;-----------------------------------------------
	;             you code goes here
	;-----------------------------------------------

;description: convert a value to decimal string
;input: R16 - the value
;output: "dstr" in data memory
itoa_decimal:

	.def dividend=r0
	.def divisor=r1
	.def quotient=r2
	.def tempt=r25
	.def char0=r3
	push dividend
	push divisor
	push quotient
	push tempt
	push char0
	push r20
	push r19
	push r18
	push r16
	push r26
	push r27
	ldi XL, low(dsstr)
	ldi XH, high(dsstr)
	
	ldi tempt, '0'
	mov char0, tempt
	adiw r27:r26, 4 
	ldi r20,4
	clr tempt 
	clr r19
	st X, tempt 
	sbiw r27:r26, 1 
	mov r18,r16
	cpi r18,0b10000000
	brsh nega
	begin:
	mov tempt,r16
	mov dividend, tempt
	ldi tempt, 10
	mov divisor, tempt
	clr quotient
	jmp digit2str

	nega:
		ldi r19,0
		sub r19,r18
		mov r16,r19
		ldi r19,'-'
		jmp begin
	digit2str:
		cp dividend, divisor
		brlo finish
		division:
			inc quotient
			sub dividend, divisor
			cp dividend, divisor
			brsh division
		add dividend, char0
		st X, dividend
		sbiw X, 1 
		dec r20
		mov dividend, quotient
		clr quotient
		jmp digit2str
	finish:
	add dividend, char0
	st X, dividend 
	sbiw X, 1
	dec r20
	cpi r20,1
	breq sign
	clr r18
	st X,r18
	sbiw X, 1
	sign:
	st X,r19

	pop r27
	pop r26
	pop r16
	pop r18
	pop r19
	pop r20
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

;description: show binary on LCD at the 2st row (right aligned; 6 bits)
;input: string in data memory with label "bstr"
;output: none
show_binary_str:
	push r18
	ldi r18, 0x01
	push r18
	ldi r18, 0x0B
	push r18
	call lcd_gotoxy
	pop r18
	pop r18

	ldi r18, high(bstr)
	push r18
	ldi r18, low(bstr)
	push r18
	call lcd_puts
	pop r18
	pop r18

	pop r18
	;-----------------------------------------------
	;             you code goes here
	;-----------------------------------------------


	ret

;description: show decimal on LCD at the 1st row (left aligned; two digits)
;input: string in data memory with label "dstr"
;output: none
show_decimal_str:
	call lcd_init
	push r18
	call lcd_clr

	ldi r18, 0x00
	push r18
	ldi r18, 0x00
	push r18
	call lcd_gotoxy
	pop r18
	pop r18

	ldi r18, high(dsstr)
	push r18
	ldi r18, low(dsstr)
	push r18
	call lcd_puts
	pop r18
	pop r18
	pop r18
	ret


;description: delay for some time
;input: none
;output: none
delay:
	push r16
	ldi r16, 0
loop_delay:
	call dly_ms
	inc r16
	cpi r16,250
	brlo loop_delay
	pop r16
	ret



.dseg

	bstr: .byte 100	;for temporarily storing string (for binary display)
	dsstr: .byte 100	;for temporarily storing string (for decimal display)



	VNUM:
	push r16
	ldi r16,high(init_v)
	push r16
	ldi r16,low(init_v)
	push r16
	ldi r16, high(init_v << 1) ; address the source string in program memory
	push r16
	ldi r16, low(init_v << 1)
	push r16
	call str_init
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16
	ret		

display_strings:
	push r16

	call lcd_clr

	ldi r16, 0x01
	push r16
	ldi r16, 0x09
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(init_v)
	push r16
	ldi r16, low(init_v)
	push r16
	call lcd_puts
	pop r16
	pop r16
	call lcd_puts
	pop r16
	pop r16
	pop r16
	ret