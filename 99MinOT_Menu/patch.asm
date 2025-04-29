;FIND 30 seconds in the rom for the address to update hijacj.asm
; find menu lengths and menuleghts 2 and update per lengths to 4 options.

;--MACROS--
	include	scripts\macros.mac

;--Load ROM from rom directory--
	org 0
		incbin rom\nhl94.bin

;--CONFIGURATION--
ExpandROM = 1			; Expand ROM to 2MB (0 = No, 1 = Yes)
RemoveChecksum = 1		; Remove the Checksum validation in the 94 rom (0 = No, 1 = Yes)
;--END CONFIGURATION--	
	
;-----------
;--Equates--
;-----------
;--Patch Equates--
NewCodeAddress	equ ($0FFB10)	; Address in ROM where the new code will be added
OptPerlen		equ $FFFFD050	; RAM Address of the Period Length Option

;--NHL 94 Equates--
	
;-----------------------------
;-- Actual Patch Assembly Code
;-----------------------------

;--Handles Checksum and Rom Expansion--
	include	scripts\utilities.asm
	
; New Code That gets added to the ROM
	org NewCodeAddress								; <-- Location in ROM to place new Menu Items + SubMenu Items + New Code			
		include scripts\99minot\99minot.asm			; <-- Code to add 99 Min OT in game		
		
; Hijack Code needs to be after the new code so it doesn't mess up assembler org values		
		include scripts\99minot\99minothijack.asm		; <-- Code to Hijack for 99 Min OT
		