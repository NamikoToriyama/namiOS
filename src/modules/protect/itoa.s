itoa:
        ; ---------------------------------
        ; スタックフレームの構築
        ; ---------------------------------
        push    ebp                          ; BP+0|BP(元の値)
        mov     ebp, esp         

        ; ---------------------------------
        ; レジスタの保存
        ; ---------------------------------
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        ; ---------------------------------
        ; 引数の取得
        ; ---------------------------------
        mov     eax, [ebp + 8]                ; val = 数値
        mov     esi, [ebp + 12]                ; dst = バッファアドレス
        mov     ecx, [ebp + 16]                ; size = 残りのバッファサイズ

        mov     edi, esi                      ; // バッファの最後尾
        add     edi, ecx                      ; dst = &dst[size - 1]
        dec     edi                          ;

        mov     ebx, [ebp + 24]          ; flags = オプション

        ; ---------------------------------
        ; 符号付き判定
        ; --------------------------------- 
        test    ebx, 0b0001                  ; if(flags & 0x01) // 符号付き
.10Q:   je     .10E                         ;
        cmp     eax, 0                       ;   if (val < 0)
.12Q:   jge     .12E                        ;
        or      ebx, 0b0010                  ;       flags |= 2; // 符号表示
.12E:
.10E:

        ; ---------------------------------
        ; 符号出力判定
        ; --------------------------------- 
        test    ebx, 0b0010                  ; if(flags & 0x02) // 符号付き
.20Q:   je     .20E                         ;
        cmp     eax, 0                       ;   if (val < 0)
.22Q:   jge     .22F                        ;   else -> 22F
        neg     eax                          ;   val *= -1;
        mov     [esi], byte '-'              ;   *dst = '-'
        jmp     .22E
.22F:
        mov     [esi], byte '+'              ;   
.22E:
        dec     ecx
.20E:

        ; ---------------------------------
        ; ASCII 変換
        ; --------------------------------- 
        mov     ebx, [ebp + 20]               ; BX = 基数;
.30L:
        mov     edx, 0
        div     ebx

        mov     esi, edx
        mov     dl, byte [.ascii + esi]

        mov     [edi], dl
        dec     edi

        cmp     ax, 0
        loopnz  .30L
    
.30E:
        ; ---------------------------------
        ; 空欄を埋める
        ; --------------------------------- 
        cmp     ecx, 0
.40Q:   je      .40E
        mov     al, ' '
        cmp     [ebp + 24], word 0b0100
.42Q:   jne     .42E
        mov     al, '0'
.42E:
        std
        rep     stosb
.40E:

        ; ---------------------------------
        ; レジスタの復帰
        ; ---------------------------------
        pop    edi
        pop    esi
        pop    edx
        pop    ecx
        pop    ebx
        pop    eax

        ; ---------------------------------
        ; スタックフレームの破棄
        ; ---------------------------------
        mov     esp, ebp
        pop     ebp

        ret

.ascii  db      "0123456789ABCDEF"          ; 変換テーブル
