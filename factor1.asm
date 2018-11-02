
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
  ;       cmp rax,1
  ;       je  check_reminder
;÷àñòíîå íå ðàâíî åäèíèöå, ïðîâåðèì îñòàòîê
         test rdx,rdx
         jne  next_dividor
;íàøëè äåëèòåëü
         inc    qword [dividers]
         inc    qword [dividers_total]
         jmp    next_try

next_dividor:
;
        add     rsi,8
        mov     rax,[rsi]
        test    rax,rax
        jne     again
;äîáàâèì ÷èñëî â ñïèñîê äåëèòåëåé
         mov   rax,[dividers_total]
         test  rax,rax
         jne    next_number

;nd2:
;        add     rsi,8
;        jmp     again

check_reminder:

simple_is:
;íîâîå ïðîñòîå
         mov   rax,[lowpart]

         mov   [rsi],rax
;çàêîí÷èëè ôàêòîðèçàöèþ
;áåðåì ñëåäóþùåå ÷èñëî
next_number:
       add       qword [lowpart],1
       adc       qword [highpart],0
       mov       rsi,simples
       mov       qword [dividers_total],0
       jmp       again

new_simp:

;add 10,13

;write to file
  mov   rcx,[handle]
  mov   rdx,[summ]
  sub   rdx,140
  mov   r8,[summlen]
  add   r8,2
  add   rdx,r8
  mov   r8,140
  mov   r9,byteswritten
  call  [WriteFile]
;move summ to firstsum
  mov   rsi,[summ]
  mov   rdi,firstnum
  mov   rcx,[summlen]
  add   qword [firstnumlen],2
  cld
  rep   movsb
  dec   byte [digits]

  xor     rcx,rcx
  call  [ExitProcess]

digits  db      12
handle  dq      0
byteswritten    dq      0
summ            dq      0


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
