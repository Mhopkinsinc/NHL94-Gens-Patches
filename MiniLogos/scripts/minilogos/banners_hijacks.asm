;==============================================================================
; NHL 94 - Custom Banners and Mini Logos
; ROM HIJACKS
;==============================================================================
; This file contains all the ROM patches/hijacks organized by feature.
; Each section can be independently enabled/disabled via patch.asm settings.
;==============================================================================


;##############################################################################
; BANNER MODE HIJACKS
;##############################################################################

	if UseBannerMode

;==============================================================================
; MINI LOGO DISPLAY HIJACKS
;==============================================================================
; Patches the scoreboard and power play logo display routines
; to show the 2x2 mini team logos using Universal routines.
;==============================================================================

	if EnableMiniLogos

	;-- Mini Logo Initialization --
    ; Also DMAs mini logo tiles to VRAM
	org $16AFA
		jsr	SetSLogos_Refactored
		nop

	;-- Home Team Score Display --
	; Original: Draws score without logo
	; Patched: Calls our routine with mini logo
	org $12C90
		jsr	HomeScoreWithLogo_Refactored
		nop

	;-- Visitor Team Score Display --
	; Original: Draws score without logo
	; Patched: Calls our routine with mini logo
	org $12CA2
		jsr	VisitorScoreWithLogo_Refactored
		nop

	;-- Power Play Logo Display --
	; Original: Shows text indicator
	; Patched: Shows mini logo for team on power play
	org $12B2C
		jmp	PowerPlayLogo_Wrapper_Refactored

	;-- Highlight Replay Logo Reload --
	; Reloads mini logos when highlight starts (teams may differ)	
	org $13684
		jsr	HighlightLogoReload_Refactored
		nop

	endif	; EnableMiniLogos


;==============================================================================
; IN-GAME BANNER HIJACKS (Regular Season / Shootout)
;==============================================================================
; Patches the banner loading during regular gameplay to use TeamBannersMap.
;==============================================================================

	if EnableInGameBanners

	;-- Banner Map Pointer (Regular Season + Shootout) --
	; Original: movea.l #TeamBlocksMap,a0
	; Patched: Points to our custom TeamBannersMap
	org $16D24
		movea.l	#TeamBannersMap,a0

	endif	; EnableInGameBanners


;==============================================================================
; PLAYOFF BANNER HIJACKS
;==============================================================================
; Patches the banner loading during playoffs to use TeamBannersMap.
;==============================================================================

	if EnablePlayoffBanners

	;-- Banner Map Pointer (Playoffs) --
	; Original: movea.l #TeamBlocksMap,a1
	; Patched: Points to our custom TeamBannersMap
	org $17670
		movea.l	#TeamBannersMap,a1

	;-- Banner Tiles Pointer (Playoffs) --
	; Original: movea.l #TeamBlocksMap+8,a2
	; Patched: Points to tile data in TeamBannersMap
	org $11F22
		movea.l	#TeamBannersMap+8,a2

	endif	; EnablePlayoffBanners


;==============================================================================
; PLAYOFF BANNER LOGO FIX HIJACK
;==============================================================================
; Replaces sub_17652 that draws team banners on the playoff tree.
; This makes the player's team logo NOT flash while the text still flashes.
;
; Original sub_17652:
;   - Checks if team is player's team
;   - If yes, sets printa=$6000 (all tiles flash)
;   - Calls dobitmap to draw entire banner
;
; Our replacement:
;   - For other teams: draws normally
;   - For player's team: draws logo without palette change, text with $6000
;==============================================================================

	if EnablePlayoffBanners

	;-- Playoff Tree Team Banner Draw (sub_17652) --
	org $17652
		jmp	PlayoffBanner_Draw

	endif	; EnablePlayoffBanners


;==============================================================================
; TEAM SELECT / GAME SETUP SCREEN HIJACKS
;==============================================================================
; Patches the Team Select screen to display custom banners.
; This requires special handling due to how the screen loads tiles.
;
; How it works:
; 1. Original loads tiles twice from unk_AFE1A - we skip first, use second
; 2. Original sub_17B78 draws banners - we replace with our routine
; 3. Our routine handles palette switching for correct colors
;==============================================================================

	if EnableTeamSelectBanners

	;-- Tile Loading (First Load) --
	; Original: movea.l #unk_AFE1A,a2 + jsr sub_11738
	; Patched: NOP out (we only need one tile load)
	org $F84D2
		nop
		nop
		nop
		nop
		nop
		nop

	;-- Tile Loading (Second Load) --
	; Original: movea.l #unk_AFE1A,a2
	; Patched: Point to our TeamBannersMap tiles
	org $F84E2
		movea.l	#TeamBannersMap+8,a2

	;-- Banner Drawing Routine --
	; Original: sub_17B78 draws from unk_AFE12
	; Patched: Jump to our custom drawing routine
	org $17B78
		jmp	TeamSelectBanner_Draw

	endif	; EnableTeamSelectBanners

	endif	; UseBannerMode


;##############################################################################
; STANDALONE MODE HIJACKS
;##############################################################################

	if UseStandaloneMode

;==============================================================================
; STANDALONE MINI LOGO HIJACKS
;==============================================================================
; Patches for standalone mini logo mode (original banners, custom logos).
; Mini logos are DMA'd to end of VRAM during game initialization.
;==============================================================================

	;-- Mini Logo Initialization --
	; Original: Just loads banners
	; Patched: Also DMAs mini logo tiles to VRAM
	org $16AFA
		jsr	SetSLogos_Refactored
		nop

	;-- Home Team Score Display --
	org $12C90
		jsr	HomeScoreWithLogo_Refactored
		nop

	;-- Visitor Team Score Display --
	org $12CA2
		jsr	VisitorScoreWithLogo_Refactored
		nop

	;-- Power Play Logo Display --
	org $12B2C
		jmp	PowerPlayLogo_Wrapper_Refactored

	;-- Highlight Replay Logo Reload --
	; Reloads mini logos when highlight starts (teams may differ)	
	org $13684
		jsr	HighlightLogoReload_Refactored
		nop

	endif	; UseStandaloneMode
	
	org $F7927
		dc.b $04