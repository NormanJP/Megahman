.equ clock, 0x10002000 #address of the timer
.equ VGApixel, 0x08000000 #address of pixel buffer
.equ VGAchar, 0x09000000 #character VGA buffer
.equ Cyan, 0b11111111
.equ Darkblue, 0b10111
.equ timerSpeed, 390325
.equ switches, 0x10000040
.equ Left, 0
.equ Right, 1
.equ PS2Keyboard, 0x10000100
.equ BASE_ADDRESS_AUDIO, 0x10003040


#390325

.section .data

.align 0

BYTE1_KEYBOARD:
	.byte 0

BYTE2_KEYBOARD:
	.byte 0

Up:
	.byte 0

Left:
	.byte 0

Right:
	.byte 0

Lkey:
	.byte 0

Prev:
	.byte 0

PrevPrev:
	.byte 0

PrevPrevPrev:
	.byte 0

PrevPrevPrevPrev:
	.byte 0

.align 1
rightWalk:
.incbin "walkRight"

rightWalk2:
.incbin "walkRight2"

rightWalk3:
.incbin "walkRight3"

.align 1
MegaBuster:
.incbin "shot"
	
MegamanStand: #a 31 x 24 image
.incbin "standRight"

JumpingRight:
.incbin "jumpRight"

lvl1:
.incbin "lvl1"

lvl2:
.incbin "lvl2"

lvl3:
.incbin "lvl3"

lvl1base:
.incbin "lvl1base"

lvl2base:
.incbin "lvl2base"

gameOver:
.incbin "gameOver"

SmallEnemy:
.incbin "smallEnemy"

EnemyStanding:
.incbin "enemyStanding"

EnemyThrowing:
.incbin "enemyThrow"

EnemyProjectile:
.incbin "enemyProjectile"

TitleScreen:
.incbin "TitleScreen"

HairFlow:
.incbin "hairFlow"

.align 2

timerNum:
	.word 0
#Coordinates of the bullet
busterX:
	.word 85
	
busterY:
	.word 58

PreviousBusterX:
	.word 85
	
PreviousBusterY:
	.word 58
	
velocity: #Direction of bullet travel
	.word 1

MegamanX: #Furthest left value of megaman
	.word 53

MegamanY: #Furthest south value of megaman
	.word 151

PreviousMegamanX:
	.word 53
	
PreviousMegamanY:
	.word 151
	
MegamanDirection: #stores the direction Megaman is facing
	.word Right

MegamanPose: #stores the pose Megaman is currently in
	.word 0

poseFlag: #stores whether or not the pose should be changed
	.word 0
	
shotOnScreen: #check if there is a shot on the screen atm
	.word 0

shotDirection:
	.word 0

movementFlag: #increment at each clock interrupt for Megaman's movement
	.word 2
	
jumpingOn: #check if megaman is currently jumping
	.word 0

StartingHeight:
	.word 0
	
peakReached: #flag to check if megaman has raeched the peak of his jump yet
	.word 0

Landed:
	.word 0

straightJump:
	.word 0
	
PreviousPose:
	.word 0

Level: #contains which level Megaman is currently in
	.word 1

shootingReturn: #find where in the code you should return to from initializing the shot
	.word 0

EnemyX:
	.word 0

EnemyY:
	.word 0

EnemyAlive:
	.word 0

EnemyPose:
	.word 0

AxeX:
	.word 0

AxeY:
	.word 0

pAxeX:
	.word 0

pAxeY:
	.word 0

axeOnScreen:
	.word 0
	
DeathFlag:
	.word 0

ThrowFlag:
	.word 0
	
ShootAudio:
.incbin "shoot.wav"

EndShoot:
.word 0

JumpAudio:
.incbin "jump.wav"

EndJump:
.word 0 


.section .text
#VGA has dimensions 320x240
#
#
# Draw pixel to screen, OFFSET = 2*x + 1024*y
# Pixel colour: 	
#
#		Red			Green 	   Blue
#	    15..11      10..5      4..0
#
# 

.section .exceptions, "ax"
.align 2
Handler:
	addi sp, sp, -56 
	stwio ra, 52(sp)
	stwio r9, 48(sp)
	stwio r8, 44(sp)
	stwio r14, 40(sp)
	stwio r13, 36(sp)
	stwio r12, 32(sp)
	stwio r4, 28(sp)
	stwio r7, 24(sp)
	stwio r10, 20(sp)
	stwio r5, 16(sp)
	stwio r6, 12(sp)
	stwio ea, 8(sp) #store the return address for the handler
	rdctl r10, ctl1 #save ctl-1
	stwio r10, 4(sp)
	rdctl r10, ctl4
	stwio r10, 0(sp) #save ctl-4 original value	

Check_Routine:
	#r10 now holds the irq value of which device has interrupted
	addi r13, r0, 1
	beq r10, r13, Timer_Subroutine
	addi r13, r0, 0b10000000
	beq r10, r13, Keyboard_Subroutine
	addi r13, r0, 0b10000001
	beq r10, r13, Nested_Sorting

	br endHandlerKeyboard


Nested_Sorting: #find out which subroutine to perform
	
	ldw r12, 56(sp) #get the previous ctl4 for checking
	addi r13, r0, 1
	beq r10, r13, Keyboard_Subroutine
	addi r13, r0, 0b10000000
	beq r10, r13, Timer_Subroutine




Keyboard_Subroutine:
	movia r8, Prev
	movia r13, PrevPrev
	movia r14, PrevPrevPrev
	movia r9, PrevPrevPrevPrev
	ldb r12, 0(r14)
	stb r12, 0(r9) #move ppp to pppp
	
	ldb r12, 0(r13)
	stb r12, 0(r14) #move pp to ppp

	ldb r12, 0(r8)
	stb r12, 0(r13)#move p to pp


movia r8,PS2Keyboard
	ldwio r14,0(r8)
	
	#RAVAIL = r16
	andhi r9,r14,0xffff
	srli  r9,r9,16
	bgt r9,r0,STORE_BYTE
	br BUTTON_PRESSED

STORE_BYTE:
	movia et, BYTE1_KEYBOARD
	movia r5, BYTE2_KEYBOARD
	ldb   r12,0(r5) #loading byte2
	ldb   r10,0(et) #loading byte1
	mov   r12,r10           #byte2 = r11
	andi  r14,r14,0xff     #byte1 = r10
	mov   r10,r14 
	stbio r12,0(r5) #storing byte2
	stbio r10,0(et) #storing byte1
	
BUTTON_PRESSED:

	movi r9,0xf0
	andi r10,r10,0xff     
	andi r12,r12,0xff     
	beq r10,r9, exit_handler
	beq r12,r9, CLEAR
	

	movia et, BYTE1_KEYBOARD
	movia r5, BYTE2_KEYBOARD
	
	movi r9,0x1c
	beq r10,r9,A
	movi r9,0x1d
	beq r10,r9,W
	movi r9,0x23
	beq r10,r9,D
	movi r9,0x4b
	beq r10,r9,L

CLEAR:
	#Any of the previous buttons were selected. Thus, clear the variable.
	stbio   r0,0(r5) #storing byte2
	stbio   r0,0(et) #storing byte1
	br endHandlerKeyboard
	
A:	
	movi r6,0x01
	movia r4,Left
	stb r6,0(r4)
	movia r13, Prev
	movia r12, 10
	stb r12, 0(r13)
	br endHandlerKeyboard
	
W:	
	movi r6,0x01
	movia r4, Up
	stb r6,0(r4)
	movia r13, Prev
	movia r12, 11
	stb r12, 0(r13)
	br endHandlerKeyboard
D:	
	movi r6,0x01
	movia r4,Right
	stb  r6,0(r4)
	movia r13, Prev
	movia r12, 12
	stb r12, 0(r13)
	br endHandlerKeyboard
L:	
	movi r6, 0x01
	movia r4,Lkey
	stb r6,0(r4)
	movia r13, Prev
	movia r12, 13
	stb r12, 0(r13)
	br endHandlerKeyboard
#END OF THE KEYBOARD SUBROUTINE
Timer_Subroutine:

	movia r10, clock
	movi r5, 0x1
	stwio r5, 0(r10) #clear the timeout bit from the timer

checkForCompletion:
	call isLevelDone
	ldw r12, 0(sp)
	addi sp, sp, 4 #restore stack pointer

	#return 1 if level is finished

	beq r12, r0, checkForBeingDead

incrementLevel:
	movia r13, Level
	ldw r12, 0(r13)
	addi r12, r12, 1
	stw r12, 0(r13)
	call loadLevel

checkForBeingDead:
	movia r13, MegamanY
	ldw r12, 0(r13)
	addi r13, r0, 189
	bne r12, r13, checkForEnemyDeath

	MegamanFellDown:

		movia r13, peakReached
		stw r0, 0(r13) #remove the peak being reached
		movia r13, jumpingOn
		stw r0, 0(r13)
	
		movia r4, gameOver
		call drawToWholeScreen
	
		movia r13, 50000000
		delayLoop:
		addi r13, r13, -1
		bne r13, r0, delayLoop
	
		call loadLevel
	
		br checkingIfJump


	checkForEnemyDeath:

		movia r13, DeathFlag
		ldw r12, 0(r13)
		beq r12, r0, checkingIfJump

		MegamanDiedRIP:
			stw r0, 0(r13) #reset the death flag
			movia r13, jumpingOn
			stw r0, 0(r13) #reset jumping flag
			movia r4, gameOver
			call drawToWholeScreen
		
			movia r13, 50000000
			delayLoopDeath:
			addi r13, r13, -1
		bne r13, r0, delayLoopDeath	

		call loadLevel


	br checkingIfJump

checkingIfJump: #check if Megaman is currently jumping before asking user for more input
	movia r13, jumpingOn
	ldw r12, 0(r13)
	bne r12, r0, inTheAir

checkIfStandingProperly:
	movia r13, MegamanX
	ldw r4, 0(r13)
	movia r13, MegamanY
	ldw r5, 0(r13)
	call amITouchingGround
	ldw r12, 0(sp)
	addi sp, sp, 4 #restore stack pointer COMPLETELY

	bne r12, r0, startFalling
	br checkIfLanded

	startFalling: 
		movia r13, peakReached
		addi r12, r0, 1
		stw r12, 0(r13)
		br initWithDirection

	
checkIfLanded: #check if Megaman has just come out of his jumping animation

	movia r13, Landed
	ldw r12, 0(r13)
	beq r12, r0, checkingInput
	
	MegamanLanded: #Accordingly reset his previous x and previous y values
		stw r0, 0(r13) #reset the landed flag
		movia r13, PreviousMegamanX #store previous location of megaman
		movia r4, MegamanX
		ldw r12, 0(r4)
		stw r12, 0(r13) #store previous X value
		movia r13, PreviousMegamanY
		movia r4, MegamanY
		ldw r12, 0(r4)
		stw r12, 0(r13) #store previous Y value
		
checkingInput:
	
	movia r13, switches
	ldw r12, 0(r13)

	andi r14, r12, 0b100000000000000000
	beq r14, r0, startReadingInput
	
	#recieve input that the keyboard designated
	movia r13, Up
	ldb r8, 0(r13)
	andi r8, r8, 0b1
	slli r8, r8, 3
	movia r13, Lkey
	ldb r9, 0(r13)
	andi r9, r9, 0b1
	slli r9, r9, 2
	or r12, r8, r9
	movia r13, Left
	ldb r8, 0(r13)
	andi r8, r8, 0b1
	slli r8, r8, 1
	or r12, r12, r8 #r12 now has the jump, shoot, and moveleft commandds in that order
	movia r13, Right
	ldb r8, 0(r13)
	andi r8, r8, 0b1
	or r12, r12, r8 #now r12 has all the values

startReadingInput:
	addi r13, r0, 0b100
	beq r12, r13, startShooting #if SW[2] is pressed make megaman start shooting
	addi r13, r0, 0b1
	beq r12, r13, noInitMovingRight #if SW[0] is on move Megaman right
	addi r13, r0, 0b10
	beq r12, r13, noInitMovingLeft #if SW[1] is on move Megaman left
	addi r13, r0, 0b1001
	beq r12, r13, initWithDirection
	addi r13, r0, 0b1010
	beq r12, r13, initWithDirection
	addi r13, r0, 0b1101
	beq r12, r13, initWithDirection
	addi r13, r0, 0b1110
	beq r12, r13, initWithDirection
	addi r13, r0, 0b1000
	beq r12, r13, initNoDirection #jump in no particular direction
	addi r13, r0, 0b1100
	beq r12, r13, initNoDirection #jump in no particular direction
	addi r13, r0, 0b101
	beq r12, r13, initMovingRight #move and initialize a shot
	addi r13, r0, 0b110
	beq r12, r13, initMovingLeft #move and initialize a shot
	#beq r12, r0, stand #if nothing is pressed make megaman do nothing 
	br stand

checkForSimultaneousShooting:

		noInitMovingRight:
			movia r13, shootingReturn
			stw r0, 0(r13) #remove shot init flag
			br goRight
		
		noInitMovingLeft:
			movia r13, shootingReturn
			stw r0, 0(r13) #turn off shot initialization flag
			br goLeft
		
		initMovingRight:
			movia r13, shootingReturn
			addi r12, r0, 1
			stw r12, 0(r13) #
			br goRight
		
		initMovingLeft:
			movia r13, shootingReturn
			addi r12, r0, 1
			stw r12, 0(r13)
			br goLeft


Attack_Subset:
startShooting:
	movia r13, shotOnScreen
	ldw r12, 0(r13)
	bne r12, r0, bulletOnScreen #if shotOnScreen != 0 then there is already a shot on screen and it must be incremented accordingly
	#at this point there is a shot on screen and we need to know where to return


intializeShot: #initialize the x, y and direction of the shot
	

	addi r12, r0, 1
	stw r12, 0(r13) #set shotOnScreen = 1

	movia r13, MegamanDirection
	ldw r12, 0(r13)

	movia r9, Left
	beq r12, r9, initLeft #if megaman is standing left initialize the shot to the left of him

initRight:
	movia r13, shotDirection
	movia r12, Right
	stw r12, 0(r13) #set the shot direction to be right (not left)

	movia r13, busterX
	movia r9, MegamanX
	ldw r8, 0(r9)
	addi r12, r8, 32
	stw r12, 0(r13) #store buster X value to right of megaman
	movia r13, PreviousBusterX
	stw r12, 0(r13) #initialize the previous X location

	movia r13, busterY
	movia r9, MegamanY
	ldw r8, 0(r9) #get Megaman's Y-value into register r9
	addi r12, r8, -15 #put it at same height as cannon
	stw r12, 0(r13) #store busterY value at the height of Megaman's cannon
	movia r13, PreviousBusterY 
	stw r12, 0(r13) #initialize the previous Y location



	br endHandler

initLeft:
	movia r13, shotDirection
	movia r12, Left
	stw r12, 0(r13)

	movia r13, busterX
	movia r9, MegamanX
	ldw r8, 0(r9)	
	addi r12, r8, -10
	stw r12, 0(r13) #store buster X value to left of megaman
	movia r13, PreviousBusterX
	stw r12, 0(r13) #initialize the previous X location

	movia r13, busterY
	movia r9, MegamanY
	ldw r8, 0(r9)
	addi r12, r8, -15
	stw r12, 0(r13) #store busterY value at the height of Megaman's cannon
	movia r13, PreviousBusterY 
	stw r12, 0(r13) #initialize the previous Y location

	br endHandler


stand:
	movia r13, MegamanPose
	ldw r12, 0(r13)
	movia r14, PreviousPose
	stw r12, 0(r14) #store the previous pose
	stw r0, 0(r13)

	movia r13, shootingReturn
	stw r0, 0(r13) #remove simlutaneous shooting flag
	
	br checkForShot

	
Jump_Subset:
initWithDirection:
	movia r13, straightJump
	stw r0, 0(r13) #remove the straight jump flag
	br jumpInitialize

initNoDirection:
	movia r13, straightJump
	addi r12, r0, 1
	stw r12, 0(r13)

jumpInitialize:
#turn on the jumping flag and store the starting height of the jump
	movia r13, jumpingOn
	addi r12, r0, 1
	stw r12, 0(r13) #turn on the jumping flag
	
	movia r13, MegamanY
	ldw r12, 0(r13)
	movia r14, StartingHeight
	stw r12, 0(r14) #store the height Megaman began jumping at
	
	movia r13, MegamanPose
	movia r14, PreviousPose
	ldw r12, 0(r13)
	stw r12, 0(r14) #get the previous pose
	addi r12, r0, 5
	stw r12, 0(r13) #set pose to jumping

	br jumpDirection #skip the check for megaman touching the ground and go straight to inrementing his vertical coordinate
	
inTheAir:
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------
#Check if Megaman is touching the ground at this point in the code ----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	movia r13, MegamanX
	ldw r4, 0(r13)
	movia r13, MegamanY
	ldw r5, 0(r13)
	call amITouchingGround
	ldw r12, 0(sp)
	addi sp, sp, 4 #completely restore the stack pointer

	beq r12, r0, wasThePeakAlsoReached #if the value returned is 0 then you're touching the ground and therefore take megaman out of the air
	br justContinue
	#else carry on

wasThePeakAlsoReached:
	movia r13, peakReached
	ldw r12, 0(r13)
	bne r12, r0, outOfTheAir

justContinue:


	movia r13, MegamanPose
	movia r14, PreviousPose
	ldw r12, 0(r13)
	stw r12, 0(r14) #get the previous pose
	
jumpDirection:
	
	movia r13, PreviousMegamanX #store previous location of megaman
	movia r4, MegamanX
	ldw r12, 0(r4)
	stw r12, 0(r13) #store previous X value
	movia r13, PreviousMegamanY
	movia r4, MegamanY
	ldw r12, 0(r4)
	stw r12, 0(r13) #store previous Y value

	movia r13, peakReached
	ldw r12, 0(r13)
	bne r12, r0, jDescend #descend megaman's jump if he has already reached his peak
	
	jAscend:
	#check if megaman has reached the peak of his jump first
		movia r4, MegamanY
		ldw r14, 0(r4) #store current Y into register r14
		movia r13, StartingHeight
		ldw r12, 0(r13) #get starting height into register r12
		addi r12, r12, -35#peak of Megaman's jump is 8 pixels above his initial jumping height
		beq r14, r12, turnPeakOn #turn on the peak of his jump if he reached the peak
		
		addi r14, r14, -1 #increase height by one pixel
		stw r14, 0(r4) #store Megaman's Y value
		br jChangeX #redundant but included for personal reference
		
	jChangeX:

		movia r13, straightJump
		ldw r12, 0(r13)
		bne r12, r0, straightUpwards #don't increment X if megaman is intended to only jump straight up


		br movingSidewaysInAir #else increment X

		straightUpwards:
				movia r13, switches
				ldw r12, 0(r13) #KeyboardPassword
				andi r8, r12, 0b100000000000000000
				bne r8, r0, jumpingKeyInputs

			jumpingSwitchInputs:
				andi r12, r12, 0b100
				bne r12, r0, startShooting #shoot if the shoot switch is on	
				br checkForShot
			jumpingKeyInputs:	
				movia r13, Lkey
				ldb r12, 0(r13)
				bne r12, r0, startShooting
				br checkForShot


		movingSidewaysInAir:
			movia r13, MegamanDirection #check if megaman is facing left or right and move him accordingly
			ldw r12, 0(r13)
			movia r4, Left
			movia r13, MegamanX
			ldw r14, 0(r13) #r14 holds Megaman's x coordinate
			beq r12, r4, jGoLeft
			
			jGoRight: 

			
			#check if right movement is prohibited
				movia r13, MegamanX
				ldw r4, 0(r13)
				movia r13, MegamanY
				ldw r5, 0(r13)
				call canIMoveRight
				ldw r12, 0(sp)
				addi sp, sp, 4 #restore sp completely
				bne r12, r0, checkForShot

				movia r13, MegamanX
				addi r14, r14, 1  #increment x value to the right
				stw r14, 0(r13)

				movia r13, switches
				ldw r12, 0(r13) #KeyboardPassword
				andi r8, r12, 0b100000000000000000
				bne r8, r0, jumpingKeyInputr

			jumpingSwitchInputr:
				andi r12, r12, 0b100
				bne r12, r0, startShooting #shoot if the shoot switch is on	
				br checkForShot
			jumpingKeyInputr:	
				movia r13, Lkey
				ldb r12, 0(r13)
				bne r12, r0, startShooting
				br checkForShot



			jGoLeft:

				movia r13, MegamanX
				ldw r4, 0(r13)
				movia r13, MegamanY
				ldw r5, 0(r13)
				call canIMoveLeft
				ldw r12, 0(sp)
				addi sp, sp, 4 #restore sp completely
				bne r12, r0, checkForShot

				movia r13, MegamanX
				addi r14, r14, -1 #increment x value to the left
				stw r14, 0(r13)

				movia r13, switches
				ldw r12, 0(r13) #KeyboardPassword
				andi r8, r12, 0b100000000000000000
				bne r8, r0, jumpingKeyInputl

			jumpingSwitchInputl:
				andi r12, r12, 0b100
				bne r12, r0, startShooting #shoot if the shoot switch is on	
				br checkForShot
			jumpingKeyInputl:	
				movia r13, Lkey
				ldb r12, 0(r13)
				bne r12, r0, startShooting
				br checkForShot

	turnPeakOn:
		movia r13, peakReached
		addi r12, r0, 1
		stw r12, 0(r13) #set the peak flag to be on
	
	jDescend:
		movia r13, MegamanY
		ldw r12, 0(r13) 
		addi r12, r12, 1 #move megaman down the screen one pixel
		stw r12, 0(r13) #store the new y value
		br jChangeX

outOfTheAir:

	movia r13, Landed
	addi r12, r0, 1
	stw r12, 0(r13) #set the Landed flag to be on
	
	movia r13, jumpingOn
	stw r0, 0(r13) #Remove the jumping flag to take Megaman out of the air
	movia r13, peakReached
	stw r0, 0(r13) #remove flag stating that megaman has reached the peak of his jump
	
	br checkForShot
	
Right_Subset:
goRight:
	
	movia r13, MegamanX
	ldw r4, 0(r13)
	movia r13, MegamanY
	ldw r5, 0(r13)
	call canIMoveRight
	ldw r12, 0(sp)
	addi sp, sp, 4 #restore stack pointer completely

	bne r12, r0, stand #if I can't move right then make Megaman stand in place 
	#else he can move right

	movia r13, movementFlag
	ldw r12, 0(r13)
	
	movia r14, 2

	beq r12, r14, startMovingRight

	addi r12, r12, 1
	stw r12, 0(r13)

	movia r13, shootingReturn
	ldw r12, 0(r13)
	bne r12, r0, startShooting #check if user is currently trying to shoot or not


	br checkForShot

startMovingRight:
	stw r0, 0(r13) #reset the movement flag (controlled by timer)
	movia r13, MegamanX
	ldw r4, 0(r13)
	movia r10, PreviousMegamanX
	stw r4, 0(r10)
	addi r4, r4, 1
	stw r4, 0(r13) #return the x value

	movia r13, MegamanDirection #Megaman will now face right
	movia r12, Right
	stw r12, 0(r13)
	
	movia r13, MegamanPose
	movia r14, PreviousPose
	ldw r12, 0(r13)
	stw r12, 0(r14) #store the previous pose
	
	movia r13, poseFlag
	ldw r12, 0(r13)
	movia r4, 6
	beq r12, r4, changePose #change Megaman's pose every 6 pixels
	
	addi r12, r12, 1
	stw r12, 0(r13) #increment poseFlag

	movia r13, shootingReturn
	ldw r12, 0(r13)
	bne r12, r0, startShooting #check if user is currently trying to shoot or not

	
	br checkForShot



Left_Subset:
goLeft:

	movia r13, MegamanX
	ldw r4, 0(r13)
	movia r13, MegamanY
	ldw r5, 0(r13)
	call canIMoveLeft
	ldw r12, 0(sp)
	addi sp, sp, 4 #restore stack pointer completely

	bne r12, r0, stand #if I can't move left then make Megaman stand in place 
	#else he can move left

	movia r13, movementFlag
	ldw r12, 0(r13)
	movia r14, 2

	beq r12, r14, startMovingLeft

	addi r12, r12, 1
	stw r12, 0(r13)


	movia r13, shootingReturn
	ldw r12, 0(r13)
	bne r12, r0, startShooting #check if user is currently trying to shoot or not

	br checkForShot #leave the movement stage if not raedy to move yet

startMovingLeft:
	stw r0, 0(r13) #reset the flag
	movia r13, MegamanX
	ldw r4, 0(r13) #get X value into register r4
	movia r10, PreviousMegamanX
	stw r4, 0(r10)
	addi r4, r4, -1
	stw r4, 0(r13) #return x value

	movia r13, MegamanDirection #store the direction megaman is facing as left
	movia r12, Left
	stw r12, 0(r13)

	movia r13, MegamanPose
	movia r14, PreviousPose
	ldw r12, 0(r13)
	stw r12, 0(r14) #store the previous pose
	
	
	movia r13, poseFlag
	ldw r12, 0(r13)
	movia r4, 6
	beq r12, r4, changePose #change Megaman's pose every 6 pixels
	
	addi r12, r12, 1
	stw r12, 0(r13) #increment poseFlag
	
	movia r13, shootingReturn
	ldw r12, 0(r13)
	bne r12, r0, startShooting #check if user is currently trying to shoot or not

	br checkForShot
	
changePose:
		#currently r13 holds the poseFlag address
		
		stw r0, 0(r13) #reset the flag
		
		movia r13, MegamanPose
		ldw r12, 0(r13)
	
		beq r12, r0, makeRunning
		addi r13, r0, 1
		beq r12, r13, makeRunning2
		addi r13, r0, 2
		beq r12, r13, makeRunning3
		addi r13, r0, 3
		beq r12, r13, makeRunning
		addi r13, r0, 5
		beq r12, r13, makeStanding

	makeStanding:
		movia r13, MegamanPose
		stw r0, 0(r13) #make megaman's position be standing
		br checkForShot

	makeRunning:
		movia r13, MegamanPose
		addi r12, r0, 1
		stw r12, 0(r13) #make megaman's position be running
	
		br checkForShot

	makeRunning2:
		addi r12, r0, 2
		movia r13, MegamanPose
		stw r12, 0(r13) 
		br checkForShot

	makeRunning3:
		movia r13, MegamanPose
		addi r12, r0, 3
		stw r12, 0(r13) 
		br checkForShot


Shooting_Subset:
checkForShot:

	movia r13, shotOnScreen #shotOnScreen == 1 if true, 0 if no shot on screen
	ldw r12, 0(r13)
	beq r12, r0, endHandler #exit handler if no shot is on the screen, else increment the shot

bulletOnScreen: #there is a bullet on the screen, increment it in one direction
	
checkForBoundaries:
	movia r14, 320 #check if the shot has flown off of the screen
	movia r9, -8
	movia r10, busterX
	ldw r8, 0(r10)
	blt r8, r9, removeBuster
	bgt r8, r14, removeBuster
	
	movia r10, PreviousBusterX #Storing the values of the previous coordinates
	stw r8, 0(r10)
	movia r10, busterY
	ldw r8, 0(r10)
	movia r10, PreviousBusterY
	stw r8, 0(r10)
	
	movia r13, shotDirection #now that the bullet is in range, check for the direction
	ldw r12, 0(r13)
	movia r13, Left
	beq r12, r13, incrementShotLeft 

incrementShotRight:

	movia r13, busterX
	ldw r4, 0(r13)
	addi r4, r4, 1 #increment one pixel to the right
	stw r4, 0(r13) #save the new X value
	
	br endHandler

incrementShotLeft:

	movia r13, busterX
	ldw r4, 0(r13)
	addi r4, r4, -1 #increment one pixel to the left
	stw r4, 0(r13) #save the new X value
	
	br endHandler


removeBuster:
	movia r13, shotOnScreen

	stw r0, 0(r13) #set shot on screen variable to off
	br endHandler

	
endHandler:
	
	call enemyLogic
	call enemyDrawing
	call redraw_Screen
	br endHandlerKeyboard

exit_handler: #clears all of the direction variables
	movia r13,Lkey
	stbio r0,0(r13)
	movia r13,Left
	stbio r0,0(r13)
	movia r13,Right
	stbio r0,0(r13)
	movia r13,Up
	stbio r0,0(r13)

#Code for unimplemented optimizations on imput for contorlling megaman
#	movia r8, Prev
#	movia r13, PrevPrev
#	movia r14, PrevPrevPrev
#	movia r9, PrevPrevPrevPrev
#	ldb r12, 0(r14)
#	stb r12, 0(r8) #shift right twice
#	ldb r12, 0(r9)
#	stb r0, 0(r9)
#	stb r0, 0(r14)
#	stb r12, 0(r13) #now p holds ppp and pp holds pppp
#	ldb r14, 0(r8)
#
#checkPrevious:
#	addi r13, r0, 10
#	beq r14, r13, turnOnA
#
#	addi r13, r0, 11
#	beq r14, r13, turnOnW
#
#	addi r13, r0, 12
#	beq r14, r13, turnonD
#
#	addi r13, r0, 13
#	beq r14, r13, turnOnL
#
#turnOnA:
#	movia r13, Left
#	addi r14, r0, 1
#	stb r14, 0(r13)
#	br checkPreviousP
#
#turnOnW:
#	movia r13, Up
#	addi r14, r0, 1
#	stb r14, 0(r13)
#	br checkPreviousP
#
#turnonD:
#	movia r13, Right
#	addi r14, r0, 1
#	stb r14, 0(r13)
#	br checkPreviousP
#
#turnOnL:
#	movia r13, Lkey
#	addi r14, r0, 1
#	stb r14, 0(r13)
#	br checkPreviousP
#
#checkPreviousP:
#	
#	addi r13, r0, 10
#	beq r12, r13, turnOnA2
#
#	addi r13, r0, 11
#	beq r12, r13, turnOnW2
#
#	addi r13, r0, 12
#	beq r12, r13, turnonD2
#
#	addi r13, r0, 13
#	beq r12, r13, turnOnL2
#
#
#turnOnA2:
#	movia r13, Left
#	addi r14, r0, 1
#	stb r14, 0(r13)
#	br endHandlerKeyboard
#
#turnOnW2:
#	movia r13, Up
#	addi r14, r0, 1
#	stb r14, 0(r13)
#	br endHandlerKeyboard
#
#turnonD2:
#	movia r13, Right
#	addi r14, r0, 1
#	stb r14, 0(r13)
#	br endHandlerKeyboard
#
#turnOnL2:
#	movia r13, Lkey
#	addi r14, r0, 1
#	stb r14, 0(r13)
#	br endHandlerKeyboard


endHandlerKeyboard:
	ldwio ra, 52(sp)
	ldwio r9, 48(sp)
	ldwio r8, 44(sp)
	ldwio r14, 40(sp)
	ldwio r13, 36(sp)
	ldwio r12, 32(sp)
	ldwio r4, 28(sp)
	ldwio r7, 24(sp)
	ldwio r10, 20(sp)
	ldwio r5, 16(sp)
	ldwio r6, 12(sp)
	ldwio ea, 8(sp)
	ldwio r10, 4(sp) #restore ctl-1
	wrctl ctl1, r10
	ldwio r10, 0(sp)
	addi sp, sp, 52
	addi ea, ea, -4 #restore ea
	
eret
#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
#---------------------------------------------- MAIN PROGRAM -----------------------------------------
#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
.global main

main:
	
startTitleLoop:
	movia r4, TitleScreen
	call drawToWholeScreen

	movia r18, 2000000
	loopOneE:
		addi r18, r18, -1
		bne r18, r0, loopOneE

	movia r4, 266
	movia r5, 101
	movia r6, HairFlow
	call drawHairFlow

	movia r18, 2000000
	loopTwoE:
		addi r18, r18, -1
		bne r18, r0, loopTwoE

	movia r13, switches
	ldw r7, 0(r13)
	andi r7, r7, 0b1

	addi r13, r0, 0b1
	bne r7, r13, startTitleLoop



	call clearScreen
	call redraw_Screen
	

	call loadLevel

	
#--------------Enable timer interrupts---------------------------

	movia r16, clock
	addi r4, r0, 0x1
	stwio r4, 4(r16) #enable timer interrupts
	movia r16, PS2Keyboard
	stwio r4, 4(r16) #enable keyboard interrupts

	addi r4, r0, 0b10000001 #enable IRQ0 and IRQ7
		
	wrctl ctl3, r4 #enable IRQ0 and IRQ7, accepting timer interrupts to the CPUs
	
	wrctl ctl0, r4 #allow CPU to accept interrupts


	call timerInitialize
#----------------------- Finish interrupt initialization---------------------------


Program_Start:
	

program_finished:
	br program_finished


#------------------------------ Functions -------------------------------------------

clearBuster:
	addi sp, sp, -12
	stw r16, 0(sp)
	stw ra, 4(sp)
	stw r4, 8(sp)
	
	call clearPreviousShot
	
	ldw r16, 0(sp)
	ldw ra, 4(sp)
	ldw r4, 8(sp)
	addi sp, sp, 12	
ret

# void redraw_Screen (        ) {     
redraw_Screen:
	addi sp, sp, -40
	stw r4, 0(sp)
	stw r5, 4(sp)
	stw r6, 8(sp)
	stw r7, 12(sp)
	stw r8, 16(sp)
	stw r9, 20(sp)
	stw r10, 24(sp)
	stw r12, 28(sp)
	stw r13, 32(sp)
	stw ra, 36(sp)

	
	movia r13, PreviousMegamanX #store the arguments for x and y
	ldw r4, 0(r13)
	movia r13, PreviousMegamanY
	ldw r5, 0(r13)
#--------------------------------------------------------------------------
#TEMPORARY CODE REMOVE LATER PLZ NORMAN
	movia r13, Level
	ldw r10, 0(r13)
	addi r13, r0, 1
	beq r10, r13, setLevelOneBG
	addi r13, r0, 2
	beq r10, r13, setLevelTwoBG
	addi r13, r0, 3
	beq r10, r13, setLevelThreeBG

setLevelOneBG:
	movia r6, lvl1
	br poseChecking

setLevelTwoBG:
	movia r6, lvl2
	br poseChecking

setLevelThreeBG:
	movia r6, lvl3
	br poseChecking
#----------------------------------------------------------------------------------------
	
poseChecking:
	movia r13, PreviousPose
	ldw r12, 0(r13) #get previous pose into register r12
	
	addi r7, r0, 5
	bne r12, r7, removeGround 
	
removeAir:
	
	call removeMegamanJumping
	br MegamanIsRemoved
	
removeGround:
	call removeMegaman #clear background entirely (when I have an image for a level I will simply erase megaman with it)
	br MegamanIsRemoved
	
	
MegamanIsRemoved:
	movia r13, MegamanX #store the arguments for x and y
	ldw r4, 0(r13)
	movia r13, MegamanY
	ldw r5, 0(r13)
	movia r6, MegamanStand
	movia r13, MegamanPose
	ldw r10, 0(r13) #store the pose position in register r10 this will be used later

	movia r13, MegamanDirection
	ldw r12, 0(r13)
	movia r13, Left
	beq r12, r13, drawHimLeft

drawHimRight:
		
	addi r7, r0, 1
	beq r10, r7, rightPoseTwo
	addi r7, r0, 2
	beq r10, r7, rightPoseThree
	addi r7, r0, 3
	beq r10, r7, rightPoseFour
	addi r7, r0, 5
	beq r10, r7, rightPoseJump
#else draw standing megaman
	rightPoseOne:
		call drawStandingRight
		br shotChecking

	rightPoseTwo:
		addi r4, r4, 2
		movia r6, rightWalk
		call drawWalkingRight
		br shotChecking

	rightPoseThree:
		addi r4, r4, 5
		movia r6, rightWalk2
		call drawWalkingRight2
		br shotChecking

	rightPoseFour:
		addi r4, r4, 1
		movia r6, rightWalk3
		call drawWalkingRight3
		br shotChecking
		
	rightPoseJump:
		movia r6, JumpingRight
		call drawJumpingRight
		br shotChecking
	

drawHimLeft:
	
	addi r7, r0, 1
	beq r10, r7, leftPoseTwo
	addi r7, r0, 2
	beq r10, r7, leftPoseThree
	addi r7, r0, 3
	beq r10, r7, leftPoseFour
	addi r7, r0, 5
	beq r10, r7, leftPoseJump
	
	leftPoseOne:
		call drawStandingLeft
		br shotChecking
		
	leftPoseTwo:
		movia r6, rightWalk
		call drawWalkingLeft
		br shotChecking

	leftPoseThree:
		movia r6, rightWalk2
		call drawWalkingLeft2
		br shotChecking

	leftPoseFour:
		movia r6, rightWalk3
		call drawWalkingLeft3
		br shotChecking
		
	leftPoseJump:
		movia r6, JumpingRight
		call drawJumpingLeft
		br shotChecking
	
shotChecking:
	
	movia r13, shotOnScreen
	ldw r12, 0(r13) 

	beq r12, r0, shotOffScreen #finish the redrawing of there is no shot on the screen

theShotIsOnTheScreen:
	movia r13, PreviousBusterX	 #Get previous coordinates
	ldw r4, 0(r13)
	movia r13, PreviousBusterY
	ldw r5, 0(r13)

	movia r13, Level
	ldw r10, 0(r13)
	addi r13, r0, 1
	beq r10, r13, setLevelOneBGBuster
	addi r13, r0, 2
	beq r10, r13, setLevelTwoBGBuster
	addi r13, r0, 3
	beq r10, r13, setLevelThreeBGBuster

setLevelOneBGBuster:
	movia r6, lvl1
	br eraseBullet

setLevelTwoBGBuster:
	movia r6, lvl2
	br eraseBullet	

setLevelThreeBGBuster:
	movia r6, lvl3
	br eraseBullet

eraseBullet:

	call clearPreviousShot


	
	movia r13, busterX
	ldw r4, 0(r13)
	movia r13, busterY
	ldw r5, 0(r13)
	movia r6, MegaBuster
	movia r13, shotDirection
	ldw r10, 0(r13) #store direction of the shot into register r10
	movia r14, Left

	beq r10, r14, drawBulletLeft

drawBulletRight:

	call drawShotRight
	br screenRedrawn

drawBulletLeft:

	call drawShotLeft
	br screenRedrawn

shotOffScreen:
	movia r13, PreviousBusterX
	ldw r4, 0(r13)
	movia r13, PreviousBusterY
	ldw r5, 0(r13)
	movia r13, Level
	ldw r10, 0(r13)
	addi r13, r0, 1
	beq r10, r13, busterClearLvl1
	addi r13, r0, 2
	beq r10, r13, busterClearLvl2

busterClearLvl1:
	
	movia r6, lvl1
	br takeShotOut	
busterClearLvl2:
	movia r6, lvl2
	br takeShotOut

takeShotOut:
	call clearPreviousShot


screenRedrawn:

	ldw r4, 0(sp)
	ldw r5, 4(sp)
	ldw r6, 8(sp)
	ldw r7, 12(sp)
	ldw r8, 16(sp)
	ldw r9, 20(sp)
	ldw r10, 24(sp)
	ldw r12, 28(sp)
	ldw r13, 32(sp)
	ldw ra, 36(sp)
	addi sp, sp, 40
ret
#    return;
# }



timerInitialize:
	
	addi sp, sp, -12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)


	movia r16, timerSpeed
	movia r17, timerSpeed

	andi r16, r16, 0xFFFF  # get the lower 16 bits
	srli r17, r17, 16

	movia r18, clock

	
	stwio r16, 8(r18) #store lower half of period
	stwio r17, 12(r18) #store upper half of period

	addi r16, r0, 7 #Start and continue for control register of the clock + keep interrupt enabling
	stwio r16, 4(r18)


	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12

ret


#CHECK IF I CAN MOVE RIGHT
canIMoveRight:
	addi sp, sp, -40
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)
	stw r19, 12(sp)
	stw r20, 16(sp)
	stw r21, 20(sp)
	stw r22, 24(sp)
	stw r23, 28(sp)
	stw ra, 32(sp)

checkLevel:
	movia r17, Level #check which level we are currently on
	ldw r18, 0(r17)
	addi r17, r0, 1
	beq r18, r17, RlevelOne
	addi r17, r0, 2
	beq r18, r17, RlevelTwo
	addi r17, r0, 3
	beq r18, r17, RlevelThree
	br iCanMoveRight

RlevelOne:
	movia r17, 195

	beq r4, r17, RlevelOneWallOne #if x == 195
	#OR
	movia r17, 295
	bgt r4, r17, iCantMoveRight

	br iCanMoveRight

	RlevelOneWallOne:
		#x is 191 at this point
		movia r18, 132
		bgt r5, r18, iCantMoveRight #if y < 132 while x == 191
		br iCanMoveRight

RlevelTwo:
	movia r17, 295
	bgt r4, r17, iCantMoveRight

	movia r17, 36
	#beq r4, r17, RlevelTwoWallOne

	movia r17, 117 #checking the second wall
	beq r4, r17, RlevelTwoWallTwo

	movia r17, 192
	beq r4, r17, RlevelTwoWallThree

	movia r17, 240
	beq r4, r17, RlevelTwoWallFour

	br iCanMoveRight

	RlevelTwoWallOne:
		movia r17, 144
		blt r5, r17, RlevelTwoWallOneSecond
		br iCanMoveRight

		RlevelTwoWallOneSecond: #y is higher than 143 at this point
			movia r17, 114
			bgt r5, r17, iCantMoveRight
			br iCanMoveRight

	RlevelTwoWallTwo:
		movia r17, 114
		blt r5, r17, RlevelTwoWallTwoSecond

		RlevelTwoWallTwoSecond:
			movia r17, 91
			bgt r5, r17, iCantMoveRight
			br iCanMoveRight

	RlevelTwoWallThree:

		movia r17, 91
		blt r5, r17, RlevelTwoWallThreeSecond
		br iCanMoveRight

		RlevelTwoWallThreeSecond:
			movia r17, 69
			bgt r5, r17, iCantMoveRight
			br iCanMoveRight

	RlevelTwoWallFour:
		movia r17, 69
		blt r5, r17, RlevelTwoWallFourSecond
		br iCanMoveRight

		RlevelTwoWallFourSecond:
			movia r17, 47
			bgt r5, r17, iCantMoveRight
			br iCanMoveRight

RlevelThree:
	movia r17, 295
	beq r4, r17, iCantMoveRight
	br iCanMoveRight



iCantMoveRight:
	addi r17, r0, 1
	stw r17, 36(sp) #put 1 for flag "can't move right"
	br canIMoveRightFINISH

iCanMoveRight:
	stw r0, 36(sp) #flag 0 for "can move right"
	br canIMoveRightFINISH

canIMoveRightFINISH:
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	ldw r19, 12(sp)
	ldw r20, 16(sp)
	ldw r21, 20(sp)
	ldw r22, 24(sp)
	ldw r23, 28(sp)
	ldw ra, 32(sp)
	ldw r16, 0(sp)
	addi sp, sp, 36 #Save room for a return address
ret



canIMoveLeft:
	addi sp, sp, -40
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)
	stw r19, 12(sp)
	stw r20, 16(sp)
	stw r21, 20(sp)
	stw r22, 24(sp)
	stw r23, 28(sp)
	stw ra, 32(sp)

	movia r17, Level
	ldw r18, 0(r17)
	addi r17, r0, 1
	beq r18, r17, LlevelOne
	addi r17, r0, 2
	beq r18, r17, LlevelTwo
	addi r17, r0, 3
	beq r18, r17, LlevelThree

	br canIMoveLeftFINISH

LlevelOne:
	
	beq r4, r0, iCantMoveLeft
	br iCanMoveLeft

LlevelTwo:
	beq r4, r0, iCantMoveLeft
	br iCanMoveLeft

LlevelThree:
	beq r4, r0, iCantMoveLeft
	br iCanMoveLeft



iCantMoveLeft:
	addi r17, r0, 1
	stw r17, 36(sp) #put 1 for flag "can't move right"
	br canIMoveLeftFINISH

iCanMoveLeft:
	stw r0, 36(sp) #flag 0 for "can move right"
	br canIMoveLeftFINISH

	canIMoveLeftFINISH:
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	ldw r19, 12(sp)
	ldw r20, 16(sp)
	ldw r21, 20(sp)
	ldw r22, 24(sp)
	ldw r23, 28(sp)
	ldw ra, 32(sp)
	ldw r16, 0(sp)
	addi sp, sp, 36 #Save room for a return address
ret



amITouchingGround:
	addi sp, sp, -40
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)
	stw r19, 12(sp)
	stw r20, 16(sp)
	stw r21, 20(sp)
	stw r22, 24(sp)
	stw r23, 28(sp)
	stw ra, 32(sp)

	movia r16, Level
	ldw r17, 0(r16)
	addi r16, r0, 1
	beq r17, r16, TlevelOne
	addi r16, r0, 2
	beq r17, r16, TlevelTwo
	addi r16, r0, 3
	beq r17, r16, TlevelThree
	br groundTouching

TlevelOne:
	movia r18, 196
	blt r4, r18, TlevelOneBeforeWall #if x < 196
	movia r18, 195
	bgt r4, r18, TlevelOneAfterWall #if x > 195
	br groundTouching

	TlevelOneBeforeWall:
		movia r18, 151
		beq r5, r18, groundTouching
		br groundNotTouching

	TlevelOneAfterWall:
		movia r18, 133
		beq r5, r18, groundTouching
		br groundNotTouching

TlevelTwo:
	movia r18, 37
	blt r4, r18, TwoxLessThan37 #if x < 37 he is on the first platform
	br TwoxMoreThan36

	br groundTouching

TwoxLessThan37:
	movia r18, 143
	beq r5, r18, groundTouching
	br groundNotTouching

TwoxMoreThan36:
	movia r18, 121
	blt r4, r18, TwoxLessThan121
	br TwoxMoreThan120

	TwoxLessThan121: #megaman is now on the first platform
		movia r18, 114
		beq r5, r18, groundTouching
		movia r18, 117
		bgt r4, r18, TwoOnThirdPlatform #megaman is now in range to be standing on platform number three
		br groundNotTouching

		TwoOnThirdPlatform: 
			movia r18, 91
			beq r5, r18, groundTouching 
			br groundNotTouching


	TwoxMoreThan120:
		movia r18, 138
		blt r4, r18, TwoBetweenSecondAndThird
		movia r18, 193
		blt r4, r18, TwoOnThirdPlatform #Megaman can only be on the third platform at this point
		movia r18, 202
		blt r4, r18, TwoxThirdOrFourth
		br TwoxMoreThan201

		TwoBetweenSecondAndThird:
			movia r18, 91
			beq r5, r18, groundTouching #megaman is on the third platform, x is in the space between 2nd and third platforms
			br groundNotTouching #else he is falling


		TwoxThirdOrFourth:
			movia r18, 91
			beq r5, r18, groundTouching 
			movia r18, 69
			beq r5, r18, groundTouching
			br groundNotTouching #at this point megaman should be falling


		TwoxMoreThan201:
			movia r18, 241
			blt r4, r18, TwoOnFourthPlatform
			movia r18, 251
			blt r4, r18, TwoOnFourthOrFifth
			#At this point x is greater than 250
			movia r18, 47
			beq r5, r18, groundTouching
			br groundNotTouching

			TwoOnFourthPlatform:
				movia r18,69
				beq r5, r18, groundTouching
				br groundNotTouching

			TwoOnFourthOrFifth:
				movia r18,69
				beq r5, r18, groundTouching
				movia r18, 47
				beq r5, r18, groundTouching
				br groundNotTouching

	TlevelThree:
		movia r18, MegamanY
		ldw r19, 0(r18)
		addi r18, r0, 140
		beq r19, r18, groundTouching
		br groundNotTouching



groundTouching:
	stw r0, 36(sp)
	br amITouchingGroundFINISH

groundNotTouching:
	addi r18, r0, 1
	stw r18, 36(sp)
	br amITouchingGroundFINISH

amITouchingGroundFINISH:
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	ldw r19, 12(sp)
	ldw r20, 16(sp)
	ldw r21, 20(sp)
	ldw r22, 24(sp)
	ldw r23, 28(sp)
	ldw ra, 32(sp)
	ldw r16, 0(sp)
	addi sp, sp, 36 #Save room for a return address
ret


loadLevel:
	addi sp, sp, -40
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)
	stw r19, 12(sp)
	stw r20, 16(sp)
	stw r21, 20(sp)
	stw r22, 24(sp)
	stw r23, 28(sp)
	stw ra, 32(sp)

	movia r18, Level
	ldw r4, 0(r18)
	addi r18, r0, 1
	beq r4, r0, loadLevelZero
	beq r4, r18, loadLevelOne #load level one if level == 1
	addi r18, r0, 2
	beq r4, r18, loadLevelTwo
	addi r18, r0, 3
	beq r4, r18, loadLevelThree

loadLevelZero:

	br loadLevelFINISH

loadLevelOne:
	#load Megaman's starting coordinates
	movia r18, MegamanX
	addi r4, r0, 2
	stw r4, 0(r18) 
	movia r18, PreviousMegamanX
	stw r4, 0(r18)
	movia r18, MegamanY
	addi r4, r0, 151
	stw r4, 0(r18)
	movia r18, PreviousMegamanY
	stw r4, 0(r18)
	movia r18, EnemyAlive
	stw r0, 0(r18) #set enemy to be dead
	movia r4, lvl1base
	call drawTheHUD



	movia r4, lvl1
	br loadLevelFINISH

loadLevelTwo: #8 and 143

	movia r18, MegamanX
	addi r4, r0, 8
	stw r4, 0(r18) 
	movia r18, PreviousMegamanX
	stw r4, 0(r18)
	movia r18, MegamanY
	addi r4, r0, 143
	stw r4, 0(r18)
	movia r18, PreviousMegamanY
	stw r4, 0(r18)
	movia r18, EnemyX
	addi r4, r0, 213
	stw r4, 0(r18)
	movia r18, EnemyY
	addi r4, r0, 69
	stw r4, 0(r18)
	movia r18, EnemyAlive
	addi r4, r0, 1
	stw r4, 0(r18) #set enemy to be alive
	movia r13, EnemyPose
	stw r0, 0(r13) #set enemy to start off standing
	movia r13, AxeX
	addi r12, r0, -12
	stw r12, 0(r13)
	movia r13, axeOnScreen
	stw r0, 0(r13)
	movia r13,shotOnScreen
	stw r0, 0(r13)
	movia r13, busterX
	addi r12, r0, 322
	stw r12, 0(r13)
	movia r13, poseFlag
	stw r0, 0(r13)
	movia r4, lvl2base
	call drawTheHUD

	movia r4, lvl2
	br loadLevelFINISH

loadLevelThree:
	movia r18, MegamanX
	addi r4, r0, 8
	stw r4, 0(r18) 
	movia r18, PreviousMegamanX
	stw r4, 0(r18)
	movia r18, MegamanY
	addi r4, r0, 42
	stw r4, 0(r18)
	movia r18, PreviousMegamanY
	stw r4, 0(r18)
	movia r18, EnemyAlive
	stw r0, 0(r18)

	movia r4, lvl3
	call drawToWholeScreen

	br loadLevelEnd

loadLevelFINISH:
	call drawLevel
loadLevelEnd: #in case i opt to draw to the entire screen instead and skip the conventional 320x240 levels
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	ldw r19, 12(sp)
	ldw r20, 16(sp)
	ldw r21, 20(sp)
	ldw r22, 24(sp)
	ldw r23, 28(sp)
	ldw ra, 32(sp)
	ldw r16, 0(sp)
	addi sp, sp, 40 #Save room for a return address
ret


enemyDrawing:
	
	addi sp, sp, -40
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)
	stw r19, 12(sp)
	stw r20, 16(sp)
	stw r21, 20(sp)
	stw r22, 24(sp)
	stw r23, 28(sp)
	stw ra, 32(sp)

	movia r18, Level
	ldw r23, 0(r18)
	addi r18, r0, 1
	beq r23, r18, enemyDrawingFINISH
	addi r18, r0, 2
	beq r23, r18, LevelTwoEnemyDrawing
	addi r18, r0, 3
	beq r23, r18, enemyDrawingFINISH

LevelTwoEnemyDrawing:

	movia r18, EnemyX
	ldw r4, 0(r18)
	movia r18, EnemyY
	ldw r5, 0(r18)
	movia r6, lvl2
	call removeEnemy

	movia r18, EnemyAlive
	ldw r4, 0(r18)
	beq r4, r0, checkForAxe #if enemy not alive simply do not draw him


	BigEnemyDrawOk:
		movia r18, EnemyX
		ldw r4, 0(r18)
		movia r18, EnemyY
		ldw r5, 0(r18)
		movia r20, EnemyPose
		ldw r21, 0(r20)
		bne r21, r0, drawGuyThrowing

	drawGuyStanding:
		movia r6, EnemyStanding
		call drawEnemy
		br checkForAxe

	drawGuyThrowing:
		movia r6, EnemyThrowing
		call drawEnemyThrowing
		br checkForAxe

	checkForAxe:
		movia r18, axeOnScreen
		ldw r19, 0(r18)
		beq r19, r0, enemyDrawingFINISH

		movia r19, pAxeX
		ldw r4, 0(r19)
		movia r19, pAxeY
		ldw r5, 0(r19)
		movia r6, lvl2
		call removeEnemyProjectile
		movia r19, AxeX
		ldw r4, 0(r19)
		movia r19, AxeY
		ldw r5, 0(r19)
		movia r6, EnemyProjectile
		call drawAxe


enemyDrawingFINISH:

	ldw r17, 4(sp)
	ldw r18, 8(sp)
	ldw r19, 12(sp)
	ldw r20, 16(sp)
	ldw r21, 20(sp)
	ldw r22, 24(sp)
	ldw r23, 28(sp)
	ldw ra, 32(sp)
	ldw r16, 0(sp)
	addi sp, sp, 40 #Save room for a return address
ret


enemyLogic:
	addi sp, sp, -40
	stw r4, 0(sp)
	stw r5, 4(sp)
	stw r6, 8(sp)
	stw r7, 12(sp)
	stw r8, 16(sp)
	stw r9, 20(sp)
	stw r10, 24(sp)
	stw r12, 28(sp)
	stw r13, 32(sp)
	stw ra, 36(sp)


	movia r13, Level
	ldw r12, 0(r13)
	addi r13, r0, 1
	beq r12, r13, lvlOneLogic
	addi r13, r0, 2
	beq r13, r12, lvlTwoLogic
	br enemyLogicFINISH



lvlOneLogic:

br enemyLogicFINISH

lvlTwoLogic:
checkingIfEnemyDiedLvl2:
	movia r13, EnemyAlive
	ldw r12, 0(r13)
	beq r12, r0, checkingIfMegamanDiedLvl2

	enemyIsAliveLvl2:
		movia r13, busterX
		ldw r12, 0(r13)
		addi r13, r0, 207
		beq r12, r13, checkHeightForEDeathLvl2
		br checkingIfMegamanDiedLvl2

		checkHeightForEDeathLvl2:
			movia r13, busterY
			ldw r12, 0(r13)
			addi r13, r0, 46
			bgt r12, r13, enemiesFinalsFateLvl2
			br checkingIfMegamanDiedLvl2

			enemiesFinalsFateLvl2:
				movia r13, 70
				blt r12, r13, EnemyDiedLvl2
				br checkingIfMegamanDiedLvl2

	EnemyDiedLvl2:
		movia r13, EnemyAlive
		stw r0, 0(r13)
		movia r13, shotOnScreen
		stw r0, 0(r13) #remove the shot


checkingIfMegamanDiedLvl2:
	movia r13, EnemyAlive
	ldw r12, 0(r13)
	beq r12, r0, EnemyActions

	Lvl2IsMegamanInDanger:

		movia r13, MegamanX
		ldw r8, 0(r13)
		movia r13, MegamanY
		ldw r9, 0(r13)
		
		movia r13, 193
		beq r8, r13, Lvl2IsMegamanY
		br EnemyActions

		Lvl2IsMegamanY:
			movia r13, 70
			blt r9, r13, Lvl2IsMegamanY2
			br EnemyActions

			Lvl2IsMegamanY2:
				movia r13, 45
				bgt r9, r13, MegamanDiedOnLvl2EnemyOne
				br EnemyActions

				MegamanDiedOnLvl2EnemyOne:
					movia r13, DeathFlag
					movia r12, 1
					stw r12, 0(r13)
					br EnemyActions

EnemyActions:


	movia r13, axeOnScreen
	ldw r12, 0(r13)
	bne r12, r0, axeIncrement
#at this point in the code we know that the axe is not on screen 

	movia r13, EnemyAlive
	ldw r12, 0(r13)
	beq r12, r0, enemyLogicFINISH

	movia r13, MegamanX
	ldw r12, 0(r13)
	movia r13, MegamanY
	ldw r10, 0(r13)

	addi r13, r0, 85
	blt r10, r13, AxeInitialize
	br enemyLogicFINISH

	AxeInitialize:
		movia r13, ThrowFlag
		stw r0, 0(r13)
		movia r13, EnemyPose
		addi r12, r0, 1
		stw r12, 0(r13)
		movia r13, AxeX
		movia r12, 201
		stw r12, 0(r13)
		movia r13, pAxeX
		stw r12, 0(r13)
		movia r13, AxeY
		movia r12, 65
		stw r12, 0(r13)
		movia r13, pAxeY
		stw r12, 0(r13)
		movia r13, axeOnScreen
		addi r12, r0, 1
		stw r12, 0(r13) #set axe flag to be on

		br enemyLogicFINISH

	axeIncrement:
		movia r13, AxeX
		movia r10, pAxeX
		ldw r12, 0(r13)

		addi r9, r0, -12
		beq r12, r9, removeAxe #check if axe is off the screen


		MegamanHitboxL2:
			#Now check if the axe has hit megaman
			movia r8, MegamanX
			ldw r9, 0(r8)
			movia r8, MegamanY
			ldw r10, 0(r8)
			# r9 has his x and r10 has his y and r12 has the axe's x

			bgt r12, r9, toRightOfMega
			br continueIncrement

			toRightOfMega:
				addi r9, r9, 30
				blt r12, r9, checkDeathY
				br continueIncrement

			checkDeathY:
				addi r9, r0, 85
				blt r10, r9, checkDeathY2
				br continueIncrement

			checkDeathY2:
				addi r9, r0, 34
				bgt r10, r9, killMegaWithAxe
				br continueIncrement

				killMegaWithAxe:
					movia r8, DeathFlag
					addi r9, r0, 1
					stw r9, 0(r8)
					br continueIncrement

			removeAxe:
				movia r13, axeOnScreen
				stw r0, 0(r13)
				br continueIncrement


		continueIncrement:
			movia r13, ThrowFlag
			ldw r12, 0(r13)
			addi r8, r0, 90
			blt r12, r8, moveTheAxe
		restorePose:
			movia r13, EnemyPose
			stw r0, 0(r13)
		moveTheAxe:
			movia r13, ThrowFlag
			ldw r12, 0(r13)
			addi r12, r12, 1
			stw r12, 0(r13)
			movia r13, AxeX
			movia r10, pAxeX
			ldw r12, 0(r13)
			stw r12, 0(r10) #store the previous location of the axe
			addi r12, r12, -1 #increment the axe
			stw r12, 0(r13) #store the axe's new location
	





enemyLogicFINISH:
	ldw r4, 0(sp)
	ldw r5, 4(sp)
	ldw r6, 8(sp)
	ldw r7, 12(sp)
	ldw r8, 16(sp)
	ldw r9, 20(sp)
	ldw r10, 24(sp)
	ldw r12, 28(sp)
	ldw r13, 32(sp)
	ldw ra, 36(sp)
	addi sp, sp, 40

ret


isLevelDone:
	addi sp, sp, -40
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)
	stw r19, 12(sp)
	stw r20, 16(sp)
	stw r21, 20(sp)
	stw r22, 24(sp)
	stw r23, 28(sp)
	stw ra, 32(sp)

	movia r18, Level
	ldw r17, 0(r18)

	addi r18, r0, 1

	beq r17, r18, checkLevelOneFinished
	addi r18, r0, 2

	beq r17,  r18, checkLevelTwoFinished
	br isNOTFinished

checkLevelOneFinished:
	movia r18, MegamanX
	ldw r17, 0(r18)
	addi r18, r0, 295
	beq r17, r18, isFinished

	br isNOTFinished


checkLevelTwoFinished:
	movia r18, MegamanX
	ldw r17, 0(r18)
	addi r18, r0, 295
	beq r17, r18, checkLevelTwoY
	br isNOTFinished

	checkLevelTwoY:
		movia r18, MegamanY
		ldw r17, 0(r18)
		movia r18, 48
		blt r17, r18, isFinished
		br isNOTFinished

isFinished:
	addi r18, r0, 1
	stw r18, 36(sp)
	br isLevelDoneFINISH

isNOTFinished:
	stw r0, 36(sp)



isLevelDoneFINISH:

	ldw r17, 4(sp)
	ldw r18, 8(sp)
	ldw r19, 12(sp)
	ldw r20, 16(sp)
	ldw r21, 20(sp)
	ldw r22, 24(sp)
	ldw r23, 28(sp)
	ldw ra, 32(sp)
	ldw r16, 0(sp)
	addi sp, sp, 36 #Save room for a return address
ret


shootSound:
	movia r5,EndShoot
	movia r4,ShootAudio
	movia r3,BASE_ADDRESS_AUDIO

POLL_SHOOT:
#	ldwio r2,4(r3)        		 #Read the FIFO space register
#	andi  r2,r2,0xffff0000		 #FIFO Full
#	beq   r2,r0,POLL_SHOOT
	
	ldwio  r2,0(r4) 			 #Load the sound data
	bgt    r4,r5,AudioShoot_Over #If addresses are equal, the shoot sound is over
	stwio  r2,8(r3)  			 #Write Left Channel
	stwio  r2,12(r3) 			 #Write Right Channel
	addi   r4,r4,1  			 #Add one to the audio pointer
	br 	   POLL_SHOOT

	
	
AudioShoot_Over:
ret


jumpSound:

# JUMP
	movia r5,EndJump
	movia r4,JumpAudio
	movia r3,BASE_ADDRESS_AUDIO
POLL_JUMP:
	ldwio r2,4(r3)         #Read the FIFO space register
	andi  r2,r2,0xffff0000 #FIFO Full
	beq   r2,r0,POLL_JUMP
	
	ldwio  r2,0(r4) 			 #Load the sound data
	bgt    r4,r5,AudioJump_Over  #If addresses are equal, the shoot sound is over
	stwio  r2,8(r3)  			 #Write Left Channel
	stwio  r2,12(r3) 			 #Write Right Channel
	addi   r4,r4,2   			 #Add one to the audio pointer
	br    POLL_JUMP
	
AudioJump_Over:
ret

