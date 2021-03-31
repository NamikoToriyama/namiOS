; *******************************
; マクロ
; *******************************
%include    "../include/define.s"
%include    "../include/macro.s"

    ORG     KERNEL_LOAD                     ; カーネルのロードアドレス
[BITS 32]
; *******************************
; エントリポイント
; *******************************
kernel:
    ; -------------------------------
    ; フォントアドレスを取得する
    ; -------------------------------
    mov     esi, BOOT_LOAD + SECT_SIZE      ; ESI = 0x7c00 + 512
    movzx   eax, word [esi + 0]
    movzx   ebx, word [esi + 2]
    shl     eax, 4                          ; shit left: eax << 4
    add     eax, ebx
    mov     [FONT_ADR], eax

    ; -------------------------------
    ; 8ビットの枠線
    ; -------------------------------
    mov     ah, 0x07                        ; 書き込みプレーンを指定 // 暗かったら0x0Fにする
    mov     al, 0x02                        ; 書き込みプレーンを指定
    mov     dx, 0x03C4                      ; シーケンサ制御ポート
    out     dx, ax                          ; 出力

    mov     [0x000A_0000 + 0], byte 0xFF

    mov     ah, 0x04                        ; プレーン指定
    out     dx, ax                          ; ポート出力

    mov     [0x000A_0000 + 1], byte 0xFF    ; 8ドットの枠線

    mov     ah, 0x02
    out     dx, ax

    mov     [0x000A_0000 + 2], byte 0xFF

    mov     ah, 0x01
    out     dx, ax

    mov     [0x000A_0000 + 3], byte 0xFF

    ;------------------------------------------
    ; ２ドット目に画面を横切る横線
    ;------------------------------------------
    mov     ah, 0x02
    out     dx, ax

    lea     edi, [0x000A_0000]              ; edi = VRAMのアドレス
    mov     ecx, 80                         ; ecx = 繰り返し回数
    mov     al, 0xFF                        ; al = ビットパターン
    rep     stosb                           ; *edi++=AL ????

    ;------------------------------------------
    ; 2行目に8ドットの矩形
    ;------------------------------------------
    mov     edi, 1                          ; edi = 行数

    shl     edi, 8                          ; edi *= 256
    lea     edi, [edi * 4 + edi + 0xA_0000] ; edi = VRAMアドレス

    mov     [edi + (80 * 0)], word 0xFF
    mov     [edi + (80 * 1)], word 0xFF
    mov     [edi + (80 * 2)], word 0xFF
    mov     [edi + (80 * 3)], word 0xFF
    mov     [edi + (80 * 4)], word 0xFF
    mov     [edi + (80 * 5)], word 0xFF
    mov     [edi + (80 * 6)], word 0xFF
    mov     [edi + (80 * 7)], word 0xFF

    ;------------------------------------------
    ; 3行目に文字を描画
    ;------------------------------------------
    mov     esi, 'A'
    shl     esi, 4
    add     esi, [FONT_ADR]

    mov     edi, 2
    shl     edi, 8
    lea     edi, [edi * 4 + edi + 0xA_0000]

    mov     ecx, 16                         ; ecx = 16; // 1文字の高さ

.10L:
        movsb
        add edi, 80 - 1                     ; 1ドット分
        loop .10L
    ; -------------------------------
    ; 処理の終了
    ; -------------------------------    
    jmp     $                   ;  while(1); // 無限ループ

ALIGN 4, db 0
FONT_ADR: dd 0
;***********************************************************
;  パディング（このファイルは8Kバイトとする）
;***********************************************************
    times   BOOT_SIZE - ($ - $$) db 0   ; 8kバイトを0で埋める
