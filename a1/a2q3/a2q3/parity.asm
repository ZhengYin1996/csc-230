/*
 * parity.asm
 *
 *  Created: V00915261
 *   Author: Zheng Yin 
 */ 


.cseg
.org 0
.def		P = r0
			ldi r16, 0x56
			ldi r18, 0xAB
			add r16, r18

compare:	cpi r16, 0x02
			brlo remain
			subi r16,0x02
			jmp compare

remain:		cpi r16,0x00
			brne done
			inc r0

done:		jmp done
