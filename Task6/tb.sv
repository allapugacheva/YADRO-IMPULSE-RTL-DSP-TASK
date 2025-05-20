`timescale 1ns / 1ps

module tb();

    logic clk, rst, in_vld;
    logic signed [7:0] a1, b1, a2, b2;
    logic signed [15:0] c1, c2;
    logic out_vld;

    complex_mul dut (
        .clk (clk),
        .rst (rst),
        
        .a1 (a1),
        .b1 (b1),
        .a2 (a2),
        .b2 (b2),
        
        .in_vld (in_vld),
        
        .a_out (c1),
        .b_out (c2),
        
        .out_vld (out_vld)
    );
    
    typedef struct {
        logic signed [7:0] a1;
        logic signed [7:0] a2;
        logic signed [7:0] b1;
        logic signed [7:0] b2;
    } packet;
    
    mailbox#(packet) monitor = new();
    
    initial begin
        rst      <= 1'b1;
        
        #100 rst <= 1'b0;
    end
    
    initial begin
        clk            <= 1'b0;
        
        forever #5 clk <= ~clk;
    end
    
    initial begin
        packet pkt;
        logic vld;
        a1     <= 'z;
        b1     <= 'z;
        a2     <= 'z;
        b2     <= 'z;
        in_vld <= 1'b0;
        @(negedge rst);
        @(posedge clk);
        
        repeat(20) begin
            vld = $urandom_range(0, 1);
            if (vld) begin                
                pkt.a1 = $urandom_range(-128, 127);
                pkt.a2 = $urandom_range(-128, 127);
                pkt.b1 = $urandom_range(-128, 127);
                pkt.b2 = $urandom_range(-128, 127);
                monitor.put(pkt);
                
                a1     <= pkt.a1;
                a2     <= pkt.a2;
                b1     <= pkt.b1;
                b2     <= pkt.b2;
                in_vld <= 1'b1;
            end
            else begin
                a1     <= 'z;
                b1     <= 'z;
                a2     <= 'z;
                b2     <= 'z;
                in_vld <= 1'b0;
            end
            @(posedge clk);
        end
        
        repeat(10) @(posedge clk); 
        $finish;
    end
    
    initial begin
        packet pkt;
        logic signed [15:0] expected_c1, expected_c2;
        
        forever begin
            @(posedge clk);
            if (out_vld) begin
                monitor.get(pkt);
                expected_c1 = pkt.a1 * pkt.a2 - pkt.b1 * pkt.b2;
                expected_c2 = pkt.a1 * pkt.b2 + pkt.b1 * pkt.a2;
                if (c1 !== expected_c1)
                    $error("%0t BAD RESULT C1. REAL: %d. EXPECTED: %d", $time(), c1, expected_c1);
                if (c2 !== expected_c2)
                    $error("%0t BAD RESULT C2. REAL: %d. EXPECTED: %d", $time(), c2, expected_c2);
            end
        end
    end

endmodule
