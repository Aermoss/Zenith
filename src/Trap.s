.text
.global TrapEntry
.global Yield
.global InitializeTraps
.global EnableInterrupts
.global DisableInterrupts
.global RestoreInterrupts
.global SetInterruptMask
.extern HandleTrap
.extern Schedule

TrapEntry:
    addi sp, sp, -152
    sw ra, 4(sp)
    sw gp, 12(sp)
    sw tp, 16(sp)
    sw fp, 20(sp)
    sw s1, 24(sp)
    sw s2, 28(sp)
    sw s3, 32(sp)
    sw s4, 36(sp)
    sw s5, 40(sp)
    sw s6, 44(sp)
    sw s7, 48(sp)
    sw s8, 52(sp)
    sw s9, 56(sp)
    sw s10, 60(sp)
    sw s11, 64(sp)
    sw t0, 68(sp)
    sw t1, 72(sp)
    sw t2, 76(sp)
    sw t3, 80(sp)
    sw t4, 84(sp)
    sw t5, 88(sp)
    sw t6, 92(sp)
    sw a0, 96(sp)
    sw a1, 100(sp)
    sw a2, 104(sp)
    sw a3, 108(sp)
    sw a4, 112(sp)
    sw a5, 116(sp)
    sw a6, 120(sp)
    sw a7, 124(sp)
    csrr t0, epc
    sw t0, 0(sp)
    csrr t0, status
    sw t0, 128(sp)

    csrr a0, cause
    mv a1, sp
    bl ra, HandleTrap
    mv sp, a0

RestoreContext:
    lw t0, 0(sp)
    csrw epc, t0
    lw t0, 128(sp)
    csrw status, t0
    lw ra, 4(sp)
    lw gp, 12(sp)
    lw tp, 16(sp)
    lw fp, 20(sp)
    lw s1, 24(sp)
    lw s2, 28(sp)
    lw s3, 32(sp)
    lw s4, 36(sp)
    lw s5, 40(sp)
    lw s6, 44(sp)
    lw s7, 48(sp)
    lw s8, 52(sp)
    lw s9, 56(sp)
    lw s10, 60(sp)
    lw s11, 64(sp)
    lw t0, 68(sp)
    lw t1, 72(sp)
    lw t2, 76(sp)
    lw t3, 80(sp)
    lw t4, 84(sp)
    lw t5, 88(sp)
    lw t6, 92(sp)
    lw a0, 96(sp)
    lw a1, 100(sp)
    lw a2, 104(sp)
    lw a3, 108(sp)
    lw a4, 112(sp)
    lw a5, 116(sp)
    lw a6, 120(sp)
    lw a7, 124(sp)
    addi sp, sp, 152
    eret

Yield:
    csrr t0, status
    andi t1, t0, 0xFFFE
    csrw status, t1
    addi sp, sp, -152
    sw ra, 0(sp)
    sw ra, 4(sp)
    sw gp, 12(sp)
    sw tp, 16(sp)
    sw fp, 20(sp)
    sw s1, 24(sp)
    sw s2, 28(sp)
    sw s3, 32(sp)
    sw s4, 36(sp)
    sw s5, 40(sp)
    sw s6, 44(sp)
    sw s7, 48(sp)
    sw s8, 52(sp)
    sw s9, 56(sp)
    sw s10, 60(sp)
    sw s11, 64(sp)
    andi t0, t0, 1
    slli t0, t0, 1
    sw t0, 128(sp)

    mv a0, sp
    bl ra, Schedule
    mv sp, a0
    b RestoreContext

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
    csrr a0, status
    andi t0, a0, 0xFFFE
    csrw status, t0
    andi a0, a0, 1
    br ra

RestoreInterrupts:
    csrr t0, status
    andi t0, t0, 0xFFFE
    or t0, t0, a0
    csrw status, t0
    br ra

SetInterruptMask:
    csrw ienable, a0
    br ra
