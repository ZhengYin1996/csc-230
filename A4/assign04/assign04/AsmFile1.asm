#define LCD_LIBONLY
.equ TOP = 31250
.equ A = 71
.equ C = 17
.equ ADC_BTN_VAL = 0x316
.def AdcBtnValLow = r24	
.def AdcBtnValHigh = r25
.def DisplayMode = r23
.def Char0 = r22
.def CharSpace = r21
.cseg
.org 0
.org 0x0000
	rjmp reset
.org 0x0024
	rjmp isr_timer1_cmpb
.org 0x003A
	rjmp isr_adc_c
.org 0x0074
.include "lcd.asm"
.cseg
	call lcd_clr
reset:
	call lcd_init	
	;init Timer/Counter 1
	ldi r16, 0x20                       ; clear register OC1A on Compare Match
	sts TCCR1A, r16 
	ldi r16, 0x05                       ; timer clock = system clock/64
	sts TCCR1B, r16
	ldi r16, 0b00000000
	sts TCCR1C, r16 
	ldi r16, 0x04                       ;Output Compare A Interrupt
	sts TIMSK1, r16
	ldi r16, high(TOP)                  ;TOP Value
	sts OCR1BH, r16
	ldi r16, low(TOP)
	sts OCR1BL, r16
	;init ADC
	ldi r16, 0x40	; out AVcc
	sts ADMUX, r16
	ldi r16, 0x05	; use Timer 1 Compare Match B to trigger ADC conversion	
	sts ADCSRB, r16
	ldi r16, 0xaf	; enable ADC, auto-trigger and ADC complete interrupt. with 128 prescaler
	sts ADCSRA, r16
	ldi r16, 0xfe	; disable other ADC pins except ADC 0
	sts DIDR0, r16
	ser r16
	sts DIDR2, r16
	; other initializations
	; copy string templates from program memory to data memory
	; show v-number
	ldi AdcBtnValLow, low(ADC_BTN_VAL)
	ldi AdcBtnValHigh, high(ADC_BTN_VAL)
	ldi ZL, low(init_v<<1)
	ldi ZH, high(init_v<<1)
	ldi XL, low(vstr)
	ldi XH, high(vstr)
	call string_to_data
	push r16
	ldi r16, 0x01
	push r16
	ldi r16, 0x0A
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	ldi r16, high(vstr)
	push r16
	ldi r16, low(vstr)
	push r16
	call lcd_puts
	pop r16
	pop r16
	pop r16
	sei
done:
	rjmp done
isr_adc_c:
	clr XL
	clr XH
	clr ZL
	clr ZH	
	call led
presset:
	lds XL, ADCL
	lds XH, ADCH
	cp XL, AdcBtnValLow
	cpc XH, AdcBtnValHigh
	brlo pressed	
	call rand	
	call str_t
	call show_decT
	call delay
	rjmp presset
pressed:
	call rand
	call str_h
	call show_decH
	call delay
	lds XL, ADCL
	lds XH, ADCH
	cp XL, AdcBtnValLow
	cpc XH, AdcBtnValHigh
	brlo isr_adc_c
	rjmp pressed
	;update LCD
	;generate temp/humi string 
	reti
isr_timer1_cmpb:
	reti
show_decH:
	push r16
	push r17	
	rcall div10
	ldi r17, '0'
	add r0, r17
	add r1, r17
	ldi r16, ' '
	cpse r1, r17
	mov r16, r1
	sts hstr, r16
	sts hstr+1, r0
	ldi r16, '\0'
	sts hstr+2, r16	
	pop r17
	pop r16	
	push r16
	ldi r16, 0x00
	push r16
	ldi r16, 0x03
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	ldi r16, high(hstr)
	push r16
	ldi r16, low(hstr)
	push r16
	call lcd_puts
	pop r16
	pop r16
	pop r16
	ret
show_decT:
	push r16
	push r17
	sbrs r16, 5
	rjmp pos
	ldi r17, '-'
	sts tstr, r17
	rjmp next
	pos:
	ldi r17,' '
	sts tstr, r17
	next:
	rcall div10
	ldi r17, '0'
	add r0, r17
	add r1, r17
	ldi r16, ' '
	cpse r1, r17
	mov r16, r1
	sts tstr+1, r16
	sts tstr+2, r0
	ldi r16, '\0'
	sts tstr+3, r16	
	pop r17
	pop r16
	push r16
	ldi r16, 0x00
	push r16
	ldi r16, 0x02
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	ldi r16, high(tstr)
	push r16
	ldi r16, low(tstr)
	push r16
	call lcd_puts
	pop r16
	pop r16
	pop r16
	ret

div10:
	push r16
	clr r1
	db10:
	cpi r16, 10
	brlo db10_done
	subi r16, 10
	inc r1
	rjmp db10
	db10_done:
	mov r0, r16
	pop r16
	ret
rand:
	push r17
	push r1
	push r0
	ldi r17, 13
	mul r16, r17
	mov r16, r0
	ldi r17, 17
	add r16, r17
	andi r16, 0b00111111
	pop r0
	pop r1
	pop r17
	ret
str_h:
	push ZL
	ldi ZL, low(init_h<<1)
	push ZH
	ldi ZH, high(init_h<<1)
	push XL
	ldi XL, low(hstr)
	push XH
	ldi XH, high(hstr)
	call string_to_data	
	push r16
	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	ldi r16, high(hstr)
	push r16
	ldi r16, low(hstr)
	push r16
	call lcd_puts
	pop r16
	pop r16
	pop r16
	pop XH
	pop XL
	pop ZH
	pop ZL
	ret

str_t:
	push ZL
	ldi ZL, low(init_t<<1)
	push ZH
	ldi ZH, high(init_t<<1)
	push XL
	ldi XL, low(tstr)
	push XH
	ldi XH, high(tstr)
	call string_to_data	
	push r16
	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	ldi r16, high(tstr)
	push r16
	ldi r16, low(tstr)
	push r16
	call lcd_puts
	pop r16
	pop r16
	pop r16
	pop XH
	pop XL
	pop ZH
	pop ZL
	ret

led:
	push r17
	clr r17
	sbrc r16, 0
	ori r17, 0b00000010
	sbrc r16, 1
	ori r17, 0b00001000
	out PORTB, r17
	clr r17
	sbrc r16, 2
	ori r17, 0b00000010
	sbrc r16, 3
	ori r17, 0b00001000
	sbrc r16, 4
	ori r17, 0b00100000
	sbrc r16, 5
	ori r17, 0b10000000
	sts PORTL, r17
	pop r17
	ret
delay:
	push r16
	ldi r16, 0
loop_delay:
	call dly_ms
	inc r16
	cpi r16,190
	brlo loop_delay
	pop r16
	ret
string_to_data:	
	ldi r18,0
loop:
	lpm r19, Z+
	st X+, r19
	inc r18
	cpi r18,6
	brlo loop
	ret
	init_v: .db "V-5261", 0, 0
	init_h: .db "H:   %", 0, 0
	init_t: .db "T:   C", 0, 0
.dseg
	hstr: .byte 20
	tstr: .byte 20
	vstr: .byte 20