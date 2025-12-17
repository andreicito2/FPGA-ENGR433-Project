# FPGA-ENGR433-Project: Pong
This is our Project for ENGR 433 Digital Design at Walla Walla Univeristy. It is a pong game written in SystemVerilog for a pico2-ice board using an iCE40UP5K FPGA and 640x480 @ 60Hz VGA signal to display the game.

The game is meant for two players with the goal of keeping the ball bouncing between the two paddles. The higher the score, the more speed it gets until a score of 8 when it maxes out. If the ball hits the right or left side of the screen, it will reset the score to 0 and spawn in the middle of the screen. At the top and bottom of the screen, the ball bounces off in the opposite direction. 

A custom version of this board was made for this class, so pins may differ.
The Makefile with OSS CAD Suite is used in the making of the .bin files.

## Required Materials

- pico2-ice FPGA board (iCE40UP5K)
- VGA Pmod (Digilent PmodVGA or compatible)
- 2 Rotary Encoder Pmods (Digilent PmodENC or compatible)
- Monitor with VGA cable
- Jumper wires or Pmod cables

## Hardware Setup

### Connecting the Pmods

#### VGA Pmod
Connect the VGA Pmod to the pico2-ice board using the following pin mappings:
- **VGA Red (4-bit)**: Pins 4, 2, 45, 47 (R0-R3)
- **VGA Green (4-bit)**: Pins 43, 38, 34, 31 (G0-G3)
- **VGA Blue (4-bit)**: Pins 3, 44, 46, 48 (B0-B3)
- **Horizontal Sync**: Pin 42
- **Vertical Sync**: Pin 36

#### Encoder Pmod 1 (Left Paddle)
- **quadA**: Pin 23
- **quadB**: Pin 18

#### Encoder Pmod 2 (Right Paddle)
- **quadC**: Pin 25
- **quadD**: Pin 19

### Assembly Steps

1. **Connect VGA Pmod**: Attach the VGA Pmod to the appropriate GPIO pins on the pico2-ice board according to the pin mappings above
2. **Connect Encoder 1**: Wire the first rotary encoder Pmod (quadA/quadB) to pins 23 and 18
3. **Connect Encoder 2**: Wire the second rotary encoder Pmod (quadC/quadD) to pins 25 and 19
4. **Connect VGA Cable**: Plug your monitor's VGA cable into the VGA Pmod
5. **Power the Board**: Connect the pico2-ice board to your computer via USB

**Note**: The custom board version used in this class may have different Pmod connector locations. Verify pin assignments match your specific board layout.

## File Descriptions

### Source Files
- **Ball_test.sv**: Test file used for ball logic and physics testing
- **Encoder_Test.sv**: Simple test with LED to check if the encoder state machine is working correctly
- **encoder.sv**: The encoder module used in Encoder_Test, Ball_test, and Pong (quadrature decoder)
- **pong.sv**: Main SystemVerilog file with VGA timing, game logic, ball physics, and paddle control
- **VGA.sv**: Test code to verify VGA connection is working

### Configuration & Build Files
- **Makefile**: Used with OSS CAD Suite to synthesize and create .bin files. Currently configured for VGA module (change TOP_MODULE variable for different builds)
- **pico2-ice.pcf**: Pin constraint file for the pico2-ice board

### Binary Files
- **Pong.bin**: Main bitstream file to upload to the board to run the game
- **Test_Bins/**: Directory containing test binaries (Ball_test.bin, encoder_test.bin, VGA.bin)

### Test Files
- **Test_Benches/**: Contains simulation testbenches
  - **pong_tb.sv**: SystemVerilog testbench for the Pong module
  - **README_pong_testbench.md**: Documentation for running the testbench on EDA Playground or locally 

## Building and Programming the FPGA

### Synthesizing the Bitstream

To build a specific module, edit the `Makefile` and change the `TOP_MODULE` and `SRCS` variables:

**For the main Pong game:**
```makefile
TOP_MODULE := Pong
SRCS := pong.sv encoder.sv
```

**For VGA test:**
```makefile
TOP_MODULE := VGA
SRCS := VGA.sv encoder.sv
```

**For Encoder test:**
```makefile
TOP_MODULE := Encoder_Test
SRCS := Encoder_Test.sv encoder.sv
```

Then run:
```bash
make
```

This will:
1. Synthesize the SystemVerilog code with Yosys
2. Place and route with nextpnr-ice40
3. Pack the design into a bitstream (.bin file)

### Programming the Board

To upload the bitstream to the pico2-ice board:
 We  manually upload the `Pong.bin` file using using Thonny to connect with the borad. It can also be upload with the Makefile if the file is uploaded.

### Playing the Game

1. Ensure all hardware connections are secure
2. Program the board with `Pong.bin`
3. Turn on your VGA monitor
4. Use the two rotary encoders to control the left and right paddles
5. Keep the ball bouncing to increase your score!

## Resources

- https://www.fpga4fun.com/ - FPGA tutorials and examples
- https://digilent.com/reference/pmod/pmodvga/start - VGA Pmod documentation
- https://digilent.com/reference/pmod/pmodenc/start - Encoder Pmod documentation
- https://github.com/frohro/pico2-ice - pico2-ice board documentation
- http://www.tinyvga.com/vga-timing/640x480@60Hz - Understanding VGA timing and clock
- https://projectf.io/posts/video-timings-vga-720p-1080p - Image reference