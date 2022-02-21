;
; blink_one_lab.asm
;
; This program blinks an LED on the six LED strip.
;
;
; Our 6 LED strip occupies ardruino pins 42, 44, 46, 48, 50, 52
; and Gnd (ground)
; bits are numbered from 7 ... 0
;
; That is, bit 7 is the leftmost bit
; and bit 0 is the rightmost bit
;
; Pin 42 Port L: bit 7 (PL7)
; Pin 44 Port L: bit 5 (PL5)
; Pin 46 Port L: bit 3 (PL3)
; Pin 48 Port L: bit 1 (PL1)
; Pin 50 Port B: bit 3 (PB3)
; Pin 52 Port B: bit 1 (PB1)
;
;
;
; Some ports are mapped to two addresses
; For example, if you click on PORTB in the
; simulator you will see:
;
; Name            Address
; ------ 
; DDRB             0x04 (0x24)
; PINB             0x03 (0x23)
; PORTB            0x05 (0x25)
;
; If you use the IN or OUT instruction, you 
; have to use the address listed first, in this 
; case: DDRB is 0x04, PINB is 0x03 and PORTB is 0x05
;
; The IN and OUT instructions are capable of addressing
; 0x00 to 0x3F
;
; However, click on PORTH and you will see:
; Name            Address
; ------ 
; DDRH             na (0x101)
; PINH             na (0x100)
; PORTH            na (0x102)
;
;  
; So PORTH cannot be manipulated using the IN and OUT 
; instructions, instead, use the LDS and STS instructions with
; the address listed in ( )
;
; This program is using the STS instruction

; Name            Address
; ------ 
; DDRB             0x04 (0x24)
; PINB             0x03 (0x23)
; PORTB            0x05 (0x25)
;

;;;.equ PORTB = 0x25
;;;.equ DDRB = 0x24

;
;
; PORTL control addresses:
; Name            Address
; ------ 
; DDRL             na (0x10A)
; PINL             na (0x109)
; PORTL            na (0x10B)
;
;;;.equ PORTL = 0x10B
;;;.equ DDRL = 0x10A


		ldi r17, 0xFF		; set data direction 
		out DDRB, r17
		sts DDRL, r17

lp:
		ldi r19, 0b00001010
		out PORTB, r19
		ldi r19, 0b10101010
		sts PORTL, r19

		ldi r20, 0x40
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

		ldi r19, 0x00
		out PORTB, r19
		sts PORTL, r19

		ldi r20, 0x40
del1_2:	nop
		ldi r21,0xFF
del2_2:	nop
		ldi r22, 0xFF
del3_2:	nop
		dec r22
		brne del3_2
		dec r21
		brne del2_2
		dec r20
		brne del1_2
			
		rjmp lp

