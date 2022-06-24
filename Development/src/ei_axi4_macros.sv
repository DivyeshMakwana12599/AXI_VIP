`define PERIOD 5
`define VERBOSITY LOW                      // `"`VERBOSITY`"
`define ASSERTION ON
`define COVERAGE ON
`define DATA_WIDTH 64
`define ADDR_WIDTH 32
`define BUS_BYTE_LANES (`DATA_WIDTH)/8
`define AXI_VERSION AXI4
`define VMST vif.MST.master_driver_cb
`define VSLV vif.SLV.slave_driver_cb


typedef enum bit [1:0] {FIXED, INCR, WRAP} burst_type_e;
typedef enum bit [1:0] {OKAY, EXOKAY, SLVERR, DECERR} response_e;
typedef enum bit [1:0] {READ, READ_WRITE, WRITE} transaction_type_e;
typedef enum bit [2:0] {NO_ERROR, ERROR_4K_BOUNDARY, ERROR_WRAP_UNALLIGNED, 
                        ERROR_WRAP_LEN, ERROR_FIXED_LEN, 
                        ERROR_EARLY_TERMINATION}possible_errors_e;
typedef enum bit {PASS, FAIL} RESULT_e; //used in checker
typedef enum bit {ALIGNED, UNALIGNED} addr_type_e;
typedef enum bit {PASSIVE, ACTIVE} AGENT_TYPE_e;

`define SV_RAND_CHECK(r) \
\
  do begin \
      if ((!r)) begin \
        $fatal("%s:%0d: Randomization Failed", \
      `__FILE__, `__LINE__); \
    end \
end while (0)

