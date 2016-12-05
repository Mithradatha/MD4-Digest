INCLUDE Irvine32.inc


;; -------------------------------------------------
mF MACRO X, Y, Z
;;
;; Returns: EAX = (X AND Y) OR((NOT X) AND Z)
;; -------------------------------------------------
	push ebx

	mov eax, X
	mov ebx, Y

	and ebx, eax
	not eax
	and eax, Z
	or eax, ebx

	pop ebx
ENDM


;; -------------------------------------------------
mG MACRO X, Y, Z
;;
;; Returns: EAX = (X AND Y) OR(X AND Z) OR(Y AND Z)
;; -------------------------------------------------
	push ebx
	push ecx

	mov eax, X
	mov ebx, Y
	mov ecx, Z

	and eax, ebx
	and ebx, ecx
	and ecx, X
	or eax, ebx
	or eax, ecx

	pop ecx
	pop ebx
ENDM


;; -------------------------------------------------
mH MACRO X, Y, Z
;;
;; Returns: EAX = X XOR Y XOR Z
;; -------------------------------------------------
	mov eax, X
	xor eax, Y
	xor eax, Z
ENDM


;; -------------------------------------------------
mR1 MACRO O, X, Y, Z, K, S
;;
;; O = (O + mF(X, Y, Z) + message[K * 4]) <<< s
;; -------------------------------------------------
	mF X, Y, Z
	mov ebx, O
	mov edx, DWORD PTR message[K * 4]
	add eax, ebx
	add eax, edx
	rol eax, S
	mov O, eax
ENDM


;; -------------------------------------------------
mR2 MACRO O, X, Y, Z, K, S
;;
;; O = (O + mG(X, Y, Z) + message[K * 4] + 05A827999h) <<< s
;; -------------------------------------------------
	mG X, Y, Z
	mov ebx, O
	mov edx, DWORD PTR message[K * 4]
	add eax, ebx
	add eax, edx
	add eax, 05A827999h
	rol eax, S
	mov O, eax
ENDM


;; -------------------------------------------------
mR3 MACRO O, X, Y, Z, K, S
;;
;; O = (O + mH(X, Y, Z) + message[K * 4] + 06ED9EBA1h) <<< s
;; -------------------------------------------------
	mH X, Y, Z
	mov ebx, O
	mov edx, DWORD PTR message[K * 4]
	add eax, ebx
	add eax, edx
	add eax, 06ED9EBA1h
	rol eax, S
	mov O, eax
ENDM


.data
message BYTE 55 DUP('A'), 80h, 0b8h, 01h, 12 DUP(0)

CR = 0Dh
LF = 0Ah

NewLine BYTE ' ', CR, LF, 0

ALIGN DWORD

A0 DWORD 067452301h
B0 DWORD 0EFCDAB89h
C0 DWORD 098BADCFEh
D0 DWORD 010325476h

A1 DWORD 067452301h
B1 DWORD 0EFCDAB89h
C1 DWORD 098BADCFEh
D1 DWORD 010325476h


New_Line MACRO
	mov edx, OFFSET NewLine
	call WriteString
ENDM

.code
MD4 PROC

; Round 1
	mR1 A0, B0, C0, D0, 0, 3
	mR1 D0, A0, B0, C0, 1, 7
	mR1 C0, D0, A0, B0, 2, 11
	mR1 B0, C0, D0, A0, 3, 19

	mR1 A0, B0, C0, D0, 4, 3
	mR1 D0, A0, B0, C0, 5, 7
	mR1 C0, D0, A0, B0, 6, 11
	mR1 B0, C0, D0, A0, 7, 19

	mR1 A0, B0, C0, D0, 8, 3
	mR1 D0, A0, B0, C0, 9, 7
	mR1 C0, D0, A0, B0, 10, 11
	mR1 B0, C0, D0, A0, 11, 19

	mR1 A0, B0, C0, D0, 12, 3
	mR1 D0, A0, B0, C0, 13, 7
	mR1 C0, D0, A0, B0, 14, 11
	mR1 B0, C0, D0, A0, 15, 19

; Round 2
	mR2 A0, B0, C0, D0, 0, 3
	mR2 D0, A0, B0, C0, 4, 5
	mR2 C0, D0, A0, B0, 8, 9
	mR2 B0, C0, D0, A0, 12, 13

	mR2 A0, B0, C0, D0, 1, 3
	mR2 D0, A0, B0, C0, 5, 5
	mR2 C0, D0, A0, B0, 9, 9
	mR2 B0, C0, D0, A0, 13, 13

	mR2 A0, B0, C0, D0, 2, 3
	mR2 D0, A0, B0, C0, 6, 5
	mR2 C0, D0, A0, B0, 10, 9
	mR2 B0, C0, D0, A0, 14, 13

	mR2 A0, B0, C0, D0, 3, 3
	mR2 D0, A0, B0, C0, 7, 5
	mR2 C0, D0, A0, B0, 11, 9
	mR2 B0, C0, D0, A0, 15, 13

; Round 3
	mR3 A0, B0, C0, D0, 0, 3
	mR3 D0, A0, B0, C0, 8, 9
	mR3 C0, D0, A0, B0, 4, 11
	mR3 B0, C0, D0, A0, 12, 15

	mR3 A0, B0, C0, D0, 2, 3
	mR3 D0, A0, B0, C0, 10, 9
	mR3 C0, D0, A0, B0, 6, 11
	mR3 B0, C0, D0, A0, 14, 15

	mR3 A0, B0, C0, D0, 1, 3
	mR3 D0, A0, B0, C0, 9, 9
	mR3 C0, D0, A0, B0, 5, 11
	mR3 B0, C0, D0, A0, 13, 15

	mR3 A0, B0, C0, D0, 3, 3
	mR3 D0, A0, B0, C0, 11, 9
	mR3 C0, D0, A0, B0, 7, 11
	mR3 B0, C0, D0, A0, 15, 15

; Increment Registers
	mov eax, A0
	add eax, A1
	mov A0, eax

	mov eax, B0
	add eax, B1
	mov B0, eax

	mov eax, C0
	add eax, C1
	mov C0, eax

	mov eax, D0
	add eax, D1
	mov D0, eax

	ret
MD4 ENDP


PrintDigest PROC
	
	mov eax, A0
	bswap eax
	call WriteHex
	
	mov eax, B0
	bswap eax
	call WriteHex
	
	mov eax, C0
	bswap eax
	call WriteHex
	
	mov eax, D0
	bswap eax
	call WriteHex
	
	New_Line

	ret
PrintDigest ENDP


main PROC

	CALL MD4
	CALL PrintDigest

	INVOKE ExitProcess, 0
main ENDP
END main