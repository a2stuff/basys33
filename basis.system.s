;;; ============================================================
;;; BASIS.SYSTEM relay for DOS3.3.LAUNCHER
;;; ============================================================

        .setcpu "6502"

        .include "apple2.inc"
        .include "prodos.inc"

neworg          := $1000        ; Relocated to...
filename_buffer := $1800        ; Saved
filename_prefix := $1880        ; Unchanged
launcher_prefix := $1900        ; Potentially shortened
io_buf          := $1C00

sys_start_address := $2000
kMaxSysLength   = ($BF00 - sys_start_address)

        .org    sys_start_address

;;; ============================================================
;;; Interpeter protocol
;;; http://www.easy68k.com/paulrsm/6502/PDOS8TRM.HTM#5.1.5.1

        jmp     start
        .byte   $EE, $EE        ; signature
        .byte   65              ; pathname buffer length ($2005)
str_path:
        .res    65              ; pathname buffer ($2006)

.proc get_prefix_params1
param_count:    .byte   1
pathname:       .addr   filename_prefix
.endproc


.proc get_prefix_params2
param_count:    .byte   1
pathname:       .addr   launcher_prefix
.endproc

;;; ============================================================

start:

;;; Save filename
        ldx     str_path
:       lda     str_path,x
        sta     filename_buffer,x
        dex
        bpl     :-

;;; Save prefix
        MLI_CALL GET_PREFIX, get_prefix_params1
        MLI_CALL GET_PREFIX, get_prefix_params2

;;; Relocation to $1000 since launcher will overwrite us at $2000
        ldx     #reloc_end - reloc_start
:       lda     reloc_start-1,x
        sta     neworg-1,x
        dex
        bne     :-

        jmp     newstart

reloc_start:
        .org    neworg

launcher_filename:
        PASCAL_STRING "DOS3.3.LAUNCHER"

.proc get_file_info_params
param_count:    .byte   $A
pathname:       .addr   filename_buffer
access:         .byte   0
file_type:      .byte   0
aux_type:       .word   0
storage_type:   .byte   0
blocks_used:    .word   0
mod_date:       .word   0
mod_time:       .word   0
create_date:    .word   0
create_time:    .word   0
.endproc

.proc open_params
param_count:    .byte   3
path:           .addr   launcher_filename
buffer:         .addr   io_buf
ref_num:        .byte   0
.endproc

.proc read_params
param_count:    .byte   4
ref_num:        .byte   1
buffer:         .word   sys_start_address
request:        .word   kMaxSysLength
trans:          .word   0
.endproc

.proc close_params
param_count:    .byte   1
ref_num:        .byte   0
.endproc

.proc set_prefix_params
param_count:    .byte   1
pathname:       .addr   launcher_prefix
.endproc


newstart:

;;; Check file type is in $F1...$F4

        MLI_CALL GET_FILE_INFO, get_file_info_params
        bcs     quit
        lda     get_file_info_params::file_type
        cmp     #$F1
        bcc     quit
        cmp     #$F4+1
        bcs     quit

;;; Find DOS3.3.LAUNCHER

check_for_launcher:
        MLI_CALL OPEN, open_params
        beq     load_launcher
        ldy     launcher_prefix   ; Pop path segment.
:       lda     launcher_prefix,y
        cmp     #'/'
        beq     update_prefix
        dey
        cpy     #1
        bne     :-
        beq     quit            ; always

update_prefix:                  ; Update prefix and try again.
        dey
        sty     launcher_prefix
        MLI_CALL SET_PREFIX, set_prefix_params
        jmp     check_for_launcher

;;; Load launcher

load_launcher:
        lda     open_params::ref_num
        sta     read_params::ref_num
        MLI_CALL READ, read_params
        bcs     quit
        MLI_CALL CLOSE, close_params
        bcs     quit


;;; Populate startup pathname buffer

startup_buffer := $2006

        ;; Prefix
        ldx     filename_prefix
:       lda     filename_prefix,x
        sta     startup_buffer,x
        dex
        bpl     :-

        ;; Append filename
        ldx     filename_prefix
        inx
        ldy     #0
:       lda     filename_buffer+1,y
        sta     startup_buffer,x
        iny
        inx
        cpy     filename_buffer
        bne     :-

        dex
        stx     startup_buffer

;;; Invoke launcher
        jmp     sys_start_address

;;; In case of error, QUIT to ProDOS
quit:
        MLI_CALL QUIT, quit_params
        brk

.proc quit_params
param_count:    .byte   4
        .byte   0
        .word   0
        .byte   0
        .word   0
.endproc


        .org    reloc_start + * - neworg

reloc_end:
        .assert (reloc_end - reloc_start) < $100, error, "more than one page, oops"
