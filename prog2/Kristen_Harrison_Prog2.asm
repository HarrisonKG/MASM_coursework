TITLE Program 2     (KristenHarrisonProg2.asm)

; Author: Kristen Harrison
; Course / Project ID:  CS271            Date: 14 October 2017
; Description: This program greets the user, requests an integer in the range 
; [1, 46], then prints out that many numbers of the Fibonacci sequence

INCLUDE Irvine32.inc

UPPER_LIMIT = 46

.data

; Intro
intro		BYTE	"Hello, this is Programming Assignment 2, by Kristen Harrison", 0
greeting_1	BYTE	"What is your name?", 0
greeting_2	BYTE	"Hi, ", 0
greeting_3	BYTE	", nice to meet you!", 0
ending		BYTE	" !", 0

; Instructions
prompt_1	BYTE	"Please enter an integer from 1 to 46 to indicate how many Fibonacci numbers to display:", 0
error_msg	BYTE	"Invalid input, please enter an integer from 1 to 46: ", 0

; User input
userName	BYTE	21 DUP(0)
numTerms	DWORD	?

; Fibonacci variables
spaces		BYTE	"      ", 0
counter		DWORD	0
numCols		DWORD	5

; Good-bye
goodBye		BYTE	"Good-bye, "


.code
main PROC

; Introduction
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	call	CrLf

; Pleasantries
	mov		edx, OFFSET greeting_1
	call	WriteString
	call	CrLf

	; Get name
	mov		edx, OFFSET userName
	mov		ecx, SIZEOF userName
	call	ReadString	
	call	CrLf

	; Say hello
	mov		edx, OFFSET greeting_2
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET greeting_3
	call	WriteString
	call	CrLf
	call	CrLf


; User instructions
	; Ask for number
	mov		edx, OFFSET prompt_1
	call	WriteString
Start:
	call	CrLf
	call	ReadInt
	
	; Validate that user entered an int in range [1, 46]
Validate:
	cmp		eax, 1
	jl		Out_Of_Range
	cmp		eax, UPPER_LIMIT
	jg		Out_Of_Range
	; else is valid
	jmp		EndValidate 

Out_Of_Range:
	mov		edx, OFFSET error_msg
	call	WriteString
	; loop until valid input is given
	jmp		Start

EndValidate:
	mov		numTerms, eax
	call	CrLf
	call	CrLf


; Display Fibonacci sequence with MASM loop instruction
	; Initialize registers
	mov		eax, 1
	mov		ebx, 0
	mov		edx, OFFSET spaces
	mov		ecx, numTerms

	; Progresses through sequence by adding and swapping two registers
FibSeq:
	add		eax, ebx		
	call	WriteDec		
	xchg	eax, ebx		
	call	WriteString
	inc		counter

	; Save eax and edx values
	push	eax
	push	edx

	; Call CrLf if counter is divisible by 5
	mov	edx, 0
	mov	eax, counter
	div	numCols	
	; if remainder is 0, need new line
	cmp	edx, 0			
	jne	Restore
	call	CrLf

Restore:
	; Restore fibonacci values to eax and edx
	pop		edx
	pop		eax

	loop	FibSeq
	

; Farewell
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodBye
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET ending
	call	WriteString
	call	CrLf
	call	CrLf	


	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
