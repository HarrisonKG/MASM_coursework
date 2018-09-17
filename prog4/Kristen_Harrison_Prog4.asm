TITLE Program 4     (Kristen_Harrison_Prog4.asm)

; Author: Kristen Harrison
; Course / Project ID:  CS271            Date: 5 November 2017
; Description: This program requests an integer from the user between 1 and 400. 
; Once a valid number has been entered, the program calculates and prints out that many
; composite numbers. The program builds and uses an array of primes to determine
; composites, and aligns the output by column. 

INCLUDE Irvine32.inc

UPPER_LIMIT = 400
LOWER_LIMIT = 1


.data

; Intro
intro		BYTE	"Hello, this is Programming Assignment 4, by Kristen Harrison", 0
ec_1		BYTE	"EC: Program aligns the output columns", 0
ec_3		BYTE	"EC: Program uses array of primes to calculate composites", 0

; User messages
prompt_1	BYTE	"Please enter the number of composite numbers you'd like to see, from 1 to 400.", 0
prompt_2	BYTE	"Enter number in range [1 .. 400]", 0
error_msg	BYTE	"Out of range! Please enter an integer from 1 to 400: ", 0
goodBye		BYTE	"Good-bye.", 0

; Computations
; Array variables
primesArray	DWORD	UPPER_LIMIT DUP(?)		
array_size	DWORD	?
; User input
num_comps	DWORD	?
valid_num	BYTE	0
; Composite calculations
valid_comp	BYTE	0
next_comp	DWORD	2				; 2 is first prime number (start calculations with 3) 
; Printing variables
col_counter	WORD	0
spaces		BYTE	"     ", 0



.code
main PROC
	call	introduction
	call	getUserData
	
	mov		[primesArray], 2		; initialize base case and size
	mov		array_size, 1
	
	call	showComposites
	call	farewell

	exit							
main ENDP


; Procedure to introduce the program
; Receives: uses the global variables intro, ec_1, and ec_2
; Returns: none (prints to the screen)
; Preconditions: none
; Registers changed: uses and restores edx

introduction PROC uses edx
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET ec_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_3
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction ENDP



; Procedure to prompt for and receive input from the user
; Receives: uses globals prompt_1, prompt_2, num_comps, valid_num
; Returns: updates global num_comps to the user's input
; Preconditions: none
; Registers changed: uses and restores eax and edx

getUserData PROC uses edx eax
	mov		edx, OFFSET prompt_1		; ask for number of composites
	call	WriteString
	call	CrLf
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	CrLf

Check_Valid:
	call	ReadInt				
	mov		num_comps, eax				; save user input
	call	validate					; subroutine outputs error if invalid
	cmp		valid_num, 0
	je		Check_Valid					; repeat loop if flag set to false	
	ret
getUserData ENDP
	


; Procedure to validate user input 
; Receives: global num_comps, valid_num, error_msg, constants LOWER_LIMIT, UPPER_LIMIT
; Returns: updates global valid_num to 0(false) or 1(true) if number is in range 
; Preconditions: user input must have been stored in num_comps
; Registers changed: uses and restores edx

validate PROC uses edx
	cmp		num_comps, LOWER_LIMIT		; below valid range
	jl		Out_Of_Range

	cmp		num_comps, UPPER_LIMIT		; above valid range
	jg		Out_Of_Range
										; else process as valid input
	mov		valid_num, 1				; set flag to true
	jmp		EndValidate

Out_Of_Range:
	mov		edx, OFFSET error_msg
	call	WriteString
	call	CrLf
	mov		valid_num, 0				; set validity bool to false

EndValidate:
	ret
validate ENDP



; Procedure to display the requested number of composite numbers
; Receives: global num_comps, next_comp, valid_comp, col_counter, spaces
; Returns: displays next_comp to console in sequence
; Preconditions: num_comps in range [1..400], next_comp initialized to 2
; Registers changed: uses and restores ecx, eax

showComposites PROC USES ecx eax
	call	CrLf
	mov		ecx, num_comps			; initialize outer loop counter to user input
Print_Comps:
Check_Composite:					; inner loop finds next composite
	inc		next_comp	
	call	isComposite
	cmp		valid_comp, 0			; flag set to false?
	je		Check_Composite			; if so, check next number
	
	mov		eax, next_comp			; after inner loop exits, next_comp is next valid composite
	call	WriteDec
	inc		col_counter
	cmp		col_counter, 10			; counter < 10 ?
	jl		Same_Row				; if so, stay on same line 
	call	CrLf					; else need new line
	mov		col_counter, 0			; reset counter
	jmp		EndPrint
Same_Row:
	cmp		next_comp, 100			; aligns output up to three digits long
	jge		Five_Spaces
	mov		al, ' '
	call	WriteChar				; extra space for numbers < 100
	cmp		next_comp, 10
	jge		Five_Spaces
	call	WriteChar				; extra space for numbers < 10
Five_Spaces:
	mov		edx, OFFSET spaces		
	call	WriteString
EndPrint:
	loop	Print_Comps				; loop decrements once for each valid composite printed
	ret
showComposites ENDP



; Procedure to check whether a number (stored in next_comp) is composite
; Receives: global next_comp, primesArray, array_size
; Returns: sets valid_comp flag to 0(false) or 1(true) if next_comp is composite
; Preconditions: array_size > 0
; Registers changed: uses and restores ecx, esi, eax, edx

isComposite PROC USES ecx esi eax edx					
	mov		ecx, array_size				; set counter for looping through array
	mov		esi, OFFSET primesArray		; initialize index
ArrayLoop:							
	mov		eax, next_comp				; move divisor into place
	mov		edx, 0
	div		DWORD PTR [esi]			; divide next_comp by each value in primesArray
	cmp		edx, 0					; remainder == 0?
	je		Divisible				; if so, next_comp is evenly divisible
	add		esi, 4					; else increment to next (DWORD) index
	loop	ArrayLoop

	mov		eax, next_comp			; if never divided evenly, is prime
	mov		[esi], eax				; add to prime array
	inc		array_size
	mov		valid_comp, 0			; set flag to false
	jmp		End_Is_Comp
Divisible:
	mov		valid_comp, 1			; next_comp is composite
End_Is_Comp:
	ret
isComposite ENDP



; Procedure to display a closing message 
; Receives: global variable goodBye
; Returns: none (displays output to console)
; Preconditions: none
; Registers changed: edx

farewell PROC
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLf
	call	CrLf
	ret
farewell ENDP


END main
