module VGA 
(
    input logic clk,               // 146.25 MHz pixel clock for 1680x1050 @ 60Hz
    output logic VGA_R_0,
    output logic VGA_R_1,
    output logic VGA_R_2,
    output logic VGA_R_3,
    output logic VGA_G_0,
    output logic VGA_G_1,
    output logic VGA_G_2,
    output logic VGA_G_3,
    output logic VGA_B_0,
    output logic VGA_B_1,
    output logic VGA_B_2,
    output logic VGA_B_3,
    output logic vga_h_sync,
    output logic vga_v_sync
);

    // 1680x1050 @ 60Hz timing (CVT Reduced Blanking)
    // Horizontal: 1680 + 104 + 176 + 280 = 2240 total
    // Vertical: 1050 + 1 + 3 + 30 = 1084 total
    
    reg [9:0] CounterX;
    reg [8:0] CounterY;
    wire CounterXmaxed = (CounterX==768);

    
    // 4-bit color outputs
    wire [3:0] VGA_R;
    wire [3:0] VGA_G;
    wire [3:0] VGA_B;

    always @(posedge clk)
    if(CounterXmaxed)
        CounterX <= 0;
    else
        CounterX <= CounterX + 1;

    always @(posedge clk)
    if(CounterXmaxed)
        CounterY <= CounterY + 1;
        
    reg vga_HS, vga_VS;
    always @(posedge clk)
    begin
        vga_HS <= (CounterX[9:4]==0);   // active for 16 clocks
        vga_VS <= (CounterY==0);   // active for 768 clocks
    end

    assign vga_h_sync = ~vga_HS;  // Negative polarity
    assign vga_v_sync = ~vga_VS;   // Positive polarity
    
    // Generate test pattern with 4-bit color depth
    assign VGA_R = {CounterY[3], CounterY[2], CounterY[1], CounterY[0]} | {4{(CounterX==768)}};
    assign VGA_G = {CounterX[5] ^ CounterX[6], CounterX[4], CounterX[3], CounterX[2]} | {4{(CounterX==768)}};
    assign VGA_B = {CounterX[4], CounterX[3], CounterX[2], CounterX[1]} | {4{(CounterX==768)}};
    
    // Assign individual color bits to output pins
    assign VGA_R_0 = VGA_R[0];
    assign VGA_R_1 = VGA_R[1];
    assign VGA_R_2 = VGA_R[2];
    assign VGA_R_3 = VGA_R[3];
    
    assign VGA_G_0 = VGA_G[0];
    assign VGA_G_1 = VGA_G[1];
    assign VGA_G_2 = VGA_G[2];
    assign VGA_G_3 = VGA_G[3];
    
    assign VGA_B_0 = VGA_B[0];
    assign VGA_B_1 = VGA_B[1];
    assign VGA_B_2 = VGA_B[2];
    assign VGA_B_3 = VGA_B[3];

endmodule