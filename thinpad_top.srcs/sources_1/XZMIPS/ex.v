/*
-- ============================================================================
-- FILE NAME	: ex.v
-- DESCRIPTION  : 本模块为五级流水线中的执行阶段
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/8		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module ex (
    input   wire	    rst,
	
	//从id阶段获得的信息
    input   wire[5:0]   aluop,

    input   wire[31:0]  reg_1,
    input   wire[31:0]  reg_2,

    input   wire[4:0]   waddr,
    input   wire        we,
    input   wire[31:0]  inst,
    input   wire[31:0]  ex_pc,

    //分支跳转存储
    input   wire[31:0]  link_addr,

    //送往mem阶段的信息
    output  reg [3:0]    mem_op,         //存储类型,同时要送往id阶段以判断load相关
    output  reg [31:0]   mem_addr_o,     //存储地址
    output  reg [31:0]   mem_data_o,     //存储数据
    output  wire         this_inst_is_load,

    //送往wb阶段的信息
    output  reg [31:0]   wdata_o,
    output  reg [4:0]    waddr_o,       //同时要送往id阶段以判断load相关
    output  reg          we_o
);

    assign this_inst_is_load = (aluop == `EXE_LB_OP) | (aluop == `EXE_LW_OP);

    //执行阶段
    always @(*) begin
        if(rst == `RstEnable) begin
            wdata_o = `ZeroWord;
            waddr_o = `NOPRegAddr;
            we_o = `WriteDisable;
        end else begin
            wdata_o = `ZeroWord;
            waddr_o = waddr;
            we_o = we;
            case(aluop)     
                `EXE_AND_OP: begin
                    wdata_o = reg_1 & reg_2;
                end      
                `EXE_OR_OP: begin
                    wdata_o = reg_1 | reg_2;
                end    
                `EXE_XOR_OP: begin
                    wdata_o = reg_1 ^ reg_2;
                end     
                `EXE_NOR_OP: begin
                    wdata_o = ~(reg_1 | reg_2);
                end

                `EXE_SLL_OP: begin
                    wdata_o = reg_2 << reg_1[4:0];
                end      
                `EXE_SRL_OP: begin
                    wdata_o = reg_2 >> reg_1[4:0];
                end      
                `EXE_SRA_OP: begin
                    wdata_o = ($signed(reg_2)) >>> reg_1[4:0];
                end      

                `EXE_SLT_OP: begin
                    wdata_o = ($signed(reg_1) < $signed(reg_2)) ? 1 : 0;
                end     
                `EXE_SLTU_OP: begin
                    wdata_o = (reg_1 < reg_2) ? 1 : 0;
                end
                `EXE_ADD_OP: begin
                    wdata_o = reg_1 + reg_2;
                end
                `EXE_SUB_OP: begin
                    wdata_o = reg_1 + (~reg_2) + 1;
                end      
                `EXE_MUL_OP: begin
                    wdata_o = reg_1 * reg_2;   //无符号乘法代替有符号乘法
                end      
                
                `EXE_JAL_OP: begin
                    wdata_o = link_addr;
                end
            endcase
        end
    end

    //送往mem阶段的信息
    
    wire[31:0]  imm_s   =   {{16{inst[15]}},inst[15:0]};

    always @(*) begin
        if(rst == `RstEnable) begin
            mem_op = `MEM_NOP_OP;
            mem_addr_o = `ZeroWord;
            mem_data_o = `ZeroWord;
        end else begin
            case(aluop)
                `EXE_LB_OP: begin
                    mem_op = `MEM_LB_OP;
                    mem_addr_o = reg_1 + imm_s;
                    mem_data_o = `ZeroWord;
                end       
                `EXE_LW_OP: begin
                    mem_op = `MEM_LW_OP;
                    mem_addr_o = reg_1 + imm_s;
                    mem_data_o = `ZeroWord;
                end       
                `EXE_SB_OP: begin
                    mem_op = `MEM_SB_OP;
                    mem_addr_o = reg_1 + imm_s;
                    mem_data_o = reg_2;
                end       
                `EXE_SW_OP: begin
                    mem_op = `MEM_SW_OP;
                    mem_addr_o = reg_1 + imm_s;
                    mem_data_o = reg_2;
                end       
                default: begin
                    mem_op = `MEM_NOP_OP;
                    mem_addr_o = `ZeroWord;
                    mem_data_o = `ZeroWord;
                end
            endcase
        end
    end


endmodule //ex