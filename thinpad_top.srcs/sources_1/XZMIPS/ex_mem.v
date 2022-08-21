/*
-- ============================================================================
-- FILE NAME	: ex_mem.v
-- DESCRIPTION  : 本模块为执行阶段到访存阶段的过渡
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/9		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module ex_mem (
    input    wire         rst,      
    input    wire         clk,        

    //ex阶段获得的信息
    input    wire[31:0]   ex_pc,
    input    wire         ex_we,
    input    wire[4:0]    ex_waddr,
    input    wire[31:0]   ex_wdata,

    input    wire[3:0]    ex_mem_op,
    input    wire[31:0]   ex_mem_addr,
    input    wire[31:0]   ex_mem_data,

    //送到mem阶段的信息
    output   reg [31:0]   mem_pc,
    output   reg [3:0]    mem_mem_op,
    output   reg [31:0]   mem_mem_addr,
    output   reg [31:0]   mem_mem_data,

    //送到wb阶段的信息
    output   reg          mem_we,
    output   reg [4:0]    mem_waddr,
    output   reg [31:0]   mem_wdata,

    output  reg [31:0]   last_store_data,
    output  reg [31:0]   last_store_addr
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            mem_pc <= `ZeroWord;
            mem_mem_op   <= `MEM_NOP_OP;
            mem_mem_addr <= `ZeroWord;
            mem_mem_data <= `ZeroWord;

            mem_we       <= `WriteDisable;
            mem_waddr    <= `NOPRegAddr;
            mem_wdata    <= `ZeroWord;

            last_store_addr <= `ZeroWord;
            last_store_data <= `ZeroWord;
        //若ex阶段不暂停，则正常进行
        end else begin
            mem_pc <= ex_pc;
            mem_mem_op <= ex_mem_op;
            mem_mem_addr <= ex_mem_addr;
            mem_mem_data <= ex_mem_data;

            mem_we <= ex_we;
            mem_waddr <= ex_waddr;
            mem_wdata <= ex_wdata;
            case(ex_mem_op)
                `MEM_SB_OP: begin
                    last_store_addr <= ex_mem_addr;
                    case(ex_mem_addr[1:0])
                    2'b00: begin
                        last_store_data <= {24'h000000,ex_mem_data[7:0]};
                    end 
                    2'b01: begin
                        last_store_data <= {16'h0000,ex_mem_data[7:0],8'h00};
                    end
                    2'b10: begin
                        last_store_data <= {8'h00,ex_mem_data[7:0],16'h0000};
                    end
                    2'b11: begin
                        last_store_data <= {ex_mem_data[7:0],12'h000000};
                    end
                    default : begin
                        last_store_data <= last_store_data;
                    end
                endcase
                end
                `MEM_SW_OP: begin
                    last_store_addr <= ex_mem_addr;
                    last_store_data <= ex_mem_data;
                end
                default: begin
                    last_store_addr <= last_store_addr;
                    last_store_data <= last_store_data;
                end
            endcase
        end
    end

endmodule //ex_mem