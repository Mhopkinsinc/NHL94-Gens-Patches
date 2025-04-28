; New Code	
	WeightBugCheck:        
        move.w  (WeightBugRamAddress).w, d0   ;Load the weight bug value from the menu 0 = On 1 = Off
        btst    #0, d0          ; Test the first bit of d0
        bne     .off            ; Branch if turned off (1 = Off)
        moveq   #$78,d0         ; NHL92 uses 60 decimal, this is 120 decimal (most likely due to change in attribute math)
        btst    #3,$62(a3)      ; checks if player a3 is player controlled
        beq.w   .jump           ; If equal, skip to jump
        asl.w   #1,d0
        jmp     $13D72          ; Jump to CheckingCalc
    .off:
        moveq   #$78,d0         ; NHL92 uses 60 decimal, this is 120 decimal (most likely due to change in attribute math)        		
    .jump:
        jmp     $13D72          ; Jump to CheckingCalc