;==============================================================================
; NHL 94 - Custom Banners and Mini Logos
; CODE ROUTINES
;==============================================================================
; This file contains all the new code routines for the banner/logo system.
; Organized by feature for easy understanding and modification.
;==============================================================================

;==============================================================================
; EQUATES
;==============================================================================

;-- RAM Addresses --
SmallLogoscset	equ $FFFFDF00		; Storage for mini logo VRAM location
HomeTeam	equ $FFFFC330		; Current home team number
VisTeam		equ $FFFFC332		; Current visitor team number
ExtraChars	equ $FFFFB026		; Extra characters VRAM location
printx		equ $FFFFB028		; Print X coordinate
printy		equ $FFFFB02A		; Print Y coordinate
printa		equ $FFFFB02C		; Print attributes (palette/priority)
sflags2		equ $FFFFC2EE		; Game state flags
disflags	equ $FFFFC302		; Display flags
potree		equ $FFFFCEF4		; Playoff tree team data (was wrong!)
potreeteam	equ $FFFFCEEE		; Player's team position in playoff tree

;-- ROM Addresses (Subroutines) --
DoDMA		equ $000113E4		; DMA transfer routine
xyVmMap		equ $00011952		; Calculate VRAM map address
dobitmap	equ $0001169A		; Draw bitmap to screen
print		equ $00011BA4		; Print text routine
DeterStrLength	equ $00011D3A	; Determine string length
sub_16D18	equ $00016D18		; Original banner loading routine

;-- Constants --
LogoTileBase	equ $07F0		; VRAM location for standalone logos
null			equ $30A		; Null pointer for dobitmap

;-- Banner Mode Tile References --
; These reference tiles within the loaded TeamBannersMap in VRAM
HomeLogo_Banner		equ $A4E7	; Home team mini logo tiles (palette + base)
VisitorLogo_Banner	equ $A4FD	; Visitor team mini logo tiles


;==============================================================================
; BANNER MODE - MINI LOGO DISPLAY ROUTINES
;==============================================================================
; These routines display the 2x2 mini logos extracted from the banner tiles.
; Used for: Scoreboard display, Power Play indicator
;==============================================================================

	if UseBannerMode

;------------------------------------------------------------------------------
; DoSmallLogo_Banner
; Draws a 2x2 tile mini logo at current print position
; Entry: d3 = base tile number (with palette bits)
;------------------------------------------------------------------------------
DoSmallLogo_Banner:
	movem.l	d0-d3/a0,-(a7)
	
	jsr	xyVmMap
	
	move.w	d3,(a0)			; Top-left tile
	addq.w	#1,d3
	move.w	d3,(a0)			; Top-right tile
	
	addq.w	#1,printy
	jsr	xyVmMap
	
	add.w	#10,d3			; Skip to bottom row (11 tiles wide - 1)
	move.w	d3,(a0)			; Bottom-left tile
	addq.w	#1,d3
	move.w	d3,(a0)			; Bottom-right tile
	
	addq.w	#1,printy
	
	movem.l	(a7)+,d0-d3/a0
	rts

;------------------------------------------------------------------------------
; HomeScoreWithLogo_Banner
; Displays home team mini logo and score on scoreboard
;------------------------------------------------------------------------------
HomeScoreWithLogo_Banner:
	move.w	#28,(printx).w
	move.w	#24,(printy).w
	
	move.w	#HomeLogo_Banner,d3
	bsr.w	DoSmallLogo_Banner
	movea.w	#$C6CE,a2
	bsr.w	PrintScoreOnly
	rts

;------------------------------------------------------------------------------
; VisitorScoreWithLogo_Banner
; Displays visitor team mini logo and score on scoreboard
;------------------------------------------------------------------------------
VisitorScoreWithLogo_Banner:
	move.w	#24,(printx).w
	move.w	#24,(printy).w
	
	move.w	#VisitorLogo_Banner,d3
	bsr.w	DoSmallLogo_Banner
	adda.w	#$364,a2
	bsr.w	PrintScoreOnly
	rts

;------------------------------------------------------------------------------
; PowerPlayLogo_Wrapper_Banner
; Displays mini logo for team on power play
;------------------------------------------------------------------------------
PowerPlayLogo_Wrapper_Banner:
	move.w	#1,(printx).w
	move.w	#25,(printy).w
	
	move.w	#HomeLogo_Banner,d3
	btst	#6,(sflags2).w
	beq.s	.draw
	move.w	#VisitorLogo_Banner,d3
.draw:
	bra.w	DoSmallLogo_Banner

	endif	; UseBannerMode


;==============================================================================
; BANNER MODE - TEAM SELECT SCREEN ROUTINES
;==============================================================================
; These routines handle banner display on the Team Select/Game Setup screen.
; Requires special palette handling due to how dobitmap processes tiles.
;==============================================================================

	if UseBannerMode
	if EnableTeamSelectBanners

;------------------------------------------------------------------------------
; TeamSelectBanner_Draw
; Replacement for sub_17B78 - draws team banners on Team Select screen
; Entry: d1 = team number, d4 = VRAM tile base
;------------------------------------------------------------------------------
TeamSelectBanner_Draw:
	; Load custom palette into palette line 4
	movem.l	a0-a1/d0,-(sp)
	lea	TeamSelectBannerPalette(pc),a0
	movea.l	#$FFBD88,a1		; Palette line 4 location
	moveq	#16-1,d0
.palcopy:
	move.w	(a0)+,(a1)+
	dbf	d0,.palcopy
	movem.l	(sp)+,a0-a1/d0
	
	; Save and modify printa for correct palette XOR
	move.w	(printa).w,-(sp)
	move.w	#$4000,(printa).w	; XOR value to select palette 3
	
	; Replicate original sub_17B78 setup
	clr.w	d0
	asl.w	#1,d1			; d1 = team * 2
	
	; Setup pointers to TeamBannersMap
	move.l	#TeamBannersMap,a0
	move.l	a0,a1
	adda.l	(a0),a0			; a0 = palette data
	adda.l	4(a1),a1		; a1 = tilemap data
	
	movea.w	#null,a2		; No extra char data
	move.w	(a1),d2			; Width from tilemap header
	moveq	#2,d3			; Height = 2 tiles
	moveq	#0,d5			; Palette flags
	
	jsr	dobitmap
	
	; Restore printa
	move.w	(sp)+,(printa).w
	rts

;------------------------------------------------------------------------------
; Team Select Banner Palette
; Custom palette for Team Select screen (palette line 4)
;------------------------------------------------------------------------------
TeamSelectBannerPalette:
	dc.w	$0EE8,$0222,$0222,$0EEE
	dc.w	$0888,$008C,$006A,$0000
	dc.w	$0822,$0600,$0042,$0020
	dc.w	$004A,$0006,$066A,$0246

	endif	; EnableTeamSelectBanners
	endif	; UseBannerMode


;==============================================================================
; STANDALONE MODE - MINI LOGO ROUTINES
;==============================================================================
; Alternative approach: DMA separate mini logo tiles to VRAM.
; Use this if you want original banners but custom mini logos.
;==============================================================================

	if UseStandaloneMode

;------------------------------------------------------------------------------
; SetSLogos_Standalone
; Loads mini logo tiles to end of VRAM during game init
;------------------------------------------------------------------------------
SetSLogos_Standalone:
	jsr	sub_16D18		; Call original banner loading routine
	move.w	d4,(ExtraChars).w	; Restore instruction we overwrote
	
	; Load mini logos to end of VRAM
	move.w	#LogoTileBase,d2
	move.w	d2,SmallLogoscset
	
	move.w	(HomeTeam).w,d0
	bsr.s	.getsl
	
	move.w	(VisTeam).w,d0

.getsl:
	move.l	#MiniLogosMap,a2
	lea	10(a2),a3
	add.l	4(a2),a2
	
	mulu	(a2),d0
	asl	#2,d0
	lea	4(a2,d0),a2
	
	; Copy 4 sequential tiles per team
	move.w	(a2),d0
	bsr.s	.chr
	move.w	2(a2),d0
	bsr.s	.chr
	move.w	4(a2),d0
	bsr.s	.chr
	move.w	6(a2),d0

.chr:
	and.w	#$07ff,d0
	asl.w	#5,d0
	lea	0(a3,d0),a0
	
	moveq	#16,d0
	move.w	d2,d1
	addq.w	#1,d2
	asl.w	#5,d1
	jsr	DoDMA
	rts

;------------------------------------------------------------------------------
; DoSmallLogo_Standalone
; Draws 2x2 mini logo using DMA'd tiles
; Entry: d3 = base tile number (with palette bits)
;------------------------------------------------------------------------------
DoSmallLogo_Standalone:
	movem.l	d0-d3/a0,-(a7)
	
	jsr	xyVmMap
	
	move.w	d3,(a0)			; Top-left tile
	addq.w	#1,d3
	move.w	d3,(a0)			; Top-right tile
	
	addq.w	#1,printy
	jsr	xyVmMap
	
	addq.w	#1,d3			; Sequential tiles
	move.w	d3,(a0)			; Bottom-left tile
	addq.w	#1,d3
	move.w	d3,(a0)			; Bottom-right tile
	
	addq.w	#1,printy
	
	movem.l	(a7)+,d0-d3/a0
	rts

;------------------------------------------------------------------------------
; HomeScoreWithLogo_Standalone
;------------------------------------------------------------------------------
HomeScoreWithLogo_Standalone:
	move.w	#28,(printx).w
	move.w	#24,(printy).w
	
	move.w	#LogoTileBase,d3
	or.w	#$A000,d3
	bsr.w	DoSmallLogo_Standalone
	movea.w	#$C6CE,a2
	bsr.w	PrintScoreOnly
	rts

;------------------------------------------------------------------------------
; VisitorScoreWithLogo_Standalone
;------------------------------------------------------------------------------
VisitorScoreWithLogo_Standalone:
	move.w	#24,(printx).w
	move.w	#24,(printy).w
	
	move.w	#LogoTileBase,d3
	addq.w	#4,d3
	or.w	#$A000,d3
	bsr.w	DoSmallLogo_Standalone
	adda.w	#$364,a2
	bsr.w	PrintScoreOnly
	rts

;------------------------------------------------------------------------------
; PowerPlayLogo_Wrapper_Standalone
;------------------------------------------------------------------------------
PowerPlayLogo_Wrapper_Standalone:
	move.w	#1,(printx).w
	move.w	#25,(printy).w
	
	move.w	#LogoTileBase,d3
	or.w	#$A000,d3
	btst	#6,(sflags2).w
	beq.s	.draw
	addq.w	#4,d3
.draw:
	bra.w	DoSmallLogo_Standalone

	endif	; UseStandaloneMode


;==============================================================================
; PLAYOFF BANNER LOGO FIX
;==============================================================================
; Fixes the playoff screen so the player's team logo doesn't flash.
; Problem: Original code applies palette 3 ($6000) to entire banner via printa.
; Solution: Draw tiles individually - logo uses palette 2, text uses palette 3.
;
; Banner layout (11 tiles wide x 2 rows):
;   Tiles 0-1:  Logo (no palette change, keeps original)
;   Tiles 2-10: Team name text (palette 3 for player's team = flashing)
;
; Original sub_17652 flow:
;   1. Check if current team (d1) is player's team
;   2. If yes, set printa = $6000 (applies to ALL tiles)
;   3. Call dobitmap to draw entire banner
;
; Our fix:
;   1. Check if current team is player's team
;   2. If NOT player's team, draw normally with dobitmap
;   3. If IS player's team, draw tiles individually with split palettes
;==============================================================================

	if UseBannerMode
	if EnablePlayoffBanners

;------------------------------------------------------------------------------
; PlayoffBanner_Draw
; Replacement for sub_17652 - draws team banners with split palette handling
; Entry: d1 = team number * 2 (already shifted by caller)
;        printx/printy set to banner position
;------------------------------------------------------------------------------
PlayoffBanner_Draw:
	movem.l	d0-d7/a0-a3,-(sp)
	
	; Save d1 (team being drawn * 2) for later use
	move.w	d1,d2
	
	; Check if this is the player's team (same logic as original)
	movea.w	#potree,a0
	move.w	(potreeteam).w,d0	; Get player's team POSITION in tree (0-15)
	move.b	(a0,d0.w),d0		; Get player's team NUMBER at that position
	ext.w	d0					; Extend byte to word
	add.w	d0,d0				; Multiply by 2
	cmp.w	d0,d2				; Compare with current team being drawn (d2)
	bne.w	.normal_draw		; If not player's team, draw normal

	;--------------------------------------------------
	; Player's team - draw with split palettes
	; Tiles 0-1: Keep current printa (no flash)
	; Tiles 2-10: Use $6000 printa (flash)
	;--------------------------------------------------
	movea.l	#TeamBannersMap,a1
	movea.l	a1,a3			; Save base for later
	adda.l	4(a1),a1		; a1 = map data pointer
	
	; Calculate offset for this team's tilemap
	; d2 = team * 2, tilemap is 11 tiles wide * 2 rows = 22 words per team
	move.w	d2,d0
	mulu	#22,d0			; d0 = team * 22 * 2 = byte offset
	adda.w	#4,a1			; Skip map header (width/height words)
	adda.l	d0,a1			; a1 now points to this team's tilemap
	
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w		; Set dfng flag
	
	moveq	#1,d7				; Row counter (2 rows: 1,0)
.row_loop:
	jsr	xyVmMap					; Get VRAM address into a0
	
	;--- First 2 tiles (logo) - NO palette override ---
	moveq	#1,d6			; 2 tiles (counter 1,0)
.logo_loop:
	move.w	(a1)+,d3		; Get tile from map
	addi.w	#2,d3			; Add base char offset
	move.w	d3,(a0)			; Write to VRAM (keeps original palette)
	dbf	d6,.logo_loop
	
	;--- Remaining 9 tiles (text) - palette 2 ($4000) for flashing ---
	moveq	#8,d6			; 9 tiles (counter 8,7,6,5,4,3,2,1,0)
.text_loop:
	move.w	(a1)+,d3		; Get tile from map
	andi.w	#$9FFF,d3		; Clear palette bits (bits 13-14)
	addi.w	#2,d3			; Add base char offset
	ori.w	#$4000,d3		; Set palette 2 (flashing)
	move.w	d3,(a0)			; Write to VRAM
	dbf	d6,.text_loop
	
	addq.w	#1,(printy).w		; Next row
	dbf	d7,.row_loop
	
	move.w	(sp)+,(disflags).w	; Restore disflags
	bra.w	.exit

.normal_draw:
	;--------------------------------------------------
	; Other teams - draw normally (original dobitmap call)
	;--------------------------------------------------
	move.w	d2,d1			; Restore d1 for dobitmap
	movea.l	#TeamBannersMap,a1
	adda.l	4(a1),a1		; a1 = map data
	movea.w	#null,a2		; No extra char data
	clr.w	d0
	move.w	(a1),d2			; Width (11)
	moveq	#2,d3			; Height (2)
	moveq	#2,d4			; Start char
	moveq	#0,d5			; Palette flags
	jsr	dobitmap

.exit:
	movem.l	(sp)+,d0-d7/a0-a3
	rts

	endif	; EnablePlayoffBanners
	endif	; UseBannerMode


;==============================================================================
; SHARED ROUTINES
;==============================================================================

;------------------------------------------------------------------------------
; PrintScoreOnly
; Prints team score at current position
;------------------------------------------------------------------------------
PrintScoreOnly:
	move.w	$C(a2),d0
	moveq	#2,d1
	jsr	DeterStrLength
	jmp	print