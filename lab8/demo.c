/* 
 * File:   demo.c
 * Author: mrg
 *
 * Created on October 31, 2014, 9:29 AM
 */

// **** Include libraries here ****
// Standard libraries
#include <stdio.h>
#include <stdlib.h>

// Microchip libraries
#include <xc.h>
#include <plib.h>
#include <p32xxxx.h>

extern void MyFunc();


// User libraries
// **** Set macros and preprocessor directives ****
#define SYS_FREQ       80000000L
#define F_PB           20000000L
#define UART_BAUD_RATE    115200
#define UART_USED          UART1

// **** Define global, module-level, or external variables here ****

// **** Declare function prototypes ****

// **** Set processor configuration ****
// Configuration Bit settings
// SYSCLK = 80 MHz (8MHz Crystal/ FPLLIDIV * FPLLMUL / FPLLODIV)
// PBCLK = 20 MHz
// Primary Osc w/PLL (XT+,HS+,EC+PLL)
#pragma config FPLLIDIV   = DIV_2     // Set the PLL input divider to 2
#pragma config FPLLMUL    = MUL_20    // Set the PLL multiplier to 20
#pragma config FPLLODIV   = DIV_1     // Don't modify the PLL output.
#pragma config FNOSC      = PRIPLL    // Set the primary oscillator to internal RC w/ PLL
#pragma config FSOSCEN    = OFF       // Disable the secondary oscillator
#pragma config IESO       = OFF       // Internal/External Switch O
#pragma config POSCMOD    = XT        // Primary Oscillator Configuration
#pragma config OSCIOFNC   = OFF       // Disable clock signal output
#pragma config FPBDIV     = DIV_4     // Set the peripheral clock to 1/4 system clock
#pragma config FCKSM      = CSECMD    // Clock Switching and Monitor Selection
#pragma config WDTPS      = PS1       // Specify the watchdog timer interval (unused)
#pragma config FWDTEN     = OFF       // Disable the watchdog timer
#pragma config ICESEL     = ICS_PGx2  // Allow for debugging with the Uno32
#pragma config PWP        = OFF       // Keep the program flash writeable
#pragma config BWP        = OFF       // Keep the boot flash writeable
#pragma config CP         = OFF       // Disable code protect




int getDelay() {
    return 0x80000;
}

int main(void)
{
    MyFunc();
}
