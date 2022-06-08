/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_helper_functions.sv
Title 			: Helper Functions for Project
Project 		: AMBA AXI-4 SV VIP
Created On  : 03-June-22
Developers  : Divyesh Makwana
Purpose 		: Helper Function like calculating strobe finding size aligned address
 
Assumptions : As per the Feature plan All the pins are not declared here
Limitations : 
Known Errors: 
-------------------------------------------------------------------------
-------------------------------------------------------------------------
Copyright (c) 2000-2022 eInfochips - All rights reserved
This software is authored by eInfochips and is eInfochips intellectual
property, including the copyrights in all countries in the world. This
software is provided under a license to use only with all other rights,
including ownership rights, being retained by eInfochips
This file may not be distributed, copied, or reproduced in any manner,
electronic or otherwise, without the express written consent of
eInfochips 
-------------------------------------------------------------------------------
Revision:0.1
-------------------------------------------------------------------------------
*/

package ei_axi4_helper_functions;

	function bit [31:0] calculate_size_aligned_address (
		bit [31:0] address, bit [2:0] awsize
	);
		return (address - (address % (2 ** awsize)));
	endfunction

	function bit [(`BUS_BYTE_LANES) - 1:0] get_wstrb (
		bit [31:0] awaddr, 
		bit [1:0] awburst, 
		bit [2:0] awsize, 
		bit [7:0] awlen, 
		int unsigned beat_no
	); 
		bit [5:0] transfer_size;
		transfer_size = 2 ** awsize;

		if(awburst == INCR) begin
			if(beat_no == 0) begin
				get_wstrb = (2**(transfer_size)) - 1;
				get_wstrb = (get_wstrb << (awaddr % transfer_size)) & get_wstrb;
				awaddr = calculate_size_aligned_address(awaddr, awsize);
				return (get_wstrb << (awaddr % (`BUS_BYTE_LANES)));
			end
			awaddr = awaddr + (beat_no * (transfer_size));
			awaddr = calculate_size_aligned_address(awaddr, awsize);
			return(((2 ** transfer_size) - 1) << (awaddr % (`BUS_BYTE_LANES)));
		end

		else if(awburst == WRAP) begin
			bit [31:0] lower_wrap_boundary;
			bit [31:0] upper_wrap_boundary;

			lower_wrap_boundary = awaddr - (awaddr % (transfer_size * (awlen + 1)));
			upper_wrap_boundary = (lower_wrap_boundary + (transfer_size * ((awlen) + 1)));

			if((awaddr + (beat_no * transfer_size)) < upper_wrap_boundary) begin
				awaddr = awaddr + (beat_no * transfer_size);
				return(((2**(transfer_size)) - 1) << (awaddr % (`BUS_BYTE_LANES)));
			end

			else begin
				awaddr = (awaddr + (beat_no * transfer_size)) - (upper_wrap_boundary) + (lower_wrap_boundary);
				return(((2**(transfer_size)) - 1) << (awaddr % (`BUS_BYTE_LANES)));
			end
		end
		else if(awburst == FIXED) begin
			get_wstrb = (2**(transfer_size)) - 1;
			get_wstrb = (get_wstrb << (awaddr % transfer_size)) & get_wstrb;
			awaddr = calculate_size_aligned_address(awaddr, awsize);
			return (get_wstrb << (awaddr % (`BUS_BYTE_LANES)));
		end
	endfunction

endpackage
