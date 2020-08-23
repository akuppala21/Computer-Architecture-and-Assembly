				.ORIG x3000
				LD R0, StartAddress
				JMP R0
				;---------------------------------------
				; -----------STRINGS--------------------
				;---------------------------------------
StartAddress			.FILL x3189
ExitMessage			.STRINGZ "\nExiting the program..."
Greating			.STRINGZ "Hello And Welcome To The Shifter Programm!"
Prop				.STRINGZ "\nEnter a decimal number or press X to quit:\n> "
Shift				.STRINGZ "\nEnter a number to shift by in the range 0-15: "
LeftShiftMessage		.STRINGZ "\nThanks, here is the first number left shifted:\n"
RightShiftMessage		.STRINGZ "\nThanks, here is the first number right shifted\n"
LeftRotateMessage		.STRINGZ "\nThanks, here is the first number left rotated\n"
RightRotateMessage		.STRINGZ "\nThanks, here is the first number right rotated\n"
BinaryResult			.STRINGZ "\nHere is your number in binary:\n"
				;------------------------
				; Prints Greating Message	
				;------------------------
START				LD R0, GreatingAddress 			; Loads Message String address
				TRAP x22 				; Prints the message
PropForNumber			JSR ClearAllReg				; Clears registers 0-6
				;------------------------
				; Prints Prop Message	
				;------------------------
				LD R0, PropAddress 			; Loads prop message address
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
				BRz CheckNegative	; If that is the case then we are done reading and we print the result
				;--------------------------
				; Reads new digit	
				;--------------------------				
Read				JSR ReadDigit
				BR ReadAgain
				;--------------------------
				; Checks negative flag
				;--------------------------
CheckNegative			LD R6, NegativeFlag 		; We check whether the negative flag is set before we print
				BRnz PrintBinary
				JSR Invert			; JSR that transforms the value to its 2's complement analog
				;--------------------------
				; Prints the result in binary
				;--------------------------
PrintBinary			LD R0, BinResAddress		; Prints binary result message
				TRAP x22
				ADD R6, R3, 0
				JSR PrintR6Binary
				LD R0, ShiftMessageAdd
				PUTS
				JSR ReadShiftCount
				LD R1, ShiftCount

LeftShift			JSR ShiftR6Left
				ADD R1, R1, -1
				BRnp LeftShift
				LD R0, LShiftMessAdd
				TRAP x22
				JSR PrintR6Binary

				ADD R6, R3, 0
				AND R6, R6, R6
				BRz PrintRightShift
				LD R2, ShiftCount
RightShift			JSR ShiftR6Right
				AND R6, R6, R6
				BRz PrintRightShift
				ADD R2, R2, -1
				BRnp RightShift
PrintRightShift			LD R0, RShiftMessAdd
				TRAP x22
				JSR PrintR6Binary

				ADD R6, R3, 0
				LD R4, ShiftCount
LeftRotate			JSR RotateR6Left
				ADD R4, R4, -1
				BRnp LeftRotate
				LD R0, LRotateMessAdd
				TRAP x22
				JSR PrintR6Binary
				ADD R6, R3, 0
				AND R6, R6, R6
				BRz PrintRightRotate
				LD R4, ShiftCount
RightRotate			JSR RotateR6Right
				ADD R4, R4, -1
				BRnp RightRotate
PrintRightRotate		LD R0, RRotateMessAdd
				TRAP x22
				JSR PrintR6Binary
Finish				AND R0, R0, 0
				ST R0, NegativeFlag
				BR PropForNumber
				;---------------------------------------
				; ----------------MASKS-----------------
				;---------------------------------------
BinaryMask	.FILL x8000
				;---------------------------------------
				;----COMPLEMENTS AND ASKII VALUES-------
				;---------------------------------------
NewLineComp  	.FILL -10
ASKIIX		.FILL -88
ASKIIMINUS	.FILL -45
ASKIIZero	.FILL 48
ASKIIZeroComp 	.FILL -48
NegativeFlag	.FILL 0
RegisterSeven	.FILL 0
PR6Reg7Save     .FILL 0
ShiftCount	.FILL 0
RotateOffset1	.FILL 32767		
RotateOffset2	.FILL -32768
				;---------------------------------------
				; ---------STRING-ADDRESSES-------------
				;---------------------------------------
GreatingAddress	.FILL x301B
PropAddress	.FILL x3046
BinResAddress	.FILL x3168
ExitMessageAdd	.FILL x3003
ShiftMessageAdd	.FILL x3075
LShiftMessAdd 	.FILL x30A5
RShiftMessAdd 	.FILL x30D6
LRotateMessAdd 	.FILL x3107
RRotateMessAdd 	.FILL x3137
			;----------------------------------------------------------------
			;-------------------------------JSR's----------------------------
			;----------------------------------------------------------------
				;---------------------------------------
				; Reads by how many bits should we shift
				;---------------------------------------
ReadShiftCount			ST R7, RegisterSeven
				AND R2, R2, 0
				ST  R2, ShiftCount
ReadAgainCount			GETC
				OUT
				LD R2, NewLineComp
				ADD R2, R2, R0
				BRz returnCount
				LD R2, ShiftCount
				AND R1, R1, 0
				ADD R1, R1, 9
				ADD R4, R2, 0
MultiplyCount			ADD R2, R2, R4
				ADD R1, R1, -1
				BRp MultiplyCount
				LD R1, ASKIIZeroComp
				ADD R0, R0, R1
				ADD R2, R2, R0
				ST R2, ShiftCount
				BR ReadAgainCount
returnCount			LD R7, RegisterSeven
				RET
				;----------------------------------
				; Reads new digit from the keyboard
				;----------------------------------
ReadDigit			AND R2, R2, 0       	; Clear R2
				ADD R2, R2, 9 		; We set R2 to be 9(To multiply 10 times)
				ADD R1, R3, 0 		; LD value of R3 into R1(R3 stores the previous value)
Multiply   			ADD R3, R3, R1 		; Increment R3 by its initial value
				ADD R2,R2,-1 		; Decrement count
				BRp Multiply 		; If count is positive, add again
				LD R1, ASKIIZeroComp	; Load R1 with -48(2's complement of ASKII 0)
				ADD R0, R0, R1 		; R0 - 48 to get the number
				ADD R3, R3, R0 		; Add this number to the R3
				RET
				;------------------------
				; Sets all registers to 0
				;------------------------
ClearAllReg			AND R0, R0, 0
				AND R1, R1, 0
				AND R2, R2, 0
				AND R3, R3, 0
				AND R4, R4, 0
				AND R5, R5, 0
				AND R6, R6, 0
				RET
				;------------------------
				; Inverts contents of R3
				;------------------------
Invert				NOT R3, R3		;Takes 2's complement balue of R3 and resets
				ADD R3, R3, 1		; negative flag
				RET
				;------------------------
				; Sets the negative flag
				;------------------------
SetNegativeFlag			AND R6, R6, 0
				ADD R6, R6, 1		; Sets negative flag to one
				ST R6, NegativeFlag
				RET
				;------------------------
				; Prints 1 to the console
				;------------------------
PrintOne			ST R7, RegisterSeven
				LD R0, ASKIIZero	; Loads ASKII '0'
				ADD R0, R0, 1 		; Increments it by 1 to get '1'
				OUT
				LD R7, RegisterSeven
				RET
				;------------------------
				; Prints 0 to the console
				;------------------------
PrintZero			ST R7, RegisterSeven
				LD R0, ASKIIZero	; Loads ASKII '0'
				OUT
				LD R7, RegisterSeven
				RET
				;------------------------
				; Prints R6 bit by bit
				;------------------------
PrintR6Binary			ST R7, PR6Reg7Save
				LD R1, BinaryMask		; Loads binary mask to R1
				AND R2, R6, R1			; Checks the first bit of entered number(R3) with the mask(R1)
				BRnp One			; Prints 1
				BRz Zero			; Prints 0
				;--------------------------
				; Prints '1' to the console
				;--------------------------
One				JSR PrintOne 				; Prints Character
				BR ShiftMask
				;--------------------------
				; Prints '0' to the console
				;--------------------------
Zero				JSR PrintZero
				;----------------------------------
				; Shifts mask by 1 bit to the right
				;----------------------------------
ShiftMask			ADD R5, R1, -1	; Checks if we are done shifting
				BRz Done
				JSR Divide 	; Shifts one bit to the right
				AND R2, R6, R1	; Check next bit
				BRz Zero
				BRnp One
Done				LD R7, PR6Reg7Save
				RET
				;---------------------------------------------
				; Rotates the value in R6 one bit to the left
				;---------------------------------------------
RotateR6Right			ST R7, RegisterSeven
				ADD R2, R6, 0
				JSR ShiftR6Right
				AND R1, R1, 0
				ADD R1, R1, 1
				AND R2, R1, R2
				BRnp CarryOne
				LD R2, RotateOffset1
				AND R6, R6, R2
				BR EndRRotate
CarryOne			LD R2, NegativeFlag
				BRnp EndRRotate
				LD R2, RotateOffset2
				ADD R6, R6, R2
				BR EndRRotate
CarryOneNegative		LD R2, RotateOffset1
				ADD R6, R6, R2
				ADD R6, R6, 1
EndRRotate			LD R7, RegisterSeven
				RET
				;---------------------------------------------
				; Rotates the value in R6 one bit to the left
				;---------------------------------------------
RotateR6Left			ST R7, RegisterSeven
				LD R1, BinaryMask
				ADD R2, R6, 0
				JSR ShiftR6Left
				AND R2, R1, R2
				BRz EndLRotate
				ADD R6, R6, 1
EndLRotate			LD R7, RegisterSeven
				RET
				;---------------------------------------------
				; Shifts the value in R6 one bit to the left
				;---------------------------------------------
ShiftR6Left			ADD R6, R6, R6
				RET
				;---------------------------------------------
				; Shifts the value in R6 one bit to the right
				;---------------------------------------------
ShiftR6Right			AND R1, R1, 0
				ADD R1, R1, 15
LOOP				ADD R6, R6, 0 
				BRn NEG
				BRp POS
NEG 				ADD R6, R6, R6
				ADD R6, R6, 1
				ADD R1, R1, -1
				BRnz DONE
				BR   LOOP
POS				ADD R6, R6, R6
				ADD R1, R1, -1
				BRnz DONE
				BRnzp LOOP
DONE				LD R1, MASK
				AND R6, R6, R1
				LD R1, NegativeFlag
				BRz FinishRightShift
NegativeOffset			LD R1, BinaryMask
				ADD R6, R6, R1
FinishRightShift		RET
MASK 				.FILL x7FFF
				;----------------------------------------------------------------
				; Shifts the bits in R1 to the right by 1 and stores result in R1
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
				ADD R1, R4, 0
				RET
				.END