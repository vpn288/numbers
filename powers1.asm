
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
;copy and shift
  mov   rsi,firstnum
  mov   rcx,[firstnumlen]
  mov   rdi,rsi
  add   rdi,rcx
  mov   [summlen],rcx
  add   qword [summlen],2
;add zero before
  mov   byte [rdi],30h
 ; inc   rdi
  mov   [summ],rdi
  inc   rdi
  rep   movsb
;add zero after
  mov   byte [rdi],30h
;summ numbers
  mov   rsi,firstnum
  mov   rcx,[firstnumlen]
  add   rsi,rcx
  inc   rcx
  inc   rcx

 sumnum:
;  int3
  mov   al,[rsi-1]
  and   al,0fh
  add   al,[rdi]
  add   al,ah
  cmp   al,32h
  jne   sumnum1
  mov   rax,130h
 ; mov   [rdi-1],ah
sumnum1:
  mov   [rdi],al
  dec   rsi
  dec   rdi
  dec   rcx
  jne   sumnum


;write to file
  mov   rcx,[handle]
  mov   rdx,[summ]
  mov   r8,[summlen]
  mov   r9,byteswritten
  call  [WriteFile]
  xor     rcx,rcx
  call  [ExitProcess]

handle  dq      0
byteswritten    dq      0
summ            dq      0


filename db '3powers.txt',0
ofStruc:  db 136
          db 0
          dw 0
          dw 0
          dw 0
          db 128 dup(0)
firstnumlen  dq  2
summlen dq  0
firstnum  db '11'

db       0x200000 dup  (?)
