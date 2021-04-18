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

    SP_TASK_0           equ     STACK_BASE + (STACK_SIZE * 1)
    SP_TASK_1           equ     STACK_BASE + (STACK_SIZE * 2)
    SP_TASK_2           equ     STACK_BASE + (STACK_SIZE * 3)
    SP_TASK_3           equ     STACK_BASE + (STACK_SIZE * 4)
