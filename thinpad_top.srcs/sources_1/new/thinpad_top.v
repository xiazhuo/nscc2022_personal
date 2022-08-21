/*
-- ============================================================================
-- FILE NAME	: thinpad_top.v
-- DESCRIPTION  : 本模块为最外层的顶层模块
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/26		  
-- Modified_by	: 夏卓
-- ============================================================================
*/

`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_59M, clk_20M,clk_60M;
pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // 外部时钟输入
  // Clock out ports
  .clk_out1(clk_59M), // 时钟输出1，频率在IP配置界面中设置 59M
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置 20M
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                     // 后级电路复位信号应当由它生成（见下）
 );

reg reset_of_clk59M;
// 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk10M
always@(posedge clk_59M or negedge locked) begin
    if(~locked) reset_of_clk59M <= 1'b1;
    else        reset_of_clk59M <= 1'b0;
end

always@(posedge clk_59M or posedge reset_of_clk59M) begin
    if(reset_of_clk59M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end

// // 不使用内存、串口时，禁用其使能信号
// assign base_ram_ce_n = 1'b1;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;

// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number用16进制显示在数码管上面
wire[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管

reg[15:0] led_bits;
assign leds = led_bits;

always@(posedge clock_btn or posedge reset_btn) begin
    if(reset_btn)begin //复位按下，设置LED为初始值
        led_bits <= 16'h1;
    end
    else begin //每次按下时钟按钮，LED循环左移
        led_bits <= {led_bits[14:0],led_bits[15]};
    end
end

// //直连串口接收发送演示，从直连串口收到的数据再发送出去
// wire [7:0] ext_uart_rx;
// reg  [7:0] ext_uart_buffer, ext_uart_tx;
// wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
// reg ext_uart_start, ext_uart_avai;
    
// assign number = ext_uart_buffer;

// async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
//     ext_uart_r(
//         .clk(clk_50M),                       //外部时钟信号
//         .RxD(rxd),                           //外部串行信号输入
//         .RxD_data_ready(ext_uart_ready),  //数据接收到标志
//         .RxD_clear(ext_uart_clear),       //清除接收标志
//         .RxD_data(ext_uart_rx)             //接收到的一字节数据
//     );

// assign ext_uart_clear = ext_uart_ready; //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中
// always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
//     if(ext_uart_ready)begin
//         ext_uart_buffer <= ext_uart_rx;
//         ext_uart_avai <= 1;
//     end else if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_avai <= 0;
//     end
// end
// always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
//     if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_tx <= ext_uart_buffer;
//         ext_uart_start <= 1;
//     end else begin 
//         ext_uart_start <= 0;
//     end
// end

// async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
//     ext_uart_t(
//         .clk(clk_50M),                  //外部时钟信号
//         .TxD(txd),                      //串行信号输出
//         .TxD_busy(ext_uart_busy),       //发送器忙状态指示
//         .TxD_start(ext_uart_start),    //开始发送信号
//         .TxD_data(ext_uart_tx)        //待发送的数据
//     );

// //图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
// wire [11:0] hdata;
// assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
// assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
// assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
// assign video_clk = clk_50M;
// vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
//     .clk(clk_50M), 
//     .hdata(hdata), //横坐标
//     .vdata(),      //纵坐标
//     .hsync(video_hsync),
//     .vsync(video_vsync),
//     .data_enable(video_de)
// );
/* =========== Demo code end =========== */


wire [31:0]  rom_addr_o ;
wire         rom_ce_o;
wire [31:0]  inst_i ;

wire [31:0]  ram_data_i;
wire [31:0]  ram_addr_o;
wire [31:0]  ram_data_o;
wire         ram_we_n;
wire [3:0]   ram_sel_n;
wire         ram_ce_o;

wire         stallreq_from_mem;
wire[1:0]    state;

XZMIPS XZMIPS_1(
    .clk            (clk_59M),
    .rst            (reset_of_clk59M),

    .rom_addr_o     (rom_addr_o),
    .rom_ce_o       (rom_ce_o),
    .inst_i         (inst_i),

    .ram_data_i     (ram_data_i),
    .ram_addr_o     (ram_addr_o),
    .ram_data_o     (ram_data_o),
    .ram_we_n       (ram_we_n),
    .ram_sel_n      (ram_sel_n),
    .ram_ce_o       (ram_ce_o),

    .state          (state)
);

RAM_Serial_Ctrl RAM_Serial_Ctrl_1(
        .clk                (clk_59M),  
        .rst                (reset_of_clk59M),

        .rom_addr_i         (rom_addr_o),
        .rom_ce_i           (rom_ce_o),
        .inst_o             (inst_i),

        .ram_data_o         (ram_data_i),
        .mem_addr_i         (ram_addr_o),
        .mem_data_i         (ram_data_o),
        .mem_we_n           (ram_we_n),
        .mem_sel_n          (ram_sel_n),
        .mem_ce_i           (ram_ce_o),

        .base_ram_data      (base_ram_data),
        .base_ram_addr      (base_ram_addr),
        .base_ram_be_n      (base_ram_be_n),
        .base_ram_ce_n      (base_ram_ce_n),
        .base_ram_oe_n      (base_ram_oe_n),
        .base_ram_we_n      (base_ram_we_n),

        .ext_ram_data       (ext_ram_data),
        .ext_ram_addr       (ext_ram_addr),
        .ext_ram_be_n       (ext_ram_be_n),
        .ext_ram_ce_n       (ext_ram_ce_n),
        .ext_ram_oe_n       (ext_ram_oe_n),
        .ext_ram_we_n       (ext_ram_we_n),

        .txd                (txd),
        .rxd                (rxd),

        .state              (state)
    );


endmodule
