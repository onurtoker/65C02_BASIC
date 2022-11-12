
module DE2_Apple1(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,
//	input 		          		CLOCK2_50,
//	input 		          		CLOCK3_50,

	//////////// LED //////////
	output		     [8:0]		LEDG,
	output		    [17:0]		LEDR,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		    [17:0]		SW,

	//////////// SEG7 //////////
//	output		     [6:0]		HEX0,
//	output		     [6:0]		HEX1,
//	output		     [6:0]		HEX2,
//	output		     [6:0]		HEX3,
//	output		     [6:0]		HEX4,
//	output		     [6:0]		HEX5,
//	output		     [6:0]		HEX6,
//	output		     [6:0]		HEX7,

	//////////// RS232 //////////
//	input 		          		UART_CTS,
//	output		          		UART_RTS,
	input 		          		UART_RXD,
	output		          		UART_TXD,

	//////////// PS2 for Keyboard and Mouse //////////
//	inout 		          		PS2_CLK,
//	inout 		          		PS2_CLK2,
//	inout 		          		PS2_DAT,
//	inout 		          		PS2_DAT2,

	//////////// VGA //////////
//	output		     [7:0]		VGA_B,
//	output		          		VGA_BLANK_N,
//	output		          		VGA_CLK,
//	output		     [7:0]		VGA_G,
//	output		          		VGA_HS,
//	output		     [7:0]		VGA_R,
//	output		          		VGA_SYNC_N,
//	output		          		VGA_VS,

	//////////// GPIO, GPIO connect to GPIO Default //////////
	output 		    [35:0]		GPIO
);


// ------------------------------------------------------------------------------------------ // CLOCK management

	wire reset, we, sync, btn, dbl, dbt, clk_cpu, reset_cpu;

	assign reset 		= ~KEY[0];
	assign btn		 	= ~KEY[1];
	assign reset_cpu	= ~KEY[3];	
	
//	assign clk_cpu 	= dbl;								// cpu_clk is KEY[1]
//	myPLL U_PLL(.inclk0(CLOCK_50), .c0(clk_cpu));	// cpu_clk is from PLL
	assign clk_cpu = CLOCK_50;								// cpu_clk is XTAL 50 MHz
		

//	wire [15:0] addr;
//	wire [7:0] din, dout;	
	
//	// 6502 CPU
//	cpu_65c02 U1(.clk(clk_cpu), .reset(reset_cpu), 
//					.AB(addr), .DI(din), .DO(dout), .WE(we), 
//					.IRQ(1'b0), .NMI(1'b0), .RDY(1'b1), .SO(0));
//										
//	// SRAM
//	test_ram U2(.clk(clk_cpu), 
//				.addr(addr), .ram_in(dout), .ram_out(din), .WE(we));

//	// Debounce
//	debounce U3(.clk(CLOCK_50), .reset(reset),
//					.sw(btn), .db_level(dbl), .db_tick(dbt));

// ------------------------------------------------------------------------------------------ // Arlet 65C02 

	wire [15:0] CPU_AB;
	wire [7:0] CPU_DI;
	wire [7:0] CPU_DO;
	wire CPU_WE;

	cpu_65c02 U_CPU( 
	  .clk(clk_cpu),
	  .reset(reset_cpu),
	  .AB(CPU_AB),
	  .DI(CPU_DI),
	  .DO(CPU_DO),
	  .WE(CPU_WE),
	  .IRQ(0),
	  .NMI(0),
	  .RDY(1),
	  .SO(0)
	); 
		
// ------------------------------------------------------------------------------------------ // ACIA

	wire tx, rx;
	assign rx = UART_RXD;
	assign UART_TXD = tx;

	wire [1:0] acia_regSel;
	wire [7:0] acia_in, acia_out;
	wire acia_wen, acia_ren;

	acia U_ACIA(
		 .clk(clk_cpu), .reset(reset_cpu),
		 .wr(acia_wen), .rd(acia_ren), .regSel(acia_regSel),
		 .dataOut(acia_out), .dataIn(acia_in), 
		 .rxd(rx), .txd(tx)
		 );

	assign acia_regSel = CPU_AB;
	assign acia_in = CPU_DO;

	assign acia_wen = ACIA_SEL & CPU_WE;
	assign acia_ren = ACIA_SEL & (~CPU_WE);
	
// ------------------------------------------------------------------------------------------ // SYS MEM

	wire [7:0] mem_in, mem_out;
	wire [15:0] mem_addr;

	assign mem_addr = CPU_AB;
	assign mem_in = CPU_DO;

		 
	smem U_SMEM(
		.address(mem_addr),
		.clock(clk_cpu),
		.data(mem_in),
		.wren(mem_wen),
		.q(mem_out)
	);		 

	assign mem_wen = RAM_SEL & CPU_WE;
	assign mem_ren = RAM_SEL & (~CPU_WE);
		 
// ------------------------------------------------------------------------------------------ // Glue logic

	wire RAM_SEL, RAM_SEL_DELAYED;
	wire ACIA_SEL;
	assign ACIA_SEL = ({CPU_AB[15:1], 1'b0} == 16'h8400); // ACIA addresses $8400-$8401
	assign RAM_SEL = ~ACIA_SEL; 

	myReg U_REG(.clk(clk_cpu), .reset(reset_cpu), .din(RAM_SEL), .dout(RAM_SEL_DELAYED));
	
	assign CPU_DI = RAM_SEL_DELAYED ? mem_out : acia_out;
	
// ------------------------------------------------------------------------------------------ // DEBUG RELATED 
	
	assign GPIO[0] 	= tx;
   assign GPIO[1] 	= rx;
//	assign GPIO[2] 	= clk_cpu;
//	assign GPIO[3] 	= ACIA_SEL;
	assign GPIO[7:4]  = CPU_AB[3:0];

	assign LEDR[15:0] = CPU_AB;
	assign LEDG[8] 	= btn;

endmodule
