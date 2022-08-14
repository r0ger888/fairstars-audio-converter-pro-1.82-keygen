
GenKey			PROTO	:DWORD
Rndproc			PROTO	:DWORD
UnicodeConvert	PROTO	:DWORD

.data 

Dashh 			db "-",0
SerialBuffer 	db 60h dup(0)
ProdNumber 		db "U0000000",0
KeyPhormat 		db "0000000000000000",0
Magicstr 		db "GTBdq211",0

.data?
Rndbuffer 		dd ?

.code
GenKey proc near hWin:DWORD
LOCAL KeyBuffer:DWORD
LOCAL MagicBuff:DWORD
LOCAL HexBuffer:DWORD

		push esi
		push edi
		push ebx
		call ShiftValues
		invoke Rndproc,9
		inc eax
		mov [HexBuffer], eax
		mov ecx, 6
		mov esi, offset ProdNumber
		jmp part_2

part_1:
		push 9
		call Rndproc
		inc eax
		add eax, 30h
		mov [ecx+esi], al
		dec ecx

part_2:
		cmp ecx, 0
		ja part_1
		mov eax, [HexBuffer]
		mov ecx, eax
		shl ecx, 1
		mov [HexBuffer], ecx
		add eax, 30h
		mov [esi+7], al
		xor ecx, ecx
		mov [MagicBuff], ecx
		mov [KeyBuffer], ecx
		mov esi, offset Magicstr
		mov edi, offset KeyPhormat
		mov ebx, offset ProdNumber
		jmp finalize

part_3:
		xor ecx, ecx
		mov ecx, [KeyBuffer]
		movzx eax, byte ptr [ecx+ebx]
		movzx ecx, byte ptr [ecx+esi]
		add eax, ecx
		add eax, 2
		add eax, [HexBuffer]
		push eax
		mov ecx, 0Fh
		cdq
		div ecx
		pop eax
		sub eax, edx
		push edx
		cdq
		div ecx
		push eax
		call UnicodeConvert
		mov ecx, [MagicBuff]
		mov [ecx+edi+1], al
		call UnicodeConvert
		mov [ecx+edi], al
		add [MagicBuff], 2
		inc [KeyBuffer]

finalize:
		cmp [KeyBuffer], 8
		jb part_3
		invoke lstrcat,offset SerialBuffer,offset ProdNumber
		invoke lstrcat,offset SerialBuffer,offset Dashh
		invoke lstrcat,offset SerialBuffer,offset KeyPhormat
		invoke SetDlgItemText,hWin,IDC_SERIAL,offset SerialBuffer
		mov eax, offset SerialBuffer
		mov byte ptr [eax], 0
		pop ebx
		pop edi
		pop esi
		ret

GenKey endp

ShiftValues proc near

		rdtsc
		shr eax, 2
		add eax, 1
		mov Rndbuffer, eax
		ret

ShiftValues endp

Rndproc proc near RndValue:DWORD

		push ecx
		push edx
		mov eax, Rndbuffer
		mov edx, 0
		mov ecx, 1F31Dh
		div ecx
		xor eax, edx
		xor edx, eax
		xor eax, edx
		push edx
		mov ecx, 41A7h
		mul ecx
		pop edx
		xor eax, edx
		xor edx, eax
		xor eax, edx
		push edx
		mov ecx, 0B14h
		mul ecx
		pop edx
		sub edx, eax
		mov eax, edx
		mov Rndbuffer, eax
		mov ecx, RndValue
		mov edx, 0
		div ecx
		mov eax, edx
		pop edx
		pop ecx
		ret

Rndproc endp

UnicodeConvert proc near String:DWORD

		mov eax, String
		cmp eax, 0Ah
		jb loc_40995D
		add eax, 37h
		jmp locret_409960

loc_40995D:
		add eax, 30h

locret_409960:
		ret

UnicodeConvert endp