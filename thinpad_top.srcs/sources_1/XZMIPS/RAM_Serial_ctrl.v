/*
-- ============================================================================
-- FILE NAME	: RAM_Serial_ctrl.v
-- DESCRIPTION  : 本模块用于处理内存映射及串口控制信号的生成
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/26		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

/*
    | 虚地址区间            | 说明           |
    | 0x80000000-0x800FFFFF | 监控程序代码   |
    | 0x80100000-0x803FFFFF | 用户代码空间   |
    | 0x80400000-0x807EFFFF | 用户数据空间   |
    | 0x807F0000-0x807FFFFF | 监控程序数据   |
    | 0xBFD003F8-0xBFD003FD | 串口数据及状态 |

    | 地址       | 位    | 说明                                               |
    | 0xBFD003F8 | [7:0] | 串口数据，读、写地址分别表示串口接收、发送一个字节 |
    | 0xBFD003FC | [0]   | 只读，为1时表示串口空闲，可发送数据                |
    | 0xBFD003FC | [1]   | 只读，为1时表示串口收到数据                        |
*/

`include "defines.v"

`define SerialState 32'hBFD003FC    //串口状态地址
`define SerialData  32'hBFD003F8    //串口数据地址

module RAM_Serial_Ctrl (
    input wire clk,
    input wire rst,

    //if阶段输入的信息和获得的指令
    input    wire[31:0]  rom_addr_i,        //读取指令的地址
    input    wire        rom_ce_i,          //指令存储器使能信号
    output   reg [31:0]  inst_o,            //获取到的指令

    //mem阶段传递的信息和取得的数据
    output   reg[31:0]   ram_data_o,        //读取的数据
    input    wire[31:0]  mem_addr_i,        //读（写）地址
    input    wire[31:0]  mem_data_i,        //写入的数据
    input    wire        mem_we_n,          //写使能，低有效
    input    wire[3:0]   mem_sel_n,         //字节选择信号
    input    wire        mem_ce_i,          //片选信号

    //BaseRAM信号
    inout    wire[31:0]  base_ram_data,     //BaseRAM数据
    output   reg [19:0]  base_ram_addr,     //BaseRAM地址
    output   reg [3:0]   base_ram_be_n,     //BaseRAM字节使能，低有效。
    output   reg         base_ram_ce_n,     //BaseRAM片选，低有效
    output   reg         base_ram_oe_n,     //BaseRAM读使能，低有效
    output   reg         base_ram_we_n,     //BaseRAM写使能，低有效

    //ExtRAM信号
    inout    wire[31:0]  ext_ram_data,      //ExtRAM数据
    output   reg [19:0]  ext_ram_addr,      //ExtRAM地址
    output   reg [3:0]   ext_ram_be_n,      //ExtRAM字节使能，低有效。
    output   reg         ext_ram_ce_n,      //ExtRAM片选，低有效
    output   reg         ext_ram_oe_n,      //ExtRAM读使能，低有效
    output   reg         ext_ram_we_n,      //ExtRAM写使能，低有效

    //直连串口信号
    output   wire        txd,                //直连串口发送端
    input    wire        rxd,                //直连串口接收端

    output   wire[1:0]   state                //串口状态
);

wire [7:0]  RxD_data;           //接收到的数据
wire [7:0]  TxD_data;           //待发送的数据
wire        RxD_data_ready;     //接收器收到数据完成之后，置为1
wire        TxD_busy;           //发送器状态是否忙碌，1为忙碌，0为不忙碌
wire        TxD_start;          //发送器是否可以发送数据，1代表可以发送
wire        RxD_clear;          //为1时将清除接收标志（ready信号）

wire        RxD_FIFO_wr_en;
wire        RxD_FIFO_full;
wire [7:0]  RxD_FIFO_din;
reg         RxD_FIFO_rd_en;
wire        RxD_FIFO_empty;
wire [7:0]  RxD_FIFO_dout;

reg         TxD_FIFO_wr_en;
wire        TxD_FIFO_full;
reg  [7:0]  TxD_FIFO_din;
wire        TxD_FIFO_rd_en;
wire        TxD_FIFO_empty;
wire [7:0]  TxD_FIFO_dout;

//串口实例化模块，波特率9600，仿真时可改为59000000
async_receiver #(.ClkFrequency(59000000),.Baud(9600))   //接收模块
                ext_uart_r(
                   .clk(clk),                           //外部时钟信号
                   .RxD(rxd),                           //外部串行信号输入
                   .RxD_data_ready(RxD_data_ready),     //数据接收到标志
                   .RxD_clear(RxD_clear),               //清除接收标志
                   .RxD_data(RxD_data)                  //接收到的一字节数据
                );

async_transmitter #(.ClkFrequency(59000000),.Baud(9600)) //发送模块
                    ext_uart_t(
                      .clk(clk),                        //外部时钟信号
                      .TxD(txd),                        //串行信号输出
                      .TxD_busy(TxD_busy),              //发送器忙状态指示
                      .TxD_start(TxD_start),            //开始发送信号
                      .TxD_data(TxD_data)               //待发送的数据
                    );

//fifo接收模块
fifo_generator_0 RXD_FIFO (
    .rst(rst),
    .clk(clk),
    .wr_en(RxD_FIFO_wr_en),     //写使能
    .din(RxD_FIFO_din),         //接收到的数据
    .full(RxD_FIFO_full),       //判满标志

    .rd_en(RxD_FIFO_rd_en),     //读使能
    .dout(RxD_FIFO_dout),       //传递给mem阶段读出的数据
    .empty(RxD_FIFO_empty)      //判空标志
);

//fifo发送模块
fifo_generator_0 TXD_FIFO (
    .rst(rst),
    .clk(clk),
    .wr_en(TxD_FIFO_wr_en),     //写使能
    .din(TxD_FIFO_din),         //需要发送的数据
    .full(TxD_FIFO_full),       //判满标志

    .rd_en(TxD_FIFO_rd_en),     //读使能，为1时串口取出数据发送
    .dout(TxD_FIFO_dout),       //传递给串口待发送的数据
    .empty(TxD_FIFO_empty)      //判空标志
);

//内存映射
wire is_SerialState = (mem_addr_i ==  `SerialState); 
wire is_SerialData  = (mem_addr_i == `SerialData);
wire is_base_ram    = (mem_addr_i >= 32'h80000000) 
                    && (mem_addr_i < 32'h80400000);
wire is_ext_ram     = (mem_addr_i >= 32'h80400000)
                    && (mem_addr_i < 32'h80800000);

reg [31:0] serial_o;        //串口输出数据
wire[31:0] base_ram_o;      //baseram输出数据
wire[31:0] ext_ram_o;       //extram输出数据

assign state = {!RxD_FIFO_empty,!TxD_FIFO_full};

assign TxD_FIFO_rd_en = TxD_start;
assign TxD_start = (!TxD_busy) && (!TxD_FIFO_empty);
assign TxD_data = TxD_FIFO_dout;

assign RxD_FIFO_wr_en = RxD_data_ready;
assign RxD_FIFO_din = RxD_data;
assign RxD_clear = RxD_data_ready && (!RxD_FIFO_full);

always @(*) begin
    TxD_FIFO_wr_en = `WriteDisable;
    TxD_FIFO_din = 8'h00;
    RxD_FIFO_rd_en = `ReadDisable;
    serial_o = `ZeroWord;
    if(is_SerialState) begin            //读取串口状态
        TxD_FIFO_wr_en = `WriteDisable;
        TxD_FIFO_din = 8'h00;
        RxD_FIFO_rd_en = `ReadDisable;
        serial_o = {{30{1'b0}}, state};
    end 
    else if(is_SerialData) begin        //通过串口获取（发送）数据
        if(mem_we_n == `WriteDisable_n) begin   //接收串口数据
            TxD_FIFO_wr_en = `WriteDisable;
            TxD_FIFO_din = 8'h00;
            RxD_FIFO_rd_en = `ReadEnable;
            serial_o = {{24{1'b0}}, RxD_FIFO_dout};
        end
        else begin                              //发送串口数据
            TxD_FIFO_wr_en = `WriteEnable;
            TxD_FIFO_din = mem_data_i[7:0];
            RxD_FIFO_rd_en = `ReadDisable;
            serial_o = `ZeroWord;
        end
    end
    else begin
        TxD_FIFO_wr_en = `WriteDisable;
        TxD_FIFO_din = 8'h00;
        RxD_FIFO_rd_en = `ReadDisable;
        serial_o = `ZeroWord;
    end
end


//处理BaseRam（指令存储器）
assign base_ram_data = is_base_ram ? ((mem_we_n == `WriteEnable_n) ? mem_data_i : 32'hzzzzzzzz) : 32'hzzzzzzzz;
assign base_ram_o = base_ram_data;      //读取到的BaseRam数据

//当mem阶段需要向BaseRam的地址写入或读取数据时，发生结构冒险
always @(*) begin
    base_ram_addr = 20'h00000;
    base_ram_be_n = 4'b0000;
    base_ram_ce_n = 1'b0;
    base_ram_oe_n = 1'b1;
    base_ram_we_n = 1'b1;
    inst_o = `ZeroWord;
    if(is_base_ram) begin           //涉及到BaseRam的相关数据操作，需要暂停流水线
        base_ram_addr = mem_addr_i[21:2];   //有对齐要求，低两位舍去
        base_ram_be_n = mem_sel_n;
        base_ram_ce_n = 1'b0;
        base_ram_oe_n = !mem_we_n;
        base_ram_we_n = mem_we_n;
        inst_o = `ZeroWord;
    end else begin                  //不涉及到BaseRam的相关数据操作，继续取指令
        base_ram_addr = rom_addr_i[21:2];   //有对齐要求，低两位舍去
        base_ram_be_n = 4'b0000;
        base_ram_ce_n = 1'b0;
        base_ram_oe_n = 1'b0;
        base_ram_we_n = 1'b1;
        inst_o = base_ram_o;
    end
end


//处理ExtRam（数据存储器）
assign ext_ram_data = is_ext_ram ? ((mem_we_n == `WriteEnable_n) ? mem_data_i : 32'hzzzzzzzz) : 32'hzzzzzzzz;
assign ext_ram_o = ext_ram_data;

always @(*) begin
    ext_ram_addr = 20'h00000;
    ext_ram_be_n = 4'b0000;
    ext_ram_ce_n = 1'b0;
    ext_ram_oe_n = 1'b1;
    ext_ram_we_n = 1'b1;
    if(is_ext_ram) begin           //涉及到extRam的相关数据操作
        ext_ram_addr = mem_addr_i[21:2];    //有对齐要求，低两位舍去
        ext_ram_be_n = mem_sel_n;
        ext_ram_ce_n = 1'b0;
        ext_ram_oe_n = !mem_we_n;
        ext_ram_we_n = mem_we_n;
    end else begin
        ext_ram_addr = 20'h00000;
        ext_ram_be_n = 4'b0000;
        ext_ram_ce_n = 1'b0;
        ext_ram_oe_n = 1'b1;
        ext_ram_we_n = 1'b1;
    end
end


//确认输出的数据
always @(*) begin
    ram_data_o = `ZeroWord;
    if(is_SerialState || is_SerialData ) begin
        ram_data_o = serial_o;
    end else if (is_base_ram) begin
        case (mem_sel_n)
            4'b1110: begin
                ram_data_o = {{24{base_ram_o[7]}}, base_ram_o[7:0]};
            end
            4'b1101: begin
                ram_data_o = {{24{base_ram_o[15]}}, base_ram_o[15:8]};
            end
            4'b1011: begin
                ram_data_o = {{24{base_ram_o[23]}}, base_ram_o[23:16]};
            end
            4'b0111: begin
                ram_data_o = {{24{base_ram_o[31]}}, base_ram_o[31:24]};
            end
            4'b0000: begin
                ram_data_o = base_ram_o;
            end
            default: begin
                ram_data_o = base_ram_o;
            end
        endcase
    end else if (is_ext_ram) begin
        case (mem_sel_n)
            4'b1110: begin
                ram_data_o = {{24{ext_ram_o[7]}}, ext_ram_o[7:0]};
            end
            4'b1101: begin
                ram_data_o = {{24{ext_ram_o[15]}}, ext_ram_o[15:8]};
            end
            4'b1011: begin
                ram_data_o = {{24{ext_ram_o[23]}}, ext_ram_o[23:16]};
            end
            4'b0111: begin
                ram_data_o = {{24{ext_ram_o[31]}}, ext_ram_o[31:24]};
            end
            4'b0000: begin
                ram_data_o = ext_ram_o;
            end
            default: begin
                ram_data_o = ext_ram_o;
            end
        endcase
    end else begin
        ram_data_o = `ZeroWord;
    end
end


endmodule //ram