module synchronizer (
	input  clk_target,
	input  rst,
	
	input  clk_source,
	output clk_syn
);

	logic syn1, syn2;
	
	always_ff @ (posedge clk_target or posedge rst)
		if (rst) begin
			syn1 <= '0;
			syn2 <= '0;
		end
		else begin
			syn1 <= clk_source;
			syn2 <= syn1;
		end
		
	assign clk_syn = syn2;

endmodule