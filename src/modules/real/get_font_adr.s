get_font_adr:
        ; ---------------------------------
        ; スタックフレームの構築
        ; ---------------------------------
                                            ; +4|パラメータバッファ
                                            ; +2|IP(戻り番地)
        push    bp                          ; BP+0|BP(元の値)
        mov     bp, sp         

        ; ---------------------------------
        ; レジスタの保存
        ; ---------------------------------
        push    ax
        push    bx
        push    si
        push    es
        push    bp

        ; ---------------------------------
        ; 引数の取得
        ; ---------------------------------
        mov     si, [bp + 4]                ; dst = FONTアドレスの保存先

        ; ---------------------------------
        ; フォントアドレスの取得
        ; ---------------------------------
        mov     ax, 0x1130                  ; フォントアドレスを取得する
        mov     bh, 0x06                    ; 8x16 font
        int     10h

        ; ---------------------------------
        ; フォントアドレスを保存
        ; ---------------------------------
        mov     [si + 0], es                ; dst[0] = セグメント;
        mov     [si + 2], bp                ; dst[1] = オフセット;

        ; ---------------------------------
        ; レジスタの復帰
        ; ---------------------------------
        pop    bp
        pop    es
        pop    si
        pop    bx
        pop    ax

        ; ---------------------------------
        ; スタックフレームの破棄
        ; ---------------------------------
        mov     sp, bp
        pop     bp

        ret