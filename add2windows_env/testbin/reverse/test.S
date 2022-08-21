    	.org 0x0
    	.set noreorder
    	.set noat
    	.text

    	.global _start 
    	
    	.macro shift reg0,reg1
    	srl \reg0,\reg0,8
	and $t2,\reg0,0xFF
	sll \reg1,\reg1,8
	or  \reg1,\reg1,$t2
	.endm
    	

_start: li $t0,0xAABBCCDD
	li $t3,3
	and $t1,$t0,0xFF

loop:
	beqz $t3,end
	shift $t0,$t1
	j  loop
	addi $t3,$t3,-1
	
end:
    beqz   $zero, end
    nop
	
	