module encoder_test ( //https://digilent.com/reference/pmod/pmodenc/start
    input logic clk,           // System clock
    input logic quadA,         // Encoder channel A
    input logic quadB,         // Encoder channel B
    output reg led_green,      // LED for clockwise (right) rotation
    output reg led_red         // LED for counter-clockwise (left) rotation
);

    // Encoder signals
    logic [7:0] count;
    logic [7:0] prev_count;
    
    // Instantiate the encoder module
    encoder uut (
        .clk(clk),
        .quadA(quadA),
        .quadB(quadB),
        .count(count)
    );

    // Detect direction based on count changes // May need to add a offset or make it sign reg to account for negative counts
    always @(posedge clk) begin
        prev_count <= count;
        
        // Check if count increased (clockwise/right)
        if (count > prev_count) begin
            led_green <= 1'b1;  // Turn on green LED for right
            led_red <= 1'b0;    // Turn off red LED
        end
        // Check if count decreased (counter-clockwise/left)
        else if (count < prev_count) begin
            led_green <= 1'b0;  // Turn off green LED
            led_red <= 1'b1;    // Turn on red LED for left
        end
        // No change - keep LEDs off or hold previous state
        else begin
            led_green <= 1'b0;
            led_red <= 1'b0;
        end
    end

endmodule