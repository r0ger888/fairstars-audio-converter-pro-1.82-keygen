include		windows.inc 
include		kernel32.inc 
include		user32.inc 
include     gdi32.inc  
include 	shell32.inc
include		winmm.inc
include		masm32.inc
include		oleaut32.inc
include		ole32.inc
include		msvcrt.inc
include		comctl32.inc
include		comdlg32.inc
include     /masm32/macros/macros.asm

includelib	kernel32.lib
includelib	user32.lib 
includelib 	gdi32.lib
includelib 	shell32.lib
includelib	winmm.lib
includelib 	masm32.lib
includelib  oleaut32.lib
includelib  ole32.lib
includelib	msvcrt.lib
includelib	comctl32.lib
includelib	comdlg32.lib

include bassmod.inc
includelib bassmod.lib

include WaveObject.asm

DlgProc		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
IdProc     	PROTO 	:DWORD,:DWORD,:DWORD,:DWORD
InfoProc   	PROTO 	:DWORD,:DWORD,:DWORD,:DWORD
DrawItem   	PROTO 	:DWORD,:DWORD
FadeOut		PROTO	:DWORD
MakeDialogTransparent	PROTO	:DWORD,:DWORD

.const
IDD_MAIN	equ	1000
IDD_ABOUT	equ	2000
IDC_TITLE	equ	1001
IDC_STATIC1	equ 1002
IDC_STATIC2 equ 1003
IDC_SERIAL	equ	1004
IDB_ABOUT	equ	1005
IDB_GENERATE	equ	1006
IDB_COPY	equ	1007
IDB_EXIT	equ 1008

CR_BACKGROUND equ 006BA1E7h
CR_FOREGROUND equ 007EB6F4h
CR_HIGHLIGHT  equ 000E255Eh
CR_INPUT      equ 00A9D8F8h
CR_INPUT2     equ 006BA3F0h
CR_INPUT3	  equ 0087C3F8h
CR_TEXT       equ 000E255Eh

.data
include earlyfall.inc
sId          TCHAR "&?", 0
sTitle       TCHAR "FairStars Audio Converter Pro 1.82 KeyGen", 0
szTitle     db  'shit.',0
szError     db  'WaveObject not working .. exiting keygen...',0

DELAY_VALUE			equ		6
Transparency		dd		?
TRANSPARENT_VALUE	equ 254

.data?
hInstance	dd	?
hIcon      HICON     ?
hIdCursor  HCURSOR   ?
hBgColor   HBRUSH    ?
hFgColor   HBRUSH    ?
hInColor   HBRUSH    ?
hIn2Color  HBRUSH    ?
hIn3Color  HBRUSH    ?
hEdge      HPEN      ?
BoldFont   LOGFONT   <?>
sBtnText   TCHAR     16 dup(?)
DefIdProc  WNDPROC   ?

stWaveObj   WAVE_OBJECT <?>
xWin dd ?
hBitmap dd ?
bitmp dd ?