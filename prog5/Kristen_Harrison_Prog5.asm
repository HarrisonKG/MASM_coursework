TITLE Program 5     (Kristen_Harrison_Prog5.asm)

; Author: Kristen Harrison
; Course / Project ID:  CS271            Date: 16 November 2017
; Description: This program receives a number from the user indicating the size of array
; to create. This array is filled with random numbers, displayed to the screen and sorted 
; in descending order. The median is calculated and printed out and the sorted array is 
; displayed before the program exits. 


INCLUDE Irvine32.inc

; Range constants
MIN_REQUEST = 10
MAX_REQUEST = 200
MIN_RAND = 100
MAX_RAND = 999


.data
; Global variable strings
; Intro
intro		BYTE	"Hello, this is Programming Assignment 5, by Kristen Harrison", 0

; User messages
prompt_1	BYTE	"This program will generate, display, and sort a series of random numbers, calculate the median, then display the sorted list in descending order", 0
prompt_2	BYTE	"How many numbers should be generated? [10 .. 200]", 0
error_msg	BYTE	"Out of range! Please enter an integer in the range [10 .. 200]: ", 0
goodBye		BYTE	"Good-bye.", 0

; Display messages
unsort_msg	BYTE	"The list in unsorted order is:", 0
sort_msg	BYTE	"The list in sorted order is:", 0
median_msg	BYTE	"The median, rounded to the nearest integer, is ", 0
spaces		BYTE	"     ", 0

; Array variables
randArray	DWORD	MAX_REQUEST DUP(?)	
request		DWORD	?



.code
main PROC
	call	Randomize							; seed sequence with system clock
	call	introduction

	push	OFFSET request						; store user input
	call	getData

	push	OFFSET randArray					; array to be filled
	push	request								; number requested by user
	call	fillArray

	push	OFFSET randArray
	push	request
	push	OFFSET unsort_msg
	call	displayList							; display unsorted array

	push	OFFSET randArray
	push	request
	call	sortList							; sort in descending order

	push	OFFSET randArray
	push	request
	call	displayMedian						; calculate and print the median

	push	OFFSET randArray
	push	request
	push	OFFSET sort_msg
	call	displayList							; display sorted array

	call	farewell

	exit							
main ENDP



; Procedure to introduce and describe the program					
; Receives: none; accesses global strings								
; Returns: none (prints to the screen)				
; Preconditions: none								
; Registers changed: none

introduction PROC uses edx
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	call	CrLf
	call	CrLf
	mov		edx, OFFSET prompt_1		; describe program
	call	WriteString
	call	CrLf
	call	CrLf
	call	CrLf
	mov		edx, OFFSET prompt_2		; request user input
	call	WriteString
	call	CrLf
	ret
introduction ENDP



; Procedure to prompt for a number in range [10..200] to designate array size					Stack:
; Receives: @ request																	[ebp]			old ebp
; Returns: updates request with the user's input										+8				2 saved regs
; Preconditions: none																	[ebp+12]		ret @
; Registers changed: none																[ebp+16]		@ request

getData PROC USES eax edx
	push	ebp
	mov		ebp, esp
	
Check_Valid:
	call	ReadInt						; response stored in eax

	cmp		eax, MIN_REQUEST			; below valid range
	jl		Out_Of_Range

	cmp		eax, MAX_REQUEST			; above valid range
	jg		Out_Of_Range									
	jmp		EndValidate					; else process as valid input

Out_Of_Range:
	mov		edx, OFFSET error_msg
	call	WriteString
	call	CrLf
	loop	Check_Valid

EndValidate:
	mov		edx, [ebp + 16]				; @ request in edx
	mov		[edx], eax					; save user input to dereferenced request
	pop		ebp
	ret		4
getData ENDP
	



																					; Stack:
; Procedure to fill an array with random numbers								; old ebp		[ebp]
; Receives:  @randArray, request												; 3 saved regs	+12
; Returns: the array passed as a parameter is updated with values				; @ ret			+16
; Preconditions: array size > 0													; request		+20
; Registers changed: none														; @ randArray	+24

fillArray PROC USES ecx esi eax
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 20]					; set ecx to size of array
	mov		esi, [ebp + 24]					; set index reg to @ randArray

NextElement:	
	; Calculate random number
	mov		eax, MAX_RAND					; 100
	sub		eax, MIN_RAND					; 999 - 100 = 899
	inc		eax								; 900
	call	RandomRange						; eax in [0 .. 899]
	add		eax, MIN_RAND					; eax in [100 .. 999] 
	
	; Add to array
	mov		[esi], eax						; update element
	add		esi, 4							; inc to next doubleword
	loop	NextElement

	pop		ebp
	ret		8
fillArray ENDP


																					
; Procedure to display the array to the screen										; [ebp]	old ebp
; Receives:	@ randArray, request, @ title											; +4	ret @
; Returns: none (prints to screen)													; +8	@ title
; Preconditions: array should already be filled										; +12	request
; Registers changed: ecx, eax, esi, edx												; +16	@ randArray

displayList PROC 
	LOCAL	col_counter:DWORD				; enforce 10 integers per row
	mov		col_counter, 0

	; Set up registers and title
	mov		esi, [ebp + 16]					; index reg set to @ randArray
	mov		ecx, [ebp + 12]					; loop counter set to array size
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 8]					; print out title
	call	WriteString
	call	CrLf

Print_Array:
	mov		eax, [esi]						; current element
	call	WriteDec
	add		esi, 4							; next element
	
	; format columns and spacing
	inc		col_counter
	cmp		col_counter, 10					; counter < 10 ?
	jl		Same_Row						; if so, stay on same line 
	call	CrLf							; else need new line
	mov		col_counter, 0					; reset counter
	jmp		EndPrint
Same_Row:
	mov		edx, OFFSET spaces				; 5 spaces between elements
	call	WriteString
EndPrint:
	loop	Print_Array	

	ret		12
displayList ENDP

																						; Stack:
																					; -4		outer loop ecx
; Procedure to sort the list in descending order									; [ebp]		old ebp
; Receives:	@ randArray, request 													; +16		4 saved registers
; Returns: array passed in as parameter is updated to be in sorted order			; +20		ret @
; Preconditions: array_size > 0														; +24		request
; Registers changed: none															; +28		@ randArray

sortList PROC USES ecx esi edi eax
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 24] 					; array size
	dec		ecx									; make size - 1 iterations
	mov		esi, [ebp + 28]						; @ randArray

; Outer loop cycles through the array once
Sort_Array:							
	mov		edi, esi							; edi will track offset of the max element
	push	ecx									; save outer loop count
	push	esi									; save current element offset

; Inner loop compares current element to every subsequent one to find the max element	
Compare:	
	add		esi, 4								; increment to next element
	mov		eax, [edi]							; get val of current max
	cmp		eax, [esi] 							; value of current maximum > current element?
	jg		Greater								; if so, no change needed for current max
	mov		edi, esi							; else update to new max
Greater:
	loop	Compare								; loop exits with max element's offset stored in edi
	
	pop		esi									; restore outer loop current element

	; swap current element [esi] and current max [edi]
	mov		eax, [edi]						 
	xchg	eax, [esi]
	mov		[edi], eax
	
	add		esi, 4								; increment outer loop current element
	pop		ecx									; restore outer loop counter
	loop Sort_Array

	pop		ebp
	ret		8
sortList ENDP




; Procedure to calculate the median to the nearest integer and display to the screen						[ebp]	old ebp
; Receives:  @ randArray,  request																			+16		4 saved registers
; Returns: none (prints to the screen)																		+20		ret @
; Preconditions: none																						+24		request
; Registers changed: none																					+28		@ randArray

displayMedian PROC USES	esi eax edx ebx		
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp + 28]					; @ randArray
	mov		eax, [ebp + 24]					; size of array

	mov		edx, 0							
	mov		ebx, 2							; divide size by 2
	div		ebx	
	
	cmp		edx, 0							; if remainder is 0, size is even
	je		Even_Size						; else eax holds the middle index
											
; Odd array median = [(size / 2) * 4 + offset of array]

	mov		ebx, 4							
	mul		ebx								; subscript * scale of 4 (size of DWORD)
	add		esi, eax						; set to offset of middle index
	mov		eax, [esi]						; get val at middle
	jmp		Print
	

; Even array median = ([(size / 2) * 4 + offset of array] + [(size / 2 - 1) * 4 + offset of array]) / 2

Even_Size:
	; Add the two middle indices' values
	mov		ebx, 4
	mul		ebx								; second middle index * size of DWORD
	add		esi, eax						; esi holds offset of the second of two middle indices
	mov		eax, [esi]						; get val at second middle index
	add		eax, [esi - 4]					; add val of first middle index
	
	; Halve to find the average
	mov		ebx, 2							
	mov		edx, 0
	div		ebx								; eax holds median value by integer division

	cmp		edx, 0							; remainder == 0 ?
	je		Print							; if so, rounding is already correct
	inc		eax								; else add one to median (remainder can only be .5)

Print:
	mov		edx, OFFSET median_msg
	call	CrLf
	call	CrLf
	call	WriteString						; Print median to screen
	call	WriteDec
	call	CrLf
	call	CrLf

	pop		ebp
	ret		8
displayMedian ENDP



; Procedure to display a closing message 
; Receives: none  (uses global string)
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
