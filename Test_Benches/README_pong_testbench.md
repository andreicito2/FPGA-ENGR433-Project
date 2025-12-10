# Pong Testbench - EDA Playground Setup Instructions

## Files needed for EDA Playground:

1. **Design Files (Top section):**
   - `pong.sv` (your main pong game module)
   - `encoder.sv` (your encoder module)

2. **Testbench File (Bottom section):**
   - `pong_tb.sv` (the testbench created)

## EDA Playground Configuration:

- **Simulator:** Icarus Verilog 12.0
- **Language:** SystemVerilog
- **Testbench + Design Mode:** Enable

## Running the simulation:

1. Copy the contents of `pong.sv` and `encoder.sv` into the **Design** section
2. Copy the contents of `pong_tb.sv` into the **Testbench** section
3. Select **Icarus Verilog 12.0** as the simulator
4. Click **Run**

## Expected Output:

The testbench will verify:
- VGA timing (H-sync and V-sync signals)
- Correct frame structure (490-525 lines per frame, ~800 pixels per line)
- Color signal generation (12-bit RGB output - 4 bits per channel)
- Encoder signal processing for both paddles (quadrature decoding)
- Encoder count changes in response to clockwise and counter-clockwise rotation
- LED status outputs

## Testbench Features:

### Test 1: VGA Timing Verification
- Runs for 1 complete frame (450,000 clock cycles)
- Validates H-sync and V-sync timing
- Checks pixel counts per line (expected: ~800) and lines per frame (expected: 490-525)

### Test 2: Encoder 1 Clockwise Rotation
- Performs 5 complete rotations (20 counts)
- Verifies encoder count increases correctly

### Test 3: Encoder 1 Counter-Clockwise Rotation
- Performs 5 complete rotations (-20 counts)
- Verifies encoder count decreases correctly

### Test 4: Encoder 2 Clockwise Rotation  
- Performs 5 complete rotations (20 counts)
- Monitors LED outputs (green/red)
- Verifies encoder count increases correctly

### Test 5: Encoder 2 Counter-Clockwise Rotation
- Performs 5 complete rotations (-20 counts)
- Monitors LED outputs (green/red)
- Verifies encoder count decreases correctly

### Test 6: Color Signals Validation
- Checks that all 12-bit RGB color signals are defined (not 'x')
- Displays current RGB values in binary format

## Waveform Analysis:

The testbench generates a VCD file (`pong_tb.vcd`) that you can view to see:
- Clock signal (25 MHz)
- H-sync and V-sync timing
- Color outputs (12-bit RGB: VGA_R[3:0], VGA_G[3:0], VGA_B[3:0])
- Encoder inputs (quadA, quadB, quadC, quadD)
- Encoder counts (count1, count2)
- LED outputs (led_green, led_red)
- Internal signals (CounterX, CounterY, paddle positions, ball position, etc.)

## Local Simulation (Alternative):

If you want to run locally with Icarus Verilog:

```bash
# Compile
iverilog -g2012 -o pong_sim encoder.sv pong.sv pong_tb.sv

# Run simulation
vvp pong_sim

# View waveforms (requires GTKWave)
gtkwave pong_tb.vcd
```

## Notes:

- The testbench uses a 25 MHz clock (40ns period) as an approximation of the 25.175 MHz VGA pixel clock
- Each complete frame takes approximately 16.8ms to render (420,000 clock cycles at 25 MHz)
- The encoder tasks generate proper quadrature sequences with 20 clock cycle hold times for 3-stage synchronizer stability
- Each encoder rotation generates 4 counts (one per quadrature state transition)
- The testbench forces initialization of internal DUT signals to prevent X propagation issues
- All timing checks are automated with pass/fail reporting
- Test timeout is set to 50ms
