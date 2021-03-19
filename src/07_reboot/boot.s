    BOOT_LOAD   equ 0x7C00          ; ブートプログラムのロード位置

    ORG     BOOT_LOAD               ; ロードアドレスをアセンブラに指示

%include    "../include/macro.s"

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

    mov     [BOOT.DRIVE], dl    ; ブートドライブを保存

    ; -------------------------------
    ; 文字の表示
    ; -------------------------------
    cdecl   puts, .s0 
    cdecl   reboot                  ; 戻ってこない

    ; -------------------------------
    ; 数字の表示
    ; -------------------------------
    cdecl   itoa, 8086, .s1, 8, 10, 0b0001; "     8086" 
    cdecl   puts, .s1

    cdecl   itoa, 8086, .s1, 8, 10, 0b0011; "    +8086" 
    cdecl   puts, .s1

    cdecl   itoa, -8086, .s1, 8, 10, 0b0001; "    -8086"
    cdecl   puts, .s1

    cdecl   itoa, -8086, .s1, 8, 10, 0b0001; "    -8086" 
    cdecl   puts, .s1

    ; -------------------------------
    ; 処理の終了
    ; -------------------------------    
    jmp     $                   ;  while(1); // 無限ループ

    ; -------------------------------
    ; データ
    ; ------------------------------- 
.s0 db  "Booting NamiOS ...", 0x0A, 0x0D, 0
.s1 db  "--------", 0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:                           ; ブートドライブに関する情報
.DRIVE:     dw 0            ; ドライブ番号

%include    "../modules/real/puts.s"
%include    "../modules/real/itoa.s"
%include    "../modules/real/reboot.s"

; -------------------------------
; ブートフラグ(先頭512バイトの終了)
; -------------------------------
    times   510 - ($ - $$) db 0x00 ; 512バイトを0で埋める // ブートプログラムやOSが参照する情報が書き込まれていることがある
    db      0x55, 0xAA ; ブートフラグの条件 p393
