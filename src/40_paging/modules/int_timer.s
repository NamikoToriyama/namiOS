int_timer:
        ; ---------------------------------
        ; レジスタの保存
        ; ---------------------------------
        pushad
        push    ds
        push    es

        ; ---------------------------------
        ; データ用セグメントの設定
        ; ---------------------------------
        mov     ax, 0x0010
        mov     ds, ax
        mov     es, ax
        
        ; ---------------------------------
        ; TICK
        ; ---------------------------------
        inc      dword[TIMER_COUNT]         ; TIMER_COUNT++ // 割り込み回数の更新

        ; ---------------------------------
        ; 割り込みフラグをクリア
        ; ---------------------------------
        outp    0x20, 0x20                  ; outp(); // マスタPIC:EDIコマンド

        ; ---------------------------------
        ; タスクの切り替え
        ; ---------------------------------
        str		ax		    ; AX = TR; // 現在のタスクレジスタ
        cmp		ax, SS_TASK_0	    ; case (AX)
        je		.11L		    ; {
        cmp		ax, SS_TASK_1	    ; case (AX)
        je		.12L
        cmp		ax, SS_TASK_2	    ; case (AX)
        je		.13L
        jmp		SS_TASK_0:0         ;     // タスク0に切り替え
        jmp		.10E	            ;     break;
                                            ;     
.11L:					    ;   case SS_TASK_0:
        jmp		SS_TASK_1:0	    ;     // タスク1に切り替え
        jmp		.10E		    ;     break;
.12L:					    ;   case SS_TASK_1:
        jmp		SS_TASK_2:0	    ;     // タスク2に切り替え
        jmp		.10E		    ;     break;
.13L:					    ;   case SS_TASK_2:
        jmp		SS_TASK_3:0	    ;     // タスク3に切り替え
        jmp		.10E		    ;     break;
.10E:					    ; }

        ; ---------------------------------
        ; レジスタの復帰
        ; ---------------------------------
        pop     es
        pop     ds
        popad

        iret

ALIGN   4, db 0
TIMER_COUNT: dq 0