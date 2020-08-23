
#include <WProgram.h>

/* define all global symbols here */
.global MyFunc
.global milliseconds

.text
.set noreorder


/*********************************************************************
 * Setup MyFunc
 ********************************************************************/
.ent MyFunc
MyFunc:
la $t0, PORTE
li $t1, 1
sw $t1, 0($t0)

la $t0, PORTF
li $t1, 1
sw $t1, 0($t0)
.end MyFunc
.data


/*********************************************************************
 * This is your ISR implementation. It is called from the vector table jump.
 ********************************************************************/
Lab5_ISR:


	
/*********************************************************************
 * This is the actual interrupt handler that gets installed
 * in the interrupt vector table. It jumps to the Lab5
 * interrupt handler function.
 ********************************************************************/
.section .vector_4, code
	j Lab5_ISR
	nop


.data
milliseconds: .word 0
