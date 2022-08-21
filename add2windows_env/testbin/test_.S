	.org 0x0
	.set noreorder
	.set noat
	.text

	.global _start 

_start: 
    lui $sp,0x807E
    addiu	$sp,$sp,-32
    sw	$ra,28($sp)
    sw	$s8,24($sp)
    move	$s8,$sp
    sw	$zero,16($s8)
    b	.L4
    nop

.L3:
    lw	$v1,16($s8)
    lw	$v0,16($s8)
    mul	$v0,$v1,$v0
    move	$a0,$v0
    lui	$v0,0x8062      #b [i]
    lw	$v1,16($s8)
    sll	$v1,$v1,0x2
    addu	$v0,$v1,$v0
    sw	$a0,0($v0)
    lw	$v0,16($s8)
    addiu	$v0,$v0,1
    sw	$v0,16($s8)

.L4:
    lw	$v1,16($s8)
    lui	$v0,0x1
    slt	$v0,$v1,$v0
    bnez	$v0,.L3
    nop
    sw	$zero,16($s8)
    b	.L2
    nop

.L1:
    lui	$v0,0x8040          # a[i]
    lw	$v1,16($s8)
    sll	$v1,$v1,0x2
    addu	$v0,$v1,$v0
    lw	$v0,0($v0)
    move	$a0,$zero
    li	$a1,0xffff
    move	$a2,$v0
    jal	bsearchr
    nop
    move	$a0,$v0
    lui	$v0,0x8050          # c[i]
    lw	$v1,16($s8)
    sll	$v1,$v1,0x2
    addu	$v0,$v1,$v0
    sw	$a0,0($v0)
    lw	$v0,16($s8)
    addiu	$v0,$v0,1
    sw	$v0,16($s8)

.L2:
    lw	$v0,16($s8)
    lui $t0,0x4
    slt	$v0,$v0,$t0
    bnez	$v0,.L1
    nop
    move	$v0,$zero
    move	$sp,$s8
    lw	$ra,28($sp)
    lw	$s8,24($sp)
    addiu	$sp,$sp,32
    jr	$ra
    nop



bsearchr:
    addiu	$sp,$sp,-16
    sw	$s8,12($sp)
    move	$s8,$sp
    sw	$a0,16($s8)
    sw	$a1,20($s8)
    sw	$a2,24($s8)
    b	.L6
    nop

.L5:
    lw	$v1,16($s8)
    lw	$v0,20($s8)
    addu	$v0,$v1,$v0
    addiu	$v0,$v0,1
    sra	$v0,$v0,0x1
    sw	$v0,0($s8)
    lui	$v0,0x8062
    lw	$v1,0($s8)
    sll	$v1,$v1,0x2
    addu	$v0,$v1,$v0
    lw	$v1,0($v0)
    lw	$v0,24($s8)
    sltu	$v0,$v0,$v1
    bnez	$v0,.L7
    nop
    lw	$v0,0($s8)
    sw	$v0,16($s8)
    b	.L6
    nop

.L7:
    lw	$v0,0($s8)
    addiu	$v0,$v0,-1
    sw	$v0,20($s8)

.L6:
    lw	$v1,16($s8)
    lw	$v0,20($s8)
    slt	$v0,$v1,$v0
    bnez	$v0,.L5
    nop
    lw	$v0,16($s8)
    move	$sp,$s8
    lw	$s8,12($sp)
    addiu	$sp,$sp,16
    jr	$ra
    nop
