module test_ram(addr, WE, ram_in, ram_out, clk);

input wire clk;
input wire WE;
input wire [15:0] addr;
input wire [7:0] ram_in;
output reg [7:0] ram_out;
    
reg [7:0] ram[65535:0];

always @(posedge clk)
begin
    if (WE) 
    begin
        ram[addr] <= ram_in;
        //ram_out <= 0; //ram_in;
    end
    else 
    begin
        ram_out <= ram[addr];
    end 
    
    //$display( "ram[$7000]:%2x", ram[16'h7000] );
    
end     

initial begin

// Simple Infinite Loop

	// Reset vector
	ram[16'hfffc] = 8'h00;
	ram[16'hfffd] = 8'hC0;
	
	// Main program
	ram[16'hC000] = 8'hEA;
	ram[16'hC001] = 8'hA0;
	ram[16'hC002] = 8'h00;
	ram[16'hC003] = 8'hC8;
	ram[16'hC004] = 8'hEA;
	ram[16'hC005] = 8'h4C;
	ram[16'hC006] = 8'h03;
	ram[16'hC007] = 8'hC0;	


end   
 
endmodule
