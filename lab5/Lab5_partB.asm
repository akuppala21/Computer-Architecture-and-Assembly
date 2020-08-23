; This program prints out my personal message 5 times
; Name: Olexiy Burov
; e-mail: oburov@ucsc.edu
; CMPE 12L
	.ORIG x3000
	LD R0, ADDRESS ; loads the address of the hello world string to register 0
	LD R5, COUNT   ; loads the counter,which is 5, into register 5
PRINT	TRAP x22       ; Prints the contents of register 0
	ADD R5, R5, -1 ; Decrements the counter by 1
	BRp PRINT      ; Branches to PRINT if counter is still positive
	HALT	       ; Otherwise, halts the program execution
ADDRESS	.FILL x3008    ; String Address declaration
COUNT 	.FILL x0005    ; Count declaration
HELLO   .STRINGZ "Hello World, this is Olexiy Burov\n" ; String declaration
	.END
