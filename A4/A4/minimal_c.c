// minimal_c.c
// David Clark
// CSC230 Fall2018

#include "CSC230.h"


void do_something(void) {
	
}

int main(){
	
	unsigned char my_variable = 10;  		 //  8-bit values
	unsigned int my_other_variable = 39047;  //  16-bit values
	
	DDRB = 0xFF;
	
	while (1) {
		do_something();	
	}
	
	return 0;

}