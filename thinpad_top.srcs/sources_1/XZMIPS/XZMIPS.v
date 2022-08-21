/*
-- ============================================================================
-- FILE NAME	: XZMIPS.v
-- DESCRIPTION  : 本模块为顶层模块，用于连接各流水级
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/8		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module XZMIPS (
    input   wire		     clk,
	input   wire			 rst,

    //连接指令存储器（存在于pc_reg）
	output  wire[31:0]       rom_addr_o,    //输出到指令存储器的地址
	output  wire             rom_ce_o,      //指令存储器使能信号
	input   wire[31:0]       inst_i,        //从指令存储器取得的指令
	
	//连接数据存储器data_ram（存在于mem）
	input   wire[31:0]       ram_data_i,    //写入的数据
	output  wire[31:0]       ram_addr_o,    //写（读）的地址
	output  wire[31:0]       ram_data_o,    //读出的数据
	output  wire             ram_we_n,      //写使能，低有效
	output  wire[3:0]        ram_sel_n,     //字节选择信号，低有效
	output  wire             ram_ce_o,      //存储器使能

    input   wire[1:0]        state
);

//if级
wire        pc_branch_flag_i;
wire[31:0]  pc_branch_address_i;

wire        stall;
wire        stallreq_from_id;	

pc_reg pc_reg_1(
    .clk     (clk),
    .rst     (rst),

    .pc      (rom_addr_o),
    .ce      (rom_ce_o),

    // 分支跳转
    .branch_flag_i          (pc_branch_flag_i),
    .branch_address_i       (pc_branch_address_i),

    .stall                  (stall)
);

wire[31:0] id_pc;
wire[31:0] id_inst;

if_id if_id_1 (
    .clk      (clk),
    .rst      (rst),

    .if_pc    (rom_addr_o),
    .if_inst  (inst_i),

    .id_pc    (id_pc),
    .id_inst  (id_inst),

    .stall    (stall)
);


//id级
wire[4:0]   wb_waddr_i;
wire[31:0]  wb_wdata_i;
wire        wb_we_i;

wire[4:0]   reg_raddr_1_i;
wire        reg_re_1_i;
wire[31:0]  reg_wdata_1_o;

wire[4:0]   reg_raddr_2_i;
wire        reg_re_2_i;
wire[31:0]  reg_wdata_2_o;

wire[31:0]  last_store_addr;
wire[31:0]  last_store_data;

regfile regfile_1(
    .rst        (rst),
    .clk        (clk),

    .we         (wb_we_i),
    .waddr      (wb_waddr_i),
    .wdata      (wb_wdata_i),

    .re_1       (reg_re_1_i),
    .raddr_1    (reg_raddr_1_i),
    .rdata_1    (reg_wdata_1_o),

    .re_2       (reg_re_2_i),
    .raddr_2    (reg_raddr_2_i),
    .rdata_2    (reg_wdata_2_o)
);

wire[5:0]   id_aluop_o;

wire[31:0]  id_reg_1_o;
wire[31:0]  id_reg_2_o;

wire[4:0]   id_waddr_o;
wire        id_we_o;

// 数据直通
wire [31:0]  ex_wdata_o;
wire [4:0]   ex_waddr_o;
wire         ex_we_o;
wire[3:0]    mem_op;
wire[31:0]   id_link_addr_o;

wire         mem_we_o;
wire[4:0]    mem_waddr_o;
wire[31:0]   mem_wdata_o;

wire[31:0]   id_inst_o;

wire        this_inst_is_load;

id id_1 (
    .rst                 (rst),
    .clk                 (clk),

    .id_pc               (id_pc),
    .inst                (id_inst),

    .raddr_1             (reg_raddr_1_i),
    .re_1                (reg_re_1_i),

    .raddr_2             (reg_raddr_2_i),
    .re_2                (reg_re_2_i),

    .rdata_1             (reg_wdata_1_o),
    .rdata_2             (reg_wdata_2_o),

    .aluop               (id_aluop_o),

    .reg_1               (id_reg_1_o),
    .reg_2               (id_reg_2_o),

    .waddr               (id_waddr_o),
    .we                  (id_we_o),
    .inst_o              (id_inst_o),

    .ex_we_i             (ex_we_o),
    .ex_waddr_i          (ex_waddr_o),
    .ex_wdata_i          (ex_wdata_o),

    .mem_we_i            (mem_we_o),
    .mem_waddr_i         (mem_waddr_o),
    .mem_wdata_i         (mem_wdata_o),

    .last_store_addr     (last_store_addr),
    .last_store_data     (last_store_data),
    .ex_load_addr        (mem_addr_o),

    .state               (state),

    .branch_flag_o       (pc_branch_flag_i),
    .branch_address_o    (pc_branch_address_i),
    .link_addr_o         (id_link_addr_o),

	.pre_inst_is_load    (this_inst_is_load),

    .stallreq            (stallreq_from_id)
);

wire[5:0]   id_ex_aluop_o;

wire[31:0]  id_ex_reg_1_o;
wire[31:0]  id_ex_reg_2_o;

wire[4:0]   id_ex_waddr_o;
wire        id_ex_we_o;

wire[31:0]  id_ex_link_addr_o;

wire[31:0]  id_ex_inst_o;
wire[31:0]  id_ex_pc_o;

id_ex id_ex_1 (
    .rst          (rst),
    .clk          (clk),

    .id_pc        (id_pc),
    .id_aluop     (id_aluop_o),

    .id_reg_1     (id_reg_1_o),
    .id_reg_2     (id_reg_2_o),

    .id_waddr     (id_waddr_o),
    .id_we        (id_we_o),
    .id_inst      (id_inst_o),

    .ex_pc        (id_ex_pc_o),
    .ex_aluop     (id_ex_aluop_o),

    .ex_reg_1     (id_ex_reg_1_o),
    .ex_reg_2     (id_ex_reg_2_o),

    .ex_waddr     (id_ex_waddr_o),
    .ex_we        (id_ex_we_o),
    .ex_inst      (id_ex_inst_o),

    .id_link_addr (id_link_addr_o),
    .ex_link_addr (id_ex_link_addr_o),

    .stall        (stall)
);


// ex级
wire[31:0]   mem_addr_o;
wire[31:0]   mem_data_o;

wire         stallreq_from_baseram;

ex ex_1(
    .rst         (rst),

    .ex_pc       (id_ex_pc_o),
    .aluop       (id_ex_aluop_o),

    .reg_1       (id_ex_reg_1_o),
    .reg_2       (id_ex_reg_2_o),

    .waddr       (id_ex_waddr_o),
    .we          (id_ex_we_o),
    .inst        (id_ex_inst_o),

    .link_addr   (id_ex_link_addr_o),

    .mem_op      (mem_op),
    .mem_addr_o  (mem_addr_o),
    .mem_data_o  (mem_data_o),
    .this_inst_is_load (this_inst_is_load),

    .wdata_o     (ex_wdata_o),
    .waddr_o     (ex_waddr_o),
    .we_o        (ex_we_o)
);

wire        ex_mem_we_o;
wire[4: 0]  ex_mem_waddr_o;
wire[31:0]  ex_mem_wdata_o;
wire[31:0]  ex_mem_pc_o;

wire[3:0]   mem_mem_op;
wire[31:0]  mem_mem_addr_o;
wire[31:0]  mem_mem_data_o;

ex_mem ex_mem_1(
    .rst            (rst),
    .clk            (clk),

    .ex_pc          (id_ex_pc_o),
    .ex_we          (ex_we_o),
    .ex_waddr       (ex_waddr_o),
    .ex_wdata       (ex_wdata_o),

    .ex_mem_op      (mem_op),
    .ex_mem_addr    (mem_addr_o),
    .ex_mem_data    (mem_data_o),

    .mem_pc         (ex_mem_pc_o),
    .mem_mem_op     (mem_mem_op),
    .mem_mem_addr   (mem_mem_addr_o),
    .mem_mem_data   (mem_mem_data_o),

    .mem_we         (ex_mem_we_o),
    .mem_waddr      (ex_mem_waddr_o),
    .mem_wdata      (ex_mem_wdata_o),

    .last_store_addr(last_store_addr),
    .last_store_data(last_store_data)
);


//mem级
mem mem_1(
    .rst                (rst),
    .clk                (clk),

    .we_i               (ex_mem_we_o),
    .waddr_i            (ex_mem_waddr_o),
    .wdata_i            (ex_mem_wdata_o),

    // 存储相关
    .mem_pc             (ex_mem_pc_o),
    .mem_op             (mem_mem_op),
    .mem_addr_i         (mem_mem_addr_o),
    .mem_data_i         (mem_mem_data_o),

    .we_o               (mem_we_o),
    .waddr_o            (mem_waddr_o),
    .wdata_o            (mem_wdata_o),

    .mem_addr_o         (ram_addr_o),
    .mem_data_o         (ram_data_o),
    .mem_we_n           (ram_we_n), // 是否为写操作

    .mem_sel_n          (ram_sel_n),
    .mem_ce_o           (ram_ce_o), // 使能信号

    .ram_data_i         (ram_data_i), // 来自存储器

    .stallreq           (stallreq_from_baseram)
);

mem_wb mem_wb_1 (
    .clk             (clk),
    .rst             (rst),

    .stall           (stall),

    .mem_waddr     (mem_waddr_o),
    .mem_we        (mem_we_o),
    .mem_wdata     (mem_wdata_o),
    
    .wb_waddr      (wb_waddr_i),
    .wb_we         (wb_we_i),
    .wb_wdata      (wb_wdata_i)
);


//流水线暂停控制模块
stall_ctrl stall_ctrl_1(
	.rst(rst),

	//来自译码阶段的暂停请求
	.stallreq_from_id(stallreq_from_id),

    //来自baseram的暂停请求
    .stallreq_from_baseram(stallreq_from_baseram),

	.stall(stall)       	
);


endmodule //XZMIPS