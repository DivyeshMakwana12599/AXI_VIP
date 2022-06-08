//macros

`define PERIOD 5
`define VERBOSITY LOW                      // `"`VERBOSITY`"
`define ASSERTION ON
`define COVERAGE ON
`define BUS_WIDTH 32
`define AXI_VERSION AXI4

`define SV_RAND_CHECK(r) \
	do begin \
		if ((r)) begin \
			$display("%s:%0d: Randomization passed %b", \
			`__FILE__, `__LINE__, r); \
		end \
end while (0)
