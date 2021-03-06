;************************************************************************
;	電断処理を行う
;------------------------------------------------------------------------
;	電断処理に成功した場合、この関数は戻ってこない
;========================================================================
;■書式		: void power_off(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
power_off:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi

		;---------------------------------------
		; 電断開始メッセージ
		;---------------------------------------
		cdecl	draw_str, 25, 14, 0x020F, .s0	; draw_str();  // 電断開始メッセージ

		;---------------------------------------
		; ページングを無効化
		;---------------------------------------
		mov		eax, cr0						; // PGビットをクリア
		and		eax, 0x7FFF_FFFF				; CR0 &= ~PG;
		mov		cr0, eax						; 
		jmp		$ + 2							; FLUSH();

												; do
												; {
		;---------------------------------------
		; ACPIデータの確認
		;---------------------------------------
		mov		eax, [0x7C00 + 512 + 4]			;   EAX = ACPIアドレス;
		mov		ebx, [0x7C00 + 512 + 8]			;   EBX = 長さ;
		cmp		eax, 0							;   if (0 == EAX)
		je		.10E							;     break;

		;---------------------------------------
		; RSDTテーブルの検索 // ここから全ての情報をとる
		;---------------------------------------
		cdecl	acpi_find, eax, ebx, 'RSDT'		;	EAX = acpi_find('RSDT');
		cmp		eax, 0							;   if (0 == EAX)
		je		.10E							;     break;

		;---------------------------------------
		; FACPテーブルの検索 // 差分システムアドレスが保存されている
		;---------------------------------------
		cdecl	find_rsdt_entry, eax, 'FACP'	;   EAX = find_rsdt_entry('FACP')
		cmp		eax, 0							;   if (0 == EAX)
		je		.10E							;     break;

		mov		ebx, [eax + 40]					;   // DSDTアドレスの取得
		cmp		ebx, 0							;   if (0 == DSDT)
		je		.10E							;     break;

		;---------------------------------------
		; ACPIレジスタの保存
		;---------------------------------------
		mov		ecx, [eax + 64]					;   // ACPIレジスタの取得
		mov		[PM1a_CNT_BLK], ecx				;   PM1a_CNT_BLK = FACP.PM1a_CNT_BLK;

		mov		ecx, [eax + 68]					;   // ACPIレジスタの取得
		mov		[PM1b_CNT_BLK], ecx				;   PM1b_CNT_BLK = FACP.PM1b_CNT_BLK;

		;---------------------------------------
		; S5名前空間の検索
		;---------------------------------------
		mov		ecx, [ebx + 4]					;   ECX  = DSDT.Length; // データ長;
		sub		ecx, 36							;   ECX -= 36;          // テーブルヘッダ分減算
		add		ebx, 36							;   EBX += 36;          // テーブルヘッダ分加算
		cdecl	acpi_find, ebx, ecx, '_S5_'		;   EAX = acpi_find('_S5_');
		cmp		eax, 0							;   if (0 == EAX)
		je		.10E							;     break;

		;---------------------------------------
		; パッケージデータの取得
		;---------------------------------------
		add		eax, 4							;   EAX  = 先頭の要素;
		cdecl	acpi_package_value, eax			;   EAX = パッケージデータ;
		mov		[S5_PACKAGE], eax				;   S5_PACKAGE = EAX;

.10E:											; } while (0);

		;---------------------------------------
		; ページングを有効化
		;---------------------------------------
		mov		eax, cr0						; // PGビットをセット
		or		eax, (1 << 31)					; CR0 |= PG;
		mov		cr0, eax						; 
		jmp		$ + 2							; FLUSH();

												; do
												; {
		;---------------------------------------
		; ACPIレジスタの取得
		;---------------------------------------
		mov		edx, [PM1a_CNT_BLK]				;   EDX = FACP.PM1a_CNT_BLK
		cmp		edx, 0							;   if (0 == EDX)
		je		.20E							;     break;

		;---------------------------------------
		; カウントダウンの表示
		;---------------------------------------
		cdecl	draw_str, 38, 14, 0x020F, .s3	;   draw_str();  // カウントダウン...3
		cdecl	wait_tick, 1000
		cdecl	draw_str, 38, 14, 0x020F, .s2	;   draw_str();  // カウントダウン...2
		cdecl	wait_tick, 1000
		cdecl	draw_str, 38, 14, 0x020F, .s1	;   draw_str();  // カウントダウン...1
		cdecl	wait_tick, 1000

		;---------------------------------------
		; PM1a_CNT_BLKの設定
		;---------------------------------------
		movzx	ax, [S5_PACKAGE.0]				;   // PM1a_CNT_BLK
		shl		ax, 10							;   AX  = SLP_TYPx;
		or		ax, 1 << 13						;   AX |= SLP_EN;
		out		dx, ax							;   out(PM1a_CNT_BLK, AX);

		;---------------------------------------
		; PM1b_CNT_BLKの確認
		;---------------------------------------
		mov		edx, [PM1b_CNT_BLK]				;   EDX = FACP.PM1b_CNT_BLK
		cmp		edx, 0							;   if (0 == EDX)
		je		.20E							;     break;

		;---------------------------------------
		; PM1b_CNT_BLKの設定
		;---------------------------------------
		movzx	ax, [S5_PACKAGE.1]				;   // PM1b_CNT_BLK
		shl		ax, 10							;   AX  = SLP_TYPx;
		or		ax, 1 << 13						;   AX |= SLP_EN;
		out		dx, ax							;   out(PM1b_CNT_BLK, AX);

.20E:											; } while (0);

		;---------------------------------------
		; 電断待ち
		;---------------------------------------
		cdecl	wait_tick, 1000					; // 100[ms]ウェイト

		;---------------------------------------
		; 電断失敗メッセージ
		;---------------------------------------
		cdecl	draw_str, 38, 14, 0x020F, .s4	;         draw_str();  // 電断失敗メッセージ

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		esi
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		ret

.s0:	db	" Power off...   ", 0
.s1:	db	" 1", 0
.s2:	db	" 2", 0
.s3:	db	" 3", 0
.s4:	db	"NG", 0

ALIGN 4, db 0
PM1a_CNT_BLK:	dd	0
PM1b_CNT_BLK:	dd	0
S5_PACKAGE:
.0:				db	0
.1:				db	0
.2:				db	0
.3:				db	0

