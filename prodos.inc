;;; ------------------------------------------------------------
;;; ProDOS MLI
;;; ------------------------------------------------------------

;;; ------------------------------------------------------------
;;; ProDOS Global Page

MLI             := $BF00        ; Entry point
DEVNUM          := $BF30        ; Most recent accessed device
DEVCNT          := $BF31        ; Number of on-line devices minus 1
DEVLST          := $BF32        ; Up to 14 units
BITMAP          := $BF58
BITMAP_SIZE     := $18          ; Bits for pages $00 to $BF
DATELO          := $BF90        ; Date lo
DATEHI          := $BF91        ; Date hi
TIMELO          := $BF92        ; Time lo
TIMEHI          := $BF93        ; Time hi


;;; ------------------------------------------------------------
;;; MLI Calls

;;; Housekeeping Calls
CREATE          := $C0
DESTROY         := $C1
RENAME          := $C2
SET_FILE_INFO   := $C3
GET_FILE_INFO   := $C4
ON_LINE         := $C5
SET_PREFIX      := $C6
GET_PREFIX      := $C7

;;; Filing Calls
OPEN            := $C8
NEWLINE         := $C9
READ            := $CA
WRITE           := $CB
CLOSE           := $CC
FLUSH           := $CD
SET_MARK        := $CE
GET_MARK        := $CF
SET_EOF         := $D0
GET_EOF         := $D1
SET_BUF         := $D2
GET_BUF         := $D3

;;; System Calls
GET_TIME        := $82
ALLOC_INTERRUPT := $40
DEALLOC_INTERRUPT       := $41
QUIT            := $65


;;; ------------------------------------------------------------
;;; Macros

.macro MLI_CALL    op, addr
        jsr     MLI
        .byte   op
        .addr   addr
.endmacro

.macro PASCAL_STRING str,res
        .local data
        .local end
        .byte   end - data
data:   .byte   str
end:
.endmacro
