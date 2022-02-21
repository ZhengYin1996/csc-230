;
; a2q1.asm
;
; Write a program that displays the binary value in r16
; on the LEDs.
;
; See the assignment PDF for details on the pin numbers and ports.
;


		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

		ldi r16, 0x33		; display the value
		mov r0, r16			; in r0 on the LEDs

; Your code here
		mov r18, r16
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
		jmp done

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
		sts PORTL,r17
		out PortB,r19
		ldi r17,0b00000000
		jmp done




;
; Don't change anything below here
;
done:	jmp done
