//code to test only ball physics
module VGA 
(
    input logic clk,               // 25.175 MHz pixel clock for 640x480 @ 60Hz
    input logic quadA,         // Encoder channel A
    input logic quadB,        // Encoder channel B
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
    output logic vga_v_sync,
    output reg led_green,      // LED for clockwise (right) rotation
    output reg led_red         // LED for counter-clockwise (left) rotation
);

    // VGA 640x480 @ 60Hz timing
    // Horizontal: 640 visible + 16 front + 96 sync + 48 back = 800 total
    // Vertical: 480 visible + 10 front + 2 sync + 33 back = 525 total
    
    reg [9:0] CounterX;
    reg [9:0] CounterY;
    wire CounterXmaxed = (CounterX == 799);

    logic [7:0] count;
    logic [7:0] prev_count;

    // Define visible area - colors should only be output during active video
    wire inDisplayArea = (CounterX < 640) && (CounterY < 480);
    
    // Paddle parameters (Breakout-style bar)
    parameter PADDLE_WIDTH = 100;   // Width of paddle in pixels
    parameter PADDLE_HEIGHT = 15;   // Height of paddle in pixels
    parameter PADDLE_Y = 450;       // Y position (near bottom)
    reg [9:0] PADDLE_X = 270;        // X position (centered at 320, minus half width)

    //Ball parameters
    parameter BALL_SIZE = 20;
    reg [9:0] BALL_X = 320;
    reg [9:0] BALL_Y = 240;

    //Score
    reg [7:0] scoretop = 0;
    reg [7:0] scorebottom = 0;

    //Ball velocity
    logic signed [9:0] BALL_VX = -1;
    logic signed [9:0] BALL_VY = -1;
    wire frame_tick = (CounterXmaxed && (CounterY == 524));

    encoder uut (
        .clk(clk),
        .quadA(quadA),
        .quadB(quadB),
        .count(count)
    );

    
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

        prev_count <= count;
        if (count > prev_count) 
        begin
            PADDLE_X <= PADDLE_X + 3;  // Move paddle right
            if (PADDLE_X < 0)
                PADDLE_X <= 0;
            else if (PADDLE_X > (640 - PADDLE_WIDTH))
                PADDLE_X <= 640 - PADDLE_WIDTH;
            led_green <= 1'b0;  // Turn on green LED for right
            led_red <= 1'b1;
        end
        else if (count < prev_count) 
        begin
            PADDLE_X <= PADDLE_X - 3;  // Move paddle left
            if (PADDLE_X < 0)
                PADDLE_X <= 640 - PADDLE_WIDTH;
            else if (PADDLE_X > (640 - PADDLE_WIDTH))
                PADDLE_X <= 0;

            led_green <= 1'b1;  // Turn off green LED
            led_red <= 1'b0;
        end
    end

    always @(posedge clk)
    begin
        if (frame_tick) begin
            // move ball
            BALL_X <= BALL_X + BALL_VX;
            BALL_Y <= BALL_Y + BALL_VY;

            // bounce off left/right walls
            if (BALL_X <= 0 || BALL_X + BALL_SIZE >= 640) 
            begin
                BALL_VX <= -BALL_VX;
                if (BALL_X <= 0)
                    BALL_X <= BALL_X + 1;

                if (BALL_X + BALL_SIZE >= 640)
                    BALL_X <= BALL_X - 1;
            end

            // bounce off top wall/bottom (reset)
            if (BALL_Y <= 0 || BALL_Y + BALL_SIZE >= 480) 
            begin
                BALL_VY <= -BALL_VY;
                if (BALL_Y <= 0)
                    BALL_Y <= BALL_Y + 1;
                if (BALL_Y + BALL_SIZE >= 480)
                begin
                    BALL_VY <= -1;
                    BALL_VX <= -1;
                    BALL_Y <= 240;
                    BALL_X <= 320;
                    scoretop <= scoretop + 1;
                end

            end


            if ((BALL_Y + BALL_SIZE >= PADDLE_Y) && (BALL_Y + BALL_SIZE <= PADDLE_Y + PADDLE_HEIGHT) && (BALL_X + BALL_SIZE > PADDLE_X) && (BALL_X < PADDLE_X + PADDLE_WIDTH)) 
            begin
                BALL_VY <= -BALL_VY;
                BALL_X <= BALL_X - 1;
                BALL_Y <= BALL_Y - 1;
            end
        end
    end
    

    assign vga_h_sync = ~vga_HS;  // Negative polarity
    assign vga_v_sync = ~vga_VS;   // Positive polarity
    
    
    // Check if current pixel is on the paddle
    wire onPaddle = (CounterX >= PADDLE_X) && (CounterX < PADDLE_X + PADDLE_WIDTH) &&
                    (CounterY >= PADDLE_Y) && (CounterY < PADDLE_Y + PADDLE_HEIGHT);

    wire ballArea = (CounterX >= BALL_X) && (CounterX < BALL_X + BALL_SIZE) &&
                    (CounterY >= BALL_Y) && (CounterY < BALL_Y + BALL_SIZE);
    
    // Score display parameters
    parameter DIGIT_WIDTH = 20;
    parameter DIGIT_HEIGHT = 30;
    parameter SCORE_TOP_X = 300;
    parameter SCORE_TOP_Y = 30;
    
    // Function to get digit pattern (5x7 bitmap scaled 4x for 20x28 visible size)
    function [34:0] get_digit_row;
        input [3:0] digit;
        input [2:0] row;
        case(digit)
            4'd0: case(row)
                3'd0: get_digit_row = 5'b01110;
                3'd1: get_digit_row = 5'b10001;
                3'd2: get_digit_row = 5'b10011;
                3'd3: get_digit_row = 5'b10101;
                3'd4: get_digit_row = 5'b11001;
                3'd5: get_digit_row = 5'b10001;
                3'd6: get_digit_row = 5'b01110;
            endcase
            4'd1: case(row)
                3'd0: get_digit_row = 5'b00100;
                3'd1: get_digit_row = 5'b01100;
                3'd2: get_digit_row = 5'b00100;
                3'd3: get_digit_row = 5'b00100;
                3'd4: get_digit_row = 5'b00100;
                3'd5: get_digit_row = 5'b00100;
                3'd6: get_digit_row = 5'b01110;
            endcase
            4'd2: case(row)
                3'd0: get_digit_row = 5'b01110;
                3'd1: get_digit_row = 5'b10001;
                3'd2: get_digit_row = 5'b00001;
                3'd3: get_digit_row = 5'b00110;
                3'd4: get_digit_row = 5'b01000;
                3'd5: get_digit_row = 5'b10000;
                3'd6: get_digit_row = 5'b11111;
            endcase
            4'd3: case(row)
                3'd0: get_digit_row = 5'b11111;
                3'd1: get_digit_row = 5'b00010;
                3'd2: get_digit_row = 5'b00100;
                3'd3: get_digit_row = 5'b00110;
                3'd4: get_digit_row = 5'b00001;
                3'd5: get_digit_row = 5'b10001;
                3'd6: get_digit_row = 5'b01110;
            endcase
            4'd4: case(row)
                3'd0: get_digit_row = 5'b00010;
                3'd1: get_digit_row = 5'b00110;
                3'd2: get_digit_row = 5'b01010;
                3'd3: get_digit_row = 5'b10010;
                3'd4: get_digit_row = 5'b11111;
                3'd5: get_digit_row = 5'b00010;
                3'd6: get_digit_row = 5'b00010;
            endcase
            4'd5: case(row)
                3'd0: get_digit_row = 5'b11111;
                3'd1: get_digit_row = 5'b10000;
                3'd2: get_digit_row = 5'b11110;
                3'd3: get_digit_row = 5'b00001;
                3'd4: get_digit_row = 5'b00001;
                3'd5: get_digit_row = 5'b10001;
                3'd6: get_digit_row = 5'b01110;
            endcase
            4'd6: case(row)
                3'd0: get_digit_row = 5'b00110;
                3'd1: get_digit_row = 5'b01000;
                3'd2: get_digit_row = 5'b10000;
                3'd3: get_digit_row = 5'b11110;
                3'd4: get_digit_row = 5'b10001;
                3'd5: get_digit_row = 5'b10001;
                3'd6: get_digit_row = 5'b01110;
            endcase
            4'd7: case(row)
                3'd0: get_digit_row = 5'b11111;
                3'd1: get_digit_row = 5'b00001;
                3'd2: get_digit_row = 5'b00010;
                3'd3: get_digit_row = 5'b00100;
                3'd4: get_digit_row = 5'b01000;
                3'd5: get_digit_row = 5'b01000;
                3'd6: get_digit_row = 5'b01000;
            endcase
            4'd8: case(row)
                3'd0: get_digit_row = 5'b01110;
                3'd1: get_digit_row = 5'b10001;
                3'd2: get_digit_row = 5'b10001;
                3'd3: get_digit_row = 5'b01110;
                3'd4: get_digit_row = 5'b10001;
                3'd5: get_digit_row = 5'b10001;
                3'd6: get_digit_row = 5'b01110;
            endcase
            4'd9: case(row)
                3'd0: get_digit_row = 5'b01110;
                3'd1: get_digit_row = 5'b10001;
                3'd2: get_digit_row = 5'b10001;
                3'd3: get_digit_row = 5'b01111;
                3'd4: get_digit_row = 5'b00001;
                3'd5: get_digit_row = 5'b00010;
                3'd6: get_digit_row = 5'b01100;
            endcase
            default: get_digit_row = 5'b00000;
        endcase
    endfunction
    
    // Score display logic
    wire [3:0] score_digit_tens = scoretop / 10;
    wire [3:0] score_digit_ones = scoretop % 10;
    
    // Check if we're in score display area
    wire in_score_tens = (CounterX >= SCORE_TOP_X) && (CounterX < SCORE_TOP_X + DIGIT_WIDTH) &&
                         (CounterY >= SCORE_TOP_Y) && (CounterY < SCORE_TOP_Y + DIGIT_HEIGHT);
    wire in_score_ones = (CounterX >= SCORE_TOP_X + DIGIT_WIDTH + 5) && (CounterX < SCORE_TOP_X + DIGIT_WIDTH + 5 + DIGIT_WIDTH) &&
                         (CounterY >= SCORE_TOP_Y) && (CounterY < SCORE_TOP_Y + DIGIT_HEIGHT);
    
    // Get pixel position within digit
    wire [4:0] digit_x_tens = (CounterX - SCORE_TOP_X) / 4;
    wire [4:0] digit_y_tens = (CounterY - SCORE_TOP_Y) / 4;
    wire [4:0] digit_x_ones = (CounterX - (SCORE_TOP_X + DIGIT_WIDTH + 5)) / 4;
    wire [4:0] digit_y_ones = (CounterY - SCORE_TOP_Y) / 4;
    
    // Get digit patterns
    wire [4:0] tens_row = get_digit_row(score_digit_tens, digit_y_tens[2:0]);
    wire [4:0] ones_row = get_digit_row(score_digit_ones, digit_y_ones[2:0]);
    
    // Check if pixel should be on for each digit
    wire tens_pixel = in_score_tens && (digit_y_tens < 7) && tens_row[4 - digit_x_tens[2:0]];
    wire ones_pixel = in_score_ones && (digit_y_ones < 7) && ones_row[4 - digit_x_ones[2:0]];
    wire score_on = tens_pixel || ones_pixel;
    
    // Combine paddle and ball rendering (both white on black)
    wire paddle_on = inDisplayArea && onPaddle;
    wire ball_on   = inDisplayArea && ballArea;
    wire object_on = paddle_on || ball_on || score_on;

    assign VGA_R = object_on ? 4'b1111 : 4'b0000;
    assign VGA_G = object_on ? 4'b1111 : 4'b0000;
    assign VGA_B = object_on ? 4'b1111 : 4'b0000;

    
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