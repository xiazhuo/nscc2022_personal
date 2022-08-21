.org 0x0
    .set noreorder
    .set noat
    .text
    .global _start
_start:
    li	$t0,1
    li	$t1,1
    lui  $a0,0x8040
    addiu $t5,$a0,0x100

loop:
    addu $t2,$t0,$t1
    move $t0,$t1
    move $t1,$t2
    sw $t1,0($a0)
    addiu $a0,$a0,0x4
    bne  $a0,$t5,loop
    nop

end:
    bne   $t5, $zero, end
    nop