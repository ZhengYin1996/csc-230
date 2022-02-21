; Michael Reiter
; V00831568
; CSC 230 assignment 3
; A flashing sign pattern for the ATMEGA 2560

#define LCD_LIBONLY
.include "lcd.asm"

.cseg

main:
	call lcd_init				; Initialize LCD
	call lcd_clr				; Clear LCD
	call initialize_strings		; Move strings from program memory to data memory
	call loop_3_times			; Repeat flashing pattern 3 times
	call flash_character		; Flash a character at the center of the LCD

done:
	rjmp done

loop_3_times:
	.def counter = r16			; Protect registers in use
	push counter
	ldi counter, 3
loop:
	call message_sequence		; for (int i = 3; i > 0; i--)
	dec counter
	brne loop					; Break from the loop once the counter reaches 0 (after 3 iterations)
	call lcd_clr

	pop counter
	.undef counter
	ret

message_sequence:
	.def row = r16
	.def column = r17
	.def counter = r18
	push row							; Protect registers in use
	push column
	push counter
	ldi counter, 2						; for (int i = 2; i > 0; i--)
loop2:
	cpi counter, 2						; Switch statement to set cursor location on each iteration
	breq first_iteration
	cpi counter, 1
	breq second_iteration
display:
	call lcd_clr		; Clear the LCD and set cursor location
	push row
	push column
	call lcd_gotoxy
	pop column
	pop row
	call display_msg_1	; Display "Michael Reiter"
	call delay

	call lcd_clr		; Clear the LCD and set cursor location
	push row
	push column
	call lcd_gotoxy
	pop column
	pop row
	call display_msg_2	; Display "CSC 230 Student!"
	call delay

	dec counter			; Break from the loop once the counter reaches 0 (after 4 iterations)
	brne loop2

	rjmp skip		; After the loop's completion, skip the following statements that set cursor locations
first_iteration:				; (0,0)
	ldi row, 0
	ldi column, 0
	rjmp display	; Jump back to before the loop after setting the cursor location
second_iteration:	; (1,1)
	ldi row, 1
	ldi column, 1
	rjmp display
skip:
	pop counter
	pop column
	pop row
	.undef counter
	.undef column
	.undef row
	ret

flash_character:			; Flash the character "!" three times
	.def row = r16			; Protect registers in use
	.def column = r17
	.def flash_count = r18
	push row
	push column
	push flash_count
	ldi flash_count, 3
loop3:
	call lcd_clr
	ldi row, 0
	push row
	ldi column, 7	; Push (0,7) to center the cursor
	push column
	call lcd_gotoxy
	pop column
	pop row
	call display_character
	call delay
	call lcd_clr
	call delay
	
	dec flash_count
	brne loop3

	pop flash_count
	pop column
	pop row
	.undef flash_count
	.undef column
	.undef row
	ret

display_character:			; Display "!" on the LCD
	.def temp = r16
	push temp				; Protect registers in use

	ldi temp, high(char)
	push temp
	ldi temp, low(char)
	push temp
	call lcd_puts
	pop temp
	pop temp

	pop temp
	.undef temp
	ret

display_msg_1:				; Display "Michael Reiter" on the LCD
	.def temp = r16
	push temp				; Protect registers in use

	ldi temp, high(line_1)
	push temp
	ldi temp, low(line_1)
	push temp
	call lcd_puts
	pop temp
	pop temp

	pop temp
	.undef temp
	ret

display_msg_2:				; Display "CSC 230 Student!" on the LCD
	.def temp = r16
	push temp				; Protect registers in use

	ldi temp, high(line_2)
	push temp
	ldi temp, low(line_2)
	push temp
	call lcd_puts
	pop temp
	pop temp

	pop temp
	.undef temp
	ret

delay:					; Delay using nested loops. 8094843 cycles is around half a second at 16MHz.
	.def first = r16
	.def second = r17
	.def third = r18
	push first			; Protect registers in use
	push second
	push third

	ldi first, 0x1D
del1:
	nop
	ldi second,0xFF
del2:
	nop
	ldi third, 0xFF
del3:
	nop
	dec third
	brne del3
	dec second
	brne del2
	dec first
	brne del1

	pop third
	pop second
	pop first
	.undef third
	.undef second
	.undef first
	ret

initialize_strings:				; Copy strings from program memory to data memory
	.def temp = r16
	push temp					; Protect registers in use

	ldi temp, high(line_1)		; Push destination (data memory)
	push temp
	ldi temp, low(line_1)
	push temp
	ldi temp, high(msg1 << 1) 	; Push source (program memory)
	push temp
	ldi temp, low(msg1 << 1)
	push temp
	call str_init
	pop temp
	pop temp
	pop temp
	pop temp

	ldi temp, high(line_2)		; Push destination (data memory)
	push temp
	ldi temp, low(line_2)
	push temp
	ldi temp, high(msg2 << 1) 	; Push source (program memory)
	push temp
	ldi temp, low(msg2 << 1)
	push temp
	call str_init
	pop temp
	pop temp
	pop temp
	pop temp

	ldi temp, high(char)			; Push destination (data memory)
	push temp
	ldi temp, low(char)
	push temp
	ldi temp, high(char_p << 1) 	; Push source (program memory)
	push temp
	ldi temp, low(char_p << 1)
	push temp
	call str_init
	pop temp
	pop temp
	pop temp
	pop temp

	pop temp
	.undef temp
	ret

; The strings are initially stored in program memory
msg1: .db "Michael Reiter", 0
msg2: .db "CSC 230 Student!", 0
char_p: .db "!", 0

.dseg

; The strings are subsequently copied into data memory
line_1: .byte 17
line_2: .byte 17
char: .byte 2