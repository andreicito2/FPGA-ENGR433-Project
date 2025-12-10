`timescale 1ns / 1ps

module pong_tb;

    // Signals
    logic clk;
    logic quadA, quadB, quadC, quadD;
    logic VGA_R_0, VGA_R_1, VGA_R_2, VGA_R_3;
    logic VGA_G_0, VGA_G_1, VGA_G_2, VGA_G_3;
    logic VGA_B_0, VGA_B_1, VGA_B_2, VGA_B_3;
    logic vga_h_sync, vga_v_sync;
    logic led_green, led_red;
    
    // Counters
    reg [15:0] h_sync_count = 0;
    reg [15:0] v_sync_count = 0;
    logic prev_v_sync;
    logic prev_h_sync;
    reg [15:0] h_sync_low_count = 0;
    reg [15:0] v_sync_low_count = 0;
    reg [15:0] clocks_per_line = 0;
    reg [15:0] lines_per_frame = 0;
    
    // Encoder outputs and tracking - monitor DUT's internal encoders
    wire [7:0] enc1_count = dut.count1;
    wire [7:0] enc2_count = dut.count2;
    logic [7:0] enc1_start, enc2_start;
    reg [7:0] enc1_expected, enc2_expected;
    
    // Instantiate the Pong module
    Pong dut (
        .clk(clk),
        .quadA(quadA),
        .quadB(quadB),
        .quadC(quadC),
        .quadD(quadD),
        .VGA_R_0(VGA_R_0),
        .VGA_R_1(VGA_R_1),
        .VGA_R_2(VGA_R_2),
        .VGA_R_3(VGA_R_3),
        .VGA_G_0(VGA_G_0),
        .VGA_G_1(VGA_G_1),
        .VGA_G_2(VGA_G_2),
        .VGA_G_3(VGA_G_3),
        .VGA_B_0(VGA_B_0),
        .VGA_B_1(VGA_B_1),
        .VGA_B_2(VGA_B_2),
        .VGA_B_3(VGA_B_3),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .led_green(led_green),
        .led_red(led_red)
    );
    
    // Clock generation - 25 MHz
    initial begin
        clk = 0;
        forever #20 clk = ~clk;  // 40ns period
    end
    
    // Initialize
    initial begin
        quadA = 0; quadB = 0; quadC = 0; quadD = 0;
        prev_v_sync = 1;
        prev_h_sync = 1;
        enc1_expected = 0;
        enc2_expected = 0;
        
        // Force initialize DUT internal counters to prevent X propagation
        #1;  // Wait for initial clock edge
        force dut.CounterX = 0;
        force dut.CounterY = 0;
        force dut.vga_HS = 1;
        force dut.vga_VS = 1;
        force dut.count1 = 0;
        force dut.count2 = 0;
        force dut.prev_count1 = 0;
        force dut.prev_count2 = 0;
        
        // Initialize DUT's internal encoder instances
        // Initialize both count registers and synchronizers
        force dut.uut.count_reg = 0;
        force dut.uut.quadA_d = 3'b000;
        force dut.uut.quadB_d = 3'b000;
        force dut.uut2.count_reg = 0;
        force dut.uut2.quadA_d = 3'b000;
        force dut.uut2.quadB_d = 3'b000;
        
        #100;  // Hold for a few clocks
        release dut.CounterX;
        release dut.CounterY;
        release dut.vga_HS;
        release dut.vga_VS;
        release dut.count1;
        release dut.count2;
        release dut.prev_count1;
        release dut.prev_count2;
        release dut.uut.count_reg;
        release dut.uut.quadA_d;
        release dut.uut.quadB_d;
        release dut.uut2.count_reg;
        release dut.uut2.quadA_d;
        release dut.uut2.quadB_d;
        
        // Wait for synchronizers to stabilize after release
        repeat(100) @(posedge clk);
        
        $display("=== Pong Testbench ===");
    end
    
    // Monitor sync signals
    reg [15:0] line_clock_counter = 0;
    reg [15:0] saved_clocks_per_line = 0;
    
    always @(posedge clk) begin
        // Count clocks continuously
        line_clock_counter <= line_clock_counter + 1;
        
        // Track H-sync pulse width
        if (!vga_h_sync) begin
            h_sync_low_count <= h_sync_low_count + 1;
        end
        
        // Detect H-sync falling edge (start of sync pulse)
        if (prev_h_sync && !vga_h_sync) begin
            h_sync_count <= h_sync_count + 1;
            saved_clocks_per_line <= line_clock_counter;
            line_clock_counter <= 0;
            h_sync_low_count <= 1;
        end
        
        // Detect V-sync falling edge (new frame)
        if (prev_v_sync && !vga_v_sync) begin
            v_sync_count <= v_sync_count + 1;
            $display("Frame %0d complete - H-syncs: %0d, Clocks/line: %0d", 
                     v_sync_count, h_sync_count, saved_clocks_per_line);
            lines_per_frame <= h_sync_count;
            clocks_per_line <= saved_clocks_per_line;
            h_sync_count <= 0;
        end
        
        // Track V-sync low period
        if (!vga_v_sync) begin
            v_sync_low_count <= v_sync_low_count + 1;
        end else if (prev_v_sync != vga_v_sync) begin
            v_sync_low_count <= 0;
        end
        
        prev_v_sync <= vga_v_sync;
        prev_h_sync <= vga_h_sync;
    end
    
    // Encoder test tasks - timing critical for 3-stage synchronizer
    task encoder_cw;
        input logic is_enc1;
        integer i;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                if (is_enc1) begin
                    {quadA, quadB} = 2'b00; 
                    repeat(20) @(posedge clk);  // Hold for 20 clocks
                    {quadA, quadB} = 2'b10; 
                    repeat(20) @(posedge clk);
                    {quadA, quadB} = 2'b11; 
                    repeat(20) @(posedge clk);
                    {quadA, quadB} = 2'b01; 
                    repeat(20) @(posedge clk);
                    {quadA, quadB} = 2'b00;  // Return to start for clean cycle
                    repeat(20) @(posedge clk);
                end else begin
                    {quadC, quadD} = 2'b00; 
                    repeat(20) @(posedge clk);
                    {quadC, quadD} = 2'b10; 
                    repeat(20) @(posedge clk);
                    {quadC, quadD} = 2'b11; 
                    repeat(20) @(posedge clk);
                    {quadC, quadD} = 2'b01; 
                    repeat(20) @(posedge clk);
                    {quadC, quadD} = 2'b00;  // Return to start for clean cycle
                    repeat(20) @(posedge clk);
                end
            end
        end
    endtask
    
    task encoder_ccw;
        input logic is_enc1;
        integer i;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                if (is_enc1) begin
                    {quadA, quadB} = 2'b00; 
                    repeat(20) @(posedge clk);  // Hold for 20 clocks
                    {quadA, quadB} = 2'b01; 
                    repeat(20) @(posedge clk);
                    {quadA, quadB} = 2'b11; 
                    repeat(20) @(posedge clk);
                    {quadA, quadB} = 2'b10; 
                    repeat(20) @(posedge clk);
                    {quadA, quadB} = 2'b00;  // Return to start for clean cycle
                    repeat(20) @(posedge clk);
                end else begin
                    {quadC, quadD} = 2'b00; 
                    repeat(20) @(posedge clk);
                    {quadC, quadD} = 2'b01; 
                    repeat(20) @(posedge clk);
                    {quadC, quadD} = 2'b11; 
                    repeat(20) @(posedge clk);
                    {quadC, quadD} = 2'b10; 
                    repeat(20) @(posedge clk);
                    {quadC, quadD} = 2'b00;  // Return to start for clean cycle
                    repeat(20) @(posedge clk);
                end
            end
        end
    endtask
    
    // Main test
    initial begin
        $display("Waiting for initialization...");
        repeat(1000) @(posedge clk);
        
        // Test VGA timing - wait for 1 complete frame (420,000 clocks)
        $display("\nTest 1: VGA Timing Validation");
        repeat(450000) @(posedge clk);
        
        // Validate VGA timing parameters
        $display("  V-syncs detected: %0d", v_sync_count);
        $display("  H-syncs per frame: %0d (expected: 490-525)", lines_per_frame);
        $display("  Clocks per line: ~%0d (expected: 800)", clocks_per_line);
        
        // Check if timing is correct
        if (v_sync_count >= 1) begin
            $display("  ✓ V-sync: PASS");
        end else begin
            $display("  ✗ V-sync: FAIL - No frames detected");
        end
        
        // V-sync starts at line 490 in this implementation, so 490 H-syncs is correct
        if (lines_per_frame >= 485 && lines_per_frame <= 530) begin
            $display("  Lines per frame: PASS");
        end else begin
            $display("  Lines per frame: FAIL - Expected 490-525, got %0d", lines_per_frame);
        end
        
        if (clocks_per_line >= 795 && clocks_per_line <= 805) begin
            $display("  Clocks per line: PASS");
        end else begin
            $display("  Clocks per line: FAIL - Expected ~800, got %0d", clocks_per_line);
        end
        
        // Test Encoder 1 Clockwise
        $display("\nTest 2: Encoder 1 CW (5 rotations = 20 counts)");
        enc1_start = enc1_count;
        encoder_cw(1);
        repeat(2000) @(posedge clk);
        enc1_expected = enc1_start + 20;
        if (enc1_count == enc1_expected) begin
            $display("  ✓ Encoder 1 CW: PASS");
        end else begin
            $display("  ✗ Encoder 1 CW: FAIL - Delta: %0d", enc1_count - enc1_start);
        end
        
        // Test Encoder 1 Counter-Clockwise
        $display("\nTest 3: Encoder 1 CCW (5 rotations = -20 counts)");
        enc1_start = enc1_count;
        encoder_ccw(1);
        repeat(2000) @(posedge clk);
        enc1_expected = enc1_start - 20;
        $display("  Count1: %0d (expected: %0d)", enc1_count, enc1_expected);
        if (enc1_count == enc1_expected) begin
            $display("  ✓ Encoder 1 CCW: PASS");
        end else begin
            $display("  ✗ Encoder 1 CCW: FAIL - Delta: %0d", enc1_count - enc1_start);
        end
        
        // Test Encoder 2 Clockwise
        $display("\nTest 4: Encoder 2 CW (5 rotations = 20 counts)");
        enc2_start = enc2_count;
        encoder_cw(0);
        repeat(2000) @(posedge clk);
        enc2_expected = enc2_start + 20;
        $display("  Count2: %0d (expected: %0d), LED: G=%b R=%b", 
                 enc2_count, enc2_expected, led_green, led_red);
        if (enc2_count == enc2_expected) begin
            $display("  ✓ Encoder 2 CW: PASS");
        end else begin
            $display("  ✗ Encoder 2 CW: FAIL - Delta: %0d", enc2_count - enc2_start);
        end
        
        // Test Encoder 2 Counter-Clockwise
        $display("\nTest 5: Encoder 2 CCW (5 rotations = -20 counts)");
        enc2_start = enc2_count;
        encoder_ccw(0);
        repeat(2000) @(posedge clk);
        enc2_expected = enc2_start - 20;
        $display("  Count2: %0d (expected: %0d), LED: G=%b R=%b", 
                 enc2_count, enc2_expected, led_green, led_red);
        if (enc2_count == enc2_expected) begin
            $display("  ✓ Encoder 2 CCW: PASS");
        end else begin
            $display("  ✗ Encoder 2 CCW: FAIL - Delta: %0d", enc2_count - enc2_start);
        end
        
        // Check color outputs
        $display("\nTest 6: Color Signals");
        $display("  R=%b%b%b%b G=%b%b%b%b B=%b%b%b%b", 
                 VGA_R_3, VGA_R_2, VGA_R_1, VGA_R_0,
                 VGA_G_3, VGA_G_2, VGA_G_1, VGA_G_0,
                 VGA_B_3, VGA_B_2, VGA_B_1, VGA_B_0);
        if (VGA_R_0 !== 1'bx && VGA_G_0 !== 1'bx && VGA_B_0 !== 1'bx) begin
            $display("  ✓ Color signals: PASS");
        end else begin
            $display("  ✗ Color signals: FAIL - Some signals undefined");
        end
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("VGA Timing:");
        $display("  Frames: %0d | Lines/Frame: %0d | Clocks/Line: %0d", 
                 v_sync_count, lines_per_frame, clocks_per_line);
        $display("Encoders:");
        $display("  Encoder 1 final: %0d", enc1_count);
        $display("  Encoder 2 final: %0d", enc2_count);
        $display("\n=== Test Complete ===");
        $finish;
    end
    
    // Timeout
    initial begin
        #50_000_000;  // 50ms
        $display("\nTIMEOUT - Test took too long");
        $finish;
    end
    
    // VCD dump
    initial begin
        $dumpfile("pong_tb.vcd");
        $dumpvars(0, pong_tb);
    end

endmodule
