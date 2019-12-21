        .setcpu "6502"

        .include "opcodes.inc"
        .include "apple2.inc"
        .include "../a2d/inc/macros.inc"
        .include "../a2d/inc/apple2.inc"
        .include "../a2d/inc/prodos.inc"


        ;; System files start at $2000
        .org    $2000
        reloc = $1000

;;; Relocate down to $1000
        copy16  #rel_start, STARTLO
        copy16  #rel_end, ENDLO
        copy16  #reloc, DESTINATIONLO
        ldy     #0
        jsr     MOVE
        jmp     reloc


;;; Relocated routine
rel_start:
        .pushorg reloc
        jmp     run

fn:     PASCAL_STRING "LAUNCHER.SYSTEM"
prefix: PASCAL_STRING "/TOTAL.REPLAY"

        DEFINE_SET_PREFIX_PARAMS set_prefix_params, prefix
        DEFINE_OPEN_PARAMS open_params, fn, $1C00
        DEFINE_READ_PARAMS read_params, $2000, $BEFF-$2000
        DEFINE_CLOSE_PARAMS close_params

        DEFINE_QUIT_PARAMS quit_params
run:
        MLI_CALL SET_PREFIX, set_prefix_params
        bcs     quit
        MLI_CALL OPEN, open_params
        bcs     quit
        lda     open_params::ref_num
        sta     read_params::ref_num
        sta     close_params::ref_num
        MLI_CALL READ, read_params
        bcs     quit
        MLI_CALL CLOSE, close_params

        ;; Disable ProDOS realtime clock
        lda     MACHID
        and     #%11111110
        sta     MACHID
        lda     #OPC_RTS
        sta     DATETIME

        jmp     $2000

quit:   MLI_CALL QUIT, quit_params

        .poporg
rel_end:
