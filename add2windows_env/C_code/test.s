	.file	1 "test.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=xx
	.module	nooddspreg
	.globl	a
	.data
	.align	2
	.type	a, @object
	.size	a, 20
a:
	.word	9
	.word	8
	.word	10
	.word	0
	.word	-1

	.comm	b,262180,4

	.comm	c,20,4
	.text
	.align	2
	.globl	bsearchr
	.set	nomips16
	.set	nomicromips
	.ent	bsearchr
	.type	bsearchr, @function
bsearchr:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$5,20($fp)
	sw	$6,24($fp)
	b	.L2
	nop

.L4:
	lw	$3,16($fp)
	lw	$2,20($fp)
	addu	$2,$3,$2
	addiu	$2,$2,1
	sra	$2,$2,1
	sw	$2,0($fp)
	lui	$2,%hi(b)
	lw	$3,0($fp)
	sll	$3,$3,2
	addiu	$2,$2,%lo(b)
	addu	$2,$3,$2
	lw	$3,0($2)
	lw	$2,24($fp)
	sltu	$2,$2,$3
	bne	$2,$0,.L3
	nop

	lw	$2,0($fp)
	sw	$2,16($fp)
	b	.L2
	nop

.L3:
	lw	$2,0($fp)
	addiu	$2,$2,-1
	sw	$2,20($fp)
.L2:
	lw	$3,16($fp)
	lw	$2,20($fp)
	slt	$2,$3,$2
	bne	$2,$0,.L4
	nop

	lw	$2,16($fp)
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	bsearchr
	.size	bsearchr, .-bsearchr
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	sw	$0,16($fp)
	b	.L7
	nop

.L8:
	lw	$3,16($fp)
	lw	$2,16($fp)
	mul	$2,$3,$2
	move	$4,$2
	lui	$2,%hi(b)
	lw	$3,16($fp)
	sll	$3,$3,2
	addiu	$2,$2,%lo(b)
	addu	$2,$3,$2
	sw	$4,0($2)
	lw	$2,16($fp)
	addiu	$2,$2,1
	sw	$2,16($fp)
.L7:
	lw	$3,16($fp)
	li	$2,65536			# 0x10000
	slt	$2,$3,$2
	bne	$2,$0,.L8
	nop

	sw	$0,16($fp)
	b	.L9
	nop

.L10:
	lui	$2,%hi(a)
	lw	$3,16($fp)
	sll	$3,$3,2
	addiu	$2,$2,%lo(a)
	addu	$2,$3,$2
	lw	$2,0($2)
	move	$4,$0
	li	$5,65535			# 0xffff
	move	$6,$2
	jal	bsearchr
	nop

	move	$4,$2
	lui	$2,%hi(c)
	lw	$3,16($fp)
	sll	$3,$3,2
	addiu	$2,$2,%lo(c)
	addu	$2,$3,$2
	sw	$4,0($2)
	lw	$2,16($fp)
	addiu	$2,$2,1
	sw	$2,16($fp)
.L9:
	lw	$3,16($fp)
	li	$2,262144			# 0x40000
	slt	$2,$3,$2
	bne	$2,$0,.L10
	nop

	move	$2,$0
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Codescape GNU Tools 2016.05-03 for MIPS MTI Bare Metal) 4.9.2"
