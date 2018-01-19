.386
.model flat,stdcall
option casemap:none

;--------------------------------------------------------------------------------------------

include    \masm32\include\windows.inc
include    \masm32\include\user32.inc
include    \masm32\include\kernel32.inc
include    \masm32\include\gdi32.inc
include    \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\masm32.lib

;--------------------------------------------------------------------------------------------

WczytanieBmpProc	  proto :dword
OknoProc            proto :dword,:dword,:dword,:dword
Przeszkoda		     proto :dword,:dword,:dword,:dword,:dword,:dword,:dword,:dword,:dword
PrzeszkodyProc      proto :dword,:dword,:dword,:dword,:dword,:dword,:dword
Postac          	  proto :dword,:dword,:dword,:dword,:dword,:dword,:dword,:dword,:dword
KlawiszWProc        proto :dword,:dword,:dword,:dword,:dword,:dword,:dword,:dword

;--------------------------------------------------------------------------------------------

.const
SzerOkno	       equ 480
WysoOkno	       equ 340
SzerTlo         equ 670
WysoTlo         equ 270
WysoPrzeszkoda  equ 120
SzerPrzeszkoda1 equ 60
SzerPrzeszkoda2 equ 30
SzerPrzeszkoda3 equ 90
SzerPrzeszkoda4 equ 150
SzerPrzeszkoda5 equ 180
Menu1ID1        equ 1
Menu1ID2        equ 2
Menu1ID3        equ 3

;--------------------------------------------------------------------------------------------

.data
ClassName           db "SimpleWinClass",0
AppName             db "Wiedümun 4",0
MenuName            db "FirstMenu",0
Tlo1                db "res\Tlo\Tlo1.bmp",0
Logo1               db "res\Logo\Logo1.bmp",0
Logo2               db "res\Logo\Logo2.bmp",0
Logo3               db "res\Logo\Logo3.bmp",0
Postac1Poz1         db "res\Postac\Postac1Poz1.bmp",0
Postac1Poz2         db "res\Postac\Postac1Poz2.bmp",0
Postac2Poz1         db "res\Postac\Postac2Poz1.bmp",0
Postac2Poz2         db "res\Postac\Postac2Poz2.bmp",0
Przeszkoda1         db "res\Przeszkoda\Przeszkoda1.bmp",0
Przeszkoda2         db "res\Przeszkoda\Przeszkoda2.bmp",0
Przeszkoda3         db "res\Przeszkoda\Przeszkoda3.bmp",0
Przeszkoda4         db "res\Przeszkoda\Przeszkoda4.bmp",0
Przeszkoda5         db "res\Przeszkoda\Przeszkoda5.bmp",0
Postac1WspX         dd 50
Postac1WspY         dd 165
SkokWyso            db 65
Predkosc            db 10
Pauza               db 0
Skok                db 0
Kucanie             db 0
NowaGra             db 0
SkokLicz            db 0
Punkty              dd 0
PunktyLicz          db 0
Krok                db 0
PrzeszkodaWspXPocz  dd 480
PrzeszkodaWspYPocz  dd 105
Punkty1             db "Wynik:",0

;--------------------------------------------------------------------------------------------

.data?
hInstance       HINSTANCE ?
CommandLine     LPSTR ?
hMenu           HMENU ?
lpTlo1          dd ?
lpLogo1         dd ?
lpLogo2         dd ?
lpLogo3         dd ?
lpPostac1Poz1   dd ?
lpPostac1Poz2   dd ?
lpPostac2Poz1   dd ?
lpPostac2Poz2   dd ?
lpPrzeszkoda1   dd ?
lpPrzeszkoda2   dd ?
lpPrzeszkoda3   dd ?
lpPrzeszkoda4   dd ?
lpPrzeszkoda5   dd ?
hMainDC         dd ?
hBackDC		    dd ?
lpBackBitmap	 dd ?
hBackBitmap	    dd ?
bmi		       BITMAPINFO <>
hThread		    dd ?
ThreadID	       dd ?
ZakonczThread	 db ?
ThreadExitCode	 dd ?
OdlPoziom	    dd ?
OdlPion		    dd ? 
zmzderz         dd ? 
NumePrzeszkoda  dd ?
SzerPrzeszkoda  dd ?
PoloPrzeszkoda  dd ?
Punkty2         db 5 dup(?)

;--------------------------------------------------------------------------------------------

.code
program:
    invoke GetModuleHandle,0
    mov    hInstance,eax
	 invoke GetCommandLine
	 mov    CommandLine,eax
    call WysrodkowanieProc
    invoke GetTickCount
    invoke nseed,eax
	 invoke OknoProc,hInstance,0,CommandLine,SW_SHOWDEFAULT
    invoke ExitProcess,eax

;--------------------------------------------------------------------------------------------
	
OknoProc proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD

    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:HWND
    mov    wc.cbSize,SIZEOF WNDCLASSEX
    mov    wc.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW or CS_BYTEALIGNCLIENT
    mov    wc.lpfnWndProc,OFFSET ZdarzeniaProc
    mov    wc.cbClsExtra,0
    mov    wc.cbWndExtra,0
    push   hInst
    pop    wc.hInstance
    mov    wc.hbrBackground,0
    mov    wc.lpszMenuName,OFFSET MenuName
    mov    wc.lpszClassName, OFFSET ClassName
    invoke LoadIcon,0,IDI_APPLICATION
    mov    wc.hIcon,eax
    mov    wc.hIconSm,eax
    invoke LoadCursor,0,IDC_ARROW
    mov    wc.hCursor,eax
    invoke RegisterClassEx,ADDR wc
    invoke LoadMenu,hInst,OFFSET MenuName
    mov    hMenu,eax
    invoke CreateWindowEx,0,addr ClassName,addr AppName,WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,OdlPoziom,OdlPion,SzerOkno,WysoOkno,0,hMenu,hInstance,0
    mov    hwnd,eax
    invoke ShowWindow,hwnd,SW_SHOWNORMAL
    invoke UpdateWindow,hwnd
    .WHILE TRUE
        invoke GetMessage,ADDR msg,0,0,0
        .BREAK .IF (!eax)
        invoke DispatchMessage,ADDR msg
    .ENDW
    mov  eax,msg.wParam
    ret
OknoProc ENDP

;--------------------------------------------------------------------------------------------

GraProc proc uses edi esi hWnd:dword
wczytywanie:
   invoke WczytanieBmpProc,addr Tlo1
	mov    lpTlo1,eax
   invoke WczytanieBmpProc,addr Logo1
	mov    lpLogo1,eax
   invoke WczytanieBmpProc,addr Logo2
	mov    lpLogo2,eax
   invoke WczytanieBmpProc,addr Logo3
	mov    lpLogo3,eax
   invoke WczytanieBmpProc,addr Postac1Poz1
	mov    lpPostac1Poz1,eax
   invoke WczytanieBmpProc,addr Postac1Poz2
	mov    lpPostac1Poz2,eax
   invoke WczytanieBmpProc,addr Postac2Poz1
	mov    lpPostac2Poz1,eax
   invoke WczytanieBmpProc,addr Postac2Poz2
	mov    lpPostac2Poz2,eax
   invoke WczytanieBmpProc,addr Przeszkoda1
	mov    lpPrzeszkoda1,eax
   invoke WczytanieBmpProc,addr Przeszkoda2
	mov    lpPrzeszkoda2,eax
   invoke WczytanieBmpProc,addr Przeszkoda3
	mov    lpPrzeszkoda3,eax
   invoke WczytanieBmpProc,addr Przeszkoda4
	mov    lpPrzeszkoda4,eax
   invoke WczytanieBmpProc,addr Przeszkoda5
	mov    lpPrzeszkoda5,eax
	invoke CreateCompatibleDC,0
	mov	 hBackDC,eax
	mov	 bmi.bmiHeader.biSize,sizeof BITMAPINFOHEADER
	mov	 bmi.bmiHeader.biWidth,SzerTlo
	mov	 bmi.bmiHeader.biHeight,(not WysoTlo)
	mov	 bmi.bmiHeader.biPlanes,1
	mov	 bmi.bmiHeader.biBitCount,32
	mov	 bmi.bmiHeader.biCompression,BI_RGB
	invoke CreateDIBSection,hBackDC,addr bmi,DIB_RGB_COLORS,addr lpBackBitmap,0,0
	mov	 hBackBitmap,eax
	invoke SelectObject,hBackDC,eax
@@:invoke GetDC,hWnd
	test	 eax,eax
	jz	    @B
	mov	 hMainDC,eax
rysowanie:
	mov	 esi,lpTlo1
	mov	 edi,lpBackBitmap
	mov	 ecx,SzerTlo*WysoTlo
	rep	 movsd
   .IF NowaGra==1
    invoke  PrzeszkodyProc,lpBackBitmap,000000FFh,lpPrzeszkoda1,lpPrzeszkoda2,lpPrzeszkoda3,lpPrzeszkoda4,lpPrzeszkoda5    
    invoke  KlawiszWProc,lpBackBitmap,lpPostac1Poz1,45,60,Postac1WspX,Postac1WspY,SzerTlo,WysoTlo
        .IF Kucanie==0
            .IF Krok<=25
                invoke	Postac,lpBackBitmap,lpPostac1Poz1,45,60,Postac1WspX,Postac1WspY,SzerTlo,WysoTlo,000000FFh
                .IF Pauza==0
                    add Krok,1
                .ENDIF
            .ELSE
                invoke	Postac,lpBackBitmap,lpPostac1Poz2,60,60,Postac1WspX,Postac1WspY,SzerTlo,WysoTlo,000000FFh
                .IF Pauza==0
                    add Krok,1
                .ENDIF
                .IF Krok==50
                    mov Krok,0
                .ENDIF
            .ENDIF
        .ELSEIF Kucanie==1
            add Postac1WspY,10
            .IF Krok<=25
                invoke	Postac,lpBackBitmap,lpPostac2Poz1,45,50,Postac1WspX,Postac1WspY,SzerTlo,WysoTlo,000000FFh
                .IF Pauza==0
                    add Krok,1
                .ENDIF
            .ELSE
                invoke	Postac,lpBackBitmap,lpPostac2Poz2,55,50,Postac1WspX,Postac1WspY,SzerTlo,WysoTlo,000000FFh
                .IF Pauza==0
                    add Krok,1
                .ENDIF
                .IF Krok==50
                    mov Krok,0
                .ENDIF
            .ENDIF
            sub Postac1WspY,10
         .ENDIF
         .IF Pauza==0 
            mov al,Predkosc
            add PunktyLicz,al
            .IF PunktyLicz>=240
                add Punkty,1
                call Konwersja
     	          invoke     TextOut,hMainDC,55,273,addr Punkty2,SIZEOF Punkty2 - 1
                mov PunktyLicz,0
            .ENDIF
         .ELSE
            invoke	Przeszkoda,lpBackBitmap,lpLogo3,210,60,135,105,SzerTlo,WysoTlo,000000FFh
         .ENDIF
         invoke Sleep,Predkosc
      .ELSEIF NowaGra==0
         invoke	Przeszkoda,lpBackBitmap,lpLogo1,443,110,17,80,SzerTlo,WysoTlo,000000FFh
         invoke     TextOut,hMainDC,5,273,addr Punkty1,SIZEOF Punkty1 - 1
      .ELSEIF NowaGra==2
         invoke	Przeszkoda,lpBackBitmap,lpLogo2,420,110,30,80,SzerTlo,WysoTlo,000000FFh
         mov Skok,0
         mov Kucanie,0
         mov Predkosc,10
         mov Postac1WspY,165
         mov Punkty,0
         mov Krok,0
         mov [Punkty2],0
         mov [Punkty2+1],0
         mov [Punkty2+2],0
         mov [Punkty2+3],0
         mov [Punkty2+4],0
      .ENDIF
      invoke	BitBlt,hMainDC,0,0,SzerTlo,WysoTlo,hBackDC,0,0,SRCCOPY
	   cmp	   ZakonczThread,1
	   jne	   rysowanie
usuwanie:
	 invoke	  ReleaseDC,hWnd,hMainDC
	 invoke	  DeleteDC,hBackDC
	 invoke    DeleteObject,hBackBitmap
	 invoke	  GlobalFree,lpTlo1
    invoke    GlobalFree,lpPostac1Poz1
    invoke    GlobalFree,lpPostac1Poz2
    invoke    GlobalFree,lpPostac2Poz1
    invoke    GlobalFree,lpPostac2Poz2
    invoke    GlobalFree,lpLogo1
    invoke    GlobalFree,lpLogo2
    invoke    GlobalFree,lpLogo3
    invoke    GlobalFree,lpPrzeszkoda1
    invoke    GlobalFree,lpPrzeszkoda2
    invoke    GlobalFree,lpPrzeszkoda3
    invoke    GlobalFree,lpPrzeszkoda4
    invoke    GlobalFree,lpPrzeszkoda5
    ret
GraProc endp

;--------------------------------------------------------------------------------------------

ZdarzeniaProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    .IF	uMsg==WM_DESTROY
		invoke	PostQuitMessage,0
        .ELSEIF wParam==VK_W
            .IF Skok==0 && Kucanie==0
                mov Skok,1
            .ELSEIF Kucanie==1
                mov Kucanie,0
            .ENDIF
        .ELSEIF wParam==VK_S && Pauza==0
            .IF Skok==0 && Kucanie==0
                mov Kucanie,1
            .ENDIF
        .ELSEIF wParam==VK_A && Pauza==0
            call KlawiszAProc
        .ELSEIF wParam==VK_D && Pauza==0
            call KlawiszDProc
        .ELSEIF wParam==VK_Z
            invoke	PostQuitMessage,0
        .ELSEIF wParam==VK_N
            .IF NowaGra==0 || NowaGra==2
                mov NowaGra,1
            .ENDIF
        .ELSEIF wParam==VK_P && uMsg==WM_KEYUP
            .IF Pauza==0
                mov Pauza,1
            .ELSE
                mov Pauza,0
            .ENDIF
      .ELSEIF    uMsg==WM_COMMAND
        mov eax,wParam
        .IF ax==Menu1ID3
            invoke	PostQuitMessage,0
        .ELSEIF ax==Menu1ID1
            .IF NowaGra==0 || NowaGra==2
                mov NowaGra,1
            .ENDIF
        .ELSEIF ax==Menu1ID2
            .IF Pauza==0
                mov Pauza,1
            .ELSE
                mov Pauza,0
            .ENDIF
        .ENDIF
	.ELSEIF	uMsg==WM_CLOSE
		mov	ZakonczThread,1
@@:		invoke	GetExitCodeThread,hThread,addr ThreadExitCode
		cmp	ThreadExitCode,STILL_ACTIVE
		je	@B
		invoke	DestroyWindow,hWnd
	.ELSEIF	uMsg==WM_CREATE
            
		invoke	CreateThread,0,0,addr GraProc,hWnd,0,addr ThreadID
		mov	hThread,eax
	.ELSE
		invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
		.IF	uMsg==WM_NCHITTEST && eax==HTCLIENT	;przesuwanie okna
			mov	eax,HTCAPTION
		.ENDIF
		jmp	_ret
	.ENDIF
	xor	eax,eax
_ret:	ret
ZdarzeniaProc endp

;--------------------------------------------------------------------------------------------

PrzeszkodyProc proc uses esi edi ebx ecx lpDstBitmap:dword,ColorKey:dword,lpPrze1:dword,lpPrze2:dword,lpPrze3:dword,lpPrze4:dword,lpPrze5:dword
    .IF Punkty==0
        mov eax,lpPrze1
        mov NumePrzeszkoda,eax
        mov eax,SzerPrzeszkoda1
        mov SzerPrzeszkoda,eax
        mov eax,PrzeszkodaWspXPocz
        mov PoloPrzeszkoda,eax
    .ENDIF
    invoke	Przeszkoda,lpBackBitmap,NumePrzeszkoda,SzerPrzeszkoda,WysoPrzeszkoda,PoloPrzeszkoda,PrzeszkodaWspYPocz,SzerTlo,WysoTlo,000000FFh
    .IF Pauza==0
        sub PoloPrzeszkoda,1
        mov eax,SzerPrzeszkoda
        add eax,PoloPrzeszkoda
        .IF eax==0
            invoke nrandom,5
            .IF eax==0
                mov eax,lpPrze1
                mov NumePrzeszkoda,eax
                mov eax,SzerPrzeszkoda1
                mov SzerPrzeszkoda,eax
                mov eax,PrzeszkodaWspXPocz
                mov PoloPrzeszkoda,eax
            .ELSEIF eax==1
                mov eax,lpPrze2
                mov NumePrzeszkoda,eax
                mov eax,SzerPrzeszkoda2
                mov SzerPrzeszkoda,eax
                mov eax,PrzeszkodaWspXPocz
                mov PoloPrzeszkoda,eax
            .ELSEIF eax==2
                mov eax,lpPrze3
                mov NumePrzeszkoda,eax
                mov eax,SzerPrzeszkoda3
                mov SzerPrzeszkoda,eax
                mov eax,PrzeszkodaWspXPocz
                mov PoloPrzeszkoda,eax
            .ELSEIF eax==3
                mov eax,lpPrze4
                mov NumePrzeszkoda,eax
                mov eax,SzerPrzeszkoda4
                mov SzerPrzeszkoda,eax
                mov eax,PrzeszkodaWspXPocz
                mov PoloPrzeszkoda,eax
            .ELSEIF eax==4
                mov eax,lpPrze5
                mov NumePrzeszkoda,eax
                mov eax,SzerPrzeszkoda5
                mov SzerPrzeszkoda,eax
                mov eax,PrzeszkodaWspXPocz
                mov PoloPrzeszkoda,eax
            .ENDIF
        .ENDIF
    .ENDIF   
    ret
PrzeszkodyProc endp

;--------------------------------------------------------------------------------------------

Przeszkoda proc uses esi edi ebx lpDstBitmap:dword,lpSrcBitmap:dword,SrcW:dword,SrcH:dword,DstX:dword,DstY:dword,DstW:dword,DstH:dword,ColorKey:dword
	mov	esi,lpSrcBitmap
	mov	edi,DstY
	imul	edi,DstW
	add	edi,DstX
	shl	edi,2
	add	edi,lpDstBitmap
	mov	edx,DstW
	sub	edx,SrcW
	shl	edx,2
	mov	ebx,SrcH
_blt:
	mov	ecx,SrcW
_wew:	lodsd
	and	eax,00FFFFFFh
	cmp	eax,ColorKey
	je	@F
	mov	[edi],eax
@@:	add	edi,4
	dec	ecx
	jnz	_wew
	add	edi,edx
	dec	ebx
	jnz	_blt
	ret
Przeszkoda endp

;--------------------------------------------------------------------------------------------

Postac proc uses esi edi ebx lpDstBitmap:dword,lpSrcBitmap:dword,SrcW:dword,SrcH:dword,DstX:dword,DstY:dword,DstW:dword,DstH:dword,ColorKey:dword
	mov	esi,lpSrcBitmap
	mov	edi,DstY
	imul	edi,DstW
	add	edi,DstX
	shl	edi,2
	add	edi,lpDstBitmap
	mov	edx,DstW
	sub	edx,SrcW
	shl	edx,2
	mov	ebx,SrcH
_blt:
	mov	ecx,SrcW
_wew:	lodsd
	and	eax,00FFFFFFh
	cmp	eax,ColorKey
	je	@F
;------------------------------------------------------
      mov zmzderz,eax
      mov eax,[edi]
    .IF eax!=0000FFFFh && eax!=00FFFFFFh
        mov NowaGra,2
        invoke Sleep,1000
        jmp _abc
    .ENDIF
      mov   eax,zmzderz
;------------------------------------------------------
	mov	[edi],eax
@@:	add	edi,4
	dec	ecx
	jnz	_wew
	add	edi,edx
	dec	ebx
	jnz	_blt
    _abc:
	ret
Postac endp

;--------------------------------------------------------------------------------------------

KlawiszWProc proc uses esi edi ebx lpDstBitmap:dword,lpSrcBitmap:dword,SrcW:dword,SrcH:dword,DstX:dword,DstY:dword,DstW:dword,DstH:dword
    LOCAL lnoga:dword,pnoga:dword
    mov	edi,DstY
    add   edi,60
    imul	edi,DstW
    add	edi,DstX
    shl	edi,2
    add	edi,lpDstBitmap
    mov eax,[edi]
    mov lnoga,eax
    .IF Krok<=25
        add   edi,152
    .ELSE
        add   edi,220
    .ENDIF
    mov eax,[edi]
    mov pnoga,eax
    mov al,SkokWyso     
    .IF Skok==0
        .IF lnoga==0000FFFFh && pnoga==0000FFFFh
            mov Skok,2
        .ENDIF
    .ELSEIF Skok==1
        .IF SkokLicz<al
            .IF Pauza==0
                sub Postac1WspY,1
            .ENDIF
            add SkokLicz,1
        .ELSEIF SkokLicz==al
            mov SkokLicz,0
            mov Skok,2
        .ENDIF
    .ELSEIF Skok==2
        .IF lnoga==0000FFFFh && pnoga==0000FFFFh && Pauza==0
            add Postac1WspY,1
        .ELSE
            mov Skok,0
        .ENDIF  
    .ENDIF
    ret
KlawiszWProc endp

;--------------------------------------------------------------------------------------------

KlawiszAProc proc
    .IF Predkosc<15
        add Predkosc,1
    .ENDIF
    ret
KlawiszAProc endp

;--------------------------------------------------------------------------------------------

KlawiszDProc proc
    .IF Predkosc>5
        sub Predkosc,1
    .ENDIF
    ret
KlawiszDProc endp

;--------------------------------------------------------------------------------------------

WysrodkowanieProc proc uses eax
	invoke	GetSystemMetrics,SM_CXSCREEN
	shr	eax,1
	sub	eax,SzerOkno/2
	mov	OdlPoziom,eax

	invoke	GetSystemMetrics,SM_CYSCREEN
	shr	eax,1
	sub	eax,WysoOkno/2
	mov	OdlPion,eax
ret
WysrodkowanieProc endp

;--------------------------------------------------------------------------------------------

WczytanieBmpProc proc uses edi esi ebx lpFileName:dword
	invoke	LoadImage,0,lpFileName,IMAGE_BITMAP,0,0,LR_LOADFROMFILE
	test	eax,eax
	jz	_ret
	mov	ebx,eax
	mov	edi,offset bmi
	assume	edi:ptr BITMAPINFO
	push	edi
	xor	eax,eax
	mov	ecx,sizeof BITMAPINFO
	rep	stosb
	pop	edi
	mov	[edi].bmiHeader.biSize,sizeof BITMAPINFOHEADER
	invoke	CreateCompatibleDC,0
	mov	esi,eax
	xor	edx,edx
	invoke	GetDIBits,esi,ebx,edx,edx,edx,edi,edx
	mov	eax,[edi].bmiHeader.biWidth
	mul	[edi].bmiHeader.biHeight
	shl	eax,2
	invoke	GlobalAlloc,GMEM_FIXED,eax
	push	eax
	test	eax,eax
	jz	@F
	push	DIB_RGB_COLORS
	push	edi
	push	eax
	push	[edi].bmiHeader.biHeight
	push	0
	push	ebx
	push	esi
	mov	[edi].bmiHeader.biBitCount,32
	neg	[edi].bmiHeader.biHeight
	call	GetDIBits
@@:invoke	DeleteDC,esi
	invoke	DeleteObject,ebx
	pop	eax
	mov	ecx,[edi].bmiHeader.biWidth
	mov	edx,[edi].bmiHeader.biHeight
	assume	edi:nothing
_ret:	ret
WczytanieBmpProc endp

;--------------------------------------------------------------------------------------------

Konwersja proc
    mov ecx,4
    mov eax,Punkty
    mov ebx,10
konwersja:
    sub edx,edx
    div ebx
    .IF edx==0
        mov [Punkty2+ecx],'0'
    .ELSEIF edx==1
        mov [Punkty2+ecx],'1'
    .ELSEIF edx==2
        mov [Punkty2+ecx],'2'
    .ELSEIF edx==3
        mov [Punkty2+ecx],'3'
    .ELSEIF edx==4
        mov [Punkty2+ecx],'4'
    .ELSEIF edx==5
        mov [Punkty2+ecx],'5'
    .ELSEIF edx==6
        mov [Punkty2+ecx],'6'
    .ELSEIF edx==7
        mov [Punkty2+ecx],'7'
    .ELSEIF edx==8
        mov [Punkty2+ecx],'8'
    .ELSEIF edx==9
        mov [Punkty2+ecx],'9'
    .ENDIF
    sub ecx,1
    .IF eax!=0
        jmp konwersja
    .ENDIF
    ret
Konwersja endp

;--------------------------------------------------------------------------------------------

end program