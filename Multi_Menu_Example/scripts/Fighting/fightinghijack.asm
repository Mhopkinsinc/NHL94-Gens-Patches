	
    org doinputPatch			; Set to patch location
	jsr chkfightinput			; JSR to new code (6 bytes long)
	nop							; Take up 4 bytes of space
	nop

; Patch checkcx subroutine
	org checkcxPatch			; Set to patch location need to replace 12 bytes 
	jsr 	cxchecks			; JSR to the new code (6 bytes long)
	bra.w		*+4				; Branch to the next 94 code (at $13B22) (4 bytes long)
	dc.w	$0					; pad 2 bytes with 00

; Patch assfight and assfwatch on asstab
	org asstabPatch
	dc.l assfight
	dc.l assfwatch