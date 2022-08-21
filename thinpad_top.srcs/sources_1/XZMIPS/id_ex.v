/*
-- ============================================================================
-- FILE NAME	: id_ex.v
-- DESCRIPTION  : 本模块为译码阶段到执行阶段的过渡
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/7		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module id_ex (
    input    wire        rst,       
    input    wire        clk,        

    //id阶段获得的信息
    input    wire[5:0]   id_aluop,

    input    wire[31:0]  id_reg_1,
    input    wire[31:0]  id_reg_2,

    input    wire[4:0]   id_waddr,
    input    wire        id_we,
    input    wire[31:0]  id_inst,
	input    wire[31:0]  id_pc,

    //送往ex阶段的信息
    output   reg [5:0]   ex_aluop,

    output   reg [31:0]  ex_reg_1,
    output   reg [31:0]  ex_reg_2,

    output   reg [4:0]   ex_waddr,
    output   reg         ex_we,
    output   reg [31:0]  ex_inst,
	output   reg [31:0]  ex_pc,

    //分支跳转存储
    input    wire[31:0]  id_link_addr,
    output   reg [31:0]  ex_link_addr,

    //流水线暂停
    input    wire   	 stall
);

    always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_reg_1 <= `ZeroWord;
			ex_reg_2 <= `ZeroWord;
			ex_waddr <= `NOPRegAddr;
			ex_we <= `WriteDisable;
			ex_inst <= `ZeroWord;
			ex_pc <= `ZeroWord;
			ex_link_addr <= `ZeroWord;
        //若id阶段暂停而ex阶段不暂停，则送空指令
		end else if(stall == `Stop) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_reg_1 <= `ZeroWord;
			ex_reg_2 <= `ZeroWord;
			ex_waddr <= `NOPRegAddr;
			ex_we <= `WriteDisable;
			ex_inst <= `ZeroWord;
			ex_pc <= `ZeroWord;
			ex_link_addr <= `ZeroWord;
        //若id阶段不暂停，则正常进行
		end else begin	
			ex_aluop <= id_aluop;
			ex_reg_1 <= id_reg_1;
			ex_reg_2 <= id_reg_2;
			ex_waddr <= id_waddr;
			ex_we <= id_we;		
			ex_inst <= id_inst;
			ex_pc <= id_pc;
			ex_link_addr <= id_link_addr;
		end
        //若id与ex阶段都暂停，则保持不变
	end

endmodule //id_ex