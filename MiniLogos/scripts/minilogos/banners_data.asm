;==============================================================================
; NHL 94 - Custom Banners and Mini Logos
; GRAPHICS DATA
;==============================================================================
; This file contains all the graphics data (JIM files) for banners and logos.
;==============================================================================

;==============================================================================
; BANNER MODE DATA
;==============================================================================

	if UseBannerMode

;------------------------------------------------------------------------------
; TeamBannersMap
; Full team banners with embedded mini logos (11 tiles wide x 2 tiles tall)
; Used for: In-Game banners, Playoffs banners, Team Select banners
; Format: JIM file (palette + tilemap + tile data)
;------------------------------------------------------------------------------
TeamBannersMap:
	incbin	scripts\minilogos\TeamBlocks.jim_28teams_banners_94_tilesize_clean_base.jim

	endif	; UseBannerMode


;==============================================================================
; STANDALONE MODE DATA
;==============================================================================

	if UseStandaloneMode

;------------------------------------------------------------------------------
; MiniLogosMap
; Separate mini logo tiles only (2x2 tiles per team)
; Used when: Original banners kept, only mini logos replaced
; Format: JIM file (palette + tilemap + tile data)
;------------------------------------------------------------------------------
MiniLogosMap:
	incbin	scripts\minilogos\TeamBlocks.jim_28teams_LogoOnly.jim

	endif	; UseStandaloneMode