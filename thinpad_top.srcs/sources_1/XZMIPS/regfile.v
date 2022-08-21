/*
-- ============================================================================
-- FILE NAME	: regfile.v
-- DESCRIPTION  : 本模块作为寄存器堆，提供一个写端口，两个读端口
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/7		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module regfile (
    input wire                  clk,
    input wire                  rst,

    //mem阶段传递的参数
    input wire                  we,
    input wire[4:0]             waddr,
    input wire[31:0]            wdata,

    //id阶段传递的参数及取得的信息
    input wire                  re_1,
    input wire[4:0]             raddr_1,
    output reg[31:0]            rdata_1,

    input wire                  re_2,
    input wire[4:0]             raddr_2,
    output reg[31:0]            rdata_2
);

reg[31:0] regs[0:31];       // 32个32位通用寄存器

integer i;

//写入操作（本模块相当于wb阶段）
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        for(i = 0;i < 32; i = i + 1) begin
            regs[i] <= `ZeroWord;
        end
    end
    else begin
        if(we == `WriteEnable && waddr != 5'b00000) begin
            regs[waddr] <= wdata;   //0号寄存器不可写入
        end
    end
end

//读端口1 组合逻辑
always @(*) begin
    if(rst == `RstEnable) begin
        rdata_1 = `ZeroWord;
    end
    else begin
        if(re_1 == `ReadEnable) begin
            if(raddr_1 == 5'b00000) begin
                rdata_1 = `ZeroWord;
            end else if(raddr_1 == waddr && we == `WriteEnable) begin
                rdata_1 = wdata;    //处理数据冒险
            end else begin
                rdata_1 = regs[raddr_1];
            end
        end else begin
            rdata_1 = `ZeroWord;
        end
    end
end

//读端口2 组合逻辑
always @(*) begin
    if(rst == `RstEnable) begin
        rdata_2 = `ZeroWord;
    end
    else begin
        if(re_2 == `ReadEnable) begin
            if(raddr_2 == 5'b00000) begin
                rdata_2 = `ZeroWord;
            end else if(raddr_2 == waddr && we == `WriteEnable) begin
                rdata_2 = wdata;    //处理数据冒险
            end else begin
                rdata_2 = regs[raddr_2];
            end
        end else begin
            rdata_2 = `ZeroWord;
        end
    end
end

endmodule //regfile