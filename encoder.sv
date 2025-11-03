module encoder (
    clk,
    count
);
    input logic clk,
    input logic quadA,
    input logic quadB,
    output logic [7:0] count;

    reg [2:0] quadA_d, quadB_d;
    always_ff @( posedge clk ) begin 
        quadA_d <= { quadA_d[1:0], quadA };
        quadB_d <= { quadB_d[1:0], quadB };        
    end

    logic count_enable = quadA_d[1] ^ quadA_d[2] ^ quadB_d[1]  ^ quadB_d[2];
    logic count_dir = quadA_d[1] ^ quadB_d[2];

    reg [7:0] count_reg;
    always_ff @( posedge clk ) begin
        if(count_enable) begin
            if(count_dir)
                count_reg <= count_reg + 1;
            else
                count_reg <= count_reg - 1;
        end
    end


endmodule