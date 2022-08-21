#include <inst_test.h>
#include <regdef.h>    

    .org 0x0
    .set noreorder
    .set noat
    .text

    .global _start
_start:
    b     fib
    nop

info:
    .asciz "Fib Finish."

    .p2align 2
feed:
    .asciz "All PASS!"

    .p2align 2
fib:
    ori   t0, zero, 0x1     # t0 = 1
    ori   t1, zero, 0x1     # t1 = 1
    lui   a0, 0x8040        # a0 = 0x80400000
    addiu t4, a0, 0x100     # t4 = 0x80400100
loop0:
    addu  t2, t0, t1        # t2 = t0+t1
    ori   t0, t1, 0x0       # t0 = t1
    ori   t1, t2, 0x0       # t1 = t2
    sw    t1, 0(a0)
    lw    t3, 0(a0)
    bne   t1, t3, end
    nop
    addiu a0, a0, 0x4       # a0 += 4

    bne   a0, t4, loop0
    nop

WRITESERIAL:
    lui   s0, %hi(info)
    addiu s0, %lo(info)
    lb    a0, 0(s0)
    lui   s1, 0xBFD0
loop1:
    addiu s0, s0, 0x1
.TESTW:
    lb    t0, 0x03FC(s1)
    andi  t0, t0, 0x0001
    beqz  t0, .TESTW
    nop

    sb    a0, 0x03F8(s1)
    lb    a0, 0(s0)
    bne   a0, zero, loop1
    nop

READSERIAL:
    # lui   s1, 0xBFD0
.TESTR:
    lb    t0, 0x03FC(s1)
    andi  t0, t0, 0x0002
    beqz  t0, .TESTR
    nop

    lb    a0, 0x03F8(s1)
    ori   t0, zero, 0x0054      # char 'T'
    bne   a0, t0, READSERIAL
    nop

RANDOMTEST:
    li s0, 0x80400100
    li s1, 0
    lw s2, 4(s0)        # selection
    lw s3, 8(s0)        # random

add:
    andi t0, s2, 0x1
    beqz t0, add_next   # skip test
    nop
    TEST_ADD(0xbccd54c8, 0x0a2c3b14, 0xc6f98fdc)
    TEST_ADD(0x95f0c7b0, 0x00000000, 0x95f0c7b0)
    TEST_ADD(0x00000000, 0x6e701f70, 0x6e701f70)
    TEST_ADD(0x00000000, 0x00000000, 0x00000000)
    ori s1, s1, 0x1
add_next:

addi:
    andi t0, s2, 0x2
    beqz t0, addi_next  # skip test
    nop
    TEST_ADDI(0xbcbfdbe0, 0x0000f6c0, 0xbcbfd2a0)
    TEST_ADDI(0xd33b01eb, 0x00000000, 0xd33b01eb)
    TEST_ADDI(0x00000000, 0x00003e0c, 0x00003e0c)
    TEST_ADDI(0x00000000, 0x00000000, 0x00000000)
    ori s1, s1, 0x2
addi_next:

sub:
    andi t0, s2, 0x4
    beqz t0, sub_next   # skip test
    nop
    TEST_SUB(0x08635494, 0x9eb51e6c, 0x69ae3628)
    TEST_SUB(0x93bd45a8, 0x00000000, 0x93bd45a8)
    TEST_SUB(0x00000000, 0xd2e54c39, 0x2d1ab3c7)
    TEST_SUB(0x00000000, 0x00000000, 0x00000000)
    ori s1, s1, 0x4
sub_next:

slt:
    andi t0, s2, 0x8
    beqz t0, slt_next   # skip test
    nop
    TEST_SLT(0x77ea82d8, 0x273da080, 0x00000000)
    TEST_SLT(0x5d1eb494, 0x00000000, 0x00000000)
    TEST_SLT(0x00000000, 0x1eaac5e3, 0x00000001)
    TEST_SLT(0x00000000, 0x00000000, 0x00000000)
    ori s1, s1, 8
slt_next:

sllv:
    andi t0, s2, 0x10
    beqz t0, sllv_next  # skip test
    nop
    TEST_SLLV(0x1b9690c3, 0x0000001b, 0x18000000)
    TEST_SLLV(0x999ff140, 0x00000000, 0x999ff140)
    TEST_SLLV(0x00000000, 0x00000001, 0x00000000)
    TEST_SLLV(0x00000000, 0x00000000, 0x00000000)
    ori s1, s1, 0x10
sllv_next:

srav:
    andi t0, s2, 0x20
    beqz t0, srav_next   # skip test
    nop
    TEST_SRAV(0xdbbad0b0, 0x00000005, 0xfeddd685)
    TEST_SRAV(0x0b24d560, 0x00000000, 0x0b24d560)
    TEST_SRAV(0x00000000, 0x00000012, 0x00000000)
    TEST_SRAV(0x00000000, 0x00000000, 0x00000000)
    ori s1, s1, 0x20
srav_next:

sra:
    andi t0, s2, 0x40
    beqz t0, sra_next   # skip test
    nop
    TEST_SRA(0xb3bf7ef8, 0x0000001c, 0xfffffffb)
    TEST_SRA(0x7f797f19, 0x00000000, 0x7f797f19)
    TEST_SRA(0x00000000, 0x00000016, 0x00000000)
    TEST_SRA(0x00000000, 0x00000000, 0x00000000)
    ori s1, s1, 0x40
sra_next:

srlv:
    andi t0, s2, 0x80
    beqz t0, srlv_next   # skip test
    nop
    TEST_SRLV(0xcfe54c57, 0x00000006, 0x033f9531)
    TEST_SRLV(0x16f9a9d8, 0x00000000, 0x16f9a9d8)
    TEST_SRLV(0x00000000, 0x0000000c, 0x00000000)
    TEST_SRLV(0x00000000, 0x00000000, 0x00000000)
    ori s1, s1, 0x80
srlv_next:

jalr:
    andi t0, s2, 0x100
    beqz t0, jalr_next   # skip test
    nop
    TEST_JALR(0x6e6b362a, 0x240baf26, 0x6e6b362a, 0x240baf26)
    TEST_JALR(0x5d0fcbc0, 0xdba3ac64, 0x5d0fcbc0, 0xdba3ac64)
    TEST_JALR(0xa832bb00, 0xf43fa620, 0xa832bb00, 0xf43fa620)
    TEST_JALR(0x1e2aa5ca, 0x4782fd22, 0x1e2aa5ca, 0x4782fd22)
    ori s1, s1, 0x100
jalr_next:

bgez:
    andi t0, s2, 0x200
    beqz t0, bgez_next   # skip test
    nop
    TEST_BGEZ(0xbb00130a, 0x1b151f5e, 0x0e6929ba, 0x00000000, 0x00000000)
    TEST_BGEZ(0x44f2bff4, 0x4020bf52, 0x4efb06d3, 0x4020bf52, 0x4efb06d3)
    TEST_BGEZ(0x12bd8028, 0xab215888, 0x55aca678, 0xab215888, 0x55aca678)
    TEST_BGEZ(0x00000000, 0x1f139900, 0xaf6531c4, 0x1f139900, 0xaf6531c4)
    ori s1, s1, 0x200
bgez_next:

blez:
    andi t0, s2, 0x400
    beqz t0, blez_next   # skip test
    nop
    TEST_BLEZ(0x95b9206f, 0x6ad0a0b8, 0x8f08db03, 0x6ad0a0b8, 0x8f08db03)
    TEST_BLEZ(0x2c09b044, 0xc7826200, 0x13ea2762, 0x00000000, 0x00000000)
    TEST_BLEZ(0xdab562ac, 0xea867f00, 0x6d7650e5, 0xea867f00, 0x6d7650e5)
    TEST_BLEZ(0x00000000, 0xbb9734a0, 0xff0af084, 0xbb9734a0, 0xff0af084)
    ori s1, s1, 0x400
blez_next:

bltz:
    andi t0, s2, 0x800
    beqz t0, bltz_next   # skip test
    nop
    TEST_BLTZ(0xfff90290, 0x6a2f7d7c, 0xc275fd82, 0x6a2f7d7c, 0xc275fd82)
    TEST_BLTZ(0x35ae8150, 0x291a3374, 0x60d28110, 0x00000000, 0x00000000)
    TEST_BLTZ(0x00000000, 0x5f7d6c5f, 0x632c31aa, 0x00000000, 0x00000000)
    TEST_BLTZ(0xf5969546, 0x18389fc2, 0xeb9542c8, 0x18389fc2, 0xeb9542c8)
    ori s1, s1, 0x800
bltz_next:

    li  t0, 0xfeed0000
    or  t0, t0, s1
    xor t0, t0, s3
    sw  t0, 0(s0)       # *s0 = t0
    bne s1, s2, end
    nop
FEEDBACK:
    lui   s0, %hi(feed)
    addiu s0, %lo(feed)
    lb    a0, 0(s0)
    lui   s1, 0xBFD0
loop2:
    addiu s0, s0, 0x1
.TEST:
    lb    t0, 0x03FC(s1)
    andi  t0, t0, 0x0001
    beqz  t0, .TEST
    nop

    sb    a0, 0x03F8(s1)
    lb    a0, 0(s0)
    bne   a0, zero, loop2
    nop

end:
    b   end
    nop
