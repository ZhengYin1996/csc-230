// A4.c
// ZhengYin
// V00915261
// CSC230 Fall2018

#include "CSC230.h"
#include <stdio.h>
#include <string.h>
#define  ADC_BTN_RIGHT 0x032
#define  ADC_BTN_UP 0x0C3
#define  ADC_BTN_DOWN 0x17C
#define  ADC_BTN_LEFT 0x22B
#define  ADC_BTN_SELECT 0x316
#define  ADC_BTN_BREAK  0x3E8
#define  ADC_MID 0xE8
int interrupt_count=0;
char str[100];
unsigned char i=0;

unsigned short adc_result = 0; 
unsigned char portb_pattern[] = { 2, 8, 0, 0,  0,   0};
unsigned char portl_pattern[] = { 0, 0, 2, 8, 32, 128};
char* upper = ("This is the first message displayed on the first line of the LCD.");
char* lower = ("On the second line of the LCD there is another message that is scrolled.");
unsigned short result_low;
unsigned short result_high;
unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	result_low = ADCL;
	short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}
int button_check(unsigned short adc_result){
	if(adc_result >= ADC_BTN_SELECT&& result_low >= ADC_MID){return 0;}
	if (adc_result >= ADC_BTN_SELECT&& result_low < ADC_MID){ return 1;}
	if (adc_result >= ADC_BTN_LEFT && adc_result < ADC_BTN_SELECT){  return 2; }
	if (adc_result >= ADC_BTN_DOWN && adc_result < ADC_BTN_LEFT){return 3;}
	if (adc_result >= ADC_BTN_UP && adc_result < ADC_BTN_DOWN){return 4;}
	if (adc_result >= ADC_BTN_RIGHT && adc_result < ADC_BTN_UP){return 5;}
	if(adc_result <= ADC_BTN_RIGHT){return 6;}
	//Up button pressed
}
int select =0;
void changeMess()
{
	
	if (select ==0)
	{
		upper = ("This is the message on the first line. Here it goes.");
		lower = ("--- buy --- more --- pop --- buy ");
		select =1;
	}
	else
	{
		upper = ("This is the first message displayed on the first line of the LCD.");
		lower = ("On the second line of the LCD there is another message that is scrolled.");
		select =0;
	}
}
int delayTime =500;
void delaySpeed()
{
	if (button_check(poll_adc()) == 3)
	{
		delayTime = delayTime*2;
	}
	if (button_check(poll_adc()) == 6)
	{
		delayTime =delayTime/2;
	}
}
int led_pos=0;
void delay()
{
	DDRL = 0x00;
	DDRB = 0x00;
	if (led_pos <6)
	{
		PORTB = portb_pattern[led_pos];
		PORTL = portl_pattern[led_pos];
		led_pos++;
	}
	
	for (int i =0;i<delayTime;i++)
	{
		_delay_ms(1);
	}
	if (led_pos==6)
	{
		led_pos=0;
	}
	
}
char sentenceLow[16];
int secondNum2 =0;
int posLow = 0;
char sentenceUp[16];
int secondNum1 =0;
int posup = 0;
void sentUp(char* sent1){
int iup =0;	
int j =0;
	if (posup < strlen(sent1)-15)
	{
			while(iup<16)
			{
			sentenceUp[iup]=sent1[iup+posup];
			iup++;
			}
	}
	else if (posup >= strlen(sent1)-15)
	{
		while (j<15)
		{
			sentenceUp[j] = sentenceUp[j+1];	
			j++;		
		}
		sentenceUp[15] = sent1[secondNum1];
		secondNum1++;
		if (secondNum1>15)
		{
			secondNum1=0;
			posup =0;
		}
	}	
	posup++;
}

void sentLow(char* sent2){
	int iup =0;
	int j =0;
	
	if (posLow < strlen(sent2)-15)
	{
		while(iup<16)
		{
			sentenceLow[iup]=sent2[iup+posLow];
			iup++;
		}
	}
	else if (posLow >= strlen(sent2)-15)
	{
		while (j<15)
		{
			sentenceLow[j] = sentenceLow[j+1];
			j++;
			
		}
		sentenceLow[15] = sent2[secondNum2];
		secondNum2++;
		if (secondNum2>15)
		{
			secondNum2=0;
			posLow =0;
		}
	}
	posLow++;
}
void show()
{
	lcd_init();
	sentUp(upper);
	lcd_xy(0,0);
	lcd_puts(sentenceUp);
	sentLow(lower);
	lcd_xy(0,1);
	lcd_puts(sentenceLow);
	delay();
	
}

void printSent(){
	while (1)
	{
		
		if (button_check(poll_adc()) == 2)
		{
			changeMess();
		}
		if (button_check(poll_adc()) == 3||button_check(poll_adc()) == 6)
		{
			delaySpeed();
		}
		if (button_check(poll_adc()) == 5)
		{
			normal2();
		}
		
		show();
	}
}
void normal2(){
	while (1)
	{
		if (button_check(poll_adc()) == 4)
		{
			printSent();
		}
		
		
	}
}

ISR(TIMER0_OVF_vect){
	interrupt_count++;
	//Every 61 interrupts, flip the LED value
	if (interrupt_count >= 6){
		interrupt_count -= 6;
		
		int adc_result = button_check(poll_adc());
		
		if(adc_result ==0){
				printSent();	
		}
		if(adc_result ==1){
			changeMess();
			printSent();
		}
		
	}
}
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
		
	while (1)
	{
	}
	

}