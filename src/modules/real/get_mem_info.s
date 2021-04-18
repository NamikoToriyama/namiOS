;************************************************************************
;	メモリ情報の表示
;------------------------------------------------------------------------
;	ACPIデータのアドレスと長さをグローバル変数に保存する
;========================================================================
;■書式		: void get_mem_info(void);
;
;■引数		: 無し
;
;■戻り値;	: 無し
;************************************************************************
get_mem_info:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	si
		push	di
		push	bp

		;---------------------------------------
		; 【処理の開始】
		;---------------------------------------
		cdecl	puts, .s0						; // ヘッダを表示

		mov		bp, 0							; lines = 0; // 行数
		mov		ebx, 0							; index = 0; // インデックスを初期化
.10L:											; do
												; {
		mov		eax, 0x0000E820					;   EAX   = 0xE820
												;   EBX   = インデックス
		mov		ecx, E820_RECORD_SIZE			;   ECX   = 要求バイト数
		mov 	edx, 'PAMS'						;   EDX   = 'SMAP';
		mov		di, .b0							;   ES:DI = バッファ
		int		0x15							;   BIOS(0x15, 0xE820);

		; コマンドに対応か？
		cmp		eax, 'PAMS'						;   if ('SMAP' != EAX)
		je		.12E							;   {
		jmp		.10E							;     break; // コマンド未対応
.12E:											;   }

		; エラー無し？							;   if (CF)
		jnc		.14E							;   {
		jmp		.10E							;     break; // エラー発生
.14E:											;   }

		; 1レコード分のメモリ情報を表示
		cdecl	put_mem_info, di				;   1レコード分のメモリ情報を表示

		; ACPI dataのアドレスを取得
		mov		eax, [di + 16]					;   EAX = レコードタイプ;
		cmp		eax, 3							;   if (3 == EAX) // ACPI data
		jne		.15E							;   {
												;     
		mov		eax, [di +  0]					;     EAX   = BASEアドレス;
		mov		[ACPI_DATA.adr], eax			;     ACPI_DATA.adr = EAX;
												;     
		mov		eax, [di +  8]					;     EAX   = Length;
		mov		[ACPI_DATA.len], eax			;     ACPI_DATA.len = EAX;
.15E:											;   }

		cmp		ebx, 0							;   if (0 != EBX)
		jz		.16E							;   {
												;     
		inc		bp								;     lines++;
		and		bp, 0x07						;     lines &= 0x07;
		jnz		.16E							;     if (0 == lines)
												;     {
		cdecl	puts, .s2						;       // 中断メッセージを表示
												;       
		mov		ah, 0x10						;       // キー入力待ち
		int		0x16							;       AL = BIOS(0x16, 0x10);
												;       
		cdecl	puts, .s3						;       // 中断メッセージを消去
												;     }
.16E:											;   }
												;   
		cmp		ebx, 0							;   
		jne		.10L							; }
.10E:											; while (0 != EBX);

		cdecl	puts, .s1						; // フッダを表示

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		bp
		pop		di
		pop		si
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		ret

.s0:	db " E820 Memory Map:", 0x0A, 0x0D
		db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:	db " <more...>", 0
.s3:	db 0x0D, "          ", 0x0D, 0

ALIGN 4, db 0
.b0:	times E820_RECORD_SIZE db 0

;************************************************************************
;	メモリ情報の表示
;========================================================================
;■書式		: void put_mem_info(adr);
;
;■引数
;	adr		: メモリ情報を参照するアドレス
;
;■戻り値;	: 無し
;************************************************************************
put_mem_info:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												;    + 4| バッファアドレス
												;    + 2| IP（戻り番地）
		push	bp								;  BP+ 0| BP（元の値）
		mov		bp, sp							; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	bx
		push	si

		;---------------------------------------
		; 引数を取得
		;---------------------------------------
		mov		si, [bp + 4]					; SI = バッファアドレス;

		;---------------------------------------
		; レコードの表示
		;---------------------------------------

		; Base(64bit)
		cdecl	itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
		cdecl	itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

		; Length(64bit)
		cdecl	itoa, word [si +14], .p4 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si +12], .p4 + 4, 4, 16, 0b0100
		cdecl	itoa, word [si +10], .p5 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 8], .p5 + 4, 4, 16, 0b0100

		; Type(32bit)
		cdecl	itoa, word [si +18], .p6 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si +16], .p6 + 4, 4, 16, 0b0100

		cdecl	puts, .s1						;   // レコード情報を表示

		mov		bx, [si +16]					;   // タイプを文字列で表示
		and		bx, 0x07						;   BX  = Type(0〜5)
		shl		bx, 1							;   BX *= 2;   // 要素サイズに変換
		add		bx, .t0							;   BX += .t0; // テーブルの先頭アドレスを加算
		cdecl	puts, word [bx]					;   puts(*BX);

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		si
		pop		bx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		sp, bp
		pop		bp

		ret;

.s1:	db " "
.p2:	db "ZZZZZZZZ_"
.p3:	db "ZZZZZZZZ "
.p4:	db "ZZZZZZZZ_"
.p5:	db "ZZZZZZZZ "
.p6:	db "ZZZZZZZZ", 0

.s4:	db " (Unknown)", 0x0A, 0x0D, 0
.s5:	db " (usable)", 0x0A, 0x0D, 0
.s6:	db " (reserved)", 0x0A, 0x0D, 0
.s7:	db " (ACPI data)", 0x0A, 0x0D, 0
.s8:	db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:	db " (bad memory)", 0x0A, 0x0D, 0

.t0:	dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4

