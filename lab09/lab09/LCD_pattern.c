// LCD_pattern.c
// David Clark
// CSC230 Fall2018

#include "CSC230.h"

// A demonstration of using LEDs and the _delay_ms() function.

// Light each of the LCDs from bottom to top in turn, with a
// delay between each.

// Stage       PORTB         PORTL        LED pattern
//   0       00000010      00000000         000001
//   1       00001000      00000000         000010
//   2       00000000      00000010         000100
//   3       00000000      00001000         001000
//   4       00000000      00100000         010000
//   5       00000000      10000000         100000

unsigned char portb_pattern[] = { 2, 8, 0, 0,  0,   0};
unsigned char portl_pattern[] = { 0, 0, 2, 8, 32, 128};
	
int main(){
	
	DDRB = 0xFF;
	DDRL = 0xFF;
	
	while (1) {
		for (int i = 0; i < 6; i++) {
			PORTB = portb_pattern[i];
			PORTL = portl_pattern[i];
			_delay_ms(250);
		}
	}
	
	// Challenge: modify this program so the light sequence goes from
	// bottom to top, then back down to the bottom one led at a time.
	
	return 0;

}