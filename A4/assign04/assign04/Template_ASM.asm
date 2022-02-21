.include "lcd.asm"
.cseg
	ldi r16,0
loop: 
	call lcd_clr
	jmp loop