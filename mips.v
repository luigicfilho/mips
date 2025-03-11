//////////////////////////////////////////////////////////////////////////////////
// Company: LC Desenvolvimentos
// Engineer: Luigi C. Filho
// 
// Create Date: 21:10 17/10/2011 
// Design Name: MIPS
// Module Name: MIPS 
// Project Name: MIPS
// Description: 
// Implementation of the MIPS processor without pipeline and just basic
// instructions and 32-bits fetch from memory.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Review of Instruction Decode
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MIPS (
			clock,
			reset
			);
			
// -------------- Signal declaration --------------------------------------------
input clock; // Clock Signal
input reset; // Reset Signal
// ---------------- Register that will become an flip-flop ----------------------
reg [31:0]program_counter;

// ---------------- Register that won't become an flip-flop ---------------------
reg [31:0]new_pc;


wire [31:0]instruction;
wire [31:0]sign_exted;
wire [31:0]rs_data;
wire [31:0]rt_data;
wire [31:0]regstb;
wire [31:0]alu_out;
wire [31:0]readmem;
wire [31:0]writeback;
wire [4:0]dest;
wire [31:0]new_jump_pc;
wire [31:0]imorsigex;
wire [0:0]zero_ext;


// ------------------------------------------------------------------------------
/*################################################################################
								Instruction FECH

Program Counter
Program Counter + 1
Instruction Memory

###################################################################################*/

// ************* Program Counter *************************************************
always @(posedge clock or negedge reset)
begin
	if(!reset)
		program_counter <= 32'd0;
	else
		program_counter <= np_jump;
end
// *******************************************************************************
// ************ Instruction Memory ***********************************************

instr_mem INST_MEM (
					.addr(program_counter), 
					.data(instruction)
					);

// ******************************************************************************
// ****************** Program Counter + 1 ***************************************
always @(program_counter)
begin
	new_pc = program_counter + 32'd1;
end
// ******************************************************************************

// ********************* Mux for Jump *******************************************
always @(jorf, pc_jump, new_pc)
begin
	np_jump = jorf ? pc_jump : new_pc;
end
// ******************************************************************************

/*################################################################################
								Instruction DECODE

Instruction Decoder Control
Jump Resolution Mux
Register File
Signal Extend

instruction 32 bits
     R-Type       |      I-Type       |     J-Type
6 opcode [31:26]  | 6 opcode [31:26]  | 6 opcode [31:26]
5 rs     [25:21]  | 5 rs     [25:21]  | 26 jump  [25:0]
5 rt     [20:16]  | 5 rt	 [20:16]  |
5 rd     [15:11]  | 16 imm   [15:0]   |
5 sa     [10:6]   |					  |
6 funct  [5:0]    |					  |

###################################################################################*/
// ************** Register File **************************************************
regfile REG_FILE (
				  .clk(clock), 
				  .w_data(writeback), // mux to UC
				  .w_ena(ref_w_ena), 
				  .r1_data(rs_data), 
				  .r2_data(rt_data), 
				  .w_addr(dest),
				  .r1_addr(instruction[25:21]), 
				  .r2_addr(instruction[20:16])
				);
// *******************************************************************************
// ***************** Signal Extension ********************************************
assign sign_exted = { {16{instruction[15]}}, instruction[15:0] }; 
// *******************************************************************************
// ****************** Instruction Decoder unit ***********************************
decoder_mips INSTR_DEC (
						.opcode(instruction[31:26]),
						.funct(instruction[5:0]),
						.outsaida(tocontrol)
						.ctrol
						);
// *******************************************************************************
// ****************** JUMP RESOLUTION ********************************************
assign pc_jump = ctrl ? { {6'd0},instruction[25:0]} : new_jump_pc;
// *******************************************************************************

/*################################################################################
							Instruction Execution

ALU
Control
Comparator
ADD
3 Muxs

###################################################################################*/

// *************** MUX register B of ALU *****************************************
// ***************** RT or Sign_extended *****************************************
assign regstb = rori ? rt_data : sign_exted ;
// *******************************************************************************

// ********************* ALU *****************************************************
alu ALU (
		  rega(rs_data),
		  regb(regstb),
		  control(aluop),
		  out_alu(alu_out),
		  cout()
		);
// *******************************************************************************

// *************** Destination Resolution ****************************************
assign dest = instype ? instruction[20:16] : instruction[15:11] ;
// *******************************************************************************

// ********************* PC Calculation and decision *****************************
assign new_jump_pc = addorn ? new_pc : (new_pc + sign_exted) ;
// *******************************************************************************

// ********************** Comparator *********************************************
always @(rs_data, rt_data)
begin
	if ( rs_data == rt_data )
	equalrsrt = 1'b1;
	else
	equalrsrt = 1'b0;
end

always @(rs_data, sign_exted)
begin
	if ( rs_data < sign_exted )
	rsmaior = 1'b0;
	else
	rsmaior = 1'b1;
end

always @(rs_data, rt_data)
begin
	if (rs_data < rt_data )
	rsmrt = 1'b1;
	else
	rsmrt = 1'b0;
end
// *******************************************************************************

// *********************** Control of Mux and ALU OP *****************************
control Control_ex (
					.in(tocontrol),
					.eq(equalrsrt),
					.muxout(muxout),
					.aluop(aluop),
					.maior(rsmaior),
					.aluormem(reoral)
					);
// *******************************************************************************

/*################################################################################
							Memory Stage

Data Memory

###################################################################################*/

// ******************* DATA Memory ***********************************************
data_mem DATA_MEM (
					.addr(alu_out),
					.w_data(rt_data),
					.r_data(readmem),
					.w_ena(d_mem_wena),
					.clk(clock)
					);
// *******************************************************************************

/*################################################################################
							Write Back Stage

Mux

###################################################################################*/

// ******************* Write Back Decision ***************************************
assign writeback = reoral ? alu_out : readmem ;
// *******************************************************************************
endmodule

