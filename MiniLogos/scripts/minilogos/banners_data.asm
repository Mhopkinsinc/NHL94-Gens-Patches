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
	if Use32Teams
		incbin	scripts\minilogos\TeamBlocks.jim_32teams_banners_94_tilesize_clean_base.jim
	else
		incbin	scripts\minilogos\TeamBlocks.jim_28teams_banners_94_tilesize_clean_base.jim
	endif
	
	endif	; UseBannerMode


;==============================================================================
; SHARED DATA
;==============================================================================

;------------------------------------------------------------------------------
; MiniLogosMap
; Separate mini logo tiles only (2x2 tiles per team)
; Used by universal logo routines (Banner Mode and Standalone Mode)
; Format: JIM file (palette + tilemap + tile data)
;------------------------------------------------------------------------------
MiniLogosMap:
	if Use32Teams
		incbin	scripts\minilogos\TeamBlocks.jim_32teams_LogoOnly.jim
	else
		incbin	scripts\minilogos\TeamBlocks.jim_28teams_LogoOnly.jim
	endif