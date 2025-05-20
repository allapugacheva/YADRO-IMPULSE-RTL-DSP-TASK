`timescale 1ns / 1ps
module tb();

	logic clk, rst;
	logic push;
	logic [7:0] indata;
	logic pop;
	logic [7:0] outdata;
	logic empty, full;
	logic [14:0] wr_addr, rd_addr;

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
	
	assign wr_addr = dut.wr_addr;
	assign rd_addr = dut.rd_addr;
	
	mailbox#(logic [7:0]) monitor = new();
	
	initial begin
		clk            <= 1'b0;
		
		forever #5 clk <= ~clk;
	end
	
	initial begin
		rst     <= 1'b1;
		
		#10 rst <= 1'b0;
	end
	
	initial begin
	   logic make_push, make_pop;
	   logic [7:0] indata_t;
	   push   <= 1'b0;
	   indata <= 'z;
	   pop    <= 1'b0;
		
	   @(negedge rst);
	   repeat (10) @(posedge clk);
		
	   repeat (50) begin
			
           make_push = $urandom_range(0, 1);
           if (make_push & ~full) begin
              indata_t = $urandom_range(0, 256);
              monitor.put(indata_t);
           
              indata <= indata_t;
              push   <= 1'b1;
          end
          else begin
              push   <= 1'b0;
              indata <= 'z;
          end 
				
		  if (~empty)
			  pop <= $urandom_range(0, 1);
		  else
			  pop <= 1'b0;
				
		   @(posedge clk);
	   end
		
	   $finish;
	end
	
	initial begin
	   logic [7:0] expected;
	
	   @(posedge clk);
	   forever begin
	       if (pop) begin
	           @(posedge clk);
	           monitor.get(expected);
	           if (outdata !== expected) $error("%0t BAD RESULT. REAL: %d. EXPECTED: %d", $time(), outdata, expected);
	       end
	       else
	           @(posedge clk);
        end
    end

endmodule
