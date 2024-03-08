.386
.MODEL FLAT

.DATA
TWO REAL4 2.
THREE WORD 3
MINUS1 REAL8 -1.

.CODE

_FUNC1@8 PROC
	PUSH EBP
	MOV EBP, ESP

	FINIT                  ; initialize (set CWR(CTRL), SWR(STAT), TWR(TAGS))
						   ; CTRL = 037F = 000000 11(64bit mantissa, 15bit exponent) 01111111

	FLD QWORD PTR [EBP+8]  ; ST = 1st param

	FSIN                   ; ST = sin(x)
	
	FSTSW AX			   ; STAT = 3800 -> good
						   ; STAT = 3820 -> PE = 1, C1 = 0, round down
						   ; STAT = 3A20 -> PE = 1, C1 = 1, round up
						   ; STAT = 3C00 -> C2 = 1, invalid value of source operand
	SAHF				   ; copy big bits of STAT to FLAGS

	JP Abort			   ; if PF = C2 = 1

	FLD ST                 ; ST(1) = ST = sin(x)
	FMULP                  ; ST(1) = ST(1) * ST = sin^2(x), POP (ST = ST(1))

	FMUL DWORD PTR [TWO]   ; ST = ST * TWO = 2sin^2(x)
						   ; or
						   ; FLD DWORD PTR [TWO]   ; ST(1) = ST, ST = TWO
						   ; FMUL                  ; ST = ST(1) * ST

	FIDIV WORD PTR [THREE] ; ST = ST / THREE = 2sin^2(x) / 3
						   ; or
						   ; FILD WORD PTR [THREE] ; ST(1) = ST, ST = THREE
						   ; FDIV                  ; ST = ST(1) / ST

	JMP Exit

	Abort:
	FLD QWORD PTR [MINUS1] ; ST = -1
	FSQRT                  ; ST = sqrt(-1) = nan

	Exit:
	POP EBP
	RET 8
_FUNC1@8 ENDP              ; RETURN ST
END