TITLE Programming Assignment #1     (prog1.asm)

; Author: Kristen Harrison
; Course / Project ID: CS 271                     Date: 8 October 2017
; Description: This program will introduce the programmer, read in two numbers, 
; calculate the sum, difference, product, and integer quotient and remainder, and 
; print the results. The program also validates that the second number is less than the first, 
; repeats until the user quits, and displays the quotient as a floating point number.

INCLUDE Irvine32.inc

.data
; Intro
intro		BYTE	"Programming Assignment 1, by Kristen Harrison", 0
ec_1		BYTE	"**EC: Program repeats until the user chooses to quit.", 0
ec_2		BYTE	"**EC: Program verifies second number to be less than the first.", 0
ec_3		BYTE	"**EC: Program displays the quotient as a floating-point number, rounded to .001", 0

; Instructions for the user
prompt_1	BYTE	"First number: ", 0
prompt_2	BYTE	"Second number: ", 0
prompt_3	BYTE	"The second number must be less than the first!", 0
prompt_4	BYTE	"Press 0 to quit, or any other number to repeat the program.", 0

; First and second user-entered values
int_1		DWORD	?
int_2		DWORD	?

; Rounding precision
precision	REAL8	1000.0

; Calculations 
sum			DWORD	? 
diff		DWORD	?
product		DWORD	?
quotient	DWORD	?
remainder	DWORD	?
fl_quot		REAL8	?

; Result strings
plus		BYTE	" + ", 0
minus		BYTE	" - ", 0
times		BYTE	" * ", 0
divided_by	BYTE	" / ", 0
with_rem	BYTE	", with a remainder of ", 0
equals		BYTE	" = ", 0

; Terminating message
goodBye		BYTE	"Good-bye !", 0

.code
main PROC

; Introduction
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_3
	call	WriteString
	call	CrLf
	call	CrLf

Start:
	; Initialize FPU
	finit

; Get user input
	; Get and store first number
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		int_1, eax

	; Get second number
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	ReadInt
	
	; Validate second number is less than the first
Validate:
	cmp		eax, int_1
	; skip rest of block if eax < int_1
	jb		endValidate
	mov		edx, OFFSET prompt_3
	call	WriteString
	call	CrLf
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	ReadInt
	; loop until correct input is given
	jmp		Validate			

	; Store validated second number
endValidate:
	mov		int_2, eax
	call	CrLf

; Calculate the results
	; Calculate the sum
	mov		eax, int_1
	add		eax, int_2
	mov		sum, eax

	; Calculate the difference
	mov		eax, int_1
	sub		eax, int_2
	mov		diff, eax

	; Calculate the product
	mov		eax, int_1
	mul		int_2
	mov		product, eax

	; Calculate the quotient and remainder
	mov		eax, int_1
	cdq
	div		int_2
	mov		quotient, eax
	mov		remainder, edx

	; Calculate floating point quotient
	fild	int_1
	fidiv	int_2
	; multiply, round to int, and divide by 1000 to get .001 precision
	fmul	precision
	frndint	
	fdiv	precision			
	fst		fl_quot

; Display the results
	; Display the sum
	mov		eax, int_1
	call	WriteDec
	mov		edx, OFFSET plus
	call	WriteString
	mov		eax, int_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf

	; Display the difference
	mov		eax, int_1
	call	WriteDec
	mov		edx, OFFSET minus
	call	WriteString
	mov		eax, int_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, diff
	call	WriteDec
	call	CrLf

	; Display the product
	mov		eax, int_1
	call	WriteDec
	mov		edx, OFFSET times
	call	WriteString
	mov		eax, int_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf

	; Display the quotient and remainder
	mov		eax, int_1
	call	WriteDec
	mov		edx, OFFSET divided_by
	call	WriteString
	mov		eax, int_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET with_rem
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf

	; Display floating point quotient 
	mov		eax, int_1
	call	WriteDec
	mov		edx, OFFSET divided_by
	call	WriteString
	mov		eax, int_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	fld		fl_quot
	call	WriteFloat
	call	CrLf
	call	CrLf

; Repeat program?
	mov		edx, OFFSET prompt_4
	call	WriteString
	call	CrLf
	call	ReadInt
	call	CrLf
	; check if user entered 0 (quit option)
	cmp		eax, 0
	jne		Start

; Say good-bye 
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
