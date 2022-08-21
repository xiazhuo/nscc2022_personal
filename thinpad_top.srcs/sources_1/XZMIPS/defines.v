/*
-- ============================================================================
-- FILE NAME	: defines.v
-- DESCRIPTION  : 本模块定义了一些常用的宏名
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/8		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`default_nettype none        // 无定义的网络类型，默认为none


/*定义OP字段*/
`define     R_OP            6'b000000       // R型指令的OP
`define     SPECIAL_OP      6'b000001       // 特殊指令的OP

`define     ADDI_OP         6'b001000       // ADDI
`define     ADDIU_OP        6'b001001       // ADDIU
`define     SLTI_OP         6'b001010       // SLTI
`define     SLTIU_OP        6'b001011       // SLTIU
`define     MUL_OP          6'b011100       // MUL

`define     ANDI_OP         6'b001100       // ANDI
`define     LUI_OP          6'b001111       // LUI
`define     ORI_OP          6'b001101       // ORI
`define     XORI_OP         6'b001110       // XORI

`define     BEQ_OP          6'b000100       // BEQ
`define     BNE_OP          6'b000101       // BNE
`define     BGTZ_OP         6'b000111       // BGTZ
`define     BLEZ_OP         6'b000110       // BLEZ
`define     J_OP            6'b000010       // J
`define     JAL_OP          6'b000011       // JAL 

`define     LB_OP           6'b100000       // LB
`define     LW_OP           6'b100011       // LW
`define     SB_OP           6'b101000       // SB
`define     SW_OP           6'b101011       // SW


/*定义FUNC字段*/
`define     ADD_FUNC        6'b100000       // ADD
`define     ADDU_FUNC       6'b100001       // ADDU
`define     SUB_FUNC        6'b100010       // SUB
`define     SUBU_FUNC       6'b100011       // SUBU
`define     SLT_FUNC        6'b101010       // SLT
`define     SLTU_FUNC       6'b101011       // SLTU
`define     MUL_FUNC        6'b000010       // MUL

`define     AND_FUNC        6'b100100       // AND
`define     OR_FUNC         6'b100101       // OR
`define     XOR_FUNC        6'b100110       // XOR
`define     NOR_FUNC        6'b100111       // NOR

`define     SLL_FUNC        6'b000000       // SLL
`define     SLLV_FUNC       6'b000100       // SLLV
`define     SRA_FUNC        6'b000011       // SRA
`define     SRAV_FUNC       6'b000111       // SRAV
`define     SRL_FUNC        6'b000010       // SRL
`define     SRLV_FUNC       6'b000110       // SRLV

`define     JR_FUNC         6'b001000       // JR
`define     JALR_FUNC       6'b001001       // JALR


/*其他需要特殊判断的指令*/
`define     BGEZ_RT         5'b00001        // BGEZ
`define     BLTZ_RT         5'b00000        // BLTZ
`define     BGEZAL_RT       5'b10001        // BGEZAL
`define     BLTZAL_RT       5'b10000        // BLTZAL


/*定义EX阶段的操作类型*/
`define     EXE_NOP_OP      6'b000000       // 空
`define     EXE_AND_OP      6'b000001       // 按位与
`define     EXE_OR_OP       6'b000010       // 按位或
`define     EXE_XOR_OP      6'b000011       // 按位异或
`define     EXE_NOR_OP      6'b000100       // 按位或非

`define     EXE_SLL_OP      6'b000101       // 逻辑左移
`define     EXE_SRL_OP      6'b000110       // 逻辑右移
`define     EXE_SRA_OP      6'b000111       // 算数右移

`define     EXE_SLT_OP      6'b001000       // 小于则置位
`define     EXE_SLTU_OP     6'b001001       // 无符号小于则置位
`define     EXE_ADD_OP      6'b001010       // 加法
`define     EXE_SUB_OP      6'b001011       // 减法
`define     EXE_MUL_OP      6'b001100       // 乘法

`define     EXE_JAL_OP      6'b001101       // 跳转并链接

`define     EXE_LB_OP       6'b001110       // LB
`define     EXE_LW_OP       6'b001111       // LW
`define     EXE_SB_OP       6'b010000       // SB
`define     EXE_SW_OP       6'b010001       // SW


/*定义MEM阶段的操作类型*/
`define     MEM_NOP_OP      4'b0000         // NOP
`define     MEM_LB_OP       4'b0001         // LB
`define     MEM_LW_OP       4'b0010         // LW
`define     MEM_SB_OP       4'b0011         // SB
`define     MEM_SW_OP       4'b0100         // SW


/*定义常用的常量*/
`define     PC_START_ADDR   32'h80000000    // PC起始地址

`define     RstEnable       1'b1            //复位使能
`define     RstDisable      1'b0            //复位除能
`define     WriteEnable     1'b1            //写使能
`define     WriteEnable_n   1'b0            //写使能（低有效）
`define     WriteDisable    1'b0            //写除能
`define     WriteDisable_n  1'b1            //写除能（高有效）
`define     ReadEnable      1'b1            //读使能
`define     ReadDisable     1'b0            //读除能
`define     ChipEnable      1'b1            //芯片使能
`define     ChipDisable     1'b0            //芯片禁止
`define     ZeroWord        32'h00000000    //32位数字0
`define     Branch          1'b1            //跳转
`define     NotBranch       1'b0            //不跳转
`define     Stop            1'b1            //停止
`define     NoStop          1'b0            //不停止
`define     NOPRegAddr      5'b00000        //空操作使用的寄存器地址
