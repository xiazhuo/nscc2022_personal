/*
-- ============================================================================
-- FILE NAME	: id.v
-- DESCRIPTION  : 本模块为五级流水线中的译码阶段
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/9		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module id (
    input    wire        rst,
    input    wire        clk,

    input    wire[31:0]  id_pc,  
    input    wire[31:0]  inst,   

    // 送到寄存器堆的信息
    output   reg [4:0]   raddr_1,        // 读寄存器1的地址
    output   reg         re_1,           // 读寄存器1的使能

    output   reg [4:0]   raddr_2,        // 读寄存器2的地址
    output   reg         re_2,           // 读寄存器2的使能

    // 从寄存器中获得的信息
    input    wire[31:0]  rdata_1,        // 读寄存器1获取的数据
    input    wire[31:0]  rdata_2,        // 读寄存器2获取的数据

    // 送往ex阶段的信息
    output   reg [5:0]   aluop,          // 操作类型

    output   reg [31:0]  reg_1,          // 源操作数1
    output   reg [31:0]  reg_2,          // 源操作数2

    output   reg [4:0]   waddr,          // 要写入的寄存器地址
    output   reg         we,             // 写使能
    output   wire[31:0]  inst_o,         // 用于计算访存阶段的存储地址

    // 数据直通，解决数据冒险问题
    input    wire        ex_we_i,        // 执行阶段的写使能
    input    wire[4:0]   ex_waddr_i,     // 执行阶段的写寄存器地址
    input    wire[31:0]  ex_wdata_i,     // 执行阶段要写的数据

    input    wire        mem_we_i,       // 访存阶段的写使能
    input    wire[4:0]   mem_waddr_i,    // 访存阶段的写寄存器地址
    input    wire[31:0]  mem_wdata_i,    // 访存阶段要写的数据

    input    wire[31:0]  last_store_addr,   //上一次存储的地址
    input    wire[31:0]  last_store_data,   //上一次存储的数据
    input    wire[31:0]  ex_load_addr,      //上一次加载的地址

    input    wire[1:0]   state,             //串口状态

    // 分支跳转，解决控制冒险问题
    output   reg         branch_flag_o,     // 分支跳转标志
    output   reg[31:0]   branch_address_o,  // 跳转地址
    output   reg[31:0]   link_addr_o,       // 连接地址

    // 执行阶段的操作符类型，用于解决load冒险
    input    wire        pre_inst_is_load,  // 判断上一条指令是否为load指令

    // 暂停信号
    output   wire        stallreq         // 流水线暂停请求
);

    // 提取指令各个字段
    // R型指令
    wire[5:0] op            = inst[31:26];
    wire[4:0] rs            = inst[25:21];
    wire[4:0] rt            = inst[20:16];
    wire[4:0] rd            = inst[15:11];
    wire[4:0] shamt         = inst[10:6];
    wire[5:0] func          = inst[5:0];

    // I型指令
    wire[15:0] imm          = inst[15:0];

    // J型指令
    wire[25:0] inst_index   = inst[25:0];

    // 立即数扩展
    wire[31:0] imm_u = {{16{1'b0}}, imm};       // 无符号扩展
    wire[31:0] imm_s = {{16{imm[15]}}, imm};    // 有符号扩展

    // 跳转地址
    wire[31:0] next_pc;
    wire[31:0] jump_addr = {next_pc[31:28], inst_index, 2'b00};
    wire[31:0] branch_addr = next_pc + {imm_s[29:0], 2'b00};

    // 发生load冒险时的流水线暂停请求
    reg stallreq_for_reg1_loadrelate;
    reg stallreq_for_reg2_loadrelate;

    // 选择是有符号扩展还是无符号扩展
    reg[31:0]   imm_o;

    assign inst_o = inst;

    assign next_pc = id_pc + 4'h4;


    //译码
    always @(*) begin
        if(rst == `RstEnable) begin
            aluop = `EXE_NOP_OP;
            re_1 = `ReadDisable;
            raddr_1 = `NOPRegAddr;
            re_2 = `ReadDisable;
            raddr_2 = `NOPRegAddr;
            we = `WriteDisable;
            waddr = `NOPRegAddr;
            imm_o = `ZeroWord;
        end else begin 
            aluop = `EXE_NOP_OP;
            re_1 = `ReadDisable;
            raddr_1 = rs;
            re_2 = `ReadDisable;
            raddr_2 = rt;
            we = `WriteDisable;
            waddr = rd;
            imm_o = `ZeroWord;
        end
        case(op)
            `ADDIU_OP,
            `ADDI_OP: begin
                aluop = `EXE_ADD_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = imm_s;
            end        
            `SLTI_OP: begin
                aluop = `EXE_SLT_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = imm_s;
            end
            `SLTIU_OP: begin
                aluop = `EXE_SLTU_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = imm_s;
            end
            `MUL_OP: begin
                if(shamt == 5'b00000) begin
                    case(func)
                        `MUL_FUNC: begin
                            aluop = `EXE_MUL_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end
                        default :begin
                        end
                    endcase
                end else begin
                end
            end

            `ANDI_OP: begin
                aluop = `EXE_AND_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = imm_u;
            end       
            `LUI_OP: begin
                aluop = `EXE_OR_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = {imm, 16'h0000};
            end        
            `ORI_OP: begin
                aluop = `EXE_OR_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = imm_u;
            end         
            `XORI_OP: begin
                aluop = `EXE_XOR_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = imm_u;
            end

            `BEQ_OP: begin
                re_1 = `ReadEnable;
                re_2 = `ReadEnable;
                we = `WriteDisable;
            end
            `BNE_OP: begin
                re_1 = `ReadEnable;
                re_2 = `ReadEnable;
                we = `WriteDisable;
            end        
            `BGTZ_OP: begin
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteDisable;
            end
            `BLEZ_OP: begin 
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteDisable;
            end
            `J_OP: begin
                re_1 = `ReadDisable;
                re_2 = `ReadDisable;
                we = `WriteDisable;
            end        
            `JAL_OP:begin
                aluop = `EXE_JAL_OP;
                re_1 = `ReadDisable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = 5'b11111;
            end

            `LB_OP: begin
                aluop = `EXE_LB_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = imm_s;
            end         
            `LW_OP: begin
                aluop = `EXE_LW_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadDisable;
                we = `WriteEnable;
                waddr = rt;
                imm_o = imm_s;
            end         
            `SB_OP: begin
                aluop = `EXE_SB_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadEnable;
                we = `WriteDisable;
            end           
            `SW_OP: begin
                aluop = `EXE_SW_OP;
                re_1 = `ReadEnable;
                re_2 = `ReadEnable;
                we = `WriteDisable;
            end           

            `R_OP: begin
                if(shamt == 5'b00000) begin
                    case(func)
                        `ADDU_FUNC,
                        `ADD_FUNC: begin
                            aluop = `EXE_ADD_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end
                        `SUBU_FUNC,
                        `SUB_FUNC: begin
                            aluop = `EXE_SUB_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end
                        `SLT_FUNC: begin
                            aluop = `EXE_SLT_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end
                        `SLTU_FUNC: begin
                            aluop = `EXE_SLTU_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end

                        `AND_FUNC: begin
                            aluop = `EXE_AND_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end  
                        `OR_FUNC: begin
                            aluop = `EXE_OR_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end   
                        `XOR_FUNC: begin
                            aluop = `EXE_XOR_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end   
                        `NOR_FUNC: begin
                            aluop = `EXE_NOR_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end

                        `SLLV_FUNC: begin
                            aluop = `EXE_SLL_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end  
                        `SRAV_FUNC: begin
                            aluop = `EXE_SRA_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end
                        `SRLV_FUNC :begin
                            aluop = `EXE_SRL_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                        end 

                        `JR_FUNC: begin
                            re_1 = `ReadEnable;
                            re_2 = `ReadDisable;
                            we = `WriteDisable;
                        end
                        `JALR_FUNC: begin
                            aluop = `EXE_JAL_OP;
                            re_1 = `ReadEnable;
                            re_2 = `ReadDisable;
                            we = `WriteEnable;
                        end
                        default : begin
                        end
                    endcase
                end else if(rs == 5'b00000) begin
                    case(func)
                        `SLL_FUNC: begin
                            aluop = `EXE_SLL_OP;
                            re_1 = `ReadDisable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                            waddr = rd;
                            imm_o[4:0] = shamt;
                        end   
                        `SRL_FUNC: begin
                            aluop = `EXE_SRL_OP;
                            re_1 = `ReadDisable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                            waddr = rd;
                            imm_o[4:0] = shamt;
                        end
                        `SRA_FUNC: begin
                            aluop = `EXE_SRA_OP;
                            re_1 = `ReadDisable;
                            re_2 = `ReadEnable;
                            we = `WriteEnable;
                            waddr = rd;
                            imm_o[4:0] = shamt;
                        end
                        default : begin
                        end
                    endcase
                end else begin
                end    
            end       

            `SPECIAL_OP: begin
                case(rt)
                    `BLTZ_RT,
                    `BGEZ_RT: begin
                        re_1 = `ReadEnable;
                        re_2 = `ReadDisable;
                        we = `WriteDisable;
                    end
                    `BLTZAL_RT,
                    `BGEZAL_RT: begin
                        aluop = `EXE_JAL_OP;
                        re_1 = `ReadEnable;
                        re_2 = `ReadDisable;
                        we = `WriteDisable;
                    end
                    default : begin
                    end
                endcase
            end       
            default : begin
            end
        endcase
    end


    //确定是否跳转及跳转地址
    always @(*) begin
        if(rst == `RstEnable) begin
            branch_flag_o = `NotBranch;
            branch_address_o = `ZeroWord;
            link_addr_o = `ZeroWord;
        end else begin
            branch_flag_o = `NotBranch;
            branch_address_o = `ZeroWord;
            link_addr_o = `ZeroWord;
        end
        case(op)
            `BEQ_OP: begin
                if(reg_1 == reg_2) begin
                    branch_flag_o = `Branch;
                    branch_address_o = branch_addr;
                end else begin 
                end
            end
            `BNE_OP: begin
                if(reg_1 != reg_2) begin
                    branch_flag_o = `Branch;
                    branch_address_o = branch_addr;
                end else begin
                end
            end        
            `BGTZ_OP: begin
                if(reg_1[31] == 1'b0 && reg_1 != `ZeroWord) begin
                    branch_flag_o = `Branch;
                    branch_address_o = branch_addr;
                end else begin
                end
            end
            `BLEZ_OP: begin 
                if(reg_1[31] == 1'b1 || reg_1 == `ZeroWord) begin
                    branch_flag_o = `Branch;
                    branch_address_o = branch_addr;
                end else begin
                end
            end
            `J_OP: begin
                branch_flag_o = `Branch;
                branch_address_o = jump_addr;
            end        
            `JAL_OP: begin
                branch_flag_o = `Branch;
                branch_address_o = jump_addr;
                link_addr_o = next_pc + 4'h4;
            end
            `R_OP: begin
                if(shamt == 5'b00000) begin
                    case(func) 
                        `JR_FUNC: begin
                            branch_flag_o = `Branch;
                            branch_address_o = reg_1;
                        end
                        `JALR_FUNC: begin
                            branch_flag_o = `Branch;
                            branch_address_o = reg_1;
                            link_addr_o = next_pc + 4'h4;
                        end
                    default:	begin
                        end
                    endcase
                end
            end
            `SPECIAL_OP: begin
                case(rt)
                    `BGEZ_RT: begin
                        if(reg_1[31] == 1'b0) begin
                            branch_flag_o = `Branch;
                            branch_address_o = branch_addr;
                        end else begin
                        end
                    end
                    `BLTZ_RT: begin
                        if(reg_1[31] == 1'b1) begin
                            branch_flag_o = `Branch;
                            branch_address_o = branch_addr;
                        end else begin
                        end
                    end
                    `BGEZAL_RT: begin
                        if(reg_1[31] == 1'b0) begin
                            branch_flag_o = `Branch;
                            branch_address_o = branch_addr;
                            link_addr_o = next_pc + 4'h4;
                        end else begin
                        end
                    end
                    `BLTZAL_RT: begin
                        if(reg_1[31] == 1'b1) begin
                            branch_flag_o = `Branch;
                            branch_address_o = branch_addr;
                            link_addr_o = next_pc + 4'h4;
                        end else begin
                        end
                    end
                    default : begin
                    end
                endcase
            end       
            default :begin
                branch_flag_o = `NotBranch;
                branch_address_o = `ZeroWord;
                link_addr_o = `ZeroWord;
            end
        endcase
    end


    //确定操作数1
    always @ (*) begin
        reg_1 = `ZeroWord;
		stallreq_for_reg1_loadrelate = `NoStop;	
		if(rst == `RstEnable) begin
			reg_1 = `ZeroWord;	
        end else if(pre_inst_is_load && ex_waddr_i == raddr_1 
			&& re_1 == 1'b1 && ex_load_addr == last_store_addr) begin
            reg_1 = last_store_data;
        //发生load冒险需要暂停流水线
		end else if(pre_inst_is_load && ex_waddr_i == raddr_1 
								&& re_1 == 1'b1 ) begin
            stallreq_for_reg1_loadrelate = `Stop;	
        //ex阶段的数据直通
        end else if(re_1==1'b1 && ex_we_i==1'b1
                        &&ex_waddr_i==raddr_1) begin
            reg_1 = ex_wdata_i;
        //mem阶段的数据直通
        end else if(re_1==1'b1 && mem_we_i==1'b1
                        &&mem_waddr_i==raddr_1) begin
            reg_1 = mem_wdata_i;
        //正常情况
        end else if(re_1 == 1'b1) begin
            reg_1 = rdata_1;
        end else if(re_1 == 1'b0) begin
            reg_1 = imm_o;
        end else begin
            reg_1 = `ZeroWord;
        end
	end

    //确定操作数2
    always @(*) begin
        reg_2 = `ZeroWord;
        stallreq_for_reg2_loadrelate = `NoStop;
        if(rst == `RstEnable) begin
            reg_2 = `ZeroWord;
        end else if(pre_inst_is_load && ex_waddr_i == raddr_2 
            && re_2 == 1'b1  && ex_load_addr == last_store_addr) begin
            reg_2 = last_store_data;
        //发生load冒险需要暂停流水线
        end else if(pre_inst_is_load && ex_waddr_i == raddr_2 
                            && re_2 == 1'b1 ) begin
            stallreq_for_reg2_loadrelate = `Stop;
        //ex阶段的数据直通
        end else if(re_2==1'b1 && ex_we_i==1'b1
                        &&ex_waddr_i==raddr_2) begin
            reg_2 = ex_wdata_i;
        //mem阶段的数据直通
        end else if(re_2==1'b1 && mem_we_i==1'b1
                        &&mem_waddr_i==raddr_2) begin
            reg_2 = mem_wdata_i;
        //正常情况
        end else if(re_2 == 1'b1) begin
            reg_2 = rdata_2;
        end else if(re_2 == 1'b0) begin
            reg_2 = imm_o;
        end else begin
            reg_2 = `ZeroWord;
        end
    end


    //流水线暂停
    assign stallreq = stallreq_for_reg1_loadrelate 
                        | stallreq_for_reg2_loadrelate;

endmodule //id