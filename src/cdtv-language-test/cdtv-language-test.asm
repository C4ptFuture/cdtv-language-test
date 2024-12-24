           ************************************************************************
           ***                                                                  ***
           ***                 -= COMMODORE CDTV CLI TOOLKIT =-                 ***
           ***                                                                  ***
           ************************************************************************
           ***                                                                  ***
           ***     CDTV-LANGUAGE-TEST                                           ***
           ***     Copyright (c) 2024 CDTV Land. Published under GPLv3.         ***
           ***     Written by Captain Future                                    ***
           ***                                                                  ***
           ************************************************************************


  INCLUDE    exec/exec_lib.i
  INCLUDE    dos/dos.i
  INCLUDE    cdtv/playerprefs_func.i
  INCLUDE    defs.i
  INCLUDE    rev.i

  bra        Start

  VSTRING

  ; This software can test whether a certain language has been selected in the
  ; CDTV System Preferences bookmark. It accepts a two letter argument (in lower
  ; case) corresponding to one of the 18 selectable languages in the CDTV System
  ; Preferences screen. If no argument is given, it assumes 'en' (=UK English).

  ; The test result is returned as an AmigaDOS return code:

  ;  0 - OK     if tested language matches the set language
  ;  5 - WARN   if tested language does not match the set language
  ; 10 - ERROR  if tested language is not a valid language code (i.e. not known by CDTV)
  ; 20 - FAIL   if playerprefs.library failed to open, a good indicator you're not
  ;               running on a CDTV system

  ; This allows usage of this small and simple command in AmigaDOS scripts like
  ; the startup-sequence in conjunction with `If WARN` statements to decide the
  ; flow of the script.


;************************************************************************************************
;*                                           FUNCTION                                           *
;************************************************************************************************

Start:

  ; We take one optional command line argument, which is a two letter language code. If none
  ; is given we assume CDTVLANG_ENGLISH.

  cmp.l      #1,d0                         ; number of args
  beq.s      .default                      ; if none set, just test for English
  bsr        MapLang                       ; map LanguageCode to CDTVLang
  cmp.b      #CDTVLANG_INVALID,d0          ; was it a valid LanguageCode?
  beq        .errorExit                    ; nope, exit
  bra        .2                            ; continue
.default: 
  move.b     #CDTVLANG_ENGLISH,d0          ; default to 'en'
.2:
  move.l     d0,d7                         ; save lang code

  ; Open playerprefs.lib, exit with fail if could not open

  clr.l      d6                            ; for ppBase
  move.l     a6,-(sp)                      ; save a6
  move.l     4.w,a6                        ; load ExecBase
  clr.l      d0                            ; any lib version
  lea.l      ppLibName(pc),a1              ; lib name
  jsr        _LVOOpenLibrary(a6)           ; open lib
  move.l     (sp)+,a6                      ; restore a6
  tst.l      d0                            ; open success?
  bne.s      .3                            ; yes
  bra.s      .failExit                     ; no
.3: 
  move.l     d0,d6                         ; save ppBase in d6

  ; Check if the requested language matches the one that is active on this CDTV system

  bsr        TestLang                      ; test for language
  move.l     d0,d5                         ; save result
  bra.s      .exit

 ; Set ERROR or FAIL return codes

.errorExit:
  move.l     #RETURN_ERROR,d0              ; set AmigaDOS ERROR return code
  bra.s      .exit
.failExit:
  move.l     #RETURN_FAIL,d0               ; set AmigaDOS FAIL return code

  ; Exit code, if pp.lib was opened successfully, close it first

.exit:
  tst.l      d6                            ; check ppBase
  beq.s      .4                            ; if 0, then no need to close
  move.l     d6,a1                         ; lib base
  move.l     a6,-(sp)                      ; save a6
  move.l     4.w,a6                        ; load ExecBase
  jsr        _LVOCloseLibrary(a6)          ; close pplib
  move.l     (sp)+,a6                      ; restore a6
  move.l     d5,d0                         ; return result

.4:
  rts



;************************************************************************************************
;*                                           FUNCTION                                           *
;************************************************************************************************

MapLang:

  ; Maps a two-letter ISO-639 language code to a CDTVLANG enum value.

  ;  SYNOPSIS
  ;      CDTVLang = MapLang(LanguageCode) 
  ;      D0                 A0 
  ;
  ;  INPUTS
  ;      LanguageCode - ptr to a two-letter ISO-639 language string
  ; 
  ;  RESULT
  ;      CDTVLang - the corresponding CDTV Human Language enumeration value/define 
  ;          or -1 if an invalid LanguageCode was passed

  clr.l      d0                            ; clear d0
  move.w     (a0),d0                       ; save the language code
  lea.l      CDTVLanguages(pc),a0          ; ptr to lang table
  move.l     #CDTVLANG_MAXLEN-1,d1         ; max num of rounds
.1:
  move.l     (a0)+,d2                      ; read a table entry
  move.l     d2,d3                         ; copy table entry to d3
  lsr.l      #8,d3                         ; move lang code to lower word
  lsr.l      #8,d3                         ; move lang code to lower word
  cmp.w      d0,d3                         ; do we have a match?
  beq.s      .2                            ; yes
  dbf        d1,.1                         ; no, do next table entry
.2:
  clr.l      d0                            ; clear d0
  cmp.b      #CDTVLANG_INVALID,d1          ; if true then invalid
  beq.s      .invalid                      ;   lang code was passed
  move.b     d2,d0                         ; set result
  bra.s      .exit
.invalid:
  move.b     #CDTVLANG_INVALID,d0          ; set invalid result
.exit
  rts


;************************************************************************************************
;*                                           FUNCTION                                           *
;************************************************************************************************

TestLang:

  ; Tests whether a specific CDTV Human Language is the currently selected language
  ; in the CDTV System Preferences bookmark.

  ;  SYNOPSIS
  ;      Result = TestLang(CDTVLang) 
  ;      D0                D0 
  ;
  ;  INPUTS
  ;      CDTVLang - CDTV Human Language value
  ; 
  ;  RESULT
  ;      Result - 0 if CDTVLang is the selected language in CDTV Prefs, 
  ;          5 (WARN) otherwise.



  move.l     d6,a6                         ; load ppBase
  lea.l      vCDTVPrefs(pc),a0             ; dest buffer
  move.l     #CDTVPrefs_SIZEOF,d0          ; size of data
  move.l     #BID_CDTVPREFS,d1             ; bookmark id
  jsr        _LVOReadBookMark(a6)          ; read bookmark

  lea.l      vCDTVPrefs(pc),a0             ; dest buffer
  move.w     cdp_Language(a0),d1           ; get language
  cmp.w      d7,d1                         ; compare test lang with set lang
  bne.s      .nomatch
.match
  clr.l      d0
  bra.s      .done
.nomatch
  moveq.l    #RETURN_WARN,d0 
.done
  rts

;************************************************************************************************
;*                                             DATA                                             *
;************************************************************************************************

ppLibName:
  dc.b       'playerprefs.library',0
  CNOP       0,4
vCDTVPrefs:
  ds.b       CDTVPrefs_SIZEOF
vPPLibBase:
  dc.l       0

CDTVLanguages:
  dc.b       'un',0,CDTVLANG_UNKNOWN       ; Unknown
  dc.b       'us',0,CDTVLANG_AMERICAN      ; Murican
  dc.b       'en',0,CDTVLANG_ENGLISH       ; English
  dc.b       'de',0,CDTVLANG_GERMAN        ; German
  dc.b       'fr',0,CDTVLANG_FRENCH        ; French
  dc.b       'es',0,CDTVLANG_SPANISH       ; Spanish
  dc.b       'it',0,CDTVLANG_ITALIAN       ; Italian
  dc.b       'pt',0,CDTVLANG_PORTUGUESE    ; Portuguese
  dc.b       'da',0,CDTVLANG_DANISH        ; Danish
  dc.b       'nl',0,CDTVLANG_DUTCH         ; Dutch
  dc.b       'no',0,CDTVLANG_NORWEGIAN     ; Norwegian
  dc.b       'fi',0,CDTVLANG_FINNISH       ; Finnish
  dc.b       'sv',0,CDTVLANG_SWEDISH       ; Swedish
  dc.b       'ja',0,CDTVLANG_JAPANESE      ; Japanese
  dc.b       'zh',0,CDTVLANG_CHINESE       ; Chinese
  dc.b       'ar',0,CDTVLANG_ARABIC        ; Arabic
  dc.b       'el',0,CDTVLANG_GREEK         ; Greek
  dc.b       'he',0,CDTVLANG_HEBREW        ; Hebrew
  dc.b       'ko',0,CDTVLANG_KOREAN        ; Korean


  END