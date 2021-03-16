entry:
    jmp     $        ;  while(1); // 無限ループ
    times   510 - ($ - $$) db 0x00
    db      0x55, 0xAA
