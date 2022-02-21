;
; 230_A1_ZhengYin_V00915261.asm
;
; Created: 2019/1/29 19:19:32
; Author : Zheng Yin
;


    .cseg
    .org 0

; Replace with your application code
		clr r0
		clr r1
		ldi r16, 0x13
		ldi r17, 0x0d
		ldi r18, 0x40
		ldi r19, 0x00
		mul r16, r17

		movw r16,r0
		ldi r17, 0x11
		add r16, r17

div:	sub r16, r18
		inc r19
		cp r16, r18
		brlo finish
		jmp div

finish:	mov r20,r16
		mov r16,r19
		jmp done

done:	jmp done