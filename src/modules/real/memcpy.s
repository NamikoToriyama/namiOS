;************************************************************************
;	メモリのコピー
;========================================================================
;■書式		: void memcpy(dst, src, size);
;
;■引数
;	dst		: コピー先
;	src		: コピー元
;	size	: バイト数
;
;■戻り値	: 無し
;************************************************************************
memcpy:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												;  BP+ 8| バイト数
												;  BP+ 6| コピー元
												;  BP+ 4| コピー先
												; ------|--------
		push	bp								;  BP+ 2| IP（戻り番地）
		mov		bp, sp							;  BP+ 0| BP（元の値）
												; ------+--------
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	cx
		push	si
		push	di

		;---------------------------------------
		; コピー方向を決定
		;---------------------------------------
		cld										; DF = 0; // +方向
		mov		di, [bp + 4]					; DI = コピー先;
		mov		si, [bp + 6]					; SI = コピー元;
		mov		cx, [bp + 8]					; CX = バイト数;

		;---------------------------------------
		; バイト単位でのコピー
		;---------------------------------------
		rep movsb								; while (*DI++ = *SI++) ;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		di
		pop		si
		pop		cx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		sp, bp
		pop		bp

		ret

