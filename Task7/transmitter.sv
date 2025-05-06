module transmitter # (
	parameter DATA_LEN = 8
) (
	input                         clk_source,
	input                         clk_target,
	input                         rst_target,
	
	input        [DATA_LEN - 1:0] indata,
	output logic [DATA_LEN - 1:0] outdata
);
	
	logic clk_syn;

	synchronizer syn (
		.clk_target (clk_target),
		.rst        (rst_target),
		
		.clk_source (clk_source),
		.clk_syn    (clk_syn)
	);
	
	always_ff @ (posedge clk_syn or posedge rst_target)
		if (rst_target)
			outdata <= 'z;
		else
			outdata <= indata;

endmodule