/*
-- ============================================================================
-- FILE NAME	: if_id.v
-- DESCRIPTION  : 本模块为取指阶段到译码阶段的过渡
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/6		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module if_id(
    input wire              clk,
    input wire              rst,

    //if阶段的pc值和取得的指令
    input wire[31:0]        if_pc,
    input wire[31:0]        if_inst,

    //送往id阶段的pc值和取得的指令
    output reg[31:0]        id_pc,
    output reg[31:0]        id_inst,

    input wire              stall       //流水线暂停
);

always @(posedge clk) begin
    if(rst == `RstEnable) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    //若if阶段不暂停，则正常进行
    end else if(stall == `NoStop) begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
    //若if与id阶段都暂停，则保持不变
end

endmodule   //if_id