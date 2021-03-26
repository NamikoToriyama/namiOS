lba_chs:
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
        push    dx
        push    si
        push    di

        ; ---------------------------------
        ; 処理の開始
        ; ---------------------------------
        mov     si, [bp + 4]                ; SI = driveバッファ
        mov     di, [bp + 6]                ; DI = drv_chsバッファ


        mov al, [si + drive.head]
        mul byte [si + drive.sect]
        mov bx, ax

        mov dx, 0
        mov ax, [bp + 8]
        div bx

        mov [di + drive.cyln], ax

        mov ax, dx                          ; AX = 残り
        div byte [si + drive.sect]

        movzx dx, ah                        ; セクタ番号
        inc dx

        mov ah, 0x00                        ; AX = ヘッド位置

        mov [di + drive.head], ax           ; ヘッド位置をセット
        mov [di + drive.sect], dx           ; セクタ番号をセット

        ; ---------------------------------
        ; レジスタの復帰
        ; ---------------------------------
        pop    di
        pop    si
        pop    dx
        pop    bx
        pop    ax

        ; ---------------------------------
        ; スタックフレームの破棄
        ; ---------------------------------
        mov     sp, bp
        pop     bp

        ret
