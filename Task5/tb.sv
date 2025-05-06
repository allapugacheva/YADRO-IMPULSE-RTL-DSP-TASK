module tb();

	logic clk, rst;
	logic push;
	logic [7:0] indata;
	logic pop;
	logic [7:0] outdata;
	logic empty, full;

	fifo dut (
		.clk     (clk),
		.rst     (rst),
		
		.push    (push),
		.indata  (indata),
		
		.pop     (pop),
		.outdata (outdata),
		
		.empty   (empty),
		.full    (full)
	);
	
	mailbox#(logic [7:0]) monitor = new();
	
	initial begin
		void'($urandom(42));
	end
	
	initial begin
		clk = 1'b0;
		
		forever #5 clk = ~clk;
	end
	
	initial begin
		rst = 1'b1;
		
		#10 rst = 1'b0;
	end
	
	initial begin
		push = 1'b0;
		indata = 'z;
		pop = 1'b0;
		
		@(negedge rst);
		
		repeat (30) begin
			
			if (~full) begin
				push = $urandom_range(0, 1);
				
				if (push) begin
					indata = $urandom();
					monitor.put(indata);
				end
				else
					indata = 'z;
			end
			else begin
				push = 1'b0;
				indata = 'z;
			end
				
			if (~empty)
				pop = $urandom_range(0, 1);
			else
				pop = 1'b0;
				
			@(posedge clk);
		end
		
		$finish;
	end
	
	initial begin
		logic [7:0] expected;
	
		forever begin
			@(posedge clk); #1
			if (pop) begin
				monitor.get(expected);
				if (outdata !== expected) $error("%0t BAD RESULT. REAL: %d. EXPECTED: %d", $time(), outdata, expected);
			end
		end
	end

endmodule