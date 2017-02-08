.equ SWI_Open, 0x66 @open a file
.equ SWI_Close,0x68 @close a file
.equ SWI_PrChr,0x00 @ Write an ASCII char to Stdout
.equ SWI_PrStr, 0x69 @ Write a null-ending string
.equ SWI_PrInt,0x6b @ Write an Integer
.equ SWI_RdInt,0x6c @ Read an Integer from a file
.equ Stdout, 1 @ Set output target to be Stdout
.equ SWI_Exit, 0x11 @ Stop execution
.global _start

.text

ldr r0,=OutFileName  @ set Name for output file
mov r1,#1            @ mode is output
swi SWI_Open @ open file for output
@ Save the file handle in memory:
ldr r1,=OutFileHandle @ if OK, load input file handle
str r0,[r1] @ save the file handle

mov r3, #1 @length of present | plength
mov r4, #15 @number of integers

@print first digit
mov r1,#1 @ R1 = integer to print
ldr R0,=OutFileHandle @ target is Stdout
ldr r0,[r0]
swi SWI_PrInt
ldr R0,=OutFileHandle @ print new line
ldr r0,[r0]
ldr r1, =NL
swi SWI_PrStr
@end print first digit

ldr r1,=PRESENT
str r3, [r1] @First number is 1


mov r9, #1 @number of loops to run | i
LOOP:
	ldr r1, =PRESENT
	ldr r2, =NEXT
	mov r5, #0 @Index of r1 | PINDEX
	mov r8,#0 @Index of next | NINDEX
	CONSTRUCT_NEXT:
		mov r6, r5 @r6 = start
		add r5,r5, #1
		NUM_EQUAL:
			cmp r5, r3
			bge EXIT_EQUAL_CHECK
			ldr r11, [r1,r5,LSL #2]
			ldr r12, [r1,r6,LSL #2]
			cmp r11, r12
			bne EXIT_EQUAL_CHECK
			add r5, r5, #1
			b NUM_EQUAL
		EXIT_EQUAL_CHECK:
		sub r7, r5, r6
		str r7, [r2,r8,LSL #2]
		add r8,r8,#1
		ldr r11, [r1,r6,LSL #2]
		str r11, [r2,r8,LSL #2]
		add r8, r8,#1
		cmp r5, r3
		blt CONSTRUCT_NEXT
	mov r3, r8
	mov r5, #0 @looping for result | j


	mov r6, r1
	STORE_RESULT:
		ldr r11, [r2,r5,LSL #2]
		str r11, [r6,r5,LSL #2]

		mov r1,r11 @ R1 = integer to print
		ldr R0,=OutFileHandle @ target is Stdout
		ldr r0,[r0]
		swi SWI_PrInt

		add r5, r5, #1
		cmp r5, r8
		blt STORE_RESULT
	
	ldr R0,=OutFileHandle @ print new line
	ldr r0,[r0]
	ldr r1, =NL
	swi SWI_PrStr
	
	add r9, r9 ,#1
	cmp r9, r4
	blt LOOP

@ == Close a file ===============================================
ldr R0, =OutFileHandle @ get address of file handle
ldr R0, [R0] @ get value at address
swi SWI_Close

Exit:
swi SWI_Exit @ stop executing

.data
PRESENT:	.space 400
	.align
NEXT: .space 400
	.align
  OutFileHandle: .skip 4
OutFileName: .asciz "assn2out.txt"
NL: .asciz "\n" @new line character
.end