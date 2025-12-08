# FPGA-ENGR433-Project: Pong
This is our Project for Digital Design. It is a pong game written in SystemVerilog for a pico2-ice board using a iCE40UP5K FPGA and 640x480 @ 60Hz VGA signal to display the game. 
A custom version on of this board was made for this class so pins may differ. 
The Makefile and wtih OSS CAD Suite has used in the makeing of the .bin file

The needed material for this project is:
 - pioc2-ice
 - VGA Pmod or other connection (https://digilent.com/reference/pmod/pmodvga/start)
 - 2 Rotary Encoder Pmod or similar (https://digilent.com/reference/pmod/pmodenc/start)
 - 640x480 @ 60Hz VGA connecting monitor

What each file does:
 - Ball_test.sv: Is a test file use for ball logic
 - Encoder_Test.sv: A simiple test with LED to check if the encoder state machine is working correctly
 - encoder.sv: The encoder modlue used in both Encoder_Test, Ball_test, and Pong
 - Makefile: Use with OSS CAD SUite to make .bin files. Makes a .bin for Pong and Encoder module
 - pico2-ice.pcf: the .pcf file pico2-ice board
 - Pong.bin: Main file to be upload to board to run the game
 - pong.sv: Main system verilog file with VGA code and logic 
 - VGA.sv: Code to test a VGA connection is working 

Resources
 - Help https://www.fpga4fun.com/ 
