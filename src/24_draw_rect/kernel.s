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

    ;------------------------------------------
    ; 文字列を表示
    ;------------------------------------------
    cdecl   draw_str, 25, 14, 0x010F, .s0   ; draw_str()

    cdecl   draw_font, 63, 13               ; フォントの一覧表示
    cdecl   draw_color_bar, 63, 4           ; カラーバーの表示

    ;------------------------------------------
    ; 線を描画
    ;------------------------------------------
    cdecl draw_rect, 100, 100, 200, 200, 0x02     ; 緑
    cdecl draw_rect, 400, 400, 200, 200, 0x03   ; 青
    cdecl draw_rect, 300, 150, 200, 300, 0x04 ; 赤
    cdecl draw_rect, 100, 400, 0, 200, 0x0F   ; 白？


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
%include    "../modules/protect/draw_pixel.s"
%include    "../modules/protect/draw_line.s"
%include    "../modules/protect/draw_rect.s"

;***********************************************************
;  パディング（このファイルは8Kバイトとする）
;***********************************************************
    times   BOOT_SIZE - ($ - $$) db 0   ; 8kバイトを0で埋める
