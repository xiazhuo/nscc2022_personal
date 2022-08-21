	.org 0x0
	.set noreorder
	.set noat
	.text

	.global _start 

_start: 
    lui $t0,0x8040

loop:
    lw $t1,0($t0)
    bne $t1,$zero,loop
    addiu $t0,$t0,4

WRITESERIAL:
    lui $s1,0xBFD0
    la $s0,feed
    lb $a0,0($s0)
    addiu $s0,$s0,1

.TESTW:
    lb    $t0, 0x03FC($s1)
    andi  $t0, $t0, 0x0001
    beqz  $t0, .TESTW
    nop

    sb    $a0, 0x03F8($s1)
    lb    $a0, 0($s0)
    addiu $s0,$s0,1
    bnez  $a0, .TESTW
    nop


end:
    b end
    nop

feed:
    .asciz "finished!"

    .p2align 2
