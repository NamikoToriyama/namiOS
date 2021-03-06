%macro cdecl 1-*.nolist
    %rep %0 - 1
        push %{-1:-1}
        %rotate -1
    %endrep
    %rotate -1
        call %1
    %if 1 < %0
        add sp, (__BITS__ >> 3) * (%0 - 1)
    %endif
%endmacro

%macro  set_vect 1-*.nolist
		push	eax
		push	edi

		mov		edi, VECT_BASE + (%1 * 8)		; ベクタアドレス;
		mov		eax, %2

		%if 3 == %0
			mov		[edi + 4], %3					; フラグ
		%endif

		mov		[edi + 0], ax					; 例外アドレス[15: 0]
		shr		eax, 16							; 
		mov		[edi + 6], ax					; 例外アドレス[31:16]

		pop		edi
		pop		eax
%endmacro

; 割り込みコントローラ用
%macro  outp 2
		mov		al, %2
		out		%1, al
%endmacro

; ディスクリプタのベースとリミットを設定する処理
%macro	set_desc	2-*.nolist
		push	eax
		push	edi

		mov		edi, %1
		mov		eax, %2

	%if	3 == %0
		mov		[edi + 0], %3
	%endif

		mov		[edi + 2], ax
		shr		eax, 16
		mov		[edi + 4], al
		mov		[edi + 7], ah

		pop		edi
		pop		eax
%endmacro

; コールゲートに関数を登録する
%macro	set_gate	2-*.nolist
		push	eax
		push	edi

		mov		edi, %1			; ディスクリプタアドレス
		mov		eax, %2			; ベースアドレス

		mov		[edi + 0], ax	; ベース
		shr		eax, 16
		mov		[edi + 6], ax	; ベース

		pop		edi
		pop		eax
%endmacro


;-----------------------------------------------
;	構造体
;-----------------------------------------------
struc drive
    .no resw 1      ; ドライブ番号
    .cyln resw 1    ; シリンダ
    .head resw 1    ; ヘッド
    .sect resw 1    ; セクタ
endstruc

%define		RING_ITEM_SIZE		(1 << 4)
%define		RING_INDEX_MASK		(RING_ITEM_SIZE - 1)
; リングバッファ
struc	ring_buff
	.rp	resd	1						; 書き込み位置
	.wp		resd	1						; 読み込み位置
	.item	resb	RING_ITEM_SIZE			; バッファ
endstruc


;-----------------------------------------------
;	バラ曲線描画パラメータ
;-----------------------------------------------
struc rose
		.x0				resd	1				; 左上座標：X0
		.y0				resd	1				; 左上座標：Y0
		.x1				resd	1				; 右下座標：X1
		.y1				resd	1				; 右下座標：Y1

		.n				resd	1				; 変数：n
		.d				resd	1				; 変数：d

		.color_x		resd	1				; 描画色：X軸
		.color_y		resd	1				; 描画色：Y軸
		.color_z		resd	1				; 描画色：枠
		.color_s		resd	1				; 描画色：文字
		.color_f		resd	1				; 描画色：グラフ描画色
		.color_b		resd	1				; 描画色：グラフ消去色

		.title			resb	16				; タイトル
endstruc