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
NewMenuRAM  			equ $FFFFDF00					; Address in RAM where the new menu items will be stored
NewMenuRamOffset  		equ NewMenuRAM-OptPlayMode-18  	; Calculates Offset for the NewMenuRamm starting address.
MenuItemsCount 			equ (MenuEnd-MenuStart)/16  	; Calculates the number of menu items from menuitems.asm
ScrollableItemsCount	equ (MenuItemsCount-6)			; Number of scrollable items in the menu
FakeShotRamAddress		equ NewMenuRAM+0				; Address in RAM where the Fighting Mode is stored

;--NHL 94 Equates--
word_FFD422		equ $FFFFD422	; RAM Address of the scrolling menu item
OptPlayMode		equ $FFFFD048	; RAM Address of the Play Mode Option
OptPerlen		equ $FFFFD050	; RAM Address of the Period Length Option
	
;-----------------------------
;-- Actual Patch Assembly Code
;-----------------------------

;--Handles Checksum and Rom Expansion--
	include	scripts\utilities.asm
	
; New Code That gets added to the ROM
	org NewCodeAddress								; <-- Location in ROM to place new Menu Items + SubMenu Items + New Code
		include	scripts\menu\menuitems.asm			; <-- Main Menu Items
		include scripts\menu\submenuitems.asm		; <-- Sub Menu Items
		include scripts\menu\menulengths.asm		; <-- Main Menu Lengths
		include scripts\menu\menulengths2.asm		; <-- Main Menu Lengths for Fourway Play (MultiTap)
		include scripts\menu\writenewmenuram.asm	; <-- Code to Write New Menu RAM Addresses
		include scripts\menu\readnewmenuram.asm		; <-- Code to Read New Menu RAM Addresses				
		include scripts\fakeshot\fakeshot.asm		; <-- Code to add Fake Shot on or off in game		
		
; Hijack Code needs to be after the new code so it doesn't mess up assembler org values
		include scripts\menu\menuhijack.asm				; <-- Code to Hijack Old Menu Items and SubMenu Items		
		include scripts\fakeshot\fakeshothijack.asm		; <-- Code to Hijack for Fake Shot
		