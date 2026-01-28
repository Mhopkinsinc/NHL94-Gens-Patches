;==============================================================================
; NHL 94 - Custom Banners and Mini Logos Patch
;==============================================================================
; Main configuration file - controls which features are enabled
;==============================================================================

;--MACROS--
	include	scripts\macros.mac

;--Load ROM from rom directory--
	org 0
		incbin rom\nhl94.bin

; Set NewCodeAddress to current location counter (end of loaded ROM)
NewCodeAddress	= *

;==============================================================================
; CONFIGURATION
;==============================================================================
; Set each option to 1 to enable, 0 to disable
;==============================================================================

;-- ROM Options --
ExpandROM = 0			; Expand ROM to 2MB (0 = No, 1 = Yes)
RemoveChecksum = 1		; Remove Checksum validation (0 = No, 1 = Yes)

;-- Banner Display Mode --
; Choose ONE of the following modes (set one to 1, others to 0):
;
; Mode 1: Full Banners - Uses TeamBannersMap with embedded mini logos
;         Banners appear on: Team Select, In-Game, Playoffs
;
; Mode 2: Standalone Mini Logos - Uses separate MiniLogosMap
;         Original banners unchanged, mini logos DMA'd separately
;         Use this if you want mini logos only
;
; Use32Teams is Experimental and can only be enabled in Mode 2 (No Banners)
;==============================================================================

UseBannerMode = 1			; Mode 1: Full custom banners with embedded mini logos
UseStandaloneMode = 0		; Mode 2: Standalone mini logos only (no custom banners)
Use32Teams = 0				; Experimantal: Use 32 teams (1 = Yes, 0 = No - use 28 teams) Standalone mode only

;-- Feature Toggles (only applied when UseBannerMode = 1) --
EnableTeamSelectBanners = 1	; Show custom banners on Team Select/Game Setup screen
EnableInGameBanners = 1		; Show custom banners during gameplay (Reg Season/Shootout)  
EnablePlayoffBanners = 1	; Show custom banners during Playoffs
EnableMiniLogos = 1			; Show mini logos on scoreboard/power play display

;==============================================================================
; END CONFIGURATION
;==============================================================================

;==============================================================================
; PATCH ASSEMBLY
;==============================================================================

;-- Utility patches (checksum, ROM expansion) --
	include	scripts\utilities.asm

;-- New code section (must come before hijacks) --
	org NewCodeAddress

	include scripts\minilogos\banners_code.asm			; All new routines
	include scripts\minilogos\banners_data.asm			; Graphics data (JIM files)

; Set RomEndAddress to current location counter (end of ROM With new code added)
RomEndAddress	= *

;-- Hijack patches (must come after new code to avoid ORG conflicts) --
	include scripts\minilogos\banners_hijacks.asm		; All ROM hijacks
CustomCodeSize	= RomEndAddress-NewCodeAddress