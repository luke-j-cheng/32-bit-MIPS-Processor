`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    wire [4:0] rs, rt;
    wire eq;
    wire [31:0] imm_sign_ex;
    wire reg_dst_sig;
    wire mem_to_reg_sig;
    wire [1:0] alu_op_sig;
    wire mem_read_sig;
    wire mem_write_sig;
    wire alu_src_sig;
    wire reg_write_sig;
    wire branch_sig;

    wire hazard;
    
    wire [25:0] tempjump;
    wire [31:0] offset;
    

    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage. 
    
    assign eq = ((reg1^reg2) == 32'd0) ? 1'b1: 1'b0;
    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign imm_value = imm_sign_ex;
    assign hazard = ~Data_Hazard || Control_Hazard; 
    assign branch_taken = branch_sig && eq;
    assign tempjump = instr[25:0] << 2;
    assign jump_address = tempjump[9:0];
    assign offset = imm_sign_ex << 2;
    assign branch_address = pc_plus4 + offset[9:0];  
    
    //Module Instantiation	
    register_file reg_inst(
        .clk(clk),
        .reset(reset),
        .reg_write_en(mem_wb_reg_write),
        .reg_write_dest(mem_wb_write_reg_addr),
        .reg_write_data(mem_wb_write_back_data),
        .reg_read_addr_1(rs),
        .reg_read_addr_2(rt),
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2)
    );
    sign_extend se_inst(
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_sign_ex));
    
    mux2 #(5) reg_dest_mux(
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg));
    
    control control_inst(
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg_sig),
        .alu_op(alu_op_sig),
        .mem_read(mem_read_sig),
        .mem_write(mem_write_sig),
        .alu_src(alu_src_sig),
        .reg_write(reg_write_sig),
        .branch(branch_sig),
        .jump(jump)
    );
        
    // Mux instantiations for the wires with the _sig suffix
    // Flush Instructions when Hazard = 1
    
    
    mux2 #(1) mem_to_reg_mux(
        .a(mem_to_reg_sig),
        .b(1'b0),
        .sel(hazard),
        .y(mem_to_reg)
    );
    
    mux2 #(2) alu_op_mux(
        .a(alu_op_sig),
        .b(2'b00),
        .sel(hazard),
        .y(alu_op)
    );
    
    mux2 #(1) mem_read_mux(
        .a(mem_read_sig),
        .b(1'b0),
        .sel(hazard),
        .y(mem_read)
    );
    
    mux2 #(1) mem_write_mux(
        .a(mem_write_sig),
        .b(1'b0),
        .sel(hazard),
        .y(mem_write)
    );
    
    mux2 #(1) alu_src_mux(
        .a(alu_src_sig),
        .b(1'b0),
        .sel(hazard),
        .y(alu_src)
    );
    
    mux2 #(1) reg_write_mux(
        .a(reg_write_sig),
        .b(1'b0),
        .sel(hazard),
        .y(reg_write)
    );
    
    


endmodule
