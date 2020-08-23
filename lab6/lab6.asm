				.ORIG x3000
				BR START
ExitMessage			.STRINGZ "\nExiting the program..."
Greating			.STRINGZ "Hello And Welcome To The Conversion Programm!"
Prop				.STRINGZ "\nEnter a decimal number or press X to quit:\n> "
IncorrectMessage		.STRINGZ "\n Incorrect number, please try again"
				;------------------------
				; Prints Greating Message	
				;------------------------
START				LD R0, GreatingAddress 	; Loads Message String address
				TRAP x22 				; Prints the message
PropForNumber			JSR ClearAllReg			; Clears registers 0-6
				LD R0, PropAddress 		; Loads prop message address
				TRAP x22 				; Prints prop
ReadAgain			GETC 					; Reads character from the keyboard to R0
				OUT 					; Echos it back to the console
				;--------------------------
				; Check for 'X' character
				;--------------------------
				LD R1, ASKIIX		; Loads the 2's complement of ASKII value of 'X' to R1
				ADD R1, R1, R0		; Checks whether they are the same character
				BRnp CheckMinus 	
				LD R0, ExitMessageAdd
				TRAP x22
				HALT				; If that is the case we just HALT
				;--------------------------
				; Checks for '-' character	
				;--------------------------
CheckMinus			LD R1, ASKIIMINUS 	; Loads the 2's complement of ASKII value of '-' to R1
				ADD R1, R1, R0		; Checks whether they are the same character
				BRnp CheckNewLine	; If that is the case we just HALT
				JSR SetNegativeFlag
				BR ReadAgain
				;--------------------------
				; Checks for '\n' character	
				;--------------------------
CheckNewLine			LD R1, NewLineComp 	; R1 hold 2's complement value of ASKII value of '\n' ro R1
				ADD R1,R1,R0 		; We check for newline here
				BRz PrintDecimal	; If that is the case then we are done reading and we print the result
				;--------------------------
				; Checks for '0'-'9' character	
				;--------------------------
				LD R1, ASKIIZeroComp
				ADD R1, R1, R0
				BRn InvalidInput			
				LD R1, ASKIIZeroComp
				ADD R1, R1, -9
				ADD R1, R1, R0
				BRp InvalidInput
				BR ReadNew
InvalidInput			LD R0, IncorrMessage
				TRAP x22
				BR PropForNumber
				;--------------------------
				; Reads new digit	
				;--------------------------				
ReadNew				AND R2, R2, 0       	; Clear R2
				ADD R2, R2, 9 		; We set R2 to be 9(To multiply 10 times)
				AND R1, R1, 0 		; Clear R1
				ADD R1, R1, R3 		; LD value of R3 into R1(R3 stores the previous value)
				JSR Multiply 		; We multiply R1 by 10 here and add new digit to the result
				BR ReadAgain
				;------------------
				; Prints in decimal
				;------------------
PrintDecimal			LD R0, DecimalResAdd	;Prints the result string
				TRAP x22
				AND R6, R6, R6		; Checks for minus
				BRz LoadDivisor
				LD R0, ASKIIZero
				ADD R0, R0, -3		; Prints 45(ASKII minus)
				OUT
LoadDivisor			LD R1, DivisorAddress	; Loads the divisor
				ADD R6, R3, 0
NextDecimal			LDR R2, R1, 0		; Shifts to the next divisor
				ADD R4, R6, 0
				AND R5, R5, 0
DivideDecimal			ADD R4, R2, R6
				BRzp IncrementR5	;Increment quotient
				BRn PrintDecimalDigit
IncrementR5			ADD R5, R5, 1		
				ADD R6, R6, R2		;Decrement number
				BR DivideDecimal
PrintDecimalDigit		LD R0, ASKIIZero
				ADD R1, R1, 1
				AND R5, R5, R5
				AND R5, R5, R5
				ADD R0, R0, R5
				OUT
				AND R6, R6, R6
				BRz CheckNegative
				BR NextDecimal
				;--------------------------
				; Checks negative flag
				;--------------------------
CheckNegative			LD R6, NegativeFlag 		; We check whether the negative flag is set before we print
				BRnz PrintBinary
				JSR Invert			; JSR that transforms the value to its 2's complement analog
				;--------------------------
				; Prints the result in binary
				;--------------------------
PrintBinary			LD R0, BinResAddress	; Prints binary result message
				TRAP x22
				LD R1, BinaryMask		; Loads binary mask to R1
				AND R2, R3, R1			; Checks the first bit of entered number(R3) with the mask(R1)
				BRnp PrintOne			; Prints 0
				BRz PrintZero			; Prints 1
				;--------------------------
				; Prints '1' to the console
				;--------------------------
PrintOne			LD R0, ASKIIZero	; Loads ASKII '0'
				ADD R0, R0, 1 		; Increments it by 1 to get '1'
				OUT 				; Prints Character
				BR ShiftMask
				;--------------------------
				; Prints '0' to the console
				;--------------------------
PrintZero			LD R0, ASKIIZero	; Loads R0 with ASKII '0'
				OUT 			; Prints the character
				;----------------------------------
				; Shifts mask by 1 bit to the right
				;----------------------------------
ShiftMask			ADD R5, R4, -1	; Checks if we are done shifting
				BRz PrintInHex
				JSR Divide 		; Shifts one bit to the right
				AND R1, R1, 0	; Clear R1
				ADD R1, R1, R4	; Put R4 to R1
				AND R2, R3, R1	; Check next bit
				BRz PrintZero
				BRnp PrintOne
				;-------------------------
				; Prints the number in hex
				;-------------------------
PrintInHex			LD R0, HexResAddress	; Loads address of hex result
				TRAP x22				; Prints it
				LD R5, HEXMaskAddress	; Load address of first mask into R5
				AND R6, R6, 0 			; Clears R6
				ADD R6, R6, 11			; Put 11 into R6(that would be shift counter, because we'll need to shift the masked result by some offset)
LoadMask			LDR R2, R5, 1			; Load first mask into R2
				AND R1, R2, R3	        ; Mask the bits
				BRz PrintHexLogic		; If 0, then just print 0
				ADD R2, R6, 0			; If counter is not negative - divide
				BRn PrintHexLogic
MaskedDivision			JSR Divide
				ADD R1, R4, 0			; Store the result of division in R1
				ADD R2, R2, -1	 		; Decrement counter
				BRzp CHECK
				BRn PrintHexLogic
CHECK   			ADD R1, R1, -1			; We check that the result of division is 1
				BRz PrintHexLogic
				ADD R1, R1, 1   		; Otherwise we keep dividing(return 1 back to R1)
				BR MaskedDivision
				;---------------------------------------
				; Determines whether to print 0-9 or A-F
				;---------------------------------------
PrintHexLogic   		ADD R4, R1, -10 ; Logic that determines whethet we should print a letter or a number
				BRp PrintCharacter
				BRnz PrintNumber
				;---------------------------------------
				; Prints A-F
				;---------------------------------------
PrintCharacter  		LD R0, ASKIIZero	
				ADD R0, R0, 7	; Loads 55 to R0(ASKII's A is 65)
				ADD R0, R0, R1  ; Then we offset from it
				OUT
				BR NextMask
				;---------------------------------------
				; Prints 0-9
				;---------------------------------------
PrintNumber			LD R0, ASKIIZero; Prints number
				ADD R0, R0, R1
				OUT
NextMask			ADD R6, R6, -4	; Changes offset for next 4 bits
				ADD R2, R6, 1	; Check's whether we've checked all the bits
				BRn PrintOctal  ; If so, print octal result
				ADD R5, R5, 1	; Increments the address of the mask to the next mask
				BR LoadMask
				;---------------------------------------
				; ----------------MASKS-----------------
				;---------------------------------------
BinaryMask	.FILL x8000
HEXMaskAddress	.FILL x3117
		.FILL xF000
		.FILL x0F00
		.FILL x00F0
		.FILL x000F
OctalMask	.FILL x7000

				;---------------------------------------
				;----COMPLEMENTS AND ASKII VALUES-------
				;---------------------------------------
NewLineComp  	.FILL -10
ASKIIX		.FILL -88
ASKIIMINUS	.FILL -45
ASKIIZero	.FILL 48
ASKIIZeroComp 	.FILL -48
NegativeFlag	.FILL 0
				;---------------------------------------
				;--------DECIMAL-CONVERSION-STUFF-------
				;---------------------------------------
DivisorAddress	.FILL x3124
DecimalDivisor	.FILL -10000
		.FILL -1000
		.FILL -100
		.FILL -10
		.FILL -1
				;---------------------------------------
				; ---------STRING-ADDRESSES-------------
				;---------------------------------------
GreatingAddress	.FILL x3019
PropAddress	.FILL x3047
BinResAddress	.FILL x313A
HexResAddress	.FILL x315B
OctalResAddress	.FILL x3164
DecimalResAdd	.FILL x3131
IncorrMessage	.FILL x3076
ExitMessageAdd	.FILL x3001
				;---------------------------------------
				; -----------STRINGS--------------------
				;---------------------------------------

DecimalResult			.STRINGz "Decimal:"
BinaryResult			.STRINGZ "\nHere is your number in binary:\n"
HexResult			.STRINGZ "\nHEX: 0x"
OctalResult			.STRINGZ "\nOCTAL: 0o"
PropAgain			.FILL x309D
				;--------------------------------------------------------
				; Prints the message and checks first bit, sign extending
				;--------------------------------------------------------
PrintOctal			LD R0, OctalResAddress	; Print hex message
				TRAP x22
				LD R1, OctalMask		; Loads Mask to R1
				AND R2, R3, R1			; Checks first bit
				BRnp Print7
				;-----------
				; Prints '0'
				;-----------
				LD R0, ASKIIZero	; Prints 0
				OUT
				BR SetOctalMask
				;-----------
				; Prints '7'
				;-----------
Print7				LD R0, ASKIIZero	;PRINT 7
				ADD R0, R0, 1
				OUT
SetOctalMask			AND R6, R6, 0		;SET R6 TO 11
				ADD R6, R6, 11
				LD 	R2, OctalMask	;LOAD MASK TO R2
CheckNextThree			AND R1, R3, R2		;Check next three bits
				BRz PrintOctalNumb				 
				ADD R5, R6, 0		;Print last
				BRn PrintOctalNumb
ShiftMaskOct			JSR Divide			; Shift Mask by R6 bits(initially 11)
				ADD R1, R4, 0	
				ADD R5, R5, -1
				BRn PrintOctalNumb
				ADD R1, R1, -1		; We check that the result of division is 1
				BRz PrintOctalNumb
				ADD R1, R1, 1   	; Otherwise we keep dividing(return 1 back to R1)
				BR ShiftMaskOct
PrintOctalNumb			LD R0, ASKIIZero	; Prints number in the R1
				ADD R0, R0, R1
				OUT
DECTOCOUNT			ADD R6, R6, -3		;Decrement shift count by 3
				ADD R5, R6, 1		; check if we are done
				BRn Finish

				;--------------------------------------------------------
				; Shifts mask by 3 bits to the right to check next number
				;--------------------------------------------------------
				ADD R1, R2, 0
				JSR Divide
				ADD R2, R4, 0

				ADD R1, R2, 0
				JSR Divide
				ADD R2, R4, 0

				ADD R1, R2, 0
				JSR Divide
				ADD R2, R4, 0
				BR CheckNextThree	;Next digit
Finish				LD R1, PropAgain
				JMP R1		
			;----------------------------------------------------------------
			;-------------------------------JSR's----------------------------
			;----------------------------------------------------------------
				;--------------------------------------------------
				; Multiplies R3 by one and adds aski number from R0
				;--------------------------------------------------
Multiply   			ADD R3, R3, R1 		; Increment R3 by its initial value
				ADD R2,R2,-1 		; Decrement count
				BRp Multiply 		; If count is positive, add again
				LD R1, ASKIIZeroComp	; Load R1 with -48(2's complement of ASKII 0)
				ADD R0, R0, R1 		; R0 - 48 to get the number
				ADD R3, R3, R0 		; Add this number to the R3
				RET
ClearAllReg			AND R0, R0, 0
				AND R1, R1, 0
				AND R2, R2, 0
				AND R3, R3, 0
				AND R4, R4, 0
				AND R5, R5, 0
				AND R6, R6, 0
				RET

Invert				NOT R3, R3		;Takes 2's complement balue of R3 and resets
				ADD R3, R3, 1		; negative flag
				AND R6, R6, 0
				ST R6, NegativeFlag
				RET
						
SetNegativeFlag			AND R6, R6, 0
				ADD R6, R6, 1		; Sets negative flag to one
				ST R6, NegativeFlag
				RET

				;----------------------------------------------------------------
				; Shifts the bits in R1 to the right by 1 and stores result in R4
				;----------------------------------------------------------------
Divide  			AND R4, R4, 0
AGAIN				ADD R4, R4, 1
				ADD R1, R1, -2
				BRp AGAIN
				ADD R1, R1, 1
				BRn AGAINN
				BRzp RETURN
AGAINN				ADD R1, R1, -1
				BR AGAIN
RETURN				ADD R1,R1,-1
				RET
				.END