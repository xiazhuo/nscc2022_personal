	.org 0x0
	.set noreorder
	.set noat
	.text

	.global _start 

_start: 
	lui $sp,0x8060
	la  $ra,end
	addiu $sp,$sp,-32
	sw $ra,28($sp)
	sw $s8,24($sp)
	move $s8,$sp
	li $v0,3			# n
	sw $v0,16($s8)		#保存n的值
	lw $a0,16($s8)		#传参
	jal fib
	nop
	sw $v0,20($s8)		#存储fib(5)
	move $t1,$v0
	lw $v0,16($s8)		#取出原来的v0（5）
	addiu $v0,$v0,1		# n = n+1
	sw $v0,16($s8)    	#存储n
	move $v0,$zero
	move $sp,$s8
	lw $ra,28($sp)
	lw $s8,24($sp)
	addiu $sp,$sp,32
	jr $ra
	nop


fib:
	addiu $sp,$sp,-32
	sw $ra,28($sp)
	sw $s8,24($sp)
	sw $s0,20($sp)
	move $s8,$sp
	sw $a0,32($s8)
	lw $v1,32($s8)
	li $v0,1
	beq $v1,$v0,L1
	nop
	lw $v1,32($s8)
	li $v0,2
	bne $v1,$v0,L2
	nop

L1:
	li $v0,1
	b L3
	nop

L2:
	lw $v0,32($s8)
	addiu $v0,$v0,-1
	move $a0,$v0
	jal fib
	nop
	move $s0,$v0
	lw $v0,32($s8)
	addiu $v0,$v0,-2
	move $a0,$v0
	jal fib
	nop
	addu $v0,$s0,$v0


L3:
	move $sp,$s8
	lw $ra,28($sp)
	lw $s8,24($sp)
	lw $s0,20($sp)
	addiu $sp,$sp,32
	jr $ra
	nop

end:
    beqz   $zero, end
    nop
	
	