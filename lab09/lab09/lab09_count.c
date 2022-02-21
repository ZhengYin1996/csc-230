/* lab09_count.c
   CSC 230 - Summer 2018
   
   A program which counts from 0 - 9 repeatedly at
   approximately one second intervals.

   B. Bird - 07/21/2018
*/


#include "CSC230.h"
#include <string.h> //Include the standard library string functions



int main(){
	
	//Call LCD init (should only be called once)
	lcd_init();
	
	char str[100];

	//Copy some data into the string
	strcpy(str,"The count is X");

	//We want the LCD to say "The count is X", where
	//X is a digit from 0 to 9. The 'X' character is at
	//index 13 of the string.

	int digit = 0;
	while(1){
		
		char digit_character = digit + '0';
		str[13] = digit_character;
		lcd_xy(0,0);
		lcd_puts(str);

		digit++;
		if (digit == 10)
			digit = 0;

		_delay_ms(1000);
			
	}




	return 0;
	
}
