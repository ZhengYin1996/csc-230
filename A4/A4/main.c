/* a4.c
   CSC 230 - Summer 2017
   
   A simple demonstration of the main features of the LCD
   library. 
    - 07/12/2017
*/

#include "CSC230.h"
#include <string.h> //Include the standard library string functions
#include <stdio.h>

//Make an array containing the maximum value allowed for each
//digit in the representation.
unsigned char maximum_values[5] = {9, 9, 5, 9, 9};// M M S S T

unsigned char A[5];

// timer0_setup()
// Set the control registers for timer 0 to enable
// the overflow interrupt and set a prescaler of 1024.
int interrupt_count0 = 0;
void timer0_setup(){
	interrupt_count0 = 0;
	TCNT0 = 0x00;
	TCCR0A = 0x00;
	TCCR0B = 0x05; //Prescaler of 1024
	TIMSK0 = 0x01;
	TIFR0 = 0x01;
}
ISR(TIMER0_OVF_vect){
	interrupt_count0++;
	//Every 61 interrupts, flip the LED value
	if (interrupt_count0 >= 61){
		interrupt_count0 -= 61;
		PORTB= (PORTB^0x02);
	}
}	




float interrupt_count2 = 0;
void timer2_setup(){
	//You can also enable output compare mode or use other
	//timers (as you would do in assembly).
	TCNT2 = 0x00;
	TCCR2A = 0x00;
	TCCR2B = 0x06; //Prescaler of 256
	TIMSK2 = 0x01;
	TIFR2 = 0x01;
}

ISR(TIMER2_OVF_vect){
	interrupt_count2++;
	//Every 24.4 interrupts, 
	if (interrupt_count2 >= 24.4){
		interrupt_count2 -= 24.4;
		increment_time(A);
		PORTL= (PORTL^0x02);
	}
}

//Add one to the MM:SS.T representation
void increment_time(unsigned char A[]){
	

	//Add one to the last index (T)
	A[4] += 1;
	//Now work backwards if any digit exceeded the limits
	//in the array above.
	int i;
	for (i = 4; i >= 0; i--){
	
		if (A[i] > maximum_values[i]){
			A[i] = 0;
			A[i-1] += 1;
		}
	}

	//If current_values[0] exceeded 9, then wrap around to 0.
	if (A[0] > maximum_values[0]){
		A[0] = 0;
	}

}

void display(){
	char str[100];
	sprintf(str, "Time: %x%x:%x%x.%x", A[0], A[1], A[2], A[3], A[4]);
	lcd_xy(0,0);
	lcd_puts(str);
}

int main(){
	DDRL=0xFF;
	DDRB=0XFF;

	lcd_init();
	timer2_setup();
	timer0_setup();

	//Enable interrupts
	//(The sei() function is defined by the AVR library as
	// a wrapper around the sei instruction)
	sei(); 
	


	while(1) {
		display();
	}


	return 0;
	
}