		; CMPE 12L
		; Lab #7
		; LC-3 Assembly: Cryptographic programm
		; Olexiy Burov: oburov@ucsc.edu
		.ORIG x3000
		;------------------------------------------
		;----------------STRINGS-------------------
		;------------------------------------------
Greating	.STRINGZ "Welcome to the Caesar Cipher encryptor/decryptor program\n\n"
EorDPrompt	.STRINGZ "Do you want to (E)ncrypt or (D)ecrypt or press X to exit\n> "
CipherPrompt	.STRINGZ "\nEnter a cipher (1-25)\n> "
String		.STRINGZ "\nEnter a string to encrypt/decrypt(up to 200 characters)\n> "
Decrypted	.STRINGZ "\n\nHere is your string and the decryption of it:\n"
Encrypted	.STRINGZ "\n\nHere is your string and the encryption of it:\n"
EResult		.STRINGZ "\n<Encrypted>"
DResult		.STRINGZ "\n<Decrypted>"
OrigResult	.STRINGZ "\n<Original>"
		;---------------------------------------------
		; Prints the greating message and prompts user
		;---------------------------------------------
PrintGreating	LD R0, GreatingAddress
		PUTS
Prompt		LD R0, PromptAddress
		PUTS
		;------------------------------------
		; Reads the selection between E and D
		;------------------------------------
ReadOption	GETC
		OUT
		;---------------
		; Checks for 'X'
		;---------------
		LD R1, XComp
		ADD R1, R1, R0
		BRz Finish
		;---------------
		; Checks for 'E'
		;---------------
		LD R1, EComp
		ADD R1, R1, R0
		;----------------
		; Sets E/D flag
		;----------------
		BRz SetFlag
		BRnp GetCipher
SetFlag		JSR SetEncryptFlag
		;--------------------------------------------------------
		; Prompts for cipher, reads it and stores it in the memory
		;--------------------------------------------------------
GetCipher	LD R0, CipherMessAdd
		PUTS
		JSR ReadCipher
		;----------------------------------------
		; Prompts for string and reads it to array
		;----------------------------------------
		LD R0, StringMessAdd
		PUTS
		JSR ReadString
		;----------------------------------------
		; Decrypt/Encrypt logic
		;----------------------------------------
		LD R0, EncryptFlag
		BRp encryptMessage
		;-----------
		; Decryption
		;-----------
decryptMessage	JSR Decrypt
		BR printMessage
		;-----------
		; Encryption
		;-----------
encryptMessage	JSR Encrypt
		;----------------------------------------
		; Prints the resulting array from memory
		;----------------------------------------
printMessage	JSR PrintArray
		AND R0, R0, 0
		;------------------------
		; Resets encryption flag
		;------------------------
		ST R0, EncryptFlag
		ADD R0, R0, 10
		;------------------------------
		; Two new lines for next prompt
		;------------------------------
		OUT
		OUT
		;----------
		; Ask again
		;----------
		BR Prompt
Finish		HALT
		;------------------------------------------
		;-------------STRING ADDRESSES-------------
		;------------------------------------------
GreatingAddress .FILL x3000
PromptAddress	.FILL x303B
CipherMessAdd	.FILL x3077
StringMessAdd	.FILL x3091
ArrayAddress	.FILL x3279
EncResAdd	.FILL x312F
DecResAdd	.FILL x313C
OrigResAdd	.FILL x3149
DecryptResult	.FILL x30CD
EncryptResult	.FILL x30FE
		;------------------------------------------
		;---------ASKII, COMPLEMENTS, ETC.---------
		;------------------------------------------
DComp		.FILL -68
EComp		.FILL -69
ZeroComp	.FILL -48
NLComp		.FILL -10
XComp		.FILL -88
AComp		.FILL -65
ZComp		.FILL -90
aComp		.FILL -97
zComp		.FILL -122
NComp 		.FILL -78
nComp		.FILL -110
		;------------------------------------------
		;----------FLAGS and Variables-------------
		;------------------------------------------
EncryptFlag	.FILL 0
ReadCipherR7	.FILL 0
AlphabetFlag	.FILL 1
UpperPartFlag	.FILL 1
Cipher		.FILL 0
RegisterOne	.FILL 0
RegisterTwo	.FILL 0
RegisterThree	.FILL 0
RegisterSeven	.FILL 0
NumberOfColumns	.FILL 100
numbOfLetters	.FILL 26
		;------------------------------------------
		;------------------JSRs--------------------
		;------------------------------------------
		;---------------------------
		; Sets encrypt flag to be 1
		;---------------------------
SetEncryptFlag	AND R1, R1, 0
		ADD R1, R1, 1
		ST R1, EncryptFlag
		RET
		;------------------------------------
		; Reads cipher value from the console
		;------------------------------------
ReadCipher	ST R7, ReadCipherR7
		AND R2,R2,0
		ST R2, Cipher  ; Resets Cipher
ReadAgainC	GETC	       ; Read new character
		OUT	       ; echo it back
		LD R2, NLComp  ; Check is it's a newline
		ADD R2, R2, R0 ; if so we are done
		BRz returnRC
		LD R2, Cipher  ; Otherwise, multiply Cipher by 10 and add new character - 48 to it
		AND R1, R1, 0
		ADD R1, R1, 9
		ADD R3, R2, 0
Multiply	ADD R2, R2, R3
		ADD R1, R1, -1
		BRp Multiply
		LD R1, ZeroComp
		ADD R0, R0, R1
		ADD R2, R2, R0
		ST R2, Cipher  ; Store it and read again
		BR ReadAgainC
returnRC	LD R7, ReadCipherR7
		RET
ReadStringR7	.FILL 0
		;---------------------------------------------------------
		; Reads string from the console and stores it in the array
		;---------------------------------------------------------
ReadString	ST R7, ReadStringR7
		AND R3, R3, 0 		; Keeps track of the column
		AND R4, R4, 0		; Keeps track of the row
ReadAgainS	GETC			; Read character
		OUT			; echo it back
		LD R2, NLComp		; check for newline
		ADD R2, R2, R0
		BRz returnRS
		ADD R5, R0, 0		; Put the read value into R5
		JSR Store		; Store it
		ADD R4, R4, 1		; Next column
		BR ReadAgainS
returnRS	AND R5, R5,0		; Put the null plug in the end
		JSR Store
		LD R7, ReadStringR7	; Return
		RET
		;--------------------------------------
		; Stores byte at R5 at the Array(R3,R4)
		;--------------------------------------
Store		ST R1, RegisterOne  	; Save registers, which we are going to use
		ST R2, RegisterTwo
		ST R3, RegisterThree

		LD R6, ArrayAddress	; Load array address
		LD R1, NumberOfColumns	; Load number of columns
		ADD R2, R3, 0		; Set R2 to number of columns
MultS		ADD R2, R2, -1		; Calculate row offset
		BRn DoneS
		ADD R6, R6, R1
		BR MultS
DoneS		ADD R6, R6, R4		; R4 is the column in which we store
		STR R5, R6, 0  		; Store R5
	
		LD R1, RegisterOne	; Restore registers
		LD R2, RegisterTwo
		LD R3, RegisterThree
		RET
		;--------------------------------------
		; Loads byte to R5 from the Array(R3,R4)
		;--------------------------------------
Load		ST R1, RegisterOne	; Save registers, which we are going to use
		ST R2, RegisterTwo
		ST R3, RegisterThree

		LD R6, ArrayAddress	; Load ArrayAddress
		LD R1, NumberOfColumns	; Load number of columns
		ADD R2, R3, 0		; Calculate row offset
MultL		ADD R2, R2, -1
		BRn DoneL
		ADD R6, R6, R1
		BR MultL
DoneL		ADD R6, R6, R4		; Offset by column index
		LDR R5, R6, 0		; Load

		LD R1, RegisterOne	; Restore registers
		LD R2, RegisterTwo
		LD R3, RegisterThree
		RET

		;--------------------------------------------------------------------
		; Checks whether the character in R5 is in upper part of the alphabet
		;--------------------------------------------------------------------
CheckUpper	LD R0, EncryptFlag	; Check whether we're decrypting or encrypting
		BRz checkDecrypt
checkEncrypt	LD R0, ZComp		; Define and check upper part for encryption
		LD R1, Cipher
		ADD R0, R0, R1
		ADD R0, R0, -1
		ADD R0, R0, R5
		BRn SetInLower
		LD R0, ZComp
		ADD R0, R0, R5
		BRnz SetInUpper
		LD R0, zComp
		ADD R0, R0, R1
		ADD R0, R0, -1
		ADD R0, R0, R5
		BRn SetInLower
		BRzp SetInUpper
SetInLower	AND R0, R0, 0
		ST R0, UpperPartFlag
		BR retCheckUp
SetInUpper	AND R0, R0, 0
		ADD R0, R0, 1
		ST R0, UpperPartFlag
		BR retCheckUp
checkDecrypt	LD R0, AComp		; Define and check upper part for decryption
		LD R1, Cipher
		NOT R2, R1
		ADD R2, R2, 1
		ADD R2, R2, R0
		ADD R2, R2, R5
		BRn SetInLower
		LD R0, ZComp
		ADD R2, R0, R5
		BRnz SetInUpper	
checkOther	LD R0, aComp
		NOT R2, R1
		ADD R2, R2, 1
		ADD R2, R0, R2
		ADD R2, R2, R5
		BRn SetInLower
		BRzp SetInUpper
retCheckUp	RET
		;--------------------------------------------------------------
		; Checks whether the character in R5 is an alphabetic character
		;--------------------------------------------------------------
CheckInAlhabet	LD R2, AComp
		ADD R2, R2, R5
		BRn NotInAlphabet
		LD R2, aComp
		ADD R2, R2, R5
		BRn CheckBetween
		BRp CheckLast
		BRz IsInAlphabet
CheckBetween	LD R2, ZComp
		ADD R2, R2, R5
		BRp NotInAlphabet
CheckLast	LD R2, zComp
		ADD R2, R2, R5
		BRp NotInAlphabet
		BRnz IsInAlphabet
NotInAlphabet	AND R2, R2, 0
		ST R2, AlphabetFlag
		BR returnCheck
IsInAlphabet	AND R2, R2, 0
		ADD R2, R2, 1
		ST R2, AlphabetFlag
returnCheck	RET
		;------------------------------------------------
		; Puts the value in Array(R3,R4) to Caesar Cipher
		;------------------------------------------------
Encrypt		ST R7, RegisterSeven
		AND R3, R3, 0		; Sets column and row to 0
		AND R4, R4, 0

		LD R1, Cipher		; R1 holds cipher value
ELoadNext	JSR Load		; Load value to R5
		AND R5, R5, R5		; Check if that is the null plug
		BRz returnEncrypt
		JSR CheckInAlhabet	; Check if that is an alphabetic character
		LD R2, AlphabetFlag
		BRz EstoreBack		; If not in alphabet store in unchanged
		JSR CheckUpper
		LD R2, UpperPartFlag
		BRp encryptUpper
encryptLower	ADD R5, R5, R1		; If in lower part, just increment by Cipher
		BR EstoreBack		; and store
encryptUpper	ADD R1, R1, -16		; If in upper part, increment by Cipher modulus 26
		ADD R1, R1, -10
		ADD R5, R5, R1
EstoreBack	ADD R3, R3, 1		; Stores the encrypted character to the first row
		JSR Store
		ADD R3, R3, -1		; Returns back to row 0
		ADD R4, R4, 1		; Switches the column
		BR ELoadNext
returnEncrypt	AND R5, R5, 0		; Puts the null plug in the end of encrypted string.
		ADD R3, R3, 1
		JSR Store
		LD R7, RegisterSeven
		RET
		;--------------------------------------------------
		; Decrypts value in Array(R3,R4) from Caesar Cipher
		;--------------------------------------------------
Decrypt		ST R7, RegisterSeven
		AND R3, R3, 0		; Set row and column to be 0
		AND R4, R4, 0

DLoadNext	JSR Load		; Load value to R5
		AND R5, R5, R5		; Check if that is null plug
		BRz returnDecrypt	
		JSR CheckInAlhabet	; Check if that an alphabetic character
		LD R2, AlphabetFlag
		BRz DstoreBack
		JSR CheckUpper		; Check alphabet part
		LD R1, Cipher		; R1 holds cipher value's complement
		NOT R1, R1
		ADD R1, R1, 1
		LD R2, UpperPartFlag
		BRp decryptUpper
decryptLower	ADD R1, R1, 15		; To decrypt "lower", deduct cipher modulus 26
		ADD R1, R1, 11
		ADD R5, R5, R1
		BR DstoreBack
decryptUpper	ADD R5, R5, R1		; To decrypt "upper", just deduct cipher
DstoreBack	ADD R3, R3, 1		; Switch to next row
		JSR Store		; Store
		ADD R3, R3, -1		; Switch back
		ADD R4, R4, 1		; Switch to next column
		BR DLoadNext
returnDecrypt	ADD R3, R3, 1		; Puts the null plug in the end of encrypted string.
		AND R5, R5, 0
		JSR Store
		LD R7, RegisterSeven
		RET
		;---------------------------
		; Prints the resulting array
		;---------------------------
PrintArray	ST R7, RegisterSeven
		LD R0, EncryptFlag
		BRz PrintDecrypt
PrintEncrypt	LD R0, EncryptResult
		PUTS
		LD R0, OrigResAdd
		PUTS
		LD R0, ArrayAddress
		PUTS
		LD R0, EncResAdd
		PUTS
		LD R0, ArrayAddress
		LD R1, NumberOfColumns
		ADD R0, R0, R1
		PUTS
		BR returnPrint
PrintDecrypt	LD R0, DecryptResult
		PUTS
		LD R0, EncResAdd
		PUTS
		LD R0, ArrayAddress
		PUTS
		LD R0, DecResAdd
		PUTS
		LD R0, ArrayAddress
		LD R1, NumberOfColumns
		ADD R0, R0, R1
		PUTS
returnPrint	LD R7, RegisterSeven
		RET
		;------------------------------------------
		;------------------Array-------------------
		;------------------------------------------
Array		.BLKW 200
		.END