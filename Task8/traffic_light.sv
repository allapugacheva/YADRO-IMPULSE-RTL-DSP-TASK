module traffic_light # (
	parameter delay = 2
) (
	input  clk,
	input  rst,
	input  control,
	output red,
	output yellow,
	output green
);

	localparam MAX_CNT = delay - 1;

	enum logic [3:0] {
		IDLE,
		RED1,
		YELLOW1,
		GREEN,
		YELLOW2,
		RED2,
		WAIT
	} state, next_state;
	
	logic [$clog2(delay) - 1:0] cnt;
	
	logic control_reg;
	
	always_comb begin
		next_state = state;
		
		case (state)
			IDLE   : if (control               ) next_state = RED1;
			RED1   :                             next_state = YELLOW1;
			YELLOW1:                             next_state = GREEN;
			GREEN  :                             next_state = YELLOW2;
			YELLOW2:                             next_state = RED2;
			RED2   : if (control_reg || control) next_state = YELLOW2;
						else                        next_state = WAIT;
			WAIT   : if (control               ) next_state = RED1;
		endcase
	end
	
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			control_reg <= '0;
		else if (state == YELLOW2 && control)
			control_reg <= '1;
		else if (state == RED2 && control_reg)
			control_reg <= '0;
	
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			state <= IDLE;
		else if ((state != IDLE && cnt == MAX_CNT) || (state == IDLE && control))
			state <= next_state;
			
	always_ff @ (posedge clk or posedge rst)
		if (rst)
			cnt <= '0;
		else if (cnt == MAX_CNT || (state == IDLE && control))
			cnt <= '0;
		else if (next_state != state || state == IDLE)
			cnt <= cnt + 1'b1;
			
	assign red    = state == RED1 || state == RED2;
	assign yellow = state == YELLOW1 || state == YELLOW2 || (state == IDLE && cnt == MAX_CNT);
	assign green  = state == GREEN;

endmodule