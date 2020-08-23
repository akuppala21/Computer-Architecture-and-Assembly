; This code has some problems, you want to find them and fix them.
; The problems could be syntactical or logical.

; This program adds the values stored in memory locations
; A, B, and C and stores the result into memory.  There are two 
; errors. 
;

	.ORIG   x3000		; this sets where the following 
				; code will start in memory 



ONE	LD	R0, A 
	ADD	R1, R1, R0
TWO	LD	R0, B
	ADD	R1, R1, R0
THREE	LD	R0, C
	ADD	R1, R1, R0
	ST	R1, SUM
	TRAP	x25		; this HALTS the program


; Here is some data declarations, we will learn more about these soon

A	.FILL	x0001
B	.FILL	x0002
C	.FILL	x0003
SUM	.FILL	x0004
	.END
