;99 min OT Hijack 
	IF Set99MinOvertime
		org $7822                   ; <-- Overtime Code We are hijacking
			jsr Set99MinOT          ; JSR to our new code
			nop                     ; 3x NOP to overwrite the old code
			nop
			nop
		org $7864                   ; <-- We re-used the 30 second period code
			dc.w $12C               ; Set period length to 5 minutes instead of 30 seconds		
		;org $F7F7E
		;	SUBMENU	'5 Minutes, 99 Min OT'
		;org $F7927
		;	dc.b 4					; Enable 4th option in the menu
	ENDIF