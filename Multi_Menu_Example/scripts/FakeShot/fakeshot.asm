; New Code	
	ButtonCheck:		
        move.w  (FakeShotRamAddress).w, d0   ;Load the Fake Shot value from the menu 0 = On 1 = Off
        btst    #0, d0              ; Test the first bit of d0
        beq     .off 
        btst    #bbut,d1			; check if pass button is pressed
        bne     .fakeshot			; branch to .fakeshot if B button is pressed, otherwise run hijacked code and jump back
    .off:
        cmpi.w  #$10,$5A(a3)		; run original opcode we hijacked
		jmp     $C23E+6             ; Skip the rest and jump to the next opcode after hijack
    .fakeshot:        
        bclr    #sfssdir,sflags     ;exit shot mode
        move    #SFXshotwiff,-(a7)  ; load wiff sound for the fake shot
        jsr     sfx					; Play SFX
        rts