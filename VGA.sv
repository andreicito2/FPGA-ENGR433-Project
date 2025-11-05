module VGA 
(
    input logic clk,               // System clock
    input logic red,
    input logic green,
    input logic blue,
    output logic hsync,
    output logic vsync
);
(
    reg [9:0] h_count;
    reg [9:0] v_count;
    
);
endmodule