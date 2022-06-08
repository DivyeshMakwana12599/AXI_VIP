/*
-------------------------------------------------------------------------
-------------------------------------------------------------------------
File name 	: ei_axi4_environment.sv
Title 		: Environment
Project 	: AMBA AXI-4 SV VIP
Created On  : 07-June-22
Developers  : Shivam Prasad
Purpose 	: Environment class contains Slave agent, Master agent, Reference Model, checker and Scoreboard.
 
Assumptions :
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
Revision	:0.1
-------------------------------------------------------------------------------
*/

class ei_axi4_environment_c ();

	ei_axi4_master_agent_c m_agt;
    ei_axi4_slave_agent_c s_agt;
    ei_axi4_refrance_model_c ref_model;
    ei_axi4_scoreboard_c scb;
	ei_axi4_checker_c check;
	ei_axi4_transaction_c mtr;
	ei_axi4_env_config env_cfg
	
	mailbox#(ei_axi4_transaction) mon2scb;
    mailbox#(ei_axi4_transaction) mon2ref;
    mailbox#(ei_axi4_transaction) ref2scb;
	
	virtual ei_axi4_interface vif;

////////////////////////////////////////////////////////////////////////////////
//   Method name          : new()
//   Parameters passed    : interface vif
//   Returned parameters  : None
//   Description          : links interface
////////////////////////////////////////////////////////////////////////////////	
	function new(ei_axi4_interface vif, ei_axi4_env_config env_cfg);
		this.vif = vif;
		this.env_cfg = env_cfg;
	endfunction

////////////////////////////////////////////////////////////////////////////////
//   Method name          : build_components()
//   Parameters passed    : None
//   Returned parameters  : None
//   Description          : Builds environment Components
////////////////////////////////////////////////////////////////////////////////	
	function void build_components();

        mon2ref = new();
        mon2scb = new();
        ref2scb = new();
        ref_model = new(.ref2scb(ref2scb),.mon2ref(mon2ref));
        scb = new(.ref2scb(ref2scb),.mon2scb(mon2scb));
        m_agt = new(mon2ref);
        s_agt = new(mon2scb,env_cfg);
		check = new();
        m_agt.vif = vif;
        s_agt.vif = vif;
      	m_agt.build();
        s_agt.build();
		check.build();
		
    endfunction : build_components

////////////////////////////////////////////////////////////////////////////////
//   Method name          : run_components()
//   Parameters passed    : None
//   Returned parameters  : None
//   Description          : runs environment components
////////////////////////////////////////////////////////////////////////////////	
	task run_components();
        
        fork
            m_agt.run();
            s_agt.run();
			//check.run();
            scb.run();
            ref_model.run();
        join

    endtask : run_components

endclass :ei_axi4_environment_c