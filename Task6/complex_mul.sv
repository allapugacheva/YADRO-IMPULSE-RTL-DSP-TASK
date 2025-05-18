module complex_mul # (
    parameter DATA_LEN = 8
) (
    input                          clk,
    input                          rst,
    
    input  signed [DATA_LEN - 1:0] a1,
    input  signed [DATA_LEN - 1:0] b1,
    
    input  signed [DATA_LEN - 1:0] a2,
    input  signed [DATA_LEN - 1:0] b2,
    
    input                          in_vld,
    
    output signed [2 * DATA_LEN - 1:0] a_out,
    output signed [2 * DATA_LEN - 1:0] b_out,
    
    output logic                  out_vld
); 
    
    localparam ADD_LEN27 = 27 - DATA_LEN;
    localparam ADD_LEN18 = 18 - DATA_LEN;
    
    logic signed [47:0] p;
    logic signed [DATA_LEN - 1:0] a1_st1_reg, a2_st1_reg, b1_st1_reg, b2_st1_reg,
                                  a1_st2_reg, a2_st2_reg, b1_st2_reg, b2_st2_reg;
    
    always_ff @ (posedge clk or posedge rst)
        if (rst) begin
            a1_st1_reg <= '0;
            a2_st1_reg <= '0;
            b1_st1_reg <= '0;
            b2_st1_reg <= '0;
        end
        else begin
            a1_st1_reg <= a1;
            a2_st1_reg <= a2;
            b1_st1_reg <= b1;
            b2_st1_reg <= b2;            
        end
        
     always_ff @ (posedge clk or posedge rst)
        if (rst) begin
            a1_st2_reg <= '0;
            a2_st2_reg <= '0;
            b1_st2_reg <= '0;
            b2_st2_reg <= '0;
        end
        else begin
            a1_st2_reg <= a1_st1_reg;
            a2_st2_reg <= a2_st1_reg;
            b1_st2_reg <= b1_st1_reg;
            b2_st2_reg <= b2_st1_reg;            
        end       
        
    logic vld_st1, vld_st2, vld_st3, vld_st4, vld_st5;
    
    always_ff @ (posedge clk or posedge rst)
        if (rst) begin
            vld_st1 <= '0;
            vld_st2 <= '0;
            vld_st3 <= '0;
            vld_st4 <= '0;
            vld_st5 <= '0;
            out_vld <= '0;
        end
        else begin
            vld_st1 <= in_vld;
            vld_st2 <= vld_st1;
            vld_st3 <= vld_st2;
            vld_st4 <= vld_st3;
            vld_st5 <= vld_st4;
            out_vld <= vld_st5;
        end
    
    logic signed [26:0] a1_st1, b1_st1;
    logic signed [17:0] b2_st1;
    
    assign a1_st1 = $signed({ { ADD_LEN27{a1[DATA_LEN - 1]} }, a1 });
    assign b1_st1 = $signed({ { ADD_LEN27{b1[DATA_LEN - 1]} }, b1 });
    assign b2_st1 = $signed({ { ADD_LEN18{b2[DATA_LEN - 1]} }, b2 });
    
    DSP48E2 #(
       .AMULTSEL      ("AD"),                  
       .BREG          (2)                         
    ) DSP48E2_upper (
       .P             (p),            
       
       .ALUMODE       (4'b0000),                 
       .CLK           (clk),                  
       .INMODE        (5'b01101),                
       .OPMODE        (9'b000000101),              
       
       .A             ({3'b111, b1_st1}),                        
       .B             (b2_st1),                         
       .C             ('1),                         
       .D             (a1_st1),                      
       
       .CEA1          (in_vld),                     
       .CEAD          (vld_st2),                  
       .CEALUMODE     (in_vld),         
       .CEB1          (in_vld),                    
       .CEB2          (vld_st2),                     
       .CEC           (1'b0),                       
       .CECARRYIN     (1'b0),          
       .CECTRL        (in_vld),            
       .CED           (in_vld),                      
       .CEINMODE      (in_vld),           
       .CEM           (vld_st3),                    
       .CEP           (vld_st4),                     
       
       .RSTA          (rst),                    
       .RSTALLCARRYIN (rst),  
       .RSTALUMODE    (rst),         
       .RSTB          (rst),                    
       .RSTCTRL       (rst),               
       .RSTD          (rst),                    
       .RSTINMODE     (rst),           
       .RSTM          (rst),                    
       .RSTP          (rst)                     
    );
    
    logic signed [26:0] b1_st2, b2_st2;
    logic signed [17:0] a1_st2, a2_st2;
    
    assign a2_st2 = $signed({ { ADD_LEN27{a2_st2_reg[DATA_LEN - 1]} }, a2_st2_reg });
    assign b2_st2 = $signed({ { ADD_LEN27{b2_st2_reg[DATA_LEN - 1]} }, b2_st2_reg });
    assign a1_st2 = $signed({ { ADD_LEN18{a1_st2_reg[DATA_LEN - 1]} }, a1_st2_reg });
    assign b1_st2 = $signed({ { ADD_LEN18{b1_st2_reg[DATA_LEN - 1]} }, b1_st2_reg });
    
    logic [47:0] p_m_out, p_l_out;
    
    DSP48E2 #(
       .AMULTSEL      ("AD"),              
       .BREG          (2),
       .CREG          (0)                      
    ) DSP48E2_middle (
       .P             (p_m_out),                      
       
       .ALUMODE       (4'b0000),               
       .CLK           (clk),                      
       .INMODE        (5'b01101),                
       .OPMODE        (9'b000110101),               
       
       .A             ({3'b111, b2_st2}),                          
       .B             (a1_st2),                          
       .C             (p),                         
       .D             (a2_st2),                        
       
       .CEA1          (vld_st2),                     
       .CEAD          (vld_st3),                  
       .CEALUMODE     (vld_st2),           
       .CEB1          (vld_st2),                    
       .CEB2          (vld_st3),                     
       .CEC           (1'b0),                     
       .CECARRYIN     (1'b0),           
       .CECTRL        (vld_st2),                
       .CED           (vld_st2),                      
       .CEINMODE      (vld_st2),            
       .CEM           (vld_st4),                       
       .CEP           (vld_st5),                      
       
       .RSTA          (rst),                    
       .RSTALLCARRYIN (rst),   
       .RSTALUMODE    (rst),         
       .RSTB          (rst),                     
       .RSTCTRL       (rst),              
       .RSTD          (rst),                    
       .RSTINMODE     (rst),        
       .RSTM          (rst),                    
       .RSTP          (rst)                    
    );
    
     DSP48E2 #(
       .AMULTSEL      ("AD"),                 
       .BREG          (2),
       .CREG          (0)                 
    ) DSP48E2_lower (
       .P             (p_l_out),                      
       
       .ALUMODE       (4'b0000),              
       .CLK           (clk),                     
       .INMODE        (5'b00101),               
       .OPMODE        (9'b000110101),                
       
       .A             ({3'b111, b2_st2}),                       
       .B             (b1_st2),                        
       .C             (p),                          
       .D             (a2_st2),                          
       
       .CEA1          (vld_st2),                    
       .CEAD          (vld_st3),                  
       .CEALUMODE     (vld_st2),           
       .CEB1          (vld_st2),                   
       .CEB2          (vld_st3),                    
       .CEC           (1'b0),                     
       .CECARRYIN     (1'b0),           
       .CECTRL        (vld_st2),                
       .CED           (vld_st2),                      
       .CEINMODE      (vld_st2),            
       .CEM           (vld_st4),                     
       .CEP           (vld_st5),                    
       
       .RSTA          (rst),               
       .RSTALLCARRYIN (rst),  
       .RSTALUMODE    (rst),        
       .RSTB          (rst),                 
       .RSTCTRL       (rst),               
       .RSTD          (rst),                    
       .RSTINMODE     (rst),          
       .RSTM          (rst),                 
       .RSTP          (rst)                    
    );
    
    assign a_out = p_m_out[2 * DATA_LEN - 1:0];
    assign b_out = p_l_out[2 * DATA_LEN - 1:0];
    
endmodule
