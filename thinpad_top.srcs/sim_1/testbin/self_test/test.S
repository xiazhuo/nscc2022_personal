	.org 0x0
	.set noreorder
	.set noat
	.text

	.global _start 

_start: 
    lui $sp,0x807E
    addiu $sp,$sp,-24
    move $s8,$sp
    move $a0,$zero      #传参0
    jal QUICKSORT
    li $a1,8            #传参8
    move $sp,$s8
    addiu $sp,$sp,24

READ:
    lui $t0,0x8040
loop:
    lw $t1,0($t0)
    bne $t1,$zero,loop
    addiu $t0,$t0,4

    j WRITESERIAL
    nop


QUICKSORT:
    addiu	$sp,$sp,-40
    sw	$ra,36($sp)
    sw	$s8,32($sp)
    move	$s8,$sp
    sw	$a0,40($s8)
    sw	$a1,44($s8)
    move $v1,$a0
    move $v0,$a1
    slt	$v0,$v1,$v0
    bnez	$v0,.L2
    nop

    b	.L1
    nop

.L2:
    lw	$v1,40($s8)
    lw	$v0,44($s8)
    addu	$v0,$v1,$v0
    sra	$v1,$v0,0x1
    lui	$v0,0x8040
    sll	$v1,$v1,0x2
    addu	$v0,$v1,$v0
    lw	$v0,0($v0)
    sw	$v0,24($s8)     # x
    lw	$v0,40($s8)
    addiu	$v0,$v0,-1
    sw	$v0,16($s8)     # i
    lw	$v0,44($s8)
    addiu	$v0,$v0,1 
    sw	$v0,20($s8)     # j
    b	.L4
    nop

.L5:
    lw	$v0,16($s8)
    addiu	$v0,$v0,1
    sw	$v0,16($s8)     # i = i+1
    lui	$v0,0x8040
    lw	$v1,16($s8)
    sll	$v1,$v1,0x2
    addu	$v0,$v1,$v0
    lw	$v1,0($v0)
    lw	$v0,24($s8)
    slt	$v0,$v1,$v0
    bnez	$v0,.L5
    nop

.L6:
    lw	$v0,20($s8)
    addiu	$v0,$v0,-1   # j = j-1
    sw	$v0,20($s8)
    lui	$v0,0x8040
    lw	$v1,20($s8)
    sll	$v1,$v1,0x2
    addu	$v0,$v1,$v0
    lw	$v1,0($v0)
    lw	$v0,24($s8)
    slt	$v0,$v0,$v1
    bnez	$v0,.L6
    nop


    lw	$v1,16($s8)
    lw	$v0,20($s8)
    slt	$v0,$v1,$v0
    beqz	$v0,.L4
    nop

SWAP:
    lui	$t0,0x8040
    lw	$v1,16($s8)
    sll	$v1,$v1,0x2
    addu	$t0,$v1,$t0
    lw	$t1,0($t0)      # a[i]
    lui	$t2,0x8040
    lw	$v1,20($s8)
    sll	$v1,$v1,0x2
    addu	$t2,$v1,$t2
    lw	$t3,0($t2)      # a[j]
    sw  $t1,0($t2)
    sw  $t3,0($t0)
    # lui	$v0,0x8040
    # lw	$v1,16($s8)
    # sll	$v1,$v1,0x2
    # addu	$v0,$v1,$v0
    # lw	$v0,0($v0)      # a[i]
    # sw	$v0,28($s8)
    # lui	$v0,0x8040
    # lw	$v1,20($s8)
    # sll	$v1,$v1,0x2
    # addu	$v0,$v1,$v0
    # lw	$v1,0($v0)      # a[j]
    # lui	$v0,0x8040
    # lw	$a0,16($s8)
    # sll	$a0,$a0,0x2
    # addu	$v0,$a0,$v0
    # sw	$v1,0($v0)      # a[i] = a[j]
    # lui	$v0,0x8040
    # lw	$v1,20($s8)
    # sll	$v1,$v1,0x2
    # addu	$v0,$v1,$v0
    # lw	$v1,28($s8)
    # sw	$v1,0($v0)      # a[j] = t

.L4:
    lw	$v1,16($s8)     # i
    lw	$v0,20($s8)     # j
    slt	$v0,$v1,$v0
    bnez	$v0,.L5
    nop

    lw	$a0,40($s8)
    jal	QUICKSORT
    lw	$a1,20($s8)

    lw	$v0,20($s8)
    addiu	$v0,$v0,1
    move	$a0,$v0
    jal	QUICKSORT
    lw	$a1,44($s8)

.L1:
    move	$sp,$s8
    lw	$ra,36($sp)
    lw	$s8,32($sp)
    addiu	$sp,$sp,40
    jr	$ra
    nop


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
