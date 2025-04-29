;--MACROS--
	include	scripts\macros.mac

;--Load ROM from rom directory--
	org 0
		incbin rom\nhl94.bin

;--CONFIGURATION--
ExpandROM = 0			; Expand ROM to 2MB (0 = No, 1 = Yes)
RemoveChecksum = 1		; Remove the Checksum validation in the 94 rom (0 = No, 1 = Yes)
;--END CONFIGURATION--	
	
;-----------
;--Equates--
;-----------
;--Patch Equates--
NewCodeAddress			equ ($0FFB10)					; Address in ROM where the new code will be added

;-----------------------------
;-- Actual Patch Assembly Code
;-----------------------------

;--Handles Checksum and Rom Expansion--
	include	scripts\utilities.asm
	
; New Code That gets added to the ROM
	org NewCodeAddress									; <-- Location in ROM to place new Menu Items + SubMenu Items + New Code				
		include scripts\weightbug\weightbug.asm			; <-- Code to add Fake Shot on or off in game		
		
; Hijack Code needs to be after the new code so it doesn't mess up assembler org values		
		include scripts\weightbug\weightbughijack.asm		; <-- Code to Hijack for Fake Shot