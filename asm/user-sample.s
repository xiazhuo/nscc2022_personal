	.org 0x0
	.set noreorder
	.set noat
	.text

	.global _start 

_start:
    lui $sp,0x807E
    lui	$a3,0x8060
    move	$v0,$zero
    lui	$a1,0x1
    move	$v1,$a3

.L1:
    mul	$a0,$v0,$v0
    addiu	$v1,$v1,4
    addiu	$v0,$v0,1
    bne	$v0,$a1,.L1
    sw	$a0,-4($v1)
    lui	$t2,0x8040
    lui	$t1,0x8050
    move	$t0,$zero
    lui	$t3,0x10

.L6:
    addu	$v0,$t2,$t0
    move	$v1,$zero
    li	$a1,0xffff
    lw	$a2,0($v0)
    addu	$a0,$a1,$v1

.L7:
    addiu	$a0,$a0,1
    sra	$a0,$a0,0x1
    sll	$v0,$a0,0x2
    addu	$v0,$a3,$v0
    lw	$v0,0($v0)
    sltu	$v0,$a2,$v0
    beqz	$v0,.L2
    nop
    b	.L3
    move	$v0,$a0

.L5:
    sra	$v0,$v0,0x1
    sll	$v1,$v0,0x2
    addu	$v1,$a3,$v1
    lw	$v1,0($v1)
    sltu	$v1,$a2,$v1
    bnez	$v1,.L4
    move	$v1,$a0
    move	$a0,$v0

.L2:
    addu	$v0,$a1,$a0
    slt	$v1,$a0,$a1
    bnez	$v1,.L5
    addiu	$v0,$v0,1
    addu	$v0,$t1,$t0
    addiu	$t0,$t0,4
    bne	$t0,$t3,.L6
    sw	$a0,0($v0)

.L8:
    jr	$ra
    move	$v0,$zero

.L4:
    addiu	$a1,$v0,-1

.L9:
    slt	$v0,$v1,$a1
    bnez	$v0,.L7
    addu	$a0,$a1,$v1
    addu	$v0,$t1,$t0
    addiu	$t0,$t0,4
    move	$a0,$v1
    bne	$t0,$t3,.L6
    sw	$a0,0($v0)
    b	.L8
    nop

.L3:
    b	.L9
    addiu	$a1,$v0,-1

bsearchr:
    move	$v0,$a0
    lui	$t1,0x8060
    slt	$v1,$v0,$a1
    beqz	$v1,.L10
    addu	$v1,$a1,$v0

.L13:
    addiu	$v1,$v1,1
    sra	$v1,$v1,0x1
    sll	$a3,$v1,0x2
    addu	$a3,$t1,$a3
    lw	$a3,0($a3)
    sltu	$a3,$a2,$a3
    bnez	$a3,.L11
    nop

.L12:
    addu	$t0,$a1,$v1
    slt	$a3,$v1,$a1
    move	$v0,$v1
    beqz	$a3,.L10
    addiu	$v1,$t0,1
    sra	$v1,$v1,0x1
    sll	$a0,$v1,0x2
    addu	$a0,$t1,$a0
    lw	$a0,0($a0)
    sltu	$a0,$a2,$a0
    beqz	$a0,.L12
    nop

.L11:
    addiu	$a1,$v1,-1
    slt	$v1,$v0,$a1
    bnez	$v1,.L13
    addu	$v1,$a1,$v0

.L10:
    jr	$ra
    nop
