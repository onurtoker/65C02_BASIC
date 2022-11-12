`timescale 1ns / 1ps

//6551 like ACIA. 
//Note that, this is not a subset of 6551, it is just a similar unit
//No control or command registers
//00 - ACIA_RX (Read)
//00 - ACIA_TX (Write)
//01 - ACIA_STATUS (Read only)

module acia(
    input clk
    ,input reset
    ,input wr
    ,input rd 
    ,input wire [1:0] regSel
    ,input wire[7:0] dataIn
    ,output wire[7:0] dataOut
    //,output n_int         // interrupts
    ,input wire rxd
    ,output wire txd
    //,output wire[7:0] debug
    );

wire rx_empty, tx_full;     
reg ren, wen;               // FIFO read/write
wire [7:0] dataOut_uart;
reg[7:0] dataOut_r, dataOut_n;

uart U_UART(
        .clk(clk), .reset(reset),
        .rx(rxd), .tx(txd),
        .rd_uart(ren), .wr_uart(wen), 
        .r_data(dataOut_uart), .w_data(dataIn),
        .rx_empty(rx_empty), .tx_full(tx_full) 
   );

//assign debug = dataOut_uart; // {rx_empty, tx_full};

always @(posedge clk)
begin
    if (reset)
    begin
        dataOut_r <= 8'b0;
    end                       
    else
    begin
        dataOut_r <= dataOut_n;
    end
end

always @*
begin
    ren = 1'b0;
    wen = 1'b0;
    dataOut_n = dataOut_r;
    
    if ((rd) && (regSel == 2'b00))
    begin
        ren = 1'b1;                 // read from FIFO 
        dataOut_n = dataOut_uart;   // update output register
    end
    else if ((wr) && (regSel == 2'b00))    
    begin
        wen = 1'b1;     // write to FIFO 
    end
    else if ((rd) && (regSel == 2'b01))
    begin
        dataOut_n = {6'b0, ~tx_full, ~rx_empty};
    end
                
end

assign dataOut = dataOut_r;

endmodule
