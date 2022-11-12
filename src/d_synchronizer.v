`timescale 1ns / 1ps
`default_nettype none

// Project F: Async Reset
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module d_synchronizer
    #(init_value = 1'b0, n = 2)
    (
    input  wire clk,        // clock
    input  wire rst,        // reset
    input  wire d_async,    // async
    output reg  d_sync      // sync
    );

    (* ASYNC_REG = "TRUE" *) reg [n-1:0] shf;  // shift reg

    always @(posedge clk)
    if (rst)
        {d_sync, shf} <= {(n+1){init_value}};
    else
        {d_sync, shf} <= {shf, d_async};

endmodule

