/* lab08_show_adc_result.c
   CSC 230 - Summer 2017
   
   This program demonstrates how to poll the ADC with C code.
   The main loop polls the ADC and displays the result on the LCD
   screen in hex.

   B. Bird - 07/12/2017
*/


#include "CSC230.h"
#include <string.h>

#define  ADC_BTN_RIGHT 0x032
#define  ADC_BTN_UP 0x0C3
#define  ADC_BTN_DOWN 0x17C
#define  ADC_BTN_LEFT 0x22B
#define  ADC_BTN_SELECT 0x316
int interrupt_count=0;
char A[5]={0,0,0,0,0};
char str[100];	
char ELMINATION[100];
unsigned char maximum_values[5] = {9,9,5,9,9};
unsigned char i=0;
char CURRENT_LAP_START[5]={0,0,0,0,0};
char LAST_LAP_START[100];
char LAST_LAP_END[100];
int lcd_state=1;
char ELMINATION[100];

unsigned short adc_result = 0; //16 bits

unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	unsigned short result_low = ADCL;
	unsigned short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}


int button_check(unsigned short adc_result){

if (adc_result >= ADC_BTN_SELECT){ return 0;}
if (adc_result >= ADC_BTN_LEFT && adc_result < ADC_BTN_SELECT){  return 1; }
if (adc_result >= ADC_BTN_DOWN && adc_result < ADC_BTN_LEFT){return 2;}
if (adc_result >= ADC_BTN_UP && adc_result < ADC_BTN_DOWN){return 3;}
if (adc_result >= ADC_BTN_RIGHT && adc_result < ADC_BTN_UP){return 4;}
	//Up button pressed
}



void normal(){
		sprintf(str,"Time: %d%d:%d%d.%d",A[0],A[1],A[2],A[3],A[4]);

		lcd_xy(0,0);
		lcd_puts(str);

		A[4]=A[4]+1;

		for(int i=4;i>=0;i--){
		if(A[i]>maximum_values[i]){
				A[i]=0;
				A[i-1]=A[i-1]+1;
				}
				}
	}
	
ISR(TIMER0_OVF_vect){

	interrupt_count++;
	//Every 61 interrupts, flip the LED value
	if (interrupt_count >= 6){
		interrupt_count -= 6;
		
		int adc_result = button_check(poll_adc());
	
	if(lcd_state==1){
		normal();
	}

	
	if (adc_result==1 & lcd_state==1){
				lcd_state=0;
		button_check(poll_adc);
		lcd_state=1;
		}
			
		

	if (adc_result==2){for (int i=4;i>=0;i--){A[i]=0;}}
	if (adc_result==3){
			for (int i=4;i>=0;i--){
			CURRENT_LAP_START[i]=0;}
		for(int g=0;g<17;g++){
			lcd_xy(g,1);
			lcd_puts(" ");
		}
		}

	if (adc_result==4){
		
		sprintf(LAST_LAP_START,"%d%d:%d%d.%d",CURRENT_LAP_START[0],CURRENT_LAP_START[1],CURRENT_LAP_START[2],CURRENT_LAP_START[3],CURRENT_LAP_START[4]);
		lcd_xy(0,1);
		lcd_puts(LAST_LAP_START);
		sprintf(LAST_LAP_END,"%d%d:%d%d.%d",A[0],A[1],A[2],A[3],A[4]);
		lcd_xy(9,1);
		lcd_puts(LAST_LAP_END);
		for (int i=4;i>=0;i--){
			CURRENT_LAP_START[i]=A[i];}
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
	//ADC Set up
	ADCSRA = 0x87;
	ADMUX = 0x40;

	timer0_setup();
	lcd_init();
	//Enable interrupts
	//(The sei() function is defined by the AVR library as
	// a wrapper around the sei instruction)
	sei(); 
	
	
	

	
	while(1){
   	
		
	//Up button pressed

		//Do nothing in the main loop
	}
	

}
