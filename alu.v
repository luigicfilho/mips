//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Luigi C. Filho
// 
// Create Date:    16:42:29 04/06/2011 
// Design Name: ALU
// Module Name: alu
// Project Name: MIPS Processor
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision 0.05 - Alterações menores
// Revision 0.04 - Adaptação para datapath final
// Revision 0.03 - Parametrização
// Revision 0.02 -Escrita do codigo
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu(
	  rega,
	  regb,
	  control,
	  out_alu,
	  cout
		);
	
parameter DATA_WITH = 16;
parameter OP_SIZE = 3;

`define ADD 4'd0
`define SUB 4'd1
`define AND 4'd2
`define OR 4'd3
`define XOR 4'd4
`define L_SH 4'd5
`define R_SH 4'd6
`define NOR 4'd7
`define PRE 17
`define PRE_ZERO 17'd0
`define ONE_BIT_ONE 1'b1
`define ONE_BIT_ZERO 1'b0

    input 		[DATA_WITH-1:0] rega;
    input 		[DATA_WITH-1:0] regb;
	input 		[OP_SIZE-1:0] 	control;
    output reg 	[DATA_WITH-1:0]	out_alu;
    output reg 					cout;

	reg 		[DATA_WITH+1:0]	pre_out;
	
always @(rega or regb or control)
begin
	case (control)
		`ADD  : pre_out = rega + regb; //0
		`SUB  : pre_out = rega - regb; //1
		`AND  : pre_out = rega & regb; //2
		`OR   : pre_out = rega | regb; //3
		`XOR  : pre_out = rega ^ regb; //4
		`L_SH : pre_out = rega << regb; //5
		`R_SH : pre_out = rega >> regb; //6
		`NOR  : pre_out = ~(rega | regb); //7
	endcase
end

always @(pre_out)
begin
		out_alu = pre_out[DATA_WITH-1:0];
		cout = pre_out[`PRE];
end		

endmodule
