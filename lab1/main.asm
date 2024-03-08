.386
.MODEL FLAT, STDCALL
EXTERN GetStdHandle@4: PROC
EXTERN WriteConsoleA@20: PROC
EXTERN ReadConsoleA@20: PROC
EXTERN CharToOemA@8: PROC
EXTERN lstrlenA@4: PROC; функция определения длины строки
EXTERN ExitProcess@4: PROC; функция выхода из программы

.DATA
STRN1 DB "Введите первое число:",13,10,0; DB резервируется массив байтов
STRN2 DB "Введите второе число:",13,10,0
STRN3 DB "Результат: ", 0
NUMBR DD ?
SIGN DB 0
DIN DD ?; директива DD резервирует память объемом
; 32 бита (4 байта), знак «?» используется для неинициализированных данных
DOUT DD ?
BUF  DB 10 dup (?)
LENS DD ?

.CODE
MAIN PROC

; перекодируем строки STRN
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

; получим дескриптор ввода 
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX

; получим дескриптор вывода
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX

BEGIN1:

; определим длину строки STRN1
PUSH OFFSET STRN1; в стек помещается адрес строки
CALL lstrlenA@4

; вызов функции WriteConsoleA для вывода строки STRN1
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; куда поместить кол-во выведенных символов
PUSH EAX; длина строки
PUSH OFFSET STRN1; адрес строки
PUSH DOUT; дескриптор вывода
CALL WriteConsoleA@20

; читаем первое число
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; куда поместить кол-во введенных символов
PUSH 200; длина буффера
PUSH OFFSET BUF; адрес буффера
PUSH DIN; дескриптор ввода
CALL ReadConsoleA@20

; первое число в NUMBR
MOV EDI, 8
MOV ECX, LENS; счетчик цикла
SUB ECX, 2
MOV ESI, OFFSET BUF; начало строки
XOR EAX, EAX; обнулить регистр EAX
XOR EBX, EBX; обнулить регистр EBX

MOV BL, [ESI]
CMP BL, '-'
JE NEGATIVE1

CONVERT1:
MOV BL, [ESI]; поместить символ из введенной строки в регистр
; BL, используя косвенную адресацию
SUB BL, '0'; вычесть из введенного символа код нуля
CMP BL, 8
JAE BEGIN1
MUL EDI; умножить значение EAX на 8, результат – в EDX:EAX
ADD EAX, EBX; добавить к полученному в EAX числу новую цифру
NEGATIVE1:
INC ESI; перейти на следующий символ строки
LOOP CONVERT1

MOV DL, [OFFSET BUF]
CMP DL, '-'
JNE POSITIVE1
NEG EAX
POSITIVE1:
MOV NUMBR, EAX

BEGIN2:

; определим длину строки STRN2
PUSH OFFSET STRN2; в стек помещается адрес строки
CALL lstrlenA@4

; вызов функции WriteConsoleA для вывода строки STRN2
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; куда поместить кол-во выведенных символов
PUSH EAX; длина строки
PUSH OFFSET STRN2; адрес строки
PUSH DOUT; дескриптор вывода
CALL WriteConsoleA@20

; читаем второе число
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; куда поместить кол-во введенных символов
PUSH 200; длина буффера
PUSH OFFSET BUF; адрес буффера
PUSH DIN; дескриптор ввода
CALL ReadConsoleA@20

; второе число в EAX
MOV EDI, 8
MOV ECX, LENS; счетчик цикла
SUB ECX, 2
MOV ESI, OFFSET BUF; начало строки
XOR EAX, EAX; обнулить регистр EAX
XOR EBX, EBX; обнулить регистр EBX

MOV BL, [ESI]
CMP BL, '-'
JE NEGATIVE2

CONVERT2:
MOV BL, [ESI]; поместить символ из введенной строки в регистр
; BL, используя косвенную адресацию
SUB BL, '0'; вычесть из введенного символа код нуля
CMP BL, 8
JAE BEGIN2
MUL EDI; умножить значение EAX на 8, результат – в EDX:EAX
ADD EAX, EBX; добавить к полученному в EAX числу новую цифру
NEGATIVE2:
INC ESI; перейти на следующий символ строки
LOOP CONVERT2

MOV DL, [OFFSET BUF]
CMP DL, '-'
JNE POSITIVE2
NEG EAX
POSITIVE2:

; складываем числа
MOV EBP, NUMBR
ADD EBP, EAX

; если EBP отрицательное
lahf
and AH, 80h
CMP AH, 0
JE POSITIVE3
MOV SIGN, 1
NEG EBP
POSITIVE3:

; определим длину строки STRN3
PUSH OFFSET STRN3; в стек помещается адрес строки
CALL lstrlenA@4

; вызов функции WriteConsoleA для вывода строки STRN3
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; куда поместить кол-во выведенных символов
PUSH EAX; длина строки
PUSH OFFSET STRN3; адрес строки
PUSH DOUT; дескриптор вывода
CALL WriteConsoleA@20

; сумма в BUF
MOV EAX, EBP
MOV EDI, 10
XOR EBX, EBX; длина числа
MOV ESI, OFFSET BUF; начало строки

CONVERT3:
XOR EDX, EDX
DIV EDI; делим EDX:EAX на 10 -> EAX - частное, EDX - остаток
ADD DL, '0'; прибавить к символу код нуля
MOV [ESI], DL;
INC ESI; перейти на следующий символ строки
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

; инвертируем BUF
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

; вызов функции WriteConsoleA для вывода BUF
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; куда поместить кол-во выведенных символов
PUSH EBX; длина строки
PUSH OFFSET BUF; адрес строки
PUSH DOUT; дескриптор вывода
CALL WriteConsoleA@20

PUSH 0
CALL ExitProcess@4

MAIN ENDP
END MAIN