; New Code	
	WeightBugCheck:
        moveq   #$78,d0         ; NHL92 uses 60 decimal, this is 120 decimal (most likely due to change in attribute math)            
        jmp     $13D72          ; Jump to CheckingCalc