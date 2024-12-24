
; CDTV Preferences Structure

  STRUCTURE    CDTVPrefs,0
  WORD         cdp_DisplayX
  WORD         cdp_DisplayY
  UWORD        cdp_Language
  UWORD        cdp_AudioVol
  UWORD        cdp_Flags
  UBYTE        cdp_SaverTime
  UBYTE        cdp_Reserved
  LABEL        CDTVPrefs_SIZEOF


; CDTV Preferences Bookmark ID

BID_CDTVPREFS       equ $00010001


; CDTV Human Language Defines

CDTVLANG_UNKNOWN    equ 0
CDTVLANG_AMERICAN   equ 1          ; American English
CDTVLANG_ENGLISH    equ 2          ; UK English
CDTVLANG_GERMAN     equ 3
CDTVLANG_FRENCH     equ 4
CDTVLANG_SPANISH    equ 5
CDTVLANG_ITALIAN    equ 6
CDTVLANG_PORTUGUESE equ 7
CDTVLANG_DANISH     equ 8
CDTVLANG_DUTCH      equ 9
CDTVLANG_NORWEGIAN  equ 10
CDTVLANG_FINNISH    equ 11
CDTVLANG_SWEDISH    equ 12
CDTVLANG_JAPANESE   equ 13
CDTVLANG_CHINESE    equ 14
CDTVLANG_ARABIC     equ 15
CDTVLANG_GREEK      equ 16
CDTVLANG_HEBREW     equ 17
CDTVLANG_KOREAN     equ 18
CDTVLANG_MAXLEN     equ 19

CDTVLANG_INVALID    equ -1



