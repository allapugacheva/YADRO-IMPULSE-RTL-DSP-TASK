module ram # (
	parameter ADDR_LEN = 8,
				 DATA_LEN = 8
) (
	input                   clk,
	
	input                   write,
	input [ADDR_LEN - 1:0]  inaddr,
	input [DATA_LEN - 1:0]  indata,
	
	input                   read,
	input  [ADDR_LEN - 1:0] outaddr,
	output [DATA_LEN - 1:0] outdata
);

	localparam MEMORY_SIZE = 2 ** ADDR_LEN;

	logic [DATA_LEN - 1:0] memory [MEMORY_SIZE];
	
	always_ff @ (posedge clk)
		if (write)
			memory[inaddr] <= indata;
	
	assign outdata = read ? memory[outaddr] : 'z;

endmodule