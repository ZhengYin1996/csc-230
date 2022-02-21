; a3_template.asm
; CSC 230 - Summer 2017
; 
; A3 Starter code
;
; B. Bird - 06/29/2017


; No data address definitions are needed since we use the "m2560def.inc" file

.equ SPH_DATASPACE = 0x5E
.equ SPL_DATASPACE = 0x5D

.equ STACK_INIT = 0x21FF


.include "m2560def.inc"


.include "LCDdefs.inc"

; Definitions for button values from the ADC
; Some boards may use the values in option B
; The code below used less than comparisons so option A should work for both
;Option A (v 1.1)
;.equ ADC_BTN_RIGHT = 0x032
;.equ ADC_BTN_UP = 0x0FA
;.equ ADC_BTN_DOWN = 0x1C2
;.equ ADC_BTN_LEFT = 0x28A
;.equ ADC_BTN_SELECT = 0x352
; Option B (v 1.0)
.equ ADC_BTN_RIGHT = 0x032
.equ ADC_BTN_UP = 0x0C3
.equ ADC_BTN_DOWN = 0x17C
.equ ADC_BTN_LEFT = 0x22B
.equ ADC_BTN_SELECT = 0x316


.cseg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          Reset/Interrupt Vectors                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.org 0x0000 ; RESET vector
	jmp main_begin
	
; Add interrupt handlers for timer interrupts here. See Section 14 (page 101) of the datasheet for addresses.

; According to the datasheet, the interrupt vector for timer 2 overflow is located
; at 0x001e
.org 0x001e
	jmp TIMER2_OVERFLOW_ISR 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Main Program                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; According to the datasheet, the last interrupt vector has address 0x0070, so the first
; "unreserved" location is 0x0072
.org 0x0072
; TIMER0_SETUP()
; Set up the control registers for timer 0
; In this version, the timer is set up for overflow interrupt mode
; (which triggers an interrupt every time the timer's counter overflows
;  from 255 to 0)
TIMER2_SETUP:
	push r16
	
	; Control register A
	; We set all bits to 0, which enables "normal port operation" and no output-compare
	; mode for all of the bit fields in TCCR0A and also disables "waveform generation mode"
	ldi r16, 0x00
	sts TCCR2A, r16
	
	; Control register B
	; Select prescaler = clock/1024 and all other control bits 0 (see page 126 of the datasheet)
	; Question: How is a prescalar value of clock/256 set? How would the ISR need to change
	; in such a case?
	ldi r16, 0x07 
	sts	TCCR2B, r16
	; Once TCCR0B is set, the timer will begin ticking
	
	; Interrupt mask register (to select which interrupts to enable)
	ldi r16, 0x01 ; Set bit 0 of TIMSK0 to enable overflow interrupt (all other bits 0)
	sts TIMSK2, r16
	
	; Interrupt flag register
	; Writing a 1 to bit 0 of this register clears any interrupt state that might
	; already exist (thereby resetting the interrupt state).
	ldi r16, 0x01
	sts TIFR2, r16
		
	
	pop r16
	ret



; TIMER0_OVERFLOW_ISR()
; This is not a regular function, but an interrupt handler, so there are no
; arguments or return value, and the RET instruction is not used. Instead,
; the "interrupt return" (RETI) instruction is used to end the ISR.
; Although it's not a regular function, we still have to follow normal
; function style for saving registers.
TIMER2_OVERFLOW_ISR:
	
	
	
	push r16
	; Since we pushed r16, we can now use it.
	; We need to push the contents of SREG (since we don't know whether the code
	; that was running before this ISR was using SREG for something). SREG isn't
	; a normal register, so to access its contents we have to go to data memory.
	; (Note that the address in data memory can be found via AVR Studio or the
	;  definition file. It is set via .equ at the top of this file)
	lds r16, SREG ; Load the value of SREG into r16
	push r16 ; Push SREG onto the stack
	push r17
	
	
	
	; Increment the value of OVERFLOW_INTERRUPT_COUNTER
	lds r16, OVERFLOW_INTERRUPT_COUNTER
	inc r16
	sts OVERFLOW_INTERRUPT_COUNTER, r16
	; Compare the value of the overflow counter to 6
	cpi r16, 6
	; If the value is setted as the tenth of seconds
	brlo timer2_isr_done
	
	; If the counter equals 6, clear its value back to 0
	clr r16
	sts OVERFLOW_INTERRUPT_COUNTER, r16
	;set the Y back to the start of the string 
	
	lds r16, BEGIN_AGAIN
	cpi r16,1
	brlo timer2_isr_done
	
	
	lds r16, NUMBERS
	inc  r16 
	cpi r16,('9'+1)
	brsh add_low_second
	 ; always increment the r16
	sts NUMBERS,r16
	rjmp timer2_isr_done
add_low_second:
	ldi r16,'0'
	sts NUMBERS,r16
	lds r16,seconds_low
	inc r16 
	cpi r16,('9'+1)
	brsh add_high_second
	sts seconds_low ,r16
	rjmp timer2_isr_done
add_high_second:
	ldi r16,'0'
	sts seconds_low,r16
	lds r16,seconds_high
	inc r16
	cpi r16,('5'+1)
	brsh add_low_minute
	sts seconds_high,r16
	rjmp timer2_isr_done
add_low_minute:
	ldi r16,'0'
	sts seconds_high,r16
	lds r16,minutes_low
	inc r16
	cpi r16,('9'+1)
	brsh add_high_minute
	sts minutes_low,r16
	rjmp timer2_isr_done
add_high_minute:
	ldi r16,'0'
	sts minutes_low,r16
	lds r16,minutes_high
	inc r16
	sts minutes_high,r16
	rjmp timer2_isr_done
timer2_isr_done:
	
	pop r17
	; The next stack value is the value of SREG
	pop r16 ; Pop SREG into r16
	sts SREG, r16 ; Store r16 into SREG
	; Now pop the original saved r16 value
	pop r16
	reti ; Return from interrupt
	
main_begin:
	
	; Initialize the stack
	; Notice that we use "SPH_DATASPACE" instead of just "SPH" for our .def
	; since m2560def.inc defines a different value for SPH which is not compatible
	; with STS.
	ldi r16, high(STACK_INIT)
	sts SPH_DATASPACE, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DATASPACE, r16
	
	; Initialize the LCD
	call lcd_init
	; Load the base address of the LINE_ONE array
	ldi YL, low(LINE_ONE)
	ldi YH, high(LINE_ONE)
	; Manually set the string to contain the text "Digit: "
	ldi r16, 'T'
	st Y+, r16
	ldi r16, 'i'
	st Y+, r16
	ldi r16, 'm'
	st Y+, r16
	ldi r16, 'e'
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ldi r16,' '
	st Y+,r16
	ldi r16,0
	call GET_DIGIT
	;position 6
	st Y+, r16
	ldi r16, 0
	call GET_DIGIT
	st Y+,r16
	;colon 
	ldi r16,':'
	st Y+,r16
	ldi r16,0
	call GET_DIGIT
	st Y+,r16
	ldi r16,0	
	call GET_DIGIT
	st Y+,r16
	ldi r16,'.'
	st Y+,r16
	ldi r16,0
	call GET_DIGIT
	st Y+,r16
	; Null terminator
	ldi r16, 0
	st Y+, r16
	; Set up the LCD to display starting on row 0, column 0
	ldi r16, 0 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	

	

	ldi r16, high(LINE_ONE)
	push r16
	ldi r16, low(LINE_ONE)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	
	
	
	; Set up the ADC
	
	; Set up ADCSRA (ADEN = 1, ADPS2:ADPS0 = 111 for divisor of 128)
	ldi	r16, 0x87
	sts	ADCSRA, r16
	
	; Set up ADCSRB (all bits 0)
	ldi	r16, 0x00
	sts	ADCSRB, r16
	
	; Set up ADMUX (MUX4:MUX0 = 00000, ADLAR = 0, REFS1:REFS0 = 1)
	ldi	r16, 0x40
	sts	ADMUX, r16
	
	ldi r16,1
	;default is on
	sts BEGIN_AGAIN,r16
   ; Display the string
	call TIMER2_SETUP
	ldi r16,0
	sts TIMER2_OVERFLOW_ISR,r16
	call GET_DIGIT
	sts NUMBERS,r16
	sts seconds_low,r16
	sts seconds_high,r16
	sts minutes_low,r16
	sts minutes_high,r16
	
	
	sei; enable the interrupt;	
button_check:
	
	
	; Set the ADSC bit to 1 in the ADCSRA register to start a conversion
	lds	r16, ADCSRA
	ori	r16, 0x40
	sts	ADCSRA, r16
	;wait the adc conversion to finish
	wait_for_adc:
	lds		r16, ADCSRA
	andi	r16, 0x40
	brne	wait_for_adc
	;store the result 
	lds XL,ADCL
	lds XH,ADCH 
	;check if there is a button pressed or not  
	ldi r20,low(ADC_BTN_SELECT)
	ldi r21,high(ADC_BTN_SELECT)
	cp XL,r20
	cpc XH,r21
	;if lower check if it is a select button
	brlo selectbutton
	;if no button pressed, jmp back to main
	rjmp main
	;check if the button is select button
	selectbutton:
	ldi r20,low(ADC_BTN_LEFT)
	ldi r21,high(ADC_BTN_LEFT)	
	cp XL,r20
	cpc XH,r21
	;if lower check if it is a select button
	brlo leftbutton
	ldi r17,1
	lds r16,BEGIN_AGAIN
	eor r16,r17
	sts BEGIN_AGAIN,r16
	rjmp main
	leftbutton:
	ldi r20,low(ADC_BTN_DOWN)
	ldi r21,high(ADC_BTN_DOWN)
	cp XL,r20
	cpc XH,r21
	;if lower going
	downbutton:
	ldi r20,low(ADC_BTN_UP)
	ldi r21,high(ADC_BTN_UP)
	cp XL,r20
	cpc XH,r21
	brlo main
	rjmp change_back
	
	
change_back:
		ldi r16,'0'
		sts NUMBERS,r16
		sts seconds_low,r16
		sts seconds_high,r16
		sts minutes_low,r16
		sts minutes_high,r16
	rjmp button_check

main:
	
	push r16 ;need to be poped when the A[0]>9
	push r17 ;need to be poped
	; ignore the null pointer'
	;lds r16, BEGIN_AGAIN
	;cpi r16,1
	;brne button_check; if not equal jmp back to button check
add_null:
	ldi r16,' '
	st Y,r16
	sbiw YH:YL,1
	ldi r16,0
	st Y,r16
	sbiw YH:YL,1
add_T:
	lds r16, NUMBERS
	st Y,r16 ; store the value in to the T
	call display
	rjmp add_second_low
	
add_second_low:
	sbiw YH:YL,2; move to the value to minute
	;compre the value if exceed the limit
	;increment the A[10]
	lds r16,seconds_low
	st Y,r16
	

	; else back to the engine 
	rjmp add_second_high
	
add_second_high:
	;move to A[9]
	sbiw YH:YL,1
	lds r16,seconds_high
	st Y,r16
	
	;jump it back to the orginal poistion
	rjmp add_minute_low

add_minute_low:

	;move to A[7]
	sbiw YH:YL,2
	

	lds r16,minutes_low
	st Y,r16
	;back to the A[12]
	;rjmp back to engine
	rjmp add_minute_high

add_minute_high:

	sbiw YH:YL, 1
	
	lds r16,minutes_high
	st Y,r16
	;jmp back the end of the array
	adiw YH:YL,8
	;increment the T again 
	
	pop r17
	pop r16
	rjmp button_check
stop:
	rjmp stop
		
	; GET_DIGIT( d: r16 )
; Given a value d in the range 0 - 9 (inclusive), return the ASCII character
; code for d. This function will produce undefined results if d is not in the
; required range.
; The return value (a character code) is stored back in r16
GET_DIGIT:
	push r17
	
	; The character '0' has ASCII value 48, and the character codes
	; for the other digits follow '0' consecutively, so we can obtain
	; the character code for an arbitrary single digit by simply
	; adding 48 (or just using the constant '0') to the digit.
	ldi r17, '0' ; Could also write "ldi r17, 48"
	add r16, r17
	
	pop r17
	ret

	

display:
	; Set up the LCD to display starting on row 0, column 0

	ldi r16, 0 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	
	ldi r16, high(LINE_ONE)
	push r16
	ldi r16, low(LINE_ONE)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	ret


; Include LCD library code
.include "lcd.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
; Note that no .org 0x200 statement should be present
; Put variables and data arrays here...


LINE_ONE: .byte 100
OVERFLOW_INTERRUPT_COUNTER: .byte 1
NUMBERS: .byte 1
seconds_low: .byte 1
seconds_high: .byte 1
minutes_low: .byte 1
minutes_high: .byte 1
null: .byte 1
BEGIN_AGAIN: .byte 1

