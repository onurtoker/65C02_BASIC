module sys_mem(addr, WE, ram_in, ram_out, clk);

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
end     

initial 
begin

	$readmemh("src/basic.hex", ram);

end   
 
endmodule
