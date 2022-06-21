/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_assertion.sv
Title 		: assertion module for Project
Project 	: AMBA AXI-4 SV VIP
Created On  : 06-June-22
Developers  : Sandip Mali
Purpose 	: assertion module for declaring all assertion which mention in assertion
			  plan document

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

parameter BUS_WIDTH = 64;
parameter BUS_BYTE_LANES = 8;

module assertion(
  input logic aclk,
    	logic aresetn,
	    logic [31:0] awaddr,
	    logic [7:0] awlen,
        logic [2:0] awsize,
        logic [1:0] awburst,
 	    logic awvalid,
	    logic awready,
        logic [BUS_WIDTH - 1:0] wdata,
	    logic [BUS_BYTE_LANES - 1:0] wstrb,
	    logic wlast,
	    logic wvalid,
	    logic wready,
  	    logic [1:0] bresp,
	    logic bvalid,	
	    logic bready,		
	    logic [31:0] araddr,
	    logic [1:0] arburst,
	    logic [7:0] arlen,
	    logic [2:0] arsize,
	    logic arvalid,
	    logic arready,
	    logic [BUS_WIDTH - 1:0] rdata,
	    logic [1:0] rresp,
	    logic rlast,
	    logic rvalid,
	    logic rready);

	/**
	\*   Method name             : pass_print_f()
	\*   Parameters passed       : None
	\*   Returned parameters     : None
	\*   Description             : printing statement pass for assertion 
	*/
	function void pass_print_f();
	  $display("*************************************************************************");
	  $display("*\t @%0t >>>> %m >>>> ASSETION PASSED \t        *",$time);
	  $display("*************************************************************************");
	endfunction :pass_print_f

	/**
	\*   Method name             : fail_print_f()
	\*   Parameters passed       : None
	\*   Returned parameters     : None
	\*   Description             : printing statement fail for assertion 
	*/
	function void fail_print_f();
	  $display("*************************************************************************");
	  $display("*\t @%0t >>>> %m >>>> ASSERTION FAILED \t        *",$time);
	  $display("*************************************************************************");
	endfunction :fail_print_f

	//logic Temp_ARESETn;
	assign #1 temp_aresetn = aresetn;
	//assign #1 temp_aclk = aclk;
	
	/**
	\*   property name           : assertion_at_rst_asserted()
	\*   Parameters passed       : signals [awvalid, arvalid, wvalid, bavlid, rvalid]
	\*   Returned parameters     : None
	\*   Description             : property fpr signals if reset is asserted 
	*/
	property assertion_at_rst_asserted(signal);
	  @(negedge temp_aresetn) 1'b1 -> !(signal);
	endproperty
	
	
	/**
	\*   property name           : assertion_after_rst_deassertion()
	\*   Parameters passed       : signals [awvalid, arvalid, wvalid]
	\*   Returned parameters     : None
	\*   Description             : property fpr signals if reset is deasserted
	*/
	property assertion_after_rst_deassertion(signal); 
	  @(posedge aclk) $rose(aresetn) |-> ##1 signal[=1:$];
	endproperty

	
	/**
	\*   property name           : assertion_invalid_signal()
	\*   Parameters passed       : vaid_signal[asresetn,awvalid,arvalid,bvlid,rvalid,wvalid],
	\*			       un_signal [awvalid, arvalid, wvalid, bvalid, rvalid,]
	\*   Returned parameters     : None
	\*   Description             : property if reset and valid signal is there 
    \*                             then signal can not be x or z
	*/
	property assertion_invalid_signal(valid_signal,un_signal);
	  @(posedge aclk) valid_signal |-> !($isunknown(un_signal));
	endproperty


	/**
	\*   property name           : assertion_for_stable_signal()
	\*   Parameters passed       : valid_signal[valid signals], ready_signal
    \*                          [ready signals], st_signal[control signals]
	\*   Returned parameters     : None
	\*   Description             : property for signal should stable till handshaking
	*/
	property assertion_for_stable_signal(valid_signal,ready_signal,st_signal);
	  @(posedge aclk) $rose(valid_signal) |-> ##1 $stable(st_signal)[*0:$] ##0 ready_signal;
	endproperty
	
	/**
	\*   property name           : assertion_addr_channel_dependency()
	\*   Parameters passed       : None
	\*   Returned parameters     : None
	\*   Description             : The slave must wait for both AWVALID and AWREADY
    \*                             to be asserted before asserting BVALID
	*/
   property assertion_addr_channel_dependency;
       @(posedge aclk) (awvalid && awready) |-> ##[1:$]bvalid;
   endproperty 
	
	/**
	\*   property name           : assertion_data_channel_dependency()
	\*   Parameters passed       : None
	\*   Returned parameters     : None
	\*   Description             : The slave must wait for WVALID, WREADY, and 
    \*                             WLAST to be asserted before asserting BVALID
	*/
   property assertion_data_channel_dependency;
       @(posedge aclk) (wvalid && wready && wlast) |-> ##[1:$]bvalid;
   endproperty

    /**
	\*   property name           : assertion_w_r_last()
	\*   Parameters passed       : None
	\*   Returned parameters     : None
    \*   Description             : wlast and rlast should be come at last
	*/
   sequence valid_ready(valid,ready);
       ##[0:$] (valid & ready);
   endsequence

   sequence dynamic_repeat(handshake,len);
       int count;
       (1'b1,count = len) ##0 first_match((handshake,count = count-1'b1) 
       [*1:$] ##0 wlast) ##0 count==0;
   endsequence
 
   property assertion_w_r_last(avalid,aready,length,valid,ready,last);
       int len;
       @(posedge aclk) (avalid & aready,len = length + 1) |-> 
       dynamic_repeat(valid_ready(valid,ready),len);
   endproperty 

	// ASSERT PROPERTY FOR AWVALID IF RESET IS ASSERTED
	AXI4_ASSERTION_002 : 
    assert property (assertion_at_rst_asserted(awvalid)) 
	    pass_print_f();
	    else begin
            fail_print_f();
            $display(" ASSERT PROPERTY FOR AWVALID IF RESET IS ASSERTED");
	    end

	// ASSERT PROPERTY FOR WVALID IF RESET IS ASSERTED
	AXI4_ASSERTION_003 :
    assert property (assertion_at_rst_asserted(wvalid))
        pass_print_f();
        else begin
            $display("ASSERT PROPERTY FOR WVALID IF RESET IS ASSERTED");
            fail_print_f();
        end

	// ASSERT PROPERTY FOR BVALID IF RESET IS ASSERTED
	AXI4_ASSERTION_005 : 
    assert property (assertion_at_rst_asserted(bvalid))
        pass_print_f();
        else begin
            $display("ASSERT PROPERTY KFOR BVALID IF RESET IS ASSERTED");
            fail_print_f();
        end

	// ASSERT PROPERTY FOR ARVALID IF RESET IS ASSERTED
	AXI4_ASSERTION_001 : 
    assert property (assertion_at_rst_asserted(arvalid))
        pass_print_f();
        else begin
            $display("ASSERT PROPERTY FOR AEVALID IF RESET IS ASSERTED");
            fail_print_f();
        end

	// ASSERT PROPERTY FOR RVALID IF RESET IS ASSERTED
	AXI4_ASSERTION_004 : 
    assert property (assertion_at_rst_asserted(rvalid)) 
        pass_print_f();
        else begin
            $display("ASSERT PROPERTY FOR RVALID IS ASSERTED");
            fail_print_f();
        end

	// ASSERT PROPERTY FOR AWVALID AFTER DEASSERTION OF RESET
	AXI4_ASSERTION_007 : 
    assert property (assertion_after_rst_deassertion(awvalid))
        pass_print_f();
        else begin
            $display("ASSERT PROPERTY FOR AWVALID AFTER DEASSERTION OF RESET");
            fail_print_f();
        end

	// ASSERT PROPERTY FOR WVALID AFTER DEASSERTION OF RESET
	AXI4_ASSERTION_008 : 
    assert property (assertion_after_rst_deassertion(wvalid)) 
        pass_print_f();
        else begin
            $display("ASSERT PROPERTY FOR WVALID AFTER DEASSERTION OF RESET");
            fail_print_f();
        end

	// ASSERT PROPERTY FOR ARVALID AFTER DEASSERTION OF RESET
	AXI4_ASSERTION_006 : 
    assert property (assertion_after_rst_deassertion(arvalid)) 
        pass_print_f();
        else begin
            $display("ASSERT PROPERTY FOR ARVALID AFTER DEASSERTION OF RESET");
            fail_print_f();
        end

	// ASSERT PROPERTY FOR IF RESET IS THERE THEN AWVALID CAN NOT DRIVE X OR Z
	AXI4_ASSERTION_010 : 
    assert property (assertion_invalid_signal(aresetn,awvalid)) 
        pass_print_f();
        else begin
            $display("ASSERT PROPERTY IF REST IS THERE THEN AWVALID CAN NOT DRIVE X/Z");
         fail_print_f();
        end

	// ASSERT PROPERTY FOR IF RESET IS THERE THEN WVALID CAN NOT DRIVE X OR Z
	AXI4_ASSERTION_011 : 
    assert property (assertion_invalid_signal(aresetn,wvalid)) 
        pass_print_f();
        else begin 
            $display("ASSERT PROPERTY FOR IF RESET IS THERE AND THEN WVALID CAN NOT DRIVE X/Z");
            fail_print_f();
        end
	
	// ASSERT PROPERTY FOR IF RESET IS THERE THEN BVALID CAN NOT DRIVE X OR Z
	AXI4_ASSERTION_013 : 
    assert property (assertion_invalid_signal(aresetn,bvalid))pass_print_f();
    else begin
        $display("ASSERT PROPERTY FOR IF RESET IS THERE THEN BVALID CAN NOT DRIVE X/Z");
        fail_print_f();
    end

	// ASSERT PROPERTY FOR IF RESET IS THERE THEN ARVALID CAN NOT DRIVE X OR Z
	AXI4_ASSERTION_009 : 
        assert property (assertion_invalid_signal(aresetn,arvalid)) pass_print_f();
        else begin
            $display("ASSERT PROPERTY FOR IF RESET IS THERE THEN ARVALID CAN NOT DRIVE X/Z");
            fail_print_f();
        end
	
	// ASSERT PROPERTY FOR IF RESET IS THERE THEN RVALID CAN NOT DRIVE X OR Z
	AXI4_ASSERTION_012 : 
        assert property (assertion_invalid_signal(aresetn,rvalid)) pass_print_f();
        else begin
            $display("ASSERT PROPERTY FOR IF RESET IS THERE THEN RVALID CAN NOT DRIVE X/Z");
            fail_print_f();
        end

	//"AWADDR remains stable when AWVALID is asserted and AWREADY is LOW"
	AXI4_ASSERTION_014 :
        assert property (assertion_for_stable_signal(awvalid,awready,awaddr)) pass_print_f();
        else begin
            $display("AWADDR REMAINS STABLE UNTILL WHEN AWVALID AND AWREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//AWLEN remains stable when AWVALID is asserted and AWREADY is LOW
	AXI4_ASSERTION_016 : 
        assert property (assertion_for_stable_signal(awvalid,awready,awlen)) pass_print_f();
        else begin
             $display("AWLEN REMAINS STABLE UNTILL WHEN AWVALID AND AWREADY HANDSHAKING DONE");
             fail_print_f();
        end
	//"AWSIZE must remains stable when AWVALID is asserted and AWREADY is LOW"
	AXI4_ASSERTION_018 : 
        assert property (assertion_for_stable_signal(awvalid,awready,awsize)) pass_print_f();
        else begin
             $display("AWSIZE REMAINS STABLE UNTILL WHEN AWVALID AND AWREADY HANDSHAKING DONE");
             fail_print_f();
         end

	//"AWBURST remains stable when AWVALID is asserted and AWREADY is LOW"
	AXI4_ASSERTION_020 :
        assert property (assertion_for_stable_signal(awvalid,awready,awburst)) pass_print_f();
        else begin
             $display("AWBURST REMAINS STABLE UNTILL WHEN AWVALID AND AWREADY HANDSHAKING DONE");
             fail_print_f();
         end

	//"ARADDR remains stable when ARVALID is asserted and ARREADY is LOW"
	AXI4_ASSERTION_021 : 
        assert property (assertion_for_stable_signal(arvalid,arready,araddr)) pass_print_f();
        else begin
             $display("ARADDR REMAINS STABLE UNTILL WHEN ARVALID AND ARREADY HANDSHAKING DONE");
             fail_print_f();
         end

	//"ARLEN remains stable when ARVALID is asserted and ARREADY is LOW"
	AXI4_ASSERTION_023 : 
        assert property (assertion_for_stable_signal(arvalid,arready,arlen)) pass_print_f();
        else begin
            $display("ARLEN REMAINS STABLE UNTILL WHEN ARVALID AND ARREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//"ARSIZE remains stable when ARVALID is asserted, and ARREADY is LOW"
	AXI4_ASSERTION_025 : 
        assert property (assertion_for_stable_signal(arvalid,arready,arsize)) pass_print_f();
        else begin
            $display("ARSIZE REMAINS STABLE UNTILL WHEN ARVALID AND ARREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//ARBURST remains stable when ARVALID is asserted, and ARREADY is LOW
	AXI4_ASSERTION_027 : 
        assert property (assertion_for_stable_signal(arvalid,arready,arburst)) pass_print_f();
        else begin
            $display("ARBURST REMAINS STABLE UNTILL WHEN ARVALID AND ARREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//RDATA REMAINS STABLE UNTILL WHEN RVALID AND RREADY HANDSHAKING DONE
	AXI4_ASSERTION_028 : 
        assert property (assertion_for_stable_signal(rvalid,rready,rdata)) pass_print_f();
        else begin
            $display("RDATA REMAINS STABLE UNTILL WHEN RVALID AND RREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//RRESP remains stable when RVALID is asserted, and RREADY is LOW
	AXI4_ASSERTION_030 : 
        assert property (assertion_for_stable_signal(rvalid,rready,rresp)) pass_print_f();
        else begin
            $display("RRESP REMAINS STABLE UNTILL WHEN RVALID AND RREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//RLAST remains stable when RVALID is asserted, and RREADY is LOW
	AXI4_ASSERTION_032 : 
        assert property (assertion_for_stable_signal(rvalid,rready,rresp)) pass_print_f();
        else begin
            $display("RLAST REMAINS STABLE UNTILL WHEN RVALID AND RREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//WVALID and WDATA must remain stable until WREADY is asserted
	AXI4_ASSERTION_035 : 
        assert property (assertion_for_stable_signal(wvalid,wready,wdata)) pass_print_f();
        else begin
            $display("WDATA REMAINS STABLE UNTILL WHEN WVALID AND WREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//WSTRB remains stable when WVALID is asserted and WREADY is LOW.
	AXI4_ASSERTION_037 : 
        assert property (assertion_for_stable_signal(wvalid,wready,wstrb)) pass_print_f();
	    else begin
            $display("WSTRB REMAINS STABLE UNTILL WHEN WVALID AND WREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//"WLAST remains stable when WVALID is asserted and WREADY is LOW"
	AXI4_ASSERTION_039 : 
        assert property (assertion_for_stable_signal(wvalid,wready,wlast)) pass_print_f();
        else begin
            $display("WLAST REMAINS STABLE UNTILL WHEN WVALID AND WREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//"BRESP remains stable when BVALID is asserted and BREADY is LOW"
	AXI4_ASSERTION_041 : 
        assert property (assertion_for_stable_signal(bvalid,bready,bresp)) pass_print_f();
        else begin
            $display("BRESP REMAINS STABLE UNTILL WHEN BVALID AND BREADY HANDSHAKING DONE");
            fail_print_f();
        end

	//A value "X" (undefined) or "Z" (high-impedence) on AWADDR is not allowed when AWVALID is HIGH
	AXI4_ASSERTION_015 : 
        assert property (assertion_invalid_signal(awvalid,awaddr)) pass_print_f();
        else begin
            $display("VALUE X/Z ON AWADDR IS NOT ALLOWED WHEN AWVALID IS HIGH");
            fail_print_f();
        end

	//A value of "X" (undefined) or Z" (high-impedence) on AWLEN is not allowed when AWVALID is HIGH
	AXI4_ASSERTION_017 : 
        assert property (assertion_invalid_signal(awvalid,awlen)) pass_print_f();
        else begin
            $display("VALUE X/Z ON AWLEN IS NOT ALLOWED WHEN AWVALID IS HIGH");
            fail_print_f();
        end

	//A value of "X " (undefined) or "Z" (high-impedence)on AWSIZE is not permitted when AWVALID is HIGH
	AXI4_ASSERTION_019 : 
        assert property (assertion_invalid_signal(awvalid,awsize)) pass_print_f();
        else begin
            $display("VALUE X/Z ON AWSIZE IS NOT ALLOWED WHEN AWVALID IS HIGH");
            fail_print_f();  
        end

	//A value "X" (undefined) or "Z" (high-impedence) on ARADDR is not allowed when ARVALID is HIGH
	AXI4_ASSERTION_022 : 
        assert property (assertion_invalid_signal(arvalid,araddr)) pass_print_f();
        else begin
            $display("VALUE X/Z ON ARADDR IS NOT ALLOWED WHEN ARVALID IS HIGH");
            fail_print_f();
        end

	//A value of "X" (undefined) or "Z" (high-impedence) on ARLEN is not allowed when ARVALID is HIGH
	AXI4_ASSERTION_024 : 
        assert property (assertion_invalid_signal(arvalid,arlen)) pass_print_f();
        else begin
            $display("VALUE X/Z ON ARLEN IS NOT ALLOWED WHEN ARVALID IS HIGH");
            fail_print_f();
        end

	//"A value of ""X"" (undefined) or ""Z"" (high-impedence) on ARSIZE is not permitted when ARVALID is HIGH"
	AXI4_ASSERTION_026 : 
        assert property (assertion_invalid_signal(arvalid,arsize)) pass_print_f();
        else begin
            $display("VALUE X/Z ON ARSIZE IS NOT ALLOWED WHEN ARVALID IS HIGH");
            fail_print_f();
        end

	//A value of X or "Z" (high-impedence) on RRESP is not permitted when RVALID is HIGH.
	AXI4_ASSERTION_031 : 
        assert property (assertion_invalid_signal(rvalid,rresp)) pass_print_f();
        else begin
            $display("VALUE X/Z ON RRESP IS NOT ALLOWED WHEN ARVALID IS HIGH");
            fail_print_f();
        end

	//A value of X or "Z" (high-impedence) on RLAST is not permitted when RVALID is HIGH.
	AXI4_ASSERTION_033 : 
        assert property (assertion_invalid_signal(rvalid,rlast)) pass_print_f();
	    else begin
            $display("VALUE X/Z ON RLAST IS NOT ALLOWED WHEN RVALID IS HIGH");
            fail_print_f();
        end

	//A value of "X" or "Z" (high-impedence) on WSTRB is not permitted when WVALID is HIGH.
	AXI4_ASSERTION_038 : 
        assert property (assertion_invalid_signal(wvalid,wstrb)) pass_print_f();
	    else begin 
            $display("VALUE X/Z ON WSTRB IS NOT ALLOWED WHEN WVALID IS HIGH");
            fail_print_f();
        end

	//A value of X or "Z" (high-impedence) on BRESP is not permitted when BVALID is HIGH
	AXI4_ASSERTION_042 : 
        assert property (assertion_invalid_signal(bvalid,bresp)) pass_print_f();
        else begin
            $display("VALUE X/Z ON BRESP IS NOT ALLOWED WHEN BVALID IS HIGH");
            fail_print_f();
        end

    //A value of "X" (undefined) or "Z" (high-impedence) on WDATA valid byte lanes is not allowed when WVALID is HIGH
    AXI_ASSERTION_036 :
        assert property (assertion_invalid_signal(wvalid,wdata)) pass_print_f();
        else begin
            $display("VALUE X/Z ON WDATA IS NOT ALLOWED WHEN WVALID IS HIGH");
           fail_print_f();
        end

    //A value of "X" (undefined) or "Z" (high-impedence) on RDATA valid byte lanes is not allowed when RVALID is HIGH
    AXI_ASSERTION_029 :
        assert property (assertion_invalid_signal(rvalid,rdata)) pass_print_f();
        else begin
            $display("VALUE X/Z PN RDATA IS NOT ALLOWED WHEN RVALID IS HIGH");
            fail_print_f();
        end

    // The slave must wait for both AWVALID and AWREADY to be asserted before asserting BVALID
    AXI_ASSERTION_043 : 
        assert property (assertion_addr_channel_dependency) pass_print_f();
        else begin
            $display("BVALID SHOULD BE ASSERTED AFTER ADDRESS CHANNEL HANDSHAKING DONE");
            fail_print_f();
        end

    // "The slave must wait for WVALID, WREADY, and WLAST to be asserted before asserting BVALID"
    AXI_ASSERTION_044 :
        assert property (assertion_data_channel_dependency) pass_print_f();
        else begin
            $display("BVALID SHOULD BE ASSERTED AFTER DATA CHANNEL HANDSHAKING IS DONE AND WLAST IS ASSERTED");
            fail_print_f();
        end

    // RLAST must come only afterwards of  the last read data transfer.
    AXI_ASSERTION_040 :
        assert property (assertion_w_r_last(awvalid,awready,awlen,wvalid,wready,wlast)) pass_print_f();
        else begin
            $display("WLAST MUST COME ONLY AFTERWARDS OF THE LAST WRITE DATA TRANSFER");
            fail_print_f();
        end

    // BLAST must come only afterwards of  the last read data transfer.
    AXI_ASSERTION_034 :
        assert property (assertion_w_r_last(arvalid,arready,arlen,rvalid,rready,rlast)) pass_print_f();
        else begin
            $display("RLAST MUST COME AFTERWARDS OF THE LAST READ DATA TRANSFER");
            fail_print_f();
        end

endmodule :assertion






