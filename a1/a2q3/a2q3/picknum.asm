/*
 * picknum.asm
 *
 *  Created: V00915261
 *   Author: Zheng Yin 
 */ 

.equ COUNT = 20

.cseg

.org 0

	rjmp start

	src: .db 33, 60, 24, 55, 20, 44, 38, 90, 40, 0, 22, 80, 57, 43, 31, 100, 33, 27, 24, 18

start:
	ldi ZL, low(src<<1)
	ldi ZH, high(src<<1)
	ldi YL, low(dest)
	ldi YH, high(dest)
	ldi r17 , 0x00
loop:
	inc r17
	lpm r16,Z+
	cpi r16,0x14
	brlo loop
	cpi r16,0x28
	brlo testEven
	cpi r17, COUNT
	brsh done
	jmp loop

testEven:
	mov r18, r16
	mov r19, r16
	lsr r18
	sub r19,r18
	sub r19,r18
	cpi r19,0x00
	brne loop
	st Y+,r16
	jmp loop

done:
	rjmp done

.dseg

.org 0x200

	dest: .byte 20