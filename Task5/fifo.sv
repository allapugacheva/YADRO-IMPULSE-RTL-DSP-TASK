module fifo # (
    parameter LEN = 8,
              DATA_LEN = 8
)(
    input                   clk,
    input                   rst,
    
    input                   push,
    input  [DATA_LEN - 1:0] indata,
    
    input                   pop,
    output [DATA_LEN - 1:0] outdata,
    
    output                  empty,
    output                  full
    );
    
    localparam ADD_BITS = 64 - DATA_LEN;
    
    localparam MAX_PTR = LEN - 1;
    logic wr_ptr_odd_circle, rd_ptr_odd_circle;
    logic [8:0] wr_ptr, rd_ptr;
    
    always_ff @ (posedge clk or posedge rst)
        if (rst) begin
            rd_ptr <= '0;
            rd_ptr_odd_circle <= 1'b0;
        end
        else if (pop & ~empty) begin
            if (rd_ptr == MAX_PTR) begin
                rd_ptr <= '0;
                rd_ptr_odd_circle <= ~rd_ptr_odd_circle;
            end
            else begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
        
    always_ff @ (posedge clk or posedge rst)
        if (rst) begin
            wr_ptr <= '0;
            wr_ptr_odd_circle <= 1'b0;
        end
        else if (push & ~full) begin
            if (wr_ptr == MAX_PTR) begin
                wr_ptr <= '0;
                wr_ptr_odd_circle <= ~wr_ptr_odd_circle;
            end
            else begin
                wr_ptr <= wr_ptr + 1'b1;
            end
        end
        
    wire equal_ptrs = wr_ptr == rd_ptr;
    wire same_circle = wr_ptr_odd_circle == rd_ptr_odd_circle;
    
    assign empty = equal_ptrs & same_circle;
    assign full  = equal_ptrs & ~same_circle;
    
    logic [63:0] data_in, data_out;    
    assign data_in = { {ADD_BITS{1'b0}}, indata };
    assign outdata = data_out[DATA_LEN - 1:0];
    
    logic [14:0] rd_addr, wr_addr;
    assign rd_addr = { rd_ptr, 6'd0 };
    assign wr_addr = { wr_ptr, 6'd0 };
        
    RAMB36E2 #(
        .CLOCK_DOMAINS ("COMMON"),
        .DOA_REG       (0),
        .DOB_REG       (0),
        .READ_WIDTH_A  (72),
        .WRITE_WIDTH_B (72)  
    ) bram (
        .ADDRARDADDR   (rd_addr), 
        .CLKARDCLK     (clk),
        .ENARDEN       (pop & ~empty),
        .DOUTADOUT     (data_out[31: 0]),
        .DOUTBDOUT     (data_out[63:32]),
        
        .ADDRBWRADDR   (wr_addr),
        .CLKBWRCLK     (clk),
        .ENBWREN       (push & ~full),
        .WEBWE         ({8{push}}),
        .DINADIN       (data_in[31: 0]),
        .DINBDIN       (data_in[63:32]),
        .DINPADINP     ({4{push}}),
        .DINPBDINP     ({4{push}})
    );
    
endmodule
