;
; a2q2.asm
;
;
; Turn the code you wrote in a2q1.asm into a subroutine
; and then use that subroutine with the delay subroutine
; to have the LEDs count up in binary.

		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

; Your code here
; Be sure that your code is an infite loop
		ldi r25,0
		mov r0,r25
		ldi r16,0x00
		ldi r20,0x10

start:
		call display
		inc r0
		mov r16,r0
		call delay
		ldi r20,0x10
		cpi r16,0
		brne start






done:		jmp done	; if you get here, you're doing it wrong

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:
		mov r18,r16
		andi r16, 0b00100000
		brne first
		mov r16,r18
one:	andi r16, 0b00010000
		brne second
		mov r16,r18
two:	andi r16, 0b00001000
		brne third
		mov r16,r18
three:	andi r16, 0b00000100
		brne fourth
		mov r16,r18
four:	andi r16, 0b00000010
		brne fifth
		mov r16,r18
five:	andi r16, 0b00000001
		brne sixth
		mov r16,r18
		jmp end

first:	ori r19,0b00000010
		mov r16,r18
		jmp one
second: ori r19,0b00001000
		mov r16,r18
		jmp two
third:	ori r17,0b00000010
		mov r16,r18
		jmp three
fourth: ori r17,0b00001000
		mov r16,r18
		jmp four
fifth:	ori r17,0b00100000
		mov r16,r18
		jmp five
sixth:	ori r17,0b10000000
		mov r16,r18
		jmp end

end:    clr r16
		sts PORTL,r17
		out PORTB,r19



		ret
;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; registers used:
;	r20
;	r21
;	r22
;
delay:	
del1:	nop
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret
