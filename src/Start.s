.text
.global _start
.extern _end
.extern Main

_start:
    b skip
    .word _end

skip:
    li sp, 0x4000
    la a0, _end
    bl ra, Main
    hlt
