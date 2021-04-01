draw_rect:
        ;-----------------------------------------
        ; 【スタックフレームの構築】
        ;-----------------------------------------
        push ebp
        mov ebp, esp

        ;-----------------------------------------
        ; 【レジスタの保存】
        ;-----------------------------------------
        push eax
        push ebx
        push ecx
        push edx
        push esi

        ;-----------------------------------------
        ; 引数の取得
        ;-----------------------------------------
        mov eax, [ebp + 8]                          ; x0
        mov ebx, [ebp + 12]                         ; y0
        mov ecx, [ebp + 16]                         ; x1
        mov edx, [ebp + 20]                         ; y1
        mov esi, [ebp + 24]                         ; color

        ;-----------------------------------------
        ; 座標軸の大小を確定
        ;-----------------------------------------
        cmp eax, ecx                                ; if(x1 < x0)
        jl .10E
        xchg eax, ecx                               ; swap(x0, x1)
.10E:
        cmp ebx, edx
        jl .20E
        xchg ebx, edx
.20E:

        ;-----------------------------------------
        ; 矩形を描画
        ;-----------------------------------------
        cdecl draw_line, eax, ebx, ecx, ebx, esi    ; 上線
        cdecl draw_line, eax, ebx, eax, edx, esi    ; 左線

        dec edx
        cdecl draw_line, eax, edx, ecx, edx, esi    ; 下線 引きすぎなので1ドット上げる
        inc edx

        dec ecx
        cdecl draw_line, ecx, ebx, ecx, edx, esi    ; 右線 1ドット左に

        ;-----------------------------------------
        ; 【レジスタの復帰】
        ;-----------------------------------------
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax

        ;-----------------------------------------
        ; 【スタックフレームの破棄】
        ;-----------------------------------------
        mov esp, ebp
        pop ebp

        ret
