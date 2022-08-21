/*
-- ============================================================================
-- FILE NAME	: pc_reg.v
-- DESCRIPTION  : 本模块用于取指阶段控制pc值
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/6		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module pc_reg (
    input wire                  clk,
    input wire                  rst,

    output reg[31:0]            pc,
    output reg                  ce, 

    input wire                  branch_flag_i,      //分支标志
    input wire[31:0]            branch_address_i,   //分支地址

    input wire                  stall   //流水线暂停
);

always @(posedge clk) begin
    if(rst == `RstEnable) begin
        ce <= `ChipDisable;
    end
    else begin
        ce <= `ChipEnable;
    end
end

always @(posedge clk) begin
    if(ce == `ChipDisable) begin
        pc <= `PC_START_ADDR;
    end else if(stall == `NoStop) begin
        if(branch_flag_i == `Branch) begin
            pc <= branch_address_i;
        end else begin
            pc <= pc + 4'h4;
        end
    end
    //流水线暂停，保持原有状态
end

endmodule //pc_reg