module fifo # (
	parameter LENGTH = 8,
				 DATA_LEN = 8,
				 ADDR_LEN = 8
) (
	input                   clk,
	input                   rst,
	
	input                   push,
	input  [DATA_LEN - 1:0] indata,
	
	input                   pop,
	output [DATA_LEN - 1:0] outdata,
	
	output                  empty,
	output                  full
);

	localparam MAX_PTR = LENGTH - 1;

	logic wr_ptr_odd_circle, rd_ptr_odd_circle;
	logic [ADDR_LEN - 1:0] wr_ptr, rd_ptr;

	always_ff @ (posedge clk or posedge rst)
		if (rst) begin
			wr_ptr <= '0;
			wr_ptr_odd_circle <= 1'b0;
		end
		else if (push) begin
			if (wr_ptr == MAX_PTR) begin
				wr_ptr <= '0;
				wr_ptr_odd_circle <= ~wr_ptr_odd_circle;
			end
			else begin
				wr_ptr <= wr_ptr + 1'b1;
			end
		end
		
	always_ff @ (posedge clk or posedge rst)
		if (rst) begin
			rd_ptr <= '0;
			rd_ptr_odd_circle <= 1'b0;
		end
		else if (pop) begin
			if (rd_ptr == MAX_PTR) begin
				rd_ptr <= '0;
				rd_ptr_odd_circle <= ~rd_ptr_odd_circle;
			end
			else begin
				rd_ptr <= rd_ptr + 1'b1;
			end
		end
		
	wire equal_ptrs = wr_ptr == rd_ptr;
	wire same_circle = wr_ptr_odd_circle == rd_ptr_odd_circle;
	
	assign empty = equal_ptrs & same_circle;
	assign full  = equal_ptrs & ~same_circle;
	
	ram # (
		.ADDR_LEN (ADDR_LEN),
		.DATA_LEN (DATA_LEN)
	) ram_module (
		.clk      (clk),
		
		.write    (push),
		.inaddr   (wr_ptr),
		.indata   (indata),
		
		.read     (pop),
		.outaddr  (rd_ptr),
		.outdata  (outdata)
	);

endmodule
	