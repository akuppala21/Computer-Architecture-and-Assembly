		.ORIG x3000
		;------------------------------------------
		;----------------STRINGS-------------------
		;------------------------------------------
Greating	.STRINGZ "Welcome to the Caesar Cipher encryptor/decryptor program\n\n"
EorDPrompt	.STRINGZ "Do you want to (E)ncrypt or (D)ecrypt or press X to exit\n> "
CipherPrompt	.STRINGZ "\nEnter a cipher (1-25)\n> "
String		.STRINGZ "\nEnter a string to encrypt/decrypt(up to 200 characters)\n> "
Decrypted	.STRINGZ "\n\nHere is your string and the decription of it:\n"
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
ReadOption	GETC
		OUT
		LD R1, XComp
		ADD R1, R1, R0
		BRz Finish
		LD R1, EComp
		ADD R1, R1, R0
		BRz SetFlag
		BRnp GetCipher
SetFlag		JSR SetEncryptFlag
GetCipher	LD R0, CipherMessAdd
		PUTS
		JSR ReadCipher
		LD R0, StringMessAdd
		PUTS
		JSR ReadString
		JSR Encrypt
		JSR PrintArray
		AND R0, R0, 0
		ST R0, EncryptFlag
		ADD R0, R0, 10
		OUT
		OUT
		BR Prompt
Finish		HALT
		;------------------------------------------
		;-------------STRING ADDRESSES-------------
		;------------------------------------------
GreatingAddress .FILL x3000
PromptAddress	.FILL x303B
CipherMessAdd	.FILL x3077
StringMessAdd	.FILL x3091
ArrayAddress	.FILL x323B
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
		;------------------------------------------
		;----------FLAGS and Variables-------------
		;------------------------------------------
EncryptFlag	.FILL 0
ReadCipherR7	.FILL 0
AlphabetFlag	.FILL 1
UpperPartFlag	.FILL 1
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
		ST R2, Cipher
ReadAgainC	GETC
		OUT
		LD R2, NLComp
		ADD R2, R2, R0
		BRz returnRC
		LD R2, Cipher
		AND R1, R1, 0
		ADD R1, R1, 9
		ADD R3, R2, 0
Multiply	ADD R2, R2, R3
		ADD R1, R1, -1
		BRp Multiply
		LD R1, ZeroComp
		ADD R0, R0, R1
		ADD R2, R2, R0
		ST R2, Cipher
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
ReadAgainS	GETC
		OUT
		LD R2, NLComp
		ADD R2, R2, R0
		BRz returnRS
		ADD R5, R0, 0		; R5 stores read value
		JSR Store
		ADD R4, R4, 1		; Next column
		BR ReadAgainS
returnRS	AND R5, R5,0
		JSR Store
		LD R7, ReadStringR7
		RET
RegisterOne	.FILL 0
RegisterTwo	.FILL 0
RegisterThree	.FILL 0
RegisterSeven	.FILL 0
NumberOfColumns	.FILL 100
		;--------------------------------------
		; Stores byte at R5 at the Array(R3,R4)
		;--------------------------------------
Store		ST R1, RegisterOne
		ST R2, RegisterTwo
		ST R3, RegisterThree

		LD R6, ArrayAddress
		LD R1, NumberOfColumns
		ADD R2, R3, 0
MultS		ADD R2, R2, -1
		BRn DoneS
		ADD R6, R6, R1
		BR MultS
DoneS		ADD R6, R6, R4
		STR R5, R6, 0

		LD R1, RegisterOne
		LD R2, RegisterTwo
		LD R3, RegisterThree
		RET
		;--------------------------------------
		; Loads byte to R5 from the Array(R3,R4)
		;--------------------------------------
Load		ST R1, RegisterOne
		ST R2, RegisterTwo
		ST R3, RegisterThree

		LD R6, ArrayAddress
		LD R1, NumberOfColumns
		ADD R2, R3, 0
MultL		ADD R2, R2, -1
		BRn DoneL
		ADD R6, R6, R1
		BR MultL
DoneL		ADD R6, R6, R4
		LDR R5, R6, 0

		LD R1, RegisterOne
		LD R2, RegisterTwo
		LD R3, RegisterThree
		RET
NComp 		.FILL -78
nComp		.FILL -110
		;--------------------------------------------------------------------
		; Checks whether the character in R5 is in upper part of the alphabet
		;--------------------------------------------------------------------
CheckUpper	LD R0, NComp
		ADD R0, R0, R5
		BRn SetInLower
		LD R0, ZComp
		ADD R0, R0, R5
		BRnz SetInUpper
		LD R0, nComp
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
retCheckUp	RET
		;--------------------------------------------------------------
		; Checks whether the character in R5 is an alphabetic character
		;--------------------------------------------------------------
AComp		.FILL -65
ZComp		.FILL -90
aComp		.FILL -97
zComp		.FILL -122
Cipher		.FILL 0

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
		AND R3, R3, 0
		AND R4, R4, 0

		LD R1, Cipher	; R1 holds cipher value
LoadNext	JSR Load	; Load value to R5
		AND R5, R5, R5
		BRz returnEncrypt
		JSR CheckInAlhabet
		LD R2, AlphabetFlag
		BRz storeBack
		JSR CheckUpper
		LD R2, UpperPartFlag
		BRp encryptUpper
encryptLower	ADD R5, R5, R1
		BR storeBack
encryptUpper	ADD R1, R1, -16
		ADD R1, R1, -10
		ADD R5, R5, R1
storeBack	ADD R3, R3, 1
		JSR Store
		ADD R3, R3, -1
		ADD R4, R4, 1
		BR LoadNext
returnEncrypt	LD R7, RegisterSeven
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