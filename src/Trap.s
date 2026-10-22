.text
.global TrapEntry
.global InitializeTraps
.global EnableInterrupts
.global DisableInterrupts
.global SetInterruptMask
.extern HandleTrap

TrapEntry:
    addi sp, sp, -80
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw t3, 16(sp)
    sw t4, 20(sp)
    sw t5, 24(sp)
    sw t6, 28(sp)
    sw a0, 32(sp)
    sw a1, 36(sp)
    sw a2, 40(sp)
    sw a3, 44(sp)
    sw a4, 48(sp)
    sw a5, 52(sp)
    sw a6, 56(sp)
    sw a7, 60(sp)

    csrr a0, cause
    bl ra, HandleTrap

    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw t3, 16(sp)
    lw t4, 20(sp)
    lw t5, 24(sp)
    lw t6, 28(sp)
    lw a0, 32(sp)
    lw a1, 36(sp)
    lw a2, 40(sp)
    lw a3, 44(sp)
    lw a4, 48(sp)
    lw a5, 52(sp)
    lw a6, 56(sp)
    lw a7, 60(sp)
    addi sp, sp, 80
    eret

InitializeTraps:
    la t0, TrapEntry
    csrw vector, t0
    br ra

EnableInterrupts:
    csrr t0, status
    ori t0, t0, 1
    csrw status, t0
    br ra

DisableInterrupts:
    csrr t0, status
    andi t0, t0, 0xFFFE
    csrw status, t0
    br ra

SetInterruptMask:
    csrw ienable, a0
    br ra
