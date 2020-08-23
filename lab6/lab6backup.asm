		.ORIG x3000
		LD R0, GREATING ; Load Message String address
		TRAP x22 	; Print the message
PRP		JSR CLEARALL
		LD R0, PROP 	; Load prop message
		TRAP x22 	; print prop
LOOP		GETC 		; Read character from the keyboard to R0
		OUT 		; echo it back to the console
		LD R1, X
		ADD R1, R1, R0
		BRz MH
		LD R1, MINUS
		ADD R1, R1, R0
		BRnp NSN
		JSR SetNF
		BR LOOP
NSN		LD R1, NLCOMP 	; R1 hold 2's complement value of 10(new line)
		ADD R1,R1,R0 	; We check for newline here
		BRz PRRES
		LD R2, TEN 		; Multiply counter
		AND R1, R1, 0 		; Clear R1
		ADD R1, R1, R3 		; LD value of R3 into R1
		JSR MULTP
		BR LOOP
PRRES		AND R6, R6, R6
		BRnz PR
		JSR Invert
PR		LD R0, RESADD	;PRINT RESULT
		TRAP x22
		LD R1, MASK	;LOAD MASK TO R1
		AND R2, R3, R1	;CHECK FIRST BIT
		BRnp PRINTO	;PRINT BIT
		BRz PRINTZ
PRINTO		LD R0, ZASKII	;Prints ASKII '1' to the concole
		ADD R0, R0, 1
		OUT
		BR STOP
PRINTZ		LD R0, ZASKII	;Prints ASKII '0' to the console
		OUT
STOP		ADD R5, R4, -1	;CHECK IF WE ARE DONE DIVIDING
		BRz HEX
		JSR DIVIDE
S		AND R1, R1, 0	;Clear R1
		ADD R1, R1, R4	;Put R4 to R1
		AND R2, R3, R1	;Check next bit
		BRz PRINTZ
		BRnp PRINTO
HEX		LD R0, HEXM	;Print hex message
		TRAP x22
		LD R5, MADD	;Load address of first mask into R5
		AND R6, R6, 0
		ADD R6, R6, 11	;Put 11 into R6(that would be shift counter)
RM		LDR R2, R5, 1	;Load first mask into R2
		AND R1, R2, R3	;Mask the bits
		BRz MH		;If 0, then just print 0
		ADD R2, R6, 0	; If counter is not negative - divide
		BRn MH
D		JSR DIVIDE
		ADD R1, R4, 0	; Store the result of division in R1
		ADD R2, R2, -1	; Decrement counter
		BRzp CHECK
		BRn MH
CHECK		ADD R1, R1, -1	; We check that the result of division is 1
		BRz MH
		ADD R1, R1, 1   ; Otherwise we keep dividing(return 1 back to R1)
		BR D
MH		ADD R4, R1, -10 ; Logic that determines whethet we should print a letter or a number
		BRp PRINTC
		BRnz PRINTN
PRINTC		LD R0, ZASKII	; Prints letter
		ADD R0, R0, 7
		ADD R0, R0, R1
		OUT
		BR DECRCOUNT
PRINTN		LD R0, ZASKII	; Prints number
		ADD R0, R0, R1
		OUT
DECRCOUNT	ADD R6, R6, -4	; Prepares for next 4 bits
		ADD R2, R6, 1	; Check's whether we've checked all the bits
		BRn OCTAL
		ADD R5, R5, 1	; Increments the address of the mask to the next mask
		BR RM

MESSAGE		.STRINGZ "Hello And Welcome To The Conversion Programm!"
PMESS		.STRINGZ "\nEnter a decimal number or press X to quit:\n> "
RESULT		.STRINGZ "Here is your number in binary:\n"
INHEX		.STRINGZ "\nHEX: "
INOCT		.STRINGZ "\nOCTAL: "
GREATING 	.FILL x3051
PROP 		.FILL x307F
RESADD		.FILL x30AE
HEXM		.FILL x30CE
OCTALM		.FILL x30D5
TEN 		.FILL 9
NLCOMP  	.FILL xFFF6
ASKII 		.FILL xFFD0
MASK		.FILL x8000
ZASKII		.FILL 48
X		.FILL -88
MINUS		.FILL -45
MADD		.FILL x30EA
MHEX1		.FILL xF000
MHEX2		.FILL x0F00
MHEX3		.FILL x00F0
MHEX4		.FILL x000F

MOCT		.FILL 0x7000






OCTAL		LD R0, OCTALM	;Print hex message
		TRAP x22
		LD R1, MASK	;LOAD MASK TO R1
		AND R2, R3, R1	;CHECK FIRST BIT
		BRnp PRINT8
		LD R0, ZASKII	;PRINT 0
		OUT
		BR OO
PRINT8		LD R0, ZASKII	;PRINT 7
		ADD R0, R0, 7
		OUT
OO		AND R6, R6, 0	;SET R6 TO 11
		ADD R6, R6, 11
		LD R2, MOCT	;LOAD MASK TO R1
OM		AND R1, R3, R2	;CHECK NEXT THREE BITS
		BRz PRINTON	;PRINT THE BIT IF ZERO
		ADD R5, R6, 0	;PRINT LAST ONE
		BRn PRINTON
DO		JSR DIVIDE	; Shift by R6 bits(initially 11)
		ADD R1, R4, 0	
		ADD R5, R5, -1
		BRn PRINTON
CHECK1		ADD R1, R1, -1	; We check that the result of division is 1
		BRz PRINTON
		ADD R1, R1, 1   ; Otherwise we keep dividing(return 1 back to R1)
		BR DO
PRINTON		LD R0, ZASKII	; Prints number
		ADD R0, R0, R1
		OUT
DECTOCOUNT	ADD R6, R6, -3	;Decrement shift count by 3
		ADD R5, R6, 1	; check if we are done
		BRn F

		ADD R1, R2, 0	;Shifts mask by 3 bits
		JSR DIVIDE
		ADD R2, R4, 0

		ADD R1, R2, 0
		JSR DIVIDE
		ADD R2, R4, 0

		ADD R1, R2, 0
		JSR DIVIDE
		ADD R2, R4, 0
		BR OM		;Next digit
		
F		HALT


CLEARALL	AND R0, R0, 0
		AND R1, R1, 0
		AND R2, R2, 0
		AND R3, R3, 0
		AND R4, R4, 0
		AND R5, R5, 0
		AND R6, R6, 0
		RET

Invert		NOT R3, R3		;Takes 2's complement balue of R3 and resets
		ADD R3, R3, 1		; negative flag
		;AND R6, R6, 0
		RET
				
SetNF		AND R6, R6, 0
		ADD R6, R6, 1		; Sets negative flag to one
		RET
				; Multiplies R3 by one and adds aski number from R0
MULTP   	ADD R3, R3, R1 		; Increment R3 by its initial value
		ADD R2,R2,-1 		; Decrement count
		BRp MULTP 		; If count is positive, add again
		LD R1, ASKII 		; Load R1 with -48(2's complement of ASKII 0)
		ADD R0, R0, R1 		; R0 - 48 to get the number
		ADD R3, R3, R0 		; Add this number to the R3
		RET

DIVIDE  	AND R4, R4, 0		; Shifts the bits in R1 to the right by 1
AGAIN		ADD R4, R4, 1		; and stores result in R4
		ADD R1, R1, -2
		BRp AGAIN
		ADD R1, R1, 1
		BRn AGAINN
		BRzp RETURN
AGAINN		ADD R1, R1, -1
		BR AGAIN
RETURN		ADD R1,R1,-1
		RET
		.END