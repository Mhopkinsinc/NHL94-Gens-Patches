
;New Code for 99 Minute Overtime
	IF Set99MinOvertime						; <-- This is the new code we are adding to the ROM @NewCodeAddr
		Set99MinOT:
				cmpi.w  #3,(OptPerlen).w    ; Check if you selected 5 minutes, 99 minute OT
				beq.s   .set99             	; If equal, jump to .set99 
				move.w  #$258,d0            ; Else: Set 10 minutes as the OT Value
				bra.s   .done               ; Skip over the 99-minute set
			.set99:
				move.w  #$1734,d0           ; 99 minutes in seconds
			.done:
				rts
	ENDIF