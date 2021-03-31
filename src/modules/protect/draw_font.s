draw_font:
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
        push edi

        ;-----------------------------------------
        ; 基準となる位置をレジスタに保存
        ;-----------------------------------------
        mov esi, [ebp + 8]
        mov edi, [ebp + 12]

        ;-----------------------------------------
        ; フォントを一覧表示する
        ;-----------------------------------------
        mov ecx, 0                                  ; ecx = 0
.10L:
        cmp ecx, 256                                ; ecx < 256
        jae .10E

        mov eax, ecx                                ; ecxの文字コード（？）的なのを書き込むように変数に退避する
        and eax, 0x0F
        add eax, esi

        mov ebx, ecx
        shr ebx, 4
        add ebx, edi

        cdecl draw_char, eax, ebx, 0x07, ecx

        inc ecx                                      ; ecx++
        jmp .10L
.10E:

        ;-----------------------------------------
        ; 【レジスタの復帰】
        ;-----------------------------------------
        pop edi
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