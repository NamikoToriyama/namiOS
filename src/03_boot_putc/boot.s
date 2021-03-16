    BOOT_LOAD   equ 0x7C00          ; ブートプログラムのロード位置

    ORG     BOOT_LOAD               ; ロードアドレスをアセンブラに指示


entry:
; -------------------------------
; BPB(BIOS Parameter Block)
; -------------------------------
    jmp     ipl                     ;  iplへジャンプ
    times   90 - ($ - $$) db 0x90   ; 92バイトを0x90で埋める
; -------------------------------
; IPL(inital Program Loder)
; -------------------------------
ipl:
    cli                         ; 割り込み禁止

    mov     ax, 0x0000          ; AX = 0x0000
    mov     ds, ax              ; セグメントレジスタにaxレジスタの値を代入
    mov     es, ax
    mov     ss, ax
    mov     sp, BOOT_LOAD       ; SP = 0x7c00

    sti                         ; 割り込み許可

    mov     [BOOT.DRIVE], dl    ; ブートドライブを保存

    mov     al, 'N'             ; AL=出力文字
    mov     ah, 0x0E            ; テレタイプ式一文字出力
    mov     bx, 0x0000          ; ページ番号と文字色を０に設定
    int     0x10                ; ビデオBIOSコール
    
    jmp     $                   ;  while(1); // 無限ループ

ALIGN 2, db 0
BOOT:                           ; ブートドライブに関する情報
    .DRIVE:     dw 0            ; ドライブ番号

; -------------------------------
; ブートフラグ(先頭512バイトの終了)
; -------------------------------
    times   510 - ($ - $$) db 0x00 ; 512バイトを0で埋める // ブートプログラムやOSが参照する情報が書き込まれていることがある
    db      0x55, 0xAA ; ブートフラグの条件 p393
