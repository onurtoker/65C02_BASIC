`timescale 1ns / 1ps

module acia_test(
  input clk                     // 100 MHz
, input reset                   // btnC

, input rx, output tx           // RX/TX          
, input ren, input wen          // btnU, btnD
, input wire[7:0] dataIn        // SW[7:0]
, output wire[7:0] dataOut      // LED[7:0]
, input regSel                  // SW[15]
, output wire[7:0] debug
);

wire cpu_clk;

PLL U_PLL(
    .clk_out1(cpu_clk),     // output clk_out1
    .clk_in1(clk)           // input clk_in1
);      

debounce U_dbw(.clk(cpu_clk), .reset(reset), .sw(wen), .db_tick(wen_tick));
debounce U_dbr(.clk(cpu_clk), .reset(reset), .sw(ren), .db_tick(ren_tick));

acia U_ACIA(
    .clk(cpu_clk), .reset(reset),
    .wr(wen_tick), .rd(ren_tick), .regSel({1'b0,regSel}),
    .dataOut(dataOut), .dataIn(dataIn), .debug(debug),
    .rxd(rx), .txd(tx)
    );

endmodule
