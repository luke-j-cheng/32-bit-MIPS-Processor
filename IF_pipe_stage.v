`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
    reg [9:0] PC;
    wire [9:0] new_addr, branch_mux_out;
    assign pc_plus4 = PC + 4;
    always @(posedge clk or posedge reset)begin
        if(reset)
            PC <= 0;
        else if (en)
            PC <= new_addr;
    end
    mux2 #(10) branchmux(
        .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(branch_mux_out));
    mux2 #(10) jumpmux(
        .a(branch_mux_out),
        .b(jump_address),
        .sel(jump),
        .y(new_addr));
        
    instruction_mem im_inst(
        .read_addr(PC),
        .data(instr));
    
        
endmodule
