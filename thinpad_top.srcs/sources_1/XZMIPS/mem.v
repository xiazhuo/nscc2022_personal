/*
-- ============================================================================
-- FILE NAME	: mem.v
-- DESCRIPTION  : 本模块为五级流水线中的访存阶段
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/9		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module mem (
    input       wire        rst,        
    input       wire        clk,   

    //来自ex阶段的信息
    input       wire[31:0]  mem_pc,
    input       wire        we_i,     
    input       wire[4:0]   waddr_i,   
    input       wire[31:0]  wdata_i,   

    input       wire[3:0]   mem_op,     
    input       wire[31:0]  mem_addr_i, 
    input       wire[31:0]  mem_data_i,

    //送往wb阶段的信息
    output      reg         we_o,    
    output      reg[4:0]    waddr_o, 
    output      reg[31:0]   wdata_o, 

    //送到数据存储器的信息
    //LB,LW,SB,SW
    output      reg[31:0]   mem_addr_o, 
    output      reg[31:0]   mem_data_o, 
    output      reg         mem_we_n,    //读使能，低有效
    //LB,SB
    output      reg[3:0]    mem_sel_n,   //字节选择信号，低有效
    output      reg         mem_ce_o,    //是否可以访问存储器

    //从数据存储器读取的信息（LB,LW）
    input       wire[31:0]  ram_data_i,

    output      wire        stallreq
    
);

    assign  stallreq    = (mem_addr_i >= 32'h80000000) 
                        && (mem_addr_i < 32'h80400000);


    always @(*) begin
        if(rst == `RstEnable) begin
            we_o = `WriteDisable;
            waddr_o = `NOPRegAddr;
            wdata_o = `ZeroWord;

            mem_addr_o = `ZeroWord;
            mem_data_o = `ZeroWord;
            mem_we_n = `WriteDisable_n;
            mem_sel_n = 4'b1111;
            mem_ce_o = `ChipDisable;
        end else begin
            we_o = we_i;
            waddr_o = waddr_i;
        end
        case(mem_op)
            `MEM_LB_OP:  begin
                wdata_o = ram_data_i;
                mem_addr_o = mem_addr_i;
                mem_data_o = `ZeroWord;
                mem_we_n = `WriteDisable_n;
                mem_ce_o = `ChipEnable;
                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_n = 4'b1110;
                    end 
                    2'b01: begin
                        mem_sel_n = 4'b1101;
                    end
                    2'b10: begin
                        mem_sel_n = 4'b1011;
                    end
                    2'b11: begin
                        mem_sel_n = 4'b0111;
                    end
                    default : begin
                        mem_sel_n = 4'b1111;
                    end
                endcase
            end
            `MEM_LW_OP:  begin
                wdata_o = ram_data_i;
                mem_addr_o = mem_addr_i;
                mem_data_o = `ZeroWord;
                mem_we_n = `WriteDisable_n;
                mem_ce_o = `ChipEnable;
                mem_sel_n = 4'b0000;
            end
            `MEM_SB_OP:  begin
                wdata_o = `ZeroWord;
                mem_addr_o = mem_addr_i;
                mem_data_o = {4{mem_data_i[7:0]}};    //低字节存储到指定位置
                mem_we_n = `WriteEnable_n;
                mem_ce_o = `ChipEnable;
                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_n = 4'b1110;
                    end 
                    2'b01: begin
                        mem_sel_n = 4'b1101;
                    end
                    2'b10: begin
                        mem_sel_n = 4'b1011;
                    end
                    2'b11: begin
                        mem_sel_n = 4'b0111;
                    end
                    default : begin
                        mem_sel_n = 4'b1111;
                    end
                endcase
            end
            `MEM_SW_OP:  begin
                wdata_o = `ZeroWord;
                mem_addr_o = mem_addr_i;
                mem_data_o = mem_data_i;
                mem_we_n = `WriteEnable_n;
                mem_ce_o = `ChipEnable;
                mem_sel_n = 4'b0000;
            end
            default: begin
                wdata_o = wdata_i;
                mem_addr_o = `ZeroWord;
                mem_data_o = `ZeroWord;
                mem_we_n = `WriteDisable_n;
                mem_ce_o = `ChipDisable;
                mem_sel_n = 4'b1111;
            end
        endcase
    end

endmodule //mem