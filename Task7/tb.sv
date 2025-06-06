module tb();

	logic clk_source, clk_target, rst_target;
	logic [7:0] indata, outdata;

	transmitter dut (
		.clk_source (clk_source),
		.clk_target (clk_target),
		.rst_target (rst_target),
		
		.indata     (indata),
		.outdata    (outdata)
	);
	
	mailbox#(logic [7:0]) monitor = new();
	
	initial begin
		clk_source             <= 1'b0;
		
		forever #10 clk_source <= ~clk_source;
	end
	
	initial begin
		clk_target            <= 1'b0;
		
		forever #5 clk_target <= ~clk_target;
	end
	
	initial begin
		rst_target     <= 1'b1;
		
		#10 rst_target <= 1'b0;
	end
	
	initial begin
	    logic [7:0] indata_t;
		indata <= 'z;
	
		repeat (30) begin
			@(posedge clk_source);
			indata_t = $urandom_range(0, 256);
			monitor.put(indata_t);
			
			indata <= indata_t;
		end
		
		$finish;
	end
	
	initial begin
		logic [7:0] expected;
	
		@(negedge rst_target);
	
		forever begin
			@(posedge clk_source);
			
			monitor.get(expected);
			if (expected !== outdata) $error("%0t BAD RESULT. REAL: %d. EXPECTED: %d", $time(), outdata, expected);
		end
	end

endmodule