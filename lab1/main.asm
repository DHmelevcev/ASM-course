.386
.MODEL FLAT, STDCALL
EXTERN GetStdHandle@4: PROC
EXTERN WriteConsoleA@20: PROC
EXTERN ReadConsoleA@20: PROC
EXTERN CharToOemA@8: PROC
EXTERN lstrlenA@4: PROC; ������� ����������� ����� ������
EXTERN ExitProcess@4: PROC; ������� ������ �� ���������

.DATA
STRN1 DB "������� ������ �����:",13,10,0; DB ������������� ������ ������
STRN2 DB "������� ������ �����:",13,10,0
STRN3 DB "���������: ", 0
NUMBR DD ?
SIGN DB 0
DIN DD ?; ��������� DD ����������� ������ �������
; 32 ���� (4 �����), ���� �?� ������������ ��� �������������������� ������
DOUT DD ?
BUF  DB 10 dup (?)
LENS DD ?

.CODE
MAIN PROC

; ������������ ������ STRN
MOV  EAX, OFFSET STRN1
PUSH EAX
PUSH EAX
CALL CharToOemA@8
MOV  EAX, OFFSET STRN2
PUSH EAX
PUSH EAX
CALL CharToOemA@8
MOV  EAX, OFFSET STRN3
PUSH EAX
PUSH EAX
CALL CharToOemA@8

; ������� ���������� ����� 
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX

; ������� ���������� ������
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX

BEGIN1:

; ��������� ����� ������ STRN1
PUSH OFFSET STRN1; � ���� ���������� ����� ������
CALL lstrlenA@4

; ����� ������� WriteConsoleA ��� ������ ������ STRN1
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; ���� ��������� ���-�� ���������� ��������
PUSH EAX; ����� ������
PUSH OFFSET STRN1; ����� ������
PUSH DOUT; ���������� ������
CALL WriteConsoleA@20

; ������ ������ �����
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; ���� ��������� ���-�� ��������� ��������
PUSH 200; ����� �������
PUSH OFFSET BUF; ����� �������
PUSH DIN; ���������� �����
CALL ReadConsoleA@20

; ������ ����� � NUMBR
MOV EDI, 8
MOV ECX, LENS; ������� �����
SUB ECX, 2
MOV ESI, OFFSET BUF; ������ ������
XOR EAX, EAX; �������� ������� EAX
XOR EBX, EBX; �������� ������� EBX

MOV BL, [ESI]
CMP BL, '-'
JE NEGATIVE1

CONVERT1:
MOV BL, [ESI]; ��������� ������ �� ��������� ������ � �������
; BL, ��������� ��������� ���������
SUB BL, '0'; ������� �� ���������� ������� ��� ����
CMP BL, 8
JAE BEGIN1
MUL EDI; �������� �������� EAX �� 8, ��������� � � EDX:EAX
ADD EAX, EBX; �������� � ����������� � EAX ����� ����� �����
NEGATIVE1:
INC ESI; ������� �� ��������� ������ ������
LOOP CONVERT1

MOV DL, [OFFSET BUF]
CMP DL, '-'
JNE POSITIVE1
NEG EAX
POSITIVE1:
MOV NUMBR, EAX

BEGIN2:

; ��������� ����� ������ STRN2
PUSH OFFSET STRN2; � ���� ���������� ����� ������
CALL lstrlenA@4

; ����� ������� WriteConsoleA ��� ������ ������ STRN2
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; ���� ��������� ���-�� ���������� ��������
PUSH EAX; ����� ������
PUSH OFFSET STRN2; ����� ������
PUSH DOUT; ���������� ������
CALL WriteConsoleA@20

; ������ ������ �����
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; ���� ��������� ���-�� ��������� ��������
PUSH 200; ����� �������
PUSH OFFSET BUF; ����� �������
PUSH DIN; ���������� �����
CALL ReadConsoleA@20

; ������ ����� � EAX
MOV EDI, 8
MOV ECX, LENS; ������� �����
SUB ECX, 2
MOV ESI, OFFSET BUF; ������ ������
XOR EAX, EAX; �������� ������� EAX
XOR EBX, EBX; �������� ������� EBX

MOV BL, [ESI]
CMP BL, '-'
JE NEGATIVE2

CONVERT2:
MOV BL, [ESI]; ��������� ������ �� ��������� ������ � �������
; BL, ��������� ��������� ���������
SUB BL, '0'; ������� �� ���������� ������� ��� ����
CMP BL, 8
JAE BEGIN2
MUL EDI; �������� �������� EAX �� 8, ��������� � � EDX:EAX
ADD EAX, EBX; �������� � ����������� � EAX ����� ����� �����
NEGATIVE2:
INC ESI; ������� �� ��������� ������ ������
LOOP CONVERT2

MOV DL, [OFFSET BUF]
CMP DL, '-'
JNE POSITIVE2
NEG EAX
POSITIVE2:

; ���������� �����
MOV EBP, NUMBR
ADD EBP, EAX

; ���� EBP �������������
lahf
and AH, 80h
CMP AH, 0
JE POSITIVE3
MOV SIGN, 1
NEG EBP
POSITIVE3:

; ��������� ����� ������ STRN3
PUSH OFFSET STRN3; � ���� ���������� ����� ������
CALL lstrlenA@4

; ����� ������� WriteConsoleA ��� ������ ������ STRN3
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; ���� ��������� ���-�� ���������� ��������
PUSH EAX; ����� ������
PUSH OFFSET STRN3; ����� ������
PUSH DOUT; ���������� ������
CALL WriteConsoleA@20

; ����� � BUF
MOV EAX, EBP
MOV EDI, 10
XOR EBX, EBX; ����� �����
MOV ESI, OFFSET BUF; ������ ������

CONVERT3:
XOR EDX, EDX
DIV EDI; ����� EDX:EAX �� 10 -> EAX - �������, EDX - �������
ADD DL, '0'; ��������� � ������� ��� ����
MOV [ESI], DL;
INC ESI; ������� �� ��������� ������ ������
ADD EBX, 1
CMP EAX, 0
JA CONVERT3

CMP SIGN, 0
JE POSITIVE4
MOV CL, '-'
;ADD CL, '0'
MOV [ESI], CL
INC ESI
ADD EBX, 1
POSITIVE4:

; ����������� BUF
MOV EDI, OFFSET BUF
INVERT:
DEC ESI
CMP EDI, ESI
JA INVERTEND
MOV CL, [EDI]
MOV CH, [ESI]
MOV [EDI], CH
MOV [ESI], CL
INC EDI
JMP INVERT
INVERTEND:

; ����� ������� WriteConsoleA ��� ������ BUF
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; ���� ��������� ���-�� ���������� ��������
PUSH EBX; ����� ������
PUSH OFFSET BUF; ����� ������
PUSH DOUT; ���������� ������
CALL WriteConsoleA@20

PUSH 0
CALL ExitProcess@4

MAIN ENDP
END MAIN