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
    ; 文字の表示
    ; -------------------------------
    cdecl   draw_char, 0, 0, 0x010F, 'A'
    cdecl   draw_char, 1, 0, 0x010F, 'B'
    cdecl   draw_char, 2, 0, 0x010F, 'C'

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
    ; 文字列を表示
    ;------------------------------------------
    cdecl   draw_str, 25, 14, 0x010F, .s0   ; draw_str()

    cdecl   draw_font, 63, 13               ; フォントの一覧表示
    cdecl   draw_color_bar, 63, 4           ; カラーバーの表示

.10L:
        movsb
        add edi, 80 - 1                     ; 1ドット分
        loop .10L

.s0     db  "Hello! NamiOS!", 0

    ; -------------------------------
    ; 処理の終了
    ; -------------------------------    
    jmp     $                   ;  while(1); // 無限ループ

ALIGN 4, db 0
FONT_ADR: dd 0

;***********************************************************
;  モジュール
;***********************************************************
%include    "../modules/protect/vga.s"
%include    "../modules/protect/draw_char.s"
%include    "../modules/protect/draw_font.s"
%include    "../modules/protect/draw_str.s"
%include    "../modules/protect/draw_color_bar.s"
;***********************************************************
;  パディング（このファイルは8Kバイトとする）
;***********************************************************
    times   BOOT_SIZE - ($ - $$) db 0   ; 8kバイトを0で埋める
