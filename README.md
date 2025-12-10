# FPGA-ENGR433-Project: Pong
This is our Project for ENGR 433 Digital Design at Walla Walla Univeristy. It is a pong game written in SystemVerilog for a pico2-ice board using an iCE40UP5K FPGA and 640x480 @ 60Hz VGA signal to display the game.

The game is meant for two players with the goal of keeping the ball bouncing between the two paddles. The higher the score, the more speed it gets until a score of 8 when it maxes out. If the ball hits the right or left side of the screen, it will reset the score to 0 and spawn in the middle of the screen. At the top and bottom of the screen, the ball bounces off in the opposite direction. 

A custom version of this board was made for this class, so pins may differ.
The Makefile with OSS CAD Suite is used in the making of the .bin files.

## Required Materials

- pico2-ice FPGA board (iCE40UP5K)
- VGA Pmod or other VGA connection
- 2 Rotary Encoder Pmods or similar
- Monitor with VGA cable 

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


## Resources

- https://www.fpga4fun.com/ - FPGA tutorials and examples
- https://digilent.com/reference/pmod/pmodvga/start - VGA Pmod documentation
- https://digilent.com/reference/pmod/pmodenc/start - Encoder Pmod documentation
- https://github.com/tinyvision-ai-inc/pico2-ice - pico2-ice board documentation
