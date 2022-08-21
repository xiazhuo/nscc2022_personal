/*
-- ============================================================================
-- FILE NAME	: stall_ctrl.v
-- DESCRIPTION  : 本模块用于处理流水线暂停信号的生成
-- ----------------------------------------------------------------------------
-- Date         : 2022/6/8		  
-- Coding_by	: 夏卓
-- ============================================================================
*/

`include "defines.v"

module stall_ctrl (
    input wire					 rst,

    //来自id阶段的暂停请求
	input wire                   stallreq_from_id,

	//来自baseram的暂停请求
	input wire 					 stallreq_from_baseram,

	output wire              	 stall
);

	assign stall = stallreq_from_id | stallreq_from_baseram;

endmodule //ctrl