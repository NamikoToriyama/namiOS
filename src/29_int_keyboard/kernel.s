;************************************************************************
;
;	カーネル部
;
;************************************************************************

;************************************************************************
;	マクロ
;************************************************************************
%include	"../include/define.s"
%include	"../include/macro.s"

		ORG		KERNEL_LOAD						; カーネルのロードアドレス

[BITS 32]
;************************************************************************
;	エントリポイント
;************************************************************************
kernel:
		;---------------------------------------
		; フォントアドレスを取得
		;---------------------------------------
		mov		esi, BOOT_LOAD + SECT_SIZE		; ESI   = 0x7C00 + 512
		movzx	eax, word [esi + 0]				; EAX   = [ESI + 0] // セグメント
		movzx	ebx, word [esi + 2]				; EBX   = [ESI + 2] // オフセット
		shl		eax, 4							; EAX <<= 4;
		add		eax, ebx						; EAX  += EBX;
		mov		[FONT_ADR], eax					; FONT_ADR[0] = EAX;

		;---------------------------------------
		; 初期化
		;---------------------------------------
		cdecl	init_int						; // 割り込みベクタの初期化
		cdecl	init_pic						; // 割り込みコントローラの初期化

		set_vect	0x00, int_zero_div			; // 割り込み処理の登録：0除算
		set_vect	0x21, int_keyboard			; // 割り込み処理の登録：KBC
		set_vect	0x28, int_rtc				; // 割り込み処理の登録：RTC

		;---------------------------------------
		; デバイスの割り込み許可
		;---------------------------------------
		cdecl	rtc_int_en, 0x10				; rtc_int_en(UIE); // 更新サイクル終了割り込み許可

		;---------------------------------------
		; IMR(割り込みマスクレジスタ)の設定
		;---------------------------------------
		outp	0x21, 0b_1111_1001				; // 割り込み有効：スレーブPIC/KBC
		outp	0xA1, 0b_1111_1110				; // 割り込み有効：RTC

		;---------------------------------------
		; CPUの割り込み許可
		;---------------------------------------
		sti										; // 割り込み許可

		;---------------------------------------
		; フォントの一覧表示
		;---------------------------------------
		cdecl	draw_font, 63, 13				; // フォントの一覧表示
		cdecl	draw_color_bar, 63, 4			; // カラーバーの表示

		;---------------------------------------
		; 文字列の表示
		;---------------------------------------
		cdecl	draw_str, 25, 14, 0x010F, .s0	; draw_str();

.10L:											; while (;;)
												; {
		;---------------------------------------
		; 時刻の表示
		;---------------------------------------
		mov		eax, [RTC_TIME]					;   // 時刻の取得
		cdecl	draw_time, 72, 0, 0x0700, eax	;   // 時刻の表示

		;---------------------------------------
		; キーコードの取得
		;---------------------------------------
		cdecl	ring_rd, _KEY_BUFF, .int_key	;   EAX = ring_rd(buff, &int_key);
		cmp		eax, 0							;   if (EAX == 0)
		je		.10E							;   {
												;   
		;---------------------------------------
		; キーコードの表示
		;---------------------------------------
		cdecl	draw_key, 2, 29, _KEY_BUFF		;     ring_show(key_buff); // 全要素を表示
.10E:											;   }
		jmp		.10L							; }

.s0:	db	" Hello, kernel! ", 0

ALIGN 4, db 0
.int_key:	dd	0

ALIGN 4, db 0
FONT_ADR:	dd	0
RTC_TIME:	dd	0

;************************************************************************
;	モジュール
;************************************************************************
%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"
%include	"../modules/protect/draw_color_bar.s"
%include	"../modules/protect/draw_pixel.s"
%include	"../modules/protect/draw_line.s"
%include	"../modules/protect/draw_rect.s"
%include	"../modules/protect/itoa.s"
%include	"../modules/protect/rtc.s"
%include	"../modules/protect/draw_time.s"
%include	"../modules/protect/interrupt.s"
%include	"../modules/protect/pic.s"
%include	"../modules/protect/int_rtc.s"
%include	"../modules/protect/int_keyboard.s"
%include	"../modules/protect/ring_buff.s"

;************************************************************************
;	パディング
;************************************************************************
		times KERNEL_SIZE - ($ - $$) db 0x00	; パディング

