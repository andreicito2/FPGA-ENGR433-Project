module VGA 
(
    input logic clk,               // System clock
    input logic led_red,
    input logic led_green,
    input logic led_blue,
    output logic vga_h_sync,
    output logic vga_v_sync,
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

    // VGA 640x480 @ 60Hz timing parameters
    // Horizontal: 800 pixels total
    // Vertical: 525 lines total
    reg [9:0] CounterX;
    reg [9:0] CounterY;
    wire CounterXmaxed = (CounterX == 799);

    
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
    begin
        if(CounterXmaxed)
        begin
            if(CounterY == 524)
                CounterY <= 0;
            else
                CounterY <= CounterY + 1;
        end
    end

    reg vga_HS, vga_VS;
    always @(posedge clk)
    begin
        vga_HS <= (CounterX >= 656) && (CounterX < 752);  // 96 clock sync pulse
        vga_VS <= (CounterY >= 490) && (CounterY < 492);  // 2 line sync pulse
    end

    assign vga_h_sync = ~vga_HS;  // Negative polarity
    assign vga_v_sync = ~vga_VS;   // Positive polarity
    
    // Generate test pattern with 4-bit color depth
    assign VGA_R = {CounterY[3], CounterY[2], CounterY[1], CounterY[0]} ;
    assign VGA_G = {CounterX[5] ^ CounterX[6], CounterX[4], CounterX[3], CounterX[2]} ;
    assign VGA_B = {CounterX[4], CounterX[3], CounterX[2], CounterX[1]} ;
    
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