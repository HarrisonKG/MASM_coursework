TITLE Program 3     (Kristen_Harrison_Prog3.asm)

; Author: Kristen Harrison
; Course / Project ID:  CS271            Date: 29 October 2017
; Description: This program greets the user and repeatedly requests 
; negative numbers, which are tallied and accumulated.
; The program displays the number of numbers entered, the sum and 
; average, and a parting message.

INCLUDE Irvine32.inc

UPPER_LIMIT = -1
LOWER_LIMIT = -100

.data

; Intro
intro		BYTE	"Hello, this is Programming Assignment 3, by Kristen Harrison", 0
ec_1		BYTE	"**EC: Program numbers the lines during user input", 0
greeting_1	BYTE	"What is your name?", 0
greeting_2	BYTE	"Hi, ", 0
greeting_3	BYTE	", nice to meet you!", 0
userName	BYTE	21 DUP(0)

; User messages
prompt_1	BYTE	"Please enter negative integers from -100 to -1. To end, enter a positive number: ", 0
prompt_2	BYTE	"Enter number ", 0
colon		BYTE	": ", 0
error_msg	BYTE	"Too low! Please enter negative integers from -100 to -1: ", 0
goodBye		BYTE	"Good-bye, ", 0
ending		BYTE	"!", 0

; Arithmetic
sum			DWORD	0
counter		DWORD	0
average		DWORD	?

; Results
no_neg_msg	BYTE	"No valid negative integers were entered.", 0
count_msg_1	BYTE	"You entered ", 0
count_msg_2	BYTE	" numbers", 0
sum_msg		BYTE	"The sum of your valid numbers is ", 0
avg_msg		BYTE	"The rounded average is ", 0


.code
main PROC

; Introduction
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_1
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
	call	CrLf


; User input loop
	; Ask for negative number
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	CrLf
	call	CrLf

Start:
	mov		edx, OFFSET prompt_2
	call	WriteString
	mov		eax, counter
	inc		eax
	; Numbers the lines the user input
	call	WriteDec
	mov		edx, OFFSET colon
	call	WriteString
	call	ReadInt
	
; Data validation
Validate:
	; Below valid range: (Error Message)
	cmp		eax, LOWER_LIMIT
	jl		Out_Of_Range
	
	; Above valid range: (Quit)
	cmp		eax, UPPER_LIMIT
	jg		Positive_Entered
	
	; Else process as negative input
	add		sum, eax
	inc		counter
	jmp		Start

Out_Of_Range:
	mov		edx, OFFSET error_msg
	call	WriteString
	call	CrLf
	jmp		Start


; Process results
Positive_Entered:
	; Check if no negative ints were entered
	cmp		counter, 0
	je		No_Negatives
	
	; Calculate average as sum / counter
	mov		eax, sum
	cdq
	idiv	counter		
	mov		average, eax

	; Round to nearest integer by checking if remainder is greater than half of the divisor
	mov		eax, edx
	; Flip sign of remainder (it's negative because of sign extension)
	neg		eax
	mov		ebx, 2
	mul		ebx		
	; Compare doubled remainder to divisor
	cmp		eax, counter
	; If doubled remainder <= divisor, rounding is already correct
	jle		Display_Results
	; If doubled remainder > counter, subtract one from average
	dec		average


; Output results to the screen
Display_Results:
	; Display number of valid integers entered
	call	CrLf
	call	CrLf
	mov		edx, OFFSET count_msg_1
	call	WriteString
	mov		eax, counter
	call	WriteDec
	mov		edx, OFFSET count_msg_2
	call	WriteString
	call	CrLf
	
	; Display sum
	mov		edx, OFFSET sum_msg
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	CrLf
	
	; Display average
	mov		edx, OFFSET avg_msg
	call	WriteString
	mov		eax, average
	call	WriteInt
	call	CrLf
	jmp		Farewell


; Special message if the user enters no valid negative numbers
No_Negatives:
	call	CrLf
	mov		edx, OFFSET no_neg_msg
	call	WriteString
	call	CrLf
	jmp		Farewell


; Say good-bye to the user
Farewell:
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
