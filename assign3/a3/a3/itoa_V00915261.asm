.equ COUNT = 4

.cseg
.org 0

	rjmp start

	nums: .db 0x12, 0x45, 0x89, 0xCD

start:

	ldi ZL, low(nums<<1)
	ldi ZH, high(nums<<1)

	ldi r17, 0
loop:
	lpm r16, Z+
	ldi XL, low(str)
	ldi XH, high(str)
	rcall itoa

	inc r17
	cpi r17, COUNT
	brlo loop

done:
	rjmp done


;description: convert a signed magnitude value into 0-endign string
;input: R16 - the value
;       X   - starting address of the string
;output:none   
itoa:
	.def dividend=r0
	.def divisor=r1
	.def quotient=r2
	.def tempt=r25
	.def char0=r3
	;preserve the values of the registers
	push dividend
	push divisor
	push quotient
	push tempt
	push char0
	push r20
	push r19
	push r18
	push r16
	ldi tempt, '0'
	clr r19
	mov char0, tempt
	adiw r27:r26, 4 
	ldi r20,4
	clr tempt 
	st X, tempt 
	sbiw r27:r26, 1 
	mov r18,r16
	cpi r18,0b10000000
	brsh nega
	;initialize values for dividend, divisor
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
		;change unsigned integer to character integer
		add dividend, char0
		st X, dividend;store digits in reverse order
		sbiw r27:r26, 1 ;Z points to previous digit
		dec r20
		mov dividend, quotient
		clr quotient
		jmp digit2str
	finish:
	add dividend, char0
	st X, dividend 
	sbiw r27:r26, 1
	dec r20
	cpi r20,1
	breq sign
	clr r18
	st X,r18
	sbiw r27:r26, 1
	sign:
	st X,r19
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
		ret


.dseg

.org 0x200

	str: .byte 100