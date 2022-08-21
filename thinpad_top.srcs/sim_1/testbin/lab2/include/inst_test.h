#define nop  ori zero, zero, 0
#define LI(reg, imm) \
    li reg, imm

/* 21 */
#define TEST_ADD(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    LI (v1, ref); \
    add v0, t0, t1; \
    bne v0, v1, add_next; \
    nop

/* 22 */
#define TEST_ADDI(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (v1, ref); \
    addi v0, t0, in_b; \
    bne v0, v1, addi_next; \
    nop

/* 23 */
#define TEST_SUB(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    LI (v1, ref); \
    sub v0, t0, t1; \
    bne v0, v1, sub_next; \
    nop

/* 8 */
#define TEST_SLT(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    LI (v1, ref); \
    slt v0, t0, t1; \
    bne v0, v1, slt_next; \
    nop

/* 32 */
#define TEST_SLLV(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    LI (v1, ref); \
    sllv v0, t0, t1; \
    bne v0, v1, sllv_next; \
    nop

/* 34 */
#define TEST_SRAV(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    LI (v1, ref); \
    srav v0, t0, t1; \
    bne v0, v1, srav_next; \
    nop

/* 33 */
#define TEST_SRA(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (v1, ref); \
    sra v0, t0, in_b; \
    bne v0, v1, sra_next; \
    nop

/* 36 */
#define TEST_SRLV(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    LI (v1, ref); \
    srlv v0, t0, t1; \
    bne v0, v1, srlv_next; \
    nop

/* 43 */
#define TEST_JALR(back_flag, front_flag, b_flag_ref, f_flag_ref) \
    addu s7, zero, $31; \
    li v0, 0x0; \
    li v1, 0x0; \
    la t0, 1000f; \
    la t1, 3000f; \
    b 2000f; \
    nop; \
1000:; \
    addu a0, ra, zero; \
    li v0, back_flag; \
    jalr t1; \
    nop; \
1001:; \
    b 4000f; \
    nop; \
2000:; \
    jalr t0; \
    nop; \
2001:; \
    b 4000f; \
    nop; \
3000:; \
    addu a1, ra, zero; \
    li v1, front_flag; \
4000:; \
    addu $31, zero, s7; \
    li s5, b_flag_ref; \
    li s6, f_flag_ref; \
    bne v0, s5, jalr_next; \
    nop; \
    bne v1, s6, jalr_next; \
    nop; \
    la s5, 1001b; \
    la s6, 2001b; \
    bne a0, s6, jalr_next; \
    nop; \
    bne a1, s5, jalr_next; \
    nop

/* 37 */
#define TEST_BGEZ(in_a, back_flag, front_flag, b_flag_ref, f_flag_ref) \
    li v0, 0x0; \
    li v1, 0x0; \
    b 2000f; \
    nop; \
1000:; \
    li v0, back_flag; \
    bgez t0, 3000f; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
2000:; \
    li t0, in_a; \
    bgez t0, 1000b; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
3000:; \
    li v1, front_flag; \
4000:; \
    li s5, b_flag_ref; \
    li s6, f_flag_ref; \
    bne v0, s5, bgez_next; \
    nop; \
    bne v1, s6, bgez_next; \
    nop

/* 39 */
#define TEST_BLEZ(in_a, back_flag, front_flag, b_flag_ref, f_flag_ref) \
    li v0, 0x0; \
    li v1, 0x0; \
    b 2000f; \
    nop; \
1000:; \
    li v0, back_flag; \
    blez t0, 3000f; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
2000:; \
    li t0, in_a; \
    blez t0, 1000b; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
3000:; \
    li v1, front_flag; \
4000:; \
    li s5, b_flag_ref; \
    li s6, f_flag_ref; \
    bne v0, s5, blez_next; \
    nop; \
    bne v1, s6, blez_next; \
    nop

/* 40 */
#define TEST_BLTZ(in_a, back_flag, front_flag, b_flag_ref, f_flag_ref) \
    li v0, 0x0; \
    li v1, 0x0; \
    b 2000f; \
    nop; \
1000:; \
    li v0, back_flag; \
    bltz t0, 3000f; \
    nop; \
    b 4000f; \
    nop; \
2000:; \
    li t0, in_a; \
    bltz t0, 1000b; \
    nop; \
    b 4000f; \
    nop; \
3000:; \
    li v1, front_flag; \
4000:; \
    li s5, b_flag_ref; \
    li s6, f_flag_ref; \
    bne v0, s5, bltz_next; \
    nop; \
    bne v1, s6, bltz_next; \
    nop
    