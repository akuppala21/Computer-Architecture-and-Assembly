
#include <WProgram.h>

/* define all global symbols here */

.global ReadSwitchesAndButtons

.text


.set noreorder


/*********************************************************************
 * Setup MyFunc
 ********************************************************************/
.ent ReadSwitchesAndButtons
ReadSwitchesAndButtons:
# Set to the input mode, by settign first bit to 0
lw $t0, TRISE
li $t1, 0x0
sw $t1, 0($t0)
# Clear the LED register
lw $t1, PORTE
li $t2, 0x0
sw $t2, 0($t1)
# Get the switches register and perform logical right shift
# to get bits 8,9,10,11 of PORTD, which correspond to SW1,SW2,SW3,SW4
# accordingly.
lw $t2, PORTD
lw $t3, 0($t2)
srl  $t3, 8
# Turn on the LED's of corresponding switches, by writing the value of the
# switches to first 4 bits of the LED register.
lw $t4, 0($t1)
add $t3, $t3, $t4
sw $t3, 0($t1)
# Get the buttons register and mask out bits 5, 6, 7, which correspond
# to BTN2, BTN3, BTN4 accordingly.
lw $t3, 0($t2)
lw $t4, BTN234MASK
and $t3, $t3, $t4
# Turn on the LED's of corresponding buttons, by writing the value of the
# buttons to bits 5,6,7 of the LED register.
lw $t4, 0($t1)
add $t3, $t3, $t4
sw $t3, 0($t1)
# Get the buttons register PORTF and mask out bit 1 which corresponds
# to BTN1. Then shift the value by three to the left, so that the bit is
# in 4th position that corresponfs to LED5.
lw $t2, PORTF
lw $t3, 0($t2)
lw $t4, BTN1MASK
and $t3, $t3, $t4
sll $t3, 3
# Turn on the LED of corresponding to BTN1, by writing the value of the
# BTN1 to bit 4 of the LED register.
lw $t4, 0($t1)
add $t3, $t3, $t4
sw $t3, 0($t1)
# return from the call.
jr $ra
nop
.end ReadSwitchesAndButtons
.data

BTN234MASK: .word 0x000000E0
BTN1MASK: .word 0x00000002


TRISE: .word 0xBF886100
PORTE: .word 0xBF886110
PORTD: .word 0xBF8860D0
PORTF: .word 0xBF886150