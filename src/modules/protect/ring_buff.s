;************************************************************************
;	リングバッファからデータを取得
;========================================================================
;■書式		: DWORD ring_rd(buff, data);
;
;■引数
;	buff	: リングバッファ
;	data	: 読み込んだデータの保存先アドレス
;
;■戻り値	: データあり(0以外)、データ無し(0)
;************************************************************************
ring_rd:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												;    +12| リングデータ
												;    + 8| データアドレス
												; ------|--------
												;    + 4| EIP（戻り番地）
		push	ebp								; EBP+ 0| EBP（元の値）
		mov		ebp, esp						; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	ebx
		push	esi
		push	edi

		;---------------------------------------
		; 引数を取得
		;---------------------------------------
		mov		esi, [ebp + 8]					; ESI = リングバッファ;
		mov		edi, [ebp +12]					; EDI = データアドレス;

		;---------------------------------------
		; 読み込み位置を確認
		;---------------------------------------
		mov		eax, 0							; EAX = 0;          // データ無し
		mov		ebx, [esi + ring_buff.rp]		; EBX = rp;         // 読み込み位置
		cmp		ebx, [esi + ring_buff.wp]		; if (EBX != wp)    // 書き込み位置と異なる
		je		.10E							; {
												;   
		mov		al, [esi + ring_buff.item + ebx] ;   AL = BUFF[rp]; // キーコードを保存
												;   
		mov		[edi], al						;   [EDI] = AL;     // データを保存
												;   
		inc		ebx								;   EBX++;          // 次の読み込み位置
		and		ebx, RING_INDEX_MASK			;   EBX &= 0x0F     // サイズの制限
		mov		[esi + ring_buff.rp], ebx		;   rp = EBX;       // 読み込み位置を保存
												;   
		mov		eax, 1							;   EAX = 1;        // データあり
.10E:											; }

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		edi
		pop		esi
		pop		ebx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

;************************************************************************
;	リングバッファにデータを格納
;========================================================================
;■書式		: DWORD ring_wr(buff, data);
;
;■引数
;	buff	: リングバッファ
;	data	: 書き込むデータ
;
;■戻り値	: 成功(0以外)、失敗(0)
;************************************************************************
ring_wr:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												;    +12| リングデータ
												;    + 8| データ
												; ------|--------
												;    + 4| EIP（戻り番地）
		push	ebp								; EBP+ 0| EBP（元の値）
		mov		ebp, esp						; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	ebx
		push	ecx
		push	esi

		;---------------------------------------
		; 引数を取得
		;---------------------------------------
		mov		esi, [ebp + 8]					; ESI = リングバッファ;

		;---------------------------------------
		; 書き込み位置を確認
		;---------------------------------------
		mov		eax, 0							; EAX  = 0;         // 失敗
		mov		ebx, [esi + ring_buff.wp]		; EBX  = wp;        // 書き込み位置
		mov		ecx, ebx						; ECX  = EBX;
		inc		ecx								; ECX++;            // 次の書き込み位置
		and		ecx, RING_INDEX_MASK			; ECX &= 0x0F       // サイズの制限
												; 
		cmp		ecx, [esi + ring_buff.rp]		; if (ECX != rp)    // 読み込み位置と異なる
		je		.10E							; {
												; 
		mov		al, [ebp +12]					;   AL = データ;
												; 
		mov		[esi + ring_buff.item + ebx], al ;   BUFF[wp] = AL; // キーコードを保存
		mov		[esi + ring_buff.wp], ecx		;   wp = ECX;       // 書き込み位置を保存
		mov		eax, 1							;   EAX = 1;        // 成功
.10E:											; }

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		esi
		pop		ecx
		pop		ebx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

;************************************************************************
;	リングバッファ内要素の表示
;========================================================================
;■書式		: void ring_show(col, row, buff);
;
;■引数
;	col		: 列
;	row		: 行
;	buff	: リングバッファ
;
;■戻り値	: 無し
;************************************************************************
draw_key:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												; EBP+16| リングバッファ
												; EBP+12| Y（行）
												; EBP+ 8| X（列）
												; ------|--------
		push	ebp								; EBP+ 4| EIP（戻り番地）
		mov		ebp, esp						; EBP+ 0| EBP（元の値）
												; ------|--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		pusha

		;---------------------------------------
		; 引数を取得
		;---------------------------------------
		mov		edx, [ebp + 8]					; EDX = X（列）;
		mov		edi, [ebp +12]					; EDI = Y（行）;
		mov		esi, [ebp +16]					; ESI = リングバッファ;

		;---------------------------------------
		; リングバッファの情報を取得
		;---------------------------------------
		mov		ebx, [esi + ring_buff.rp]		; EBX = rp;             // 読み込み位置
		lea		esi, [esi + ring_buff.item]		; ESI = &KEY_BUFF[EBX];
		mov		ecx, RING_ITEM_SIZE				; ECX = RING_ITEM_SIZE; // 要素数

		;---------------------------------------
		; 文字に変換しながら表示
		;---------------------------------------
.10L:											; do
												; {
		dec		ebx								;   EBX--; // 読み込み位置
		and		ebx, RING_INDEX_MASK			;   EBX &= RING_INDEX_MASK;
		mov		al, [esi + ebx]					;   EAX  = KEY_BUFF[EBX];
												;   
		cdecl	itoa, eax, .tmp, 2, 16, 0b0100	;   // キーコードを文字列に変換
		cdecl	draw_str, edx, edi, 0x02, .tmp	;   // 変換した文字列を表示
												;   
		add		edx, 3							;   // 表示位置を更新（3文字分）
												;   
		loop	.10L							;   
.10E:											; } while (ECX--);

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		popa

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

.tmp	db "-- ", 0
