entry:
    jmp     ipl       ;  iplへジャンプ

    times   90 - ($ - $$) db 0x90 ; 92バイトを0x90で埋める
    ; -------------------------------
    ; IPL(inital Program Loder)
    ; -------------------------------
ipl:
    ; 処理の終了
    jmp     $        ;  while(1); // 無限ループ
    ; ブートフラグ(先頭512バイトの終了)
    times   510 - ($ - $$) db 0x00 ; 512バイトを0で埋める // ブートプログラムやOSが参照する情報が書き込まれていることがある
    db      0x55, 0xAA ; ブートフラグの条件 p393
