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

mov r12,#1    @turn == r12

@---------------------BOARD--INITIALIZATION-------------------------------@
@-------------------------------------------------------------------------@


@-------------------------------------------------------------------------@
check_valid: @ i: r0, j: r1 -> ans:r0
  str r14, [r13,#-4]!
  str r3, [r13,#-4]!
  str r2, [r13,#-4]!
  mov r3, r1
  mov r2, r0

  @if check_bound(i,j)==0 then return 0
  bl check_bound
  mov r1,r0
  mov r0, #0
  cmp r1, #0
  beq return_check_valid

  @get BOARD[x,y] in r1
  mov r0,r2
  mov r1,r3
  bl get
  ldr r1, =BOARD
  ldr r1, [r1,r0,LSL#2]

  @if BOARD[x,y] == turn then return 0
  mov r0,#0
  cmp r1,r12
  beq return_check_valid

  mov r0,#1
  b return_check_valid

  return_check_valid:
    ldr r2, [r13],#4
    ldr r3, [r13],#4
    ldr r14, [r13],#4
    mov r15,r14
@-------------------------------------------------------------------------@

@-------------------------------------------------------------------------@
check_bound: @x:r0,y:r1 -> r0:(x < 0 || y < 0 || x > 7 || y > 7)
  cmp r0,#0
  blt return_check_bound
  cmp r1,#0
  blt return_check_bound
  cmp r0,#7
  bgt return_check_bound
  cmp r1, #7
  bgt return_check_bound
  mov r0,#1
  mov r15,r14

  return_check_bound:
  	mov r0,#0
    mov r15,r14
@-------------------------------------------------------------------------@

@-------------------------------------------------------------------------@
get: @x:r0 , y:r1 -> r0:(x*8+y)
  mov r0,r0,LSL#3
  add r0, r0, r1
  mov r15, r14
@-------------------------------------------------------------------------@

@-------------------------------------------------------------------------@
recurse_turn: @ x: r0, y: r1, inc_x: r2, inc_y: r3, set: r4 -> ans: r0
  str r14, [r13,#-4]!
	str r9, [r13,#-4]!
	str r8, [r13,#-4]!
	str r7, [r13,#-4]!
	str r6, [r13,#-4]!
	str r5, [r13,#-4]!
	mov r9, r4
  mov r8, r3
  mov r7, r2
  mov r6, r1
  mov r5, r0
  
  @if check_bound(x,y)==0 then return 0
  bl check_bound
  mov r1,r0
  mov r0,#0
	cmp r1, #0
  beq return_recurse

  @get BOARD[x,y] in r1
  mov r0,r5
  mov r1,r6
  bl get
  ldr r1, =BOARD
  ldr r1, [r1,r0,LSL#2]

  @if BOARD[x,y] == 0 then return 0
  mov r0,#0
  cmp r1,#0
  beq return_recurse

  @if BOARD[x,y] == turn then return 1
  mov r0,#1
  cmp r1,r12
  beq return_recurse

  @call recursion
  add r0, r5,r7
  add r1, r6,r8
  mov r2, r7
  mov r3, r8
  mov r4, r9
  bl recurse_turn

  @if ans == 0 then return
  mov r1,r0
  mov r0,#0
  cmp r1,#0
  beq return_recurse

  @if set == 0 then return 1
  mov r0,#1
  cmp r9,#0
  beq return_recurse

  @else store in BOARD and then return
  mov r0,r5
  mov r1,r6
  bl get
  ldr r1, =BOARD
  str r12, [r1,r0,LSL#2]
  ldr r0, =SCORE
  
  @SCORE[turn-1]++
  sub r1,r12,#1
  ldr r4, [r0,r1,LSL#2]
  add r4,r4,#1
  str r4, [r0,r1,LSL#2]

  @SCORE[turn%2]--
  and r1,r12,#1
  ldr r4, [r0,r1,LSL#2]
  sub r4,r4,#1
  str r4, [r0,r1,LSL#2]

  mov r0,#1
  b return_recurse

  return_recurse:
    ldr r5, [r13],#4
    ldr r6, [r13],#4
    ldr r7, [r13],#4
    ldr r8, [r13],#4
    ldr r9, [r13],#4
    ldr r14, [r13],#4
    mov r15,r14
@-------------------------------------------------------------------------@

@-------------------------------------------------------------------------@
move: @ i:r0, j:r1, set:r2 -> ans: r0
  str r14, [r13,#-4]!
  str r8, [r13,#-4]!
  str r7, [r13,#-4]!
  str r6, [r13,#-4]!
  str r5, [r13,#-4]!
  str r4, [r13,#-4]!
  str r3, [r13,#-4]!
  mov r8, #0    @r8 == ans
  mov r7, r2    @r7 == set
  mov r6, r1    @r6 == j
  mov r5, r0    @r5 == i

  sub r0, r5,#1
  mov r1,r6
  bl check_valid
  cmp r0,#1
  bne move1
    sub r0, r5,#1
    mov r1,r6
    mov r2, #-1
    mov r3, #0
    mov r4, r7
    bl recurse_turn
    add r8,r8,r0

  move1:
  add r0, r5,#1
  mov r1,r6
  bl check_valid
  cmp r0,#1
  bne move2
    add r0, r5,#1
    mov r1,r6
    mov r2, #1
    mov r3, #0
    mov r4, r7
    bl recurse_turn
    add r8,r8,r0
  
  move2:
  sub r1, r6,#1
  mov r0,r5
  bl check_valid
  cmp r0,#1
  bne move3
    sub r1, r6,#1
    mov r0,r5
    mov r2, #0
    mov r3, #-1
    mov r4, r7
    bl recurse_turn
    add r8,r8,r0
  
  move3:
  add r1, r6,#1
  mov r0,r5
  bl check_valid
  cmp r0,#1
  bne move4
    add r1, r6,#1
    mov r0,r5
    mov r2, #0
    mov r3, #1
    mov r4, r7
    bl recurse_turn
    add r8,r8,r0
  
  move4:
  add r0, r5,#1
  add r1, r6,#1
  bl check_valid
  cmp r0,#1
  bne move5
    add r0, r5,#1
    add r1, r6,#1
    mov r2, #1
    mov r3, #1
    mov r4, r7
    bl recurse_turn
    add r8,r8,r0

  move5:
  sub r0, r5,#1
  sub r1, r6,#1
  bl check_valid
  cmp r0,#1
  bne move6
    sub r0, r5,#1
    sub r1, r6,#1
    mov r2, #-1
    mov r3, #-1
    mov r4, r7
    bl recurse_turn
    add r8,r8,r0

  move6:
  add r0, r5,#1
  sub r1, r6,#1
  bl check_valid
  cmp r0,#1
  bne move7
    add r0, r5,#1
    sub r1, r6,#1
    mov r2, #1
    mov r3, #-1
    mov r4, r7
    bl recurse_turn
    add r8,r8,r0

  move7:
  sub r0, r5,#1
  add r1, r6,#1
  bl check_valid
  cmp r0,#1
  bne move8
    sub r0, r5,#1
    add r1, r6,#1
    mov r2, #-1
    mov r3, #1
    mov r4, r7
    bl recurse_turn
    add r8,r8,r0
  
  move8:
    mov r0, r8
  return_move:
    ldr r3, [r13],#4
    ldr r4, [r13],#4
    ldr r5, [r13],#4
    ldr r6, [r13],#4
    ldr r7, [r13],#4
    ldr r8, [r13],#4
    ldr r14, [r13],#4
    mov r15,r14
@-------------------------------------------------------------------------@

@-------------------------------------------------------------------------@
play: @ x: r0, y: r1 -> ans: r0
  str r14, [r13,#-4]!
  str r4, [r13,#-4]!
  str r3, [r13,#-4]!
  str r2, [r13,#-4]!
  sub r4, r1, #1    @r4 == y--
  sub r3, r0, #1    @r3 == x--

  mov r0,r3
  mov r1,r4
  @if check_bound(x,y)==0 then return 0
  bl check_bound
  mov r1,r0
  mov r0, #0
  cmp r1, #0
  beq return_play

  @get BOARD[x,y] in r1
  mov r0,r3
  mov r1,r2
  bl get
  ldr r1, =BOARD
  ldr r1, [r1,r0,LSL#2]

  @if BOARD[x,y] == 0 then return 0
  mov r0,#0
  cmp r1,r0
  bne return_play

  @if move(x,y,1) == 0 then return 0
  mov r0,r3
  mov r1,r4
  mov r2,#1
  bl move
  mov r1,r0
  mov r0, #0
  cmp r1,#0
  beq return_play

  @set BOARD[x,y] to turn
  mov r0,r3
  mov r1,r2
  bl get
  ldr r1, =BOARD
  str r12, [r1,r0,LSL#2]

  @score[turn-1]++
  ldr r0, =SCORE
  sub r1, r12,#1
  ldr r2, [r0,r1,LSL#2]
  add r2,r2,#1
  str r2, [r0,r1,LSL#2]

  @ r2 = next_turn (turn%2 + 1)
  and r2,r12,#1
  add r2,r0,#1

  mov r0,r2
  bl check
  cmp r0,#1
  bne play1
    mov r12, r2    @turn = next_turn
    mov r0,r2
    b return_play

  play1:
  mov r0,r12
  bl check
  mov r1,r0
  mov r0,#-1
  cmp r1,#1
  bne return_play
    mov r0,r12
    b return_play

  return_play:
    ldr r2, [r13],#4
    ldr r3, [r13],#4
    ldr r4, [r13],#4
    ldr r14, [r13],#4
    mov r15,r14
@-------------------------------------------------------------------------@

@-------------------------------------------------------------------------@
check: @ player:r0 -> isPossible:r0
  str r14, [r13,#-4]!
  str r7, [r13,#-4]!
  str r6, [r13,#-4]!
  str r5, [r13,#-4]!
  str r4, [r13,#-4]!
  str r3, [r13,#-4]!
  str r2, [r13,#-4]!
  str r1, [r13,#-4]!

  mov r7, r12     @ original_turn=r7
  mov r12, r0     @ turn = player

  mov r6, #0      @ isPossible = r6
  mov r5, #0      @ i = r5
  mov r4, #0      @ j = r4

  Outer_Loop:
    mov r4,#0     @j=0
    Inner_Loop:
      @r1 = BOARD[get(i,j)]
      mov r0, r5
      mov r1, r4
      bl get
      ldr r1, =BOARD
      ldr r1, [r1,r0,LSL#2]

      @if(board[i,j] == 0)
      cmp r1,#0
      bne check_skip
        mov r0,r5
        mov r1,r4
        mov r2,#0
        bl move
        mov r6,r0

      check_skip:

      add r4,r4,#1    @j++

      cmp r4,#8
      bge Inner_Exit
      cmp r6,#0
      bne Inner_Exit
      b Inner_Loop
    Inner_Exit:
    
    add r5,r5,#1      @i++

    cmp r5, #8
    bge Outer_Exit
    cmp r6,#0
    bne Outer_Exit
    b Outer_Loop
  Outer_Exit:

  mov r12, r7
  mov r0,r6
  return_check:
    ldr r1, [r13],#4
    ldr r2, [r13],#4
    ldr r3, [r13],#4
    ldr r4, [r13],#4
    ldr r5, [r13],#4
    ldr r6, [r13],#4
    ldr r7, [r13],#4
    ldr r14, [r13],#4
    mov r15,r14
@-------------------------------------------------------------------------@

  .data
BOARD:  .space 400
  .align
SCORE: .space 400
  .align
.end

