.686
.model	flat, stdcall
option	casemap :none

USE_BRUSH = 1

include	resID.inc
include algo.asm
include CrazyWord.asm

.code

AllowSingleInstance MACRO lpTitle
        invoke FindWindow,NULL,lpTitle
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
      ENDM
      
      
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	invoke LoadIcon,eax,200
	mov hIcon, eax
	invoke LoadCursor, NULL, IDC_HAND
	mov hIdCursor, eax
	invoke CreateSolidBrush, CR_BACKGROUND
	mov hBgColor, eax
	invoke CreateSolidBrush, CR_FOREGROUND
	mov hFgColor, eax
	invoke CreateSolidBrush, CR_INPUT
	mov hInColor, eax
	invoke CreateSolidBrush, CR_INPUT2
	mov hIn2Color, eax
	invoke CreateSolidBrush, CR_INPUT3
	mov hIn3Color, eax
	invoke CreatePen, PS_INSIDEFRAME, 1, CR_FOREGROUND
	mov hEdge, eax
	invoke	InitCommonControls
	AllowSingleInstance addr sTitle
	invoke	DialogBoxParam, hInstance, IDD_MAIN, 0, offset DlgProc, 0
	invoke 	DeleteObject, hEdge
	invoke 	DeleteObject, hInColor
	invoke 	DeleteObject, hIn2Color
	invoke 	DeleteObject, hFgColor
	invoke 	DeleteObject, hBgColor
	invoke	ExitProcess, eax

DlgProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
LOCAL @stPs:PAINTSTRUCT,@hDc,@stRect:RECT
LOCAL @stBmp:BITMAP
LOCAL hMemDC:HDC
	
	mov	eax,uMsg
	
	.if	eax == WM_INITDIALOG
		invoke GetDlgItem, hWnd, IDB_ABOUT
	    invoke SetWindowLong, eax, GWL_WNDPROC, ADDR IdProc
	    mov DefIdProc, eax
	    invoke SendMessage, hWnd, WM_SETICON, ICON_BIG, hIcon
	    invoke SetWindowText, hWnd, ADDR sTitle
	    invoke SetDlgItemText, hWnd, IDC_TITLE, ADDR sTitle
	    invoke SetDlgItemText, hWnd, IDB_ABOUT, ADDR sId
	    invoke LoadBitmap,hInstance,888
	    mov hBitmap,eax
	    invoke GetDlgItem,hWnd,IDC_STATIC1
	    push hBitmap
	    invoke _WaveInit,addr stWaveObj,eax,hBitmap,1,0
        .if eax
            invoke MessageBox,hWnd,addr szError,addr szTitle,MB_OK or MB_ICONSTOP
            invoke	SendMessage,hWnd,WM_CLOSE,0,0
        .else
        .endif
        pop hBitmap
        invoke  DeleteObject,hBitmap
        invoke  _WaveEffect,addr stWaveObj,3,2,2,25
	    invoke BASSMOD_DllMain, hInstance, DLL_PROCESS_ATTACH,NULL
		invoke BASSMOD_Init, -1, 44100, 0
		invoke BASSMOD_MusicLoad, TRUE, addr xm, 0, 0, BASS_MUSIC_LOOP OR BASS_MUSIC_RAMPS; OR BASS_MUSIC_NONINTER
		invoke BASSMOD_MusicPlay
		invoke GenKey,hWnd
	.elseif eax == WM_CTLCOLORDLG
		mov eax, hBgColor
		ret
	.elseif eax == WM_CTLCOLORSTATIC
		invoke GetDlgCtrlID, lParam
	    .if eax == IDC_TITLE
	      invoke SendMessage, hWnd, WM_GETFONT, 0, 0
	      invoke GetObject, eax, SIZEOF LOGFONT, ADDR BoldFont
	      mov BoldFont.lfWeight, FW_BOLD
	      mov BoldFont.lfItalic, TRUE
	      invoke CreateFontIndirect, ADDR BoldFont
	      invoke SelectObject, wParam, eax
	      invoke SetBkMode, wParam, TRANSPARENT
	      invoke SetTextColor, wParam, CR_HIGHLIGHT
	      mov eax, hFgColor
	      ret
	    .else
	      invoke SetBkMode, wParam, TRANSPARENT
	      .if eax == IDC_SERIAL
	        invoke SetTextColor, wParam, CR_HIGHLIGHT
	      .else
	        invoke SetTextColor, wParam, CR_TEXT
	      .endif
	      mov eax, hIn3Color
	      ret
	    .endif
	.elseif eax == WM_CTLCOLOREDIT
	    invoke SetBkMode, wParam, TRANSPARENT
	    invoke SetTextColor, wParam, CR_HIGHLIGHT
	    mov eax, hInColor
	    ret
	.elseif eax == WM_DRAWITEM
	    invoke DrawItem, hWnd, lParam
	.elseif eax == WM_PAINT
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax
		invoke CreateCompatibleDC,@hDc
		mov hMemDC,eax
		invoke SelectObject,hMemDC,hBitmap
		invoke GetClientRect,hWnd,addr @stRect
		invoke BitBlt,@hDc,10,10,@stRect.right,@stRect.bottom,hMemDC,0,0,MERGECOPY
		invoke DeleteDC,hMemDC
		invoke _WaveUpdateFrame,addr stWaveObj,eax,TRUE
		invoke EndPaint,hWnd,addr @stPs
		xor eax,eax
		ret
	.elseif eax==WM_LBUTTONDOWN
		invoke SendMessage,hWnd,WM_NCLBUTTONDOWN,HTCAPTION,0
	.elseif eax == WM_COMMAND
		mov eax,wParam
		.if eax == IDB_GENERATE
			invoke GenKey,hWnd
		.elseif eax == IDB_COPY
			invoke SendDlgItemMessage,hWnd,IDC_SERIAL,EM_SETSEL,0,-1
			invoke SendDlgItemMessage,hWnd,IDC_SERIAL,WM_COPY,0,0
		.elseif eax == IDB_ABOUT
			invoke DialogBoxParam,0,IDD_ABOUT,hWnd,addr AboutProc,0
		.elseif	eax == IDB_EXIT
			invoke SendMessage, hWnd, WM_CLOSE, 0, 0
		.endif
	.elseif	eax == WM_CLOSE
		invoke BASSMOD_Free
		invoke BASSMOD_DllMain, hInstance, DLL_PROCESS_DETACH, NULL
		invoke  _WaveFree,addr stWaveObj
		invoke	EndDialog, hWnd, 0
	.elseif eax == WM_DESTROY
		invoke DeleteObject,hBitmap
		invoke PostQuitMessage,NULL
	.endif

	xor	eax,eax
	ret
DlgProc endp

IdProc PROC hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM

  .IF uMsg == WM_SETCURSOR
    invoke SetCursor, hIdCursor
  .ELSE
    invoke CallWindowProc, DefIdProc, hWnd, uMsg, wParam, lParam
    ret
  .ENDIF

  xor eax, eax
  ret
IdProc ENDP

DrawItem PROC hWnd: HWND, lParam: LPARAM
  push esi
  mov esi, lParam
  assume esi: ptr DRAWITEMSTRUCT

  .IF [esi].itemState & ODS_SELECTED
    invoke SelectObject, [esi].hdc, hIn2Color
  .ELSE
    invoke SelectObject, [esi].hdc, hInColor
  .ENDIF

  invoke SelectObject, [esi].hdc, hEdge

  invoke FillRect, [esi].hdc, ADDR [esi].rcItem, hFgColor
  invoke RoundRect, [esi].hdc, [esi].rcItem.left, [esi].rcItem.top, [esi].rcItem.right, [esi].rcItem.bottom, 6, 6

  .IF [esi].itemState & ODS_SELECTED
    invoke OffsetRect, ADDR [esi].rcItem, 1, 1
  .ENDIF

  ; Write the text
  invoke GetDlgItemText, hWnd, [esi].CtlID, ADDR sBtnText, SIZEOF sBtnText
  invoke SetBkMode, [esi].hdc, TRANSPARENT
  invoke SetTextColor, [esi].hdc, CR_HIGHLIGHT
  invoke DrawText, [esi].hdc, ADDR sBtnText, -1, ADDR [esi].rcItem, DT_CENTER or DT_VCENTER or DT_SINGLELINE

  .IF [esi].itemState & ODS_SELECTED
    invoke OffsetRect, ADDR [esi].rcItem, -1, -1
  .ENDIF

  ; Draw the focus rectangle
  .IF [esi].itemState & ODS_FOCUS
    invoke InflateRect, ADDR [esi].rcItem, -3, -3
    ;invoke DrawFocusRect, [esi].hdc, ADDR [esi].rcItem
  .ENDIF

  assume esi:nothing
  pop esi
  mov eax, TRUE
  ret
DrawItem ENDP

FadeOut proc hWnd:HWND
	mov Transparency,250
@@:
	invoke SetLayeredWindowAttributes,hWnd,0,Transparency,LWA_ALPHA
	invoke Sleep,DELAY_VALUE
	sub Transparency,5
	cmp Transparency,0
	jne @b
	ret
FadeOut endp

MakeDialogTransparent proc _handle:dword,_transvalue:dword
	
	pushad
	invoke GetModuleHandle,chr$("user32.dll")
	invoke GetProcAddress,eax,chr$("SetLayeredWindowAttributes")
	.if eax!=0
		invoke GetWindowLong,_handle,GWL_EXSTYLE	;get EXSTYLE
		
		.if _transvalue==255
			xor eax,WS_EX_LAYERED	;remove WS_EX_LAYERED
		.else
			or eax,WS_EX_LAYERED	;eax = oldstlye + new style(WS_EX_LAYERED)
		.endif
		
		invoke SetWindowLong,_handle,GWL_EXSTYLE,eax
		
		.if _transvalue<255
			invoke SetLayeredWindowAttributes,_handle,0,_transvalue,LWA_ALPHA
		.endif	
	.endif
	popad
	ret
MakeDialogTransparent endp

end start