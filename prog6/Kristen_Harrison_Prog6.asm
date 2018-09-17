TITLE Program 6A     (Kristen_Harrison_Prog6.asm)

; Author: Kristen Harrison
; Course / Project ID:  CS271            Date: 3 December 2017
; Description: This program gets and validates 10 unsigned integers (lower than 2^32) from the user, 
; and displays them again to the user along with their sum and average. The numbers are read in as 
; strings, converted to ints using lodsb, stored in an array, then converted back to strings using stosb
; as they are printed back out. The numbers submitted must be able to fit inside 32 bits, and it is
; assumed that the sum will fit inside 32 bits as well. 

INCLUDE Irvine32.inc

; Range constants
ARRAY_SIZE = 10
MAX_LENGTH = 12
BASE = 10


; Macro to receive and store a string from the user 
; Receives: @ user prompt, @ storage string, @ string length
; Returns: stores user string into @ store_address parameter, stores length in @ str_length
; Preconditions: none
; Registers changed: none

getString MACRO prompt_address, store_address, str_leng
	push	edx
	push	ecx
	push	eax
	
	mov		edx, prompt_address								; print requirements for input string			
	call	WriteString
	call	CrLf
	
	mov		edx, store_address								; offset to save string
	mov		ecx, MAX_LENGTH
	call	ReadString
	mov		[str_leng], eax									; save string length
	
	pop		eax
	pop		ecx
	pop		edx
ENDM



; Macro to print a string to the console
; Receives: @ string
; Returns: none (prints string to screen)
; Preconditions: none
; Registers changed: none

displayString MACRO string 
	push	edx
	mov		edx, string
	call	WriteString
	pop		edx
ENDM



.data
; User messages
intro		BYTE	"Programming Assignment 6A, by Kristen Harrison", 0
prompt_1	BYTE	"This program will display a list of user-generated integers, the sum, and the average value.", 0
prompt_2	BYTE	"Please provide 10 unsigned decimal integers. Each needs to be small enough to fit inside a 32-bit register.", 0
prompt_3	BYTE	"Please enter an unsigned integer: ", 0
error_msg	BYTE	"Error: Your input was either too big or was not an unsigned integer. ", 0

; Result messages
list_msg	BYTE	"You entered the following numbers: ", 0
sum_msg		BYTE	"The sum of these numbers is ", 0
avg_msg		BYTE	"The average is ", 0

; Array variables
randArray	DWORD	ARRAY_SIZE DUP(?)						; size 10 array
user_str	BYTE	MAX_LENGTH DUP(?)
str_leng	DWORD	?



.code
main PROC
	push	OFFSET intro
	push	OFFSET prompt_1
	push	OFFSET prompt_2
	call	introduction						

	push	OFFSET randArray					; array to be filled
	push	OFFSET prompt_3						; asks for next input
	push	OFFSET error_msg					; input validation
	push	OFFSET user_str						; store temp string
	push	OFFSET str_leng						; record string length
	call	fillArray

	push	OFFSET randArray
	push	OFFSET list_msg
	push	OFFSET user_str						; temp storage for converting back to string
	call	displayList							; display user-generated numbers

	push	OFFSET user_str
	push	OFFSET randArray
	push	OFFSET sum_msg
	push	OFFSET avg_msg
	call	displayResults						; calculate and print the sum and average

	exit							
main ENDP



; Procedure to introduce and describe the program							[ebp]	old ebp
; Receives: @ intro, @ prompt_1, @ prompt_2									+4		ret @
; Returns: none (prints to the screen)										+8		@ prompt_2
; Preconditions: none														+12		@ prompt_1
; Registers changed: none													+16		@ intro

introduction PROC 
	push	ebp
	mov		ebp, esp

	displayString [ebp + 16]				; introduction
	call	CrLf
	call	CrLf
	call	CrLf
	
	displayString [ebp + 12]				; describe program
	call	CrLf
	call	CrLf
	call	CrLf

	displayString [ebp + 8]					; describe required user input
	call	CrLf

	pop		ebp
	ret		12
introduction ENDP
																					
																					
																					; Stack:
; Procedure to fill an array with user-entered numbers								; old ebp		[ebp]
; Receives:  @randArray, @ prompt_3, @ error_msg, @ user_str, @ str_leng			; ret @			+4
; Returns: randArray is updated with values											; @ str_leng	+8
; Preconditions: ARRAY_SIZE > 0														; @ user_str	+12
; Registers changed: none															; @ error_msg	+16
; Notes: calls ReadVal to read in and store each value in succession				; @ prompt_3	+20
;		using the same stack parameters												; @ randArray	+24

fillArray PROC 
	push	ebp
	mov		ebp, esp
	push	ecx
	push	esi

	mov		ecx, ARRAY_SIZE							; set ecx to 10
	mov		esi, [ebp + 24]							; set index reg to @ randArray

; Loop to store elements in array
NextElement:										
	call	ReadVal									; prompt for, validate, and store input	
	add		esi, 4									; inc to next doubleword
	loop	NextElement

	pop		esi
	pop		ecx
	pop		ebp
	ret		20
fillArray ENDP


																							; Stack:
; Procedure to prompt for and read in an input string of ascii numbers,						; old ebp		[ebp]
; then convert to its integer value and store it in the address held by esi					; ret @			+4
; Receives: uses fillArray parameters, and esi holds address to store input value			; @ str_leng	+8
; Returns: [esi] is updated with the user's integer input									; @ user_str	+12
; Preconditions: array element address is in esi register									; @ error_msg	+16
; Registers changed: none																	; @ prompt_3	+20													
										
ReadVal PROC USES eax ecx edx ebx 
	push	esi

Start:
	; Invoke macro to receive numeric string from user
	getString [ebp + 20], [ebp + 12], [ebp + 8]				; prompt_address, str_storage, str_leng
	
	mov		ecx, [ebp + 8]									; set loop counter to string length returned by getString
	mov		ebx, 0											; accumulator
	mov		eax, 0
	mov		esi, [ebp + 12]									; offset of string returned by getString macro
	cld

; Convert the string to an integer 
Convert:											
	lodsb
	
	; Validation
	cmp		al, 48									; validate that the byte holds a numeric char
	jb		Error
	cmp		al, 57
	ja		Error
	
	; Conversion
	sub		al, 48									; convert ascii code to numeric equivalent
	xchg	eax, ebx								; move accumulator to eax for MUL instruction, and save current digit in ebx
	mov		edx, BASE
	mul		edx										; multiply accumulator by 10 to shift by one placevalue
	jc		Error									; check for overflow
	add		eax, ebx								; add current digit to accumulator
	jc		Error
	
	; Update accumulator register
	mov		ebx, eax								; current sum saved to ebx for next loop iteration
	mov		eax, 0									; zero out eax before lodsb instruction
	loop	Convert


	; Move final converted value to array element
	pop		esi
	mov		[esi], ebx								
	jmp		End_Convert


; Print error message in case of overflow or non-numeric input
Error:
	displayString [ebp + 16]						
	call	CrLf
	jmp		Start									; start over with fresh input 

End_Convert:
	ret 
ReadVal ENDP




; Procedure to display the array to the screen										; [ebp]	old ebp
; Receives:	@ randArray, @ list_msg, @ user_str										; +4	ret @
; Returns: none (prints to screen)													; +8	@ user_str
; Preconditions: array should already be filled										; +12	@ list_msg
; Registers changed: none															; +16	@ randArray

displayList PROC 
	; Set up registers and title
	push	ebp
	mov		ebp, esp	
	push	esi
	push	ecx

	mov		esi, [ebp + 16]					; index reg set to @ randArray
	mov		ecx, ARRAY_SIZE					; loop counter set to array size
	call	CrLf
	call	CrLf
	
	displayString [ebp + 12]					; print out list message
	call	CrLf

; Loop to print out array
Print_Array:
	push	[esi]
	push	[ebp + 8]
	call	WriteVal
	call	CrLf
	add		esi, 4							; next element
	loop	Print_Array	

	; Restore registers
	pop		ecx
	pop		esi
	pop		ebp
	ret		12
displayList ENDP


; Procedure to convert an integer to a numeric string and print it to the screen			; old ebp		[ebp]
; Receives: @ user_str, and value to convert												; ret @			+4
; Returns: @ user_str is updated with the numeric string of the integer						; 5 saved regs	+24
; Preconditions: none																		; @ user_str	+28
; Registers changed: none																	; int value		+32											
										
WriteVal PROC USES edi eax ecx edx ebx
	push	ebp
	mov		ebp, esp

	; Prepare registers
	mov		edi, [ebp + 28]					; temp string offset
	mov		eax, [ebp + 32]					; value to convert
	mov		ecx, 0							; keep track of the number of digits
	mov		edx, 0	
	mov		ebx, BASE						; set to 10
	cld

; Divides integer by 10 repeatedly and pushes remainder onto stack
Deconstruct_Int:
	mov		edx, 0
	div		ebx								; number / 10
	push	edx								; push value of remainder to stack
	inc		ecx
	cmp		eax, 0							; continue until number reaches zero
	jne		Deconstruct_Int


; Constructs string by popping values off the stack
Build_String:								
	pop		eax
	add		eax, 48
	stosb
	loop	Build_String
	
	; Add null terminator
	mov		eax, 0							
	stosb

	; Print to console
	displayString [ebp + 28]

	pop		ebp
	ret		8
WriteVal ENDP
																		
																				

																					; Stack:
; Procedure to calculate and display the sum and average						[ebp]	old ebp
; Receives: @ user_str, @ randArray, @ sum_msg, @ avg_msg						+4		ret @
; Returns: none (prints to the screen)											+8		@ avg_msg
; Preconditions: none															+12		@ sum_msg
; Registers changed: none														+16		@ randArray
;																				+20		@ user_str																				
displayResults PROC 	
	push	ebp
	mov		ebp, esp

	push	esi
	push	ecx
	push	eax
	push	ebx

	mov		esi, [ebp + 16]						; offset of randArray
	mov		ecx, ARRAY_SIZE						; size of array
	mov		eax, 0								; accumulator

; Iterate through array and add all to eax
Sum_Array:
	add		eax, [esi]						; add current element to accumulator
	add		esi, 4							; next element
	loop	Sum_Array	


	; Print sum
	call	CrLf
	displayString [ebp + 12]
	
	push	eax								; sum parameter
	push	[ebp + 20]						; address of string to store input
	call	WriteVal						
	call	CrLf
	call	CrLf


	; Divide sum by ARRAY_SIZE to get average
	mov		ebx, ARRAY_SIZE
	mov		edx, 0
	div		ebx
	
	; Print average
	call	CrLf
	displayString [ebp + 8]
	
	push	eax								; average parameter
	push	[ebp + 20]						; address of string to store input
	call	WriteVal
	call	CrLf
	call	CrLf

	; Clean up
	pop		ebx
	pop		eax
	pop		ecx
	pop		esi
	pop		ebp
	ret		16
displayResults ENDP


END main


