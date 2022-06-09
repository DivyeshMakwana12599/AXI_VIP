//macros

`define PERIOD 5
`define VERBOSITY LOW                      // `"`VERBOSITY`"
`define ASSERTION ON
`define COVERAGE ON
`define DATA_WIDTH 64
`define ADDR_WIDTH 32
`define BUS_BYTE_LANES `DATA_WIDTH/8
`define AXI_VERSION AXI4
`define VMST vif.MST.master_cb 


//<<<<<<< HEAD

typedef enum bit [1:0] {FIXED, INCR, WRAP} burst_type_e;
typedef enum bit [1:0] {OKAY, EXOKAY, SLVERR, DECERR} response_e;
typedef enum bit [1:0] {READ, WRITE, READ_WRITE} transaction_type_e;
typedef enum bit [2:0] {NO_ERROR, ERROR_4K_BOUNDARY, ERROR_WRAP_UNALLIGNED, 
                        ERROR_WRAP_LEN, ERROR_FIXED_LEN, 
                        ERROR_EARLY_TERMINATION}possible_errors_e;
typedef enum bit {PASS, FAIL} RESULT_e; //used in checker

//=======
//>>>>>>> 2c7c973ea4f762e9c89977595edd522ac6c39c24
`define SV_RAND_CHECK(r) \
	do begin \
		if ((r)) begin \
			$display("%s:%0d: Randomization passed %b", \
			`__FILE__, `__LINE__, r); \
		end \
end while (0)
