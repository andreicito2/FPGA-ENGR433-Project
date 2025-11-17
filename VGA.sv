module VGA 
(
    input logic clk,               // 25.175 MHz pixel clock for 640x480 @ 60Hz
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

    // VGA 640x480 @ 60Hz timing
    // Horizontal: 640 visible + 16 front + 96 sync + 48 back = 800 total
    // Vertical: 480 visible + 10 front + 2 sync + 33 back = 525 total
    
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
    
    // Define visible area - colors should only be output during active video
    wire inDisplayArea = (CounterX < 640) && (CounterY < 480);
    
    // Paddle parameters (Breakout-style bar)
    parameter PADDLE_WIDTH = 100;   // Width of paddle in pixels
    parameter PADDLE_HEIGHT = 15;   // Height of paddle in pixels
    parameter PADDLE_Y = 450;       // Y position (near bottom)
    parameter PADDLE_X = 270;       // X position (centered at 320, minus half width)
    
    // Check if current pixel is on the paddle
    wire onPaddle = (CounterX >= PADDLE_X) && (CounterX < PADDLE_X + PADDLE_WIDTH) &&
                    (CounterY >= PADDLE_Y) && (CounterY < PADDLE_Y + PADDLE_HEIGHT);
    
    // Generate paddle (white bar) on black background
    assign VGA_R = (inDisplayArea && onPaddle) ? 4'b1111 : 4'b0000;
    assign VGA_G = (inDisplayArea && onPaddle) ? 4'b1111 : 4'b0000;
    assign VGA_B = (inDisplayArea && onPaddle) ? 4'b1111 : 4'b0000;
    
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