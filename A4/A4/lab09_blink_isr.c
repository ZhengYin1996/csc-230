/* lab09_blink_isr.c
   CSC 230 - Summer 2018

   Blink an LED at one second intervals using timer 0.

   B. Bird - 07/21/2018
*/


#include "CSC230.h"

//This global variable is used to count the number of interrupts
//which have occurred. Note that 'int' is a 16-bit type in this case.
int interrupt_count = 0;

//Global variable to track the state of the LED on pin 52.
int LED_state = 0;


//Define the ISR for the timer 0 overflow interrupt.

ISR(TIMER0_OVF_vect){

	interrupt_count++;
	//Every 61 interrupts, flip the LED value
	if (interrupt_count >= 61){
		interrupt_count -= 61;

		//Flip the value of LED_state
		LED_state = 1 - LED_state;

		if (LED_state == 0){
			PORTB = 0x00;
		}else{
			PORTB = 0x02;
		}
	}
}


// timer0_setup()
// Set the control registers for timer 0 to enable
// the overflow interrupt and set a prescaler of 1024.
void timer0_setup(){
	//You can also enable output compare mode or use other
	//timers (as you would do in assembly).

	TIMSK0 = 0x01;
	TCNT0 = 0x00;
	TCCR0A = 0x00;
	TCCR0B = 0x05; //Prescaler of 1024
}


int main(){

	//Set data direction for Port B
	DDRB = 0xff;

	timer0_setup();

	lcd_init();

	//Enable interrupts
	//(The sei() function is defined by the AVR library as
	// a wrapper around the sei instruction)
	sei(); 



	while(1){
		//Do nothing in the main loop
	}
	
}
