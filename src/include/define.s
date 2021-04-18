    BOOT_SIZE           equ     (1024*8)                ; ブートプログラムのロードサイズ
    KERNEL_SIZE         equ     (1024*8)

    BOOT_LOAD           equ     0x7C00                  ; ブートプログラムのロード位置
    BOOT_END            equ     (BOOT_LOAD + BOOT_SIZE) 

    SECT_SIZE           equ     (512)                   ; セクタサイズ
    BOOT_SECT           equ     (BOOT_SIZE/SECT_SIZE)   ; ブートプログラムのセクタ数
    KERNEL_SECT         equ      (KERNEL_SIZE/SECT_SIZE)

    E820_RECORD_SIZE    equ     20                      ; メモリ情報を格納する領域のサイズ
    KERNEL_LOAD         equ     0x0010_1000

    VECT_BASE           equ     0x0010_0000

    STACK_BASE          equ     0x0010_3000             ; タスク用スタックエリア
    STACK_SIZE          equ     1024                    ; スタックサイズ

    SP_TASK_0			equ		STACK_BASE + (STACK_SIZE * 1)
    SP_TASK_1			equ		STACK_BASE + (STACK_SIZE * 2)
    SP_TASK_2			equ		STACK_BASE + (STACK_SIZE * 3)
    SP_TASK_3			equ		STACK_BASE + (STACK_SIZE * 4)
    SP_TASK_4			equ		STACK_BASE + (STACK_SIZE * 5)
    SP_TASK_5			equ		STACK_BASE + (STACK_SIZE * 6)
    SP_TASK_6			equ		STACK_BASE + (STACK_SIZE * 7)

    CR3_BASE			equ		0x0010_5000		; ページ変換テーブル：タスク3用

    PARAM_TASK_4		equ		0x0010_8000		; 描画パラメータ：タスク4用
    PARAM_TASK_5		equ		0x0010_9000		; 描画パラメータ：タスク5用
    PARAM_TASK_6		equ		0x0010_A000		; 描画パラメータ：タスク6用

    CR3_TASK_4			equ		0x0020_0000		; ページ変換テーブル：タスク4用
    CR3_TASK_5			equ		0x0020_2000		; ページ変換テーブル：タスク5用
    CR3_TASK_6			equ		0x0020_4000		; ページ変換テーブル：タスク6用
    
    ATTR_VOLUME_ID      equ     0x08
    ATTR_DIRECTORY      equ     0x10
    ATTR_ARCHIVE        equ     0x20