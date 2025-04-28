;--MACROS--
	include	scripts\macros.mac

;--Load ROM from rom directory--
	org 0
		incbin rom\nhl94.bin
	
;--Remove Checksum Code--
	include	scripts\patch_checksum.asm
	
;-----------
;--Equates--
;-----------
;--Patch Equates--
HiJackAddr 	equ ($C23E)		; Address in ROM where the code is HIJACKED
NewCodeAddr	equ ($0FFB10)	; Address in ROM where the new code will be patched in

;--NHL 94 Equates--
sflags 		equ ($C2EC)		; RAM Address sflags.
bbut		equ 4			; B Button (Pass button) #
sfssdir 	equ 3			; Shot Direction Mode #
SFXshotwiff equ 5			; Shotwiff sound fx #
sfx			equ ($011132)	; Address of SFX subroutine
	
;-----------------------------
;-- Actual Patch Assembly Code
;-----------------------------

; HiJack instruction in ShotMode: subroutine 
	org HiJackAddr					; <-- Location In ROM to HIJACK
		jmp NewCodeAddr				; <-- New Location in ROM to JUMP To
	
; New Code
	org NewCodeAddr					; <-- Location in ROM to place new Code		
	ButtonCheck:
		btst    #bbut,d1			; check if pass button is pressed
		bne     .fakeshot			; branch to .fakeshot if B button is pressed, otherwise run hijacked code and jump back
		cmpi.w  #$10,$5A(a3)		; run original opcode we hijacked
		jmp     HiJackAddr+6  		; resume normal flow, Jump to Next opcode after Hijack
	.fakeshot:
		BCLR_SHORT sfssdir,(sflags)	; Exit Shot Mode, clear sfssdir flag. Expectes Short RAM Address
		move    #SFXshotwiff,-(a7)  ; load wiff sound for the fake shot
		jsr     sfx					; Play SFX
		rts							; rts