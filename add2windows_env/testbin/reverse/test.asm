
test.elf:     file format elf32-tradlittlemips


Disassembly of section .text:

80000000 <_ftext>:
80000000:	3c08aabb 	lui	t0,0xaabb
80000004:	3508ccdd 	ori	t0,t0,0xccdd
80000008:	240b0003 	li	t3,3
8000000c:	310900ff 	andi	t1,t0,0xff

80000010 <loop>:
80000010:	11600006 	beqz	t3,8000002c <end>
80000014:	00084202 	srl	t0,t0,0x8
80000018:	310a00ff 	andi	t2,t0,0xff
8000001c:	00094a00 	sll	t1,t1,0x8
80000020:	012a4825 	or	t1,t1,t2
80000024:	08000004 	j	80000010 <loop>
80000028:	216bffff 	addi	t3,t3,-1

8000002c <end>:
8000002c:	1000ffff 	b	8000002c <end>
80000030:	00000000 	nop
