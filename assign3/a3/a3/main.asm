/*
 * rled.asm
 *
 *  Created:
 *   Author:
 */ 

 .def ZERO = r20
 .def ONE = r21

 .cseg

.org 0

		ldi ZERO, 0
		ldi ONE, 1
	;necessary initialization
.equ A = 13
.equ C = 17
.equ SEED = 24
		ldi r16, SEED
		sts DDRL, r16
		out DDRB, r16
repeat:
	; generate a random number in range 0~63 and store it in R16
random:
		
		ldi r17, A
		mul r16, r17
		mov r16, r0
		ldi r17, C
		add r16, r17
		andi r16, 0b00111111
		mov r0, r16
	; illuminate LEDs according to value in R16
display:
		ldi r23, 0x00
		ldi r22, 0x00
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

	
delay: 	; delay 1s
	clr r19
	clr r18
loop1:
	ldi r20, 20
loop2:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec r20
	cpi r20, 0
	brne loop2
	add r18, ONE
	adc r19, ZERO
	cpi r19, 250
	brne loop1

	;another round
	rjmp repeat
