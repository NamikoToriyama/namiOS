; *******************************
; マクロ
; *******************************
%include    "../include/define.s"
%include    "../include/macro.s"

    ORG     BOOT_LOAD               ; ロードアドレスをアセンブラに指示

; *******************************
; エントリポイント
; *******************************
entry:
; -------------------------------
; BPB(BIOS Parameter Block)
; -------------------------------
    jmp     ipl                     ;  iplへジャンプ
    times   90 - ($ - $$) db 0x90   ; 92バイトを0x90で埋める
; -------------------------------
; IPL(inital Program Loder)
; -------------------------------
ipl:
    cli                         ; 割り込み禁止

    mov     ax, 0x0000          ; AX = 0x0000
    mov     ds, ax              ; セグメントレジスタにaxレジスタの値を代入
    mov     es, ax
    mov     ss, ax
    mov     sp, BOOT_LOAD       ; SP = 0x7c00

    sti                         ; 割り込み許可

    mov     [BOOT  + drive.no], dl    ; ブートドライブを保存

    ; -------------------------------
    ; 文字の表示
    ; -------------------------------
    cdecl   puts, .s0 

    ; -------------------------------
    ; 残りのセクタを全て読み込む
    ; -------------------------------   
    mov     bx, BOOT_SECT - 1           ; BX = 残りのブートセクタすう
    mov     cx, BOOT_LOAD + SECT_SIZE   ; CX = 次のロードアドレス

    cdecl   read_chs, BOOT, bx, cx      ; AX = read_chs(.chs, bx, cx)

    cmp     ax, bx                     ; if(ax != bx(残りの亜wクラウう))
.10Q:   
    jz     .10E                    ; jz = !=を確認
.10T:   
    cdecl   puts, .e0
    call    reboot                      ; 再起動
.10E:
    ; -------------------------------
    ; 次のステージへ移行
    ; ------------------------------- 
    jmp     stage_2  

    ; -------------------------------
    ; データ
    ; ------------------------------- 
.s0 db  "Booting NamiOS ...", 0x0A, 0x0D, 0
.e0 db  "Error: sector read", 0

ALIGN 2, db 0
BOOT:                               ; ブートドライブに関する情報
    istruc drive
        at drive.no,   dw 0        ; ドライブ番号
        at drive.cyln, dw 0        ; C: シリンダ
        at drive.head, dw 0        ; H: ヘッド
        at drive.sect, dw 2        ; S: セクタ
    iend

%include    "../modules/real/puts.s"
%include    "../modules/real/reboot.s"
%include    "../modules/real/read_chs.s"

; *******************************
; ブートフラグ(先頭512バイトの終了)
; *******************************
    times   510 - ($ - $$) db 0x00 ; 512バイトを0で埋める // ブートプログラムやOSが参照する情報が書き込まれていることがある
    db      0x55, 0xAA ; ブートフラグの条件 p393

; *******************************
; リアルモード時に取得した情報
; *******************************
FONT:
.seg:   dw  0
.off:   dw  0
ACPI_DATA:
.adr:   dd  0
.len:   dd  0

%include    "../modules/real/itoa.s"
%include    "../modules/real/get_drive_param.s"
%include    "../modules/real/get_font_adr.s"
%include    "../modules/real/get_mem_info.s"

; *******************************
; ブート処理の第二ステージ
; *******************************
stage_2:
    ; -------------------------------
    ; 文字の表示
    ; -------------------------------
    cdecl   puts, .s0 

    ; -------------------------------
    ; ドライブ情報を取得
    ; -------------------------------
    cdecl   get_drive_param, BOOT   ;
    cmp     ax, 0                   ; if(0 == AX)
.10Q:   jne     .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:

    ; -------------------------------
    ; ドライブ情報を表示
    ; -------------------------------
    mov     ax, [BOOT + drive.no]           ; AX = ブートドライブ // no
    cdecl   itoa, ax, .p1, 2, 16, 0x0100    ;
    mov     ax, [BOOT + drive.cyln]         ; シリンダー数
    cdecl   itoa, ax, .p2, 4, 16, 0x0100    ;
    mov     ax, [BOOT + drive.head]         ; ヘッド数
    cdecl   itoa, ax, .p3, 2, 16, 0x0100    ; 
    mov     ax, [BOOT + drive.sect]
    cdecl   itoa, ax, .p4, 2, 16, 0x0100    ;
    cdecl   puts, .s1

    ; -------------------------------
    ; 次のステージへ移行
    ; ------------------------------- 
    jmp     stage_3rd

    ;------------------------------------------
    ; データ
    ;------------------------------------------
.s0     db "2nd stage...", 0x0A, 0x0D, 0
.s1     db " Drive:0x"
.p1     db "  , C:0x"
.p2     db "    , H:0x"
.p3     db "  , S:0x"
.p4     db "  ", 0x0A, 0x0D, 0
.e0     db "Can't get drive parameter.", 0

; *******************************
; ブート処理の第三ステージ
; *******************************
stage_3rd:
    ; -------------------------------
    ; 文字の表示
    ; -------------------------------
    cdecl   puts, .s0 

    ; -------------------------------
    ; プロテクトモードで使用するフォントは、BIOSに内蔵されたものを使用する
    ; -------------------------------
    cdecl   get_font_adr, FONT

    ; -------------------------------
    ; フォントアドレスの表示
    ; -------------------------------
    cdecl   itoa, word [FONT.seg], .p1, 4, 16, 0b0100
    cdecl   itoa, word [FONT.off], .p2, 4, 16, 0b0100
    cdecl   puts, .s1

    ; -------------------------------
    ; メモリ情報の取得と表示
    ; -------------------------------   
    cdecl   get_mem_info, ACPI_DATA

    mov     eax, [ACPI_DATA.adr]
    cmp     eax, 0
    je      .10E

    cdecl   itoa, ax, .p4, 4, 16, 0b0100
    shr     eax, 16
    cdecl   itoa, ax, .p3, 4, 16, 0b0100
    cdecl   puts, .s2

.10E:

    ; -------------------------------
    ; 処理の終了
    ; -------------------------------    
    jmp     $                   ;  while(1); // 無限ループ

    ; -------------------------------
    ; データ
    ; -------------------------------
.s0     db "3rd stage...", 0x0A, 0x0D, 0
.s1     db " Font Address="
.p1     db "ZZZZ:"
.p2     db "ZZZZ:", 0x0A, 0x0D, 0
        db  0x0A, 0x0D, 0

.s2     db  " ACPI data="
.p3     db  "ZZZZ"
.p4     db  "ZZZZ", 0x0A, 0x0D, 0

.e0     db " error",  0


;***********************************************************
;  パディング（このファイルは8Kバイトとする）
;***********************************************************
    times   BOOT_SIZE - ($ - $$) db 0   ; 8kバイトを0で埋める
