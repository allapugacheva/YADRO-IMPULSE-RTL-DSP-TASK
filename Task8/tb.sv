module tb();

	logic clk, rst, control, red, yellow, green;
	logic [3:0] state;

	traffic_light dut (
		.clk     (clk),
		.rst     (rst),
		.control (control),
		.red     (red),
		.yellow  (yellow),
		.green   (green)
	);
	
	assign state = dut.state;
	
	initial begin
		void'($urandom(42));
	end
	
	initial begin
		rst = 1'b1;
		
		#10 rst = 1'b0;
	end
	
	initial begin
		clk = 1'b0;
		
		forever #5 clk = ~clk;
	end
	
	initial begin
		control = 1'b0;
		@(negedge rst);
		
		repeat(50) begin
			control = $urandom_range(0, 1);
			@(posedge clk);
		end
		
		$finish;
	end

endmodule