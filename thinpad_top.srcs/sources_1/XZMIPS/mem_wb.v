/*
-- ============================================================================
-- FILE NAME	: mem_wb.v
-- DESCRIPTION  : 本模块为访存阶段到回写阶段的过渡
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/8		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module mem_wb (
    input	wire				    clk,
	input   wire				    rst,
	
	input   wire	                stall,

	//来自mem阶段的信息	
	input   wire[4:0]               mem_waddr,
	input   wire                    mem_we,
	input   wire[31:0]			    mem_wdata,

	//送到wb阶段的信息（实际上wb阶段在regfile中得以实现，因此是送给regfile）
	output  reg[4:0]                wb_waddr,
	output  reg                     wb_we,
	output  reg[31:0]			    wb_wdata	 
);

    always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			wb_waddr <= `NOPRegAddr;
			wb_we <= `WriteDisable;
            wb_wdata <= `ZeroWord;	
        //若mem阶段不暂停，则正常进行
		end else begin
			wb_waddr <= mem_waddr;
			wb_we <= mem_we;
			wb_wdata <= mem_wdata;
		end
	end 

endmodule //mem_wb