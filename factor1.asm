
; Example of 64-bit PE program

format PE64 GUI
entry start
  section '.idata' import data readable writeable

  dd 0,0,0,RVA kernel_name,RVA kernel_table
  dd 0,0,0,RVA user_name,RVA user_table
  dd 0,0,0,0,0

  kernel_table:
    ExitProcess dq RVA _ExitProcess
    ReadFile    dq RVA _ReadFile
    WriteFile   dq RVA _WriteFile
    CreateFile  dq RVA _CreateFile
    OpenFile    dq RVA _OpenFile
    dq 0
  user_table:
    MessageBoxA dq RVA _MessageBoxA
    dq 0

  kernel_name db 'KERNEL32.DLL',0
  user_name db 'USER32.DLL',0

  _ExitProcess dw 0
    db 'ExitProcess',0
  _MessageBoxA dw 0
    db 'MessageBoxA',0
  _ReadFile dw 0
    db 'ReadFile',0
  _WriteFile dw 0
    db 'WriteFile',0
  _CreateFile dw 0
    db 'CreateFileA',0
  _OpenFile   dw 0
    db 'OpenFile',0

; section '.text' code readable executable
  section '.text' code readable executable  writeable
  start:
         mov   rcx,filename
         mov   r8,2
         mov   rdx,ofStruc
         call  [OpenFile]
         mov   [handle],rax

         mov   rsi,simples
again:

         mov rdx,[highpart]
         mov rax,[lowpart]

next_try:
         div qword [rsi]
;пока остаток не станет равен нулю
         test rdx,rdx
         jne  next_dividor
;нашли делитель
         inc    qword [dividers]
         inc    qword [dividers_total]

         jmp    next_try

next_dividor:
         mov   rax,[dividers_total]
         test  rax,rax
         je    nd2
;так как всего делителей не ноль, проверим, первый ли это
         cmp   rax,1
         jne   nd3
;первый делитель. конвертируем и выводим его
         mov    rax,[rsi]
         mov    [convert_i],rax
         call   to_decimal
         call   cut_leading_zeroes
         mov    [str_start],rdi
         mov    [str_len],rcx
         call   to_file
nd3:
;не первый делитель. Ставим звездочку, а потом конвертируем
         mov     qword [str_start],star
         mov     qword [str_len],1
         call    to_file
nd2:
;не было делителей еще
         add     rsi,8
         mov     rax,[rsi]
         test    rax,rax
         jne     again
;добавим число в список делителей
         mov   rax,[dividers_total]
         test  rax,rax
         jne    next_number

;nd2:
;        add     rsi,8
;        jmp     again

check_reminder:

simple_is:
;новое простое
         mov   rax,[lowpart]

         mov   [rsi],rax
;выведем его
         mov    [convert_i],rax
         call   to_decimal
         call   cut_leading_zeroes
         mov    [str_start],rdi
         mov    [str_len],rcx
         call   to_file
;закончили факторизацию
;берем следующее число
;добавляем перенос строки
next_number:
        mov     qword [str_start],crlf
        mov     qword [str_len],2
        call    to_file
        add       qword [lowpart],1
        adc       qword [highpart],0
        mov       rsi,simples
        mov       qword [dividers_total],0
        jmp       again

new_simp:

;add 10,13

;write to file
;
to_file:
         push    rsi
         mov   rcx,[handle]
         mov   rdx,[str_start]
         mov   r8,[str_len]
         mov   r9,byteswritten
         call  [WriteFile]
         pop   rsi
         ret


  xor     rcx,rcx
  call  [ExitProcess]

;подпрограммы преобразования в десятичный вид
to_decimal:
        push    rsi
        xor     rdi,rdi
        fild    qword [convert_i]
        fbstp    tbyte [convertbcd]
        mov      rsi,convertbcd+9

todec2:
        mov      al,[rsi]
        dec      rsi
        mov      ah,al
        shr      al,4
        and      ah,0fh
        or       ax,3030h
        mov     word [firstnum+rdi],ax
        inc     rdi
        inc     rdi
        cmp     rsi,convertbcd
        jnb     todec2
        pop     rsi
        ret

cut_leading_zeroes:
;rdi укажет на наччало строки
;rcx - длина строки
        mov     rdi,firstnum
        mov     rcx,21
        mov     al,30h
        cld
        repe     scasb
        dec      rdi
        ret


convert_i       dq      123456789123456789
convertbcd:     dq      0
                dw 0
digits          db      12
handle          dq      0
byteswritten    dq      0
str_start       dq      0
str_len         dq      0
star            db      '*'
crlf            db      13,10


filename db 'factory.txt',0
ofStruc:  db 136
          db 0
          dw 0
          dw 0
          dw 0
          db 128 dup(0)
firstnumlen  dq  2
summlen   dq  0
          db  '00'
firstnum  db '11'
          db 256 dup(20h)
dividers         dq 0
dividers_total   dq      0
lowpart          dq 2
highpart         dq 0
simples:         dq 2
          dq 1024 dup(?)

          db       0x200000 dup  (?)
