`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2026 07:49:51 AM
// Design Name: 
// Module Name: DataGen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module DataGen(
    input clk,
    input rstn,
    input [15:0] sw,
    
    // =========================================================================
    // BRAM Port A Interface (Master)
    // =========================================================================
    (* X_INTERFACE_MODE = "master" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *)
    output [8:0]  addrsa,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *)
    output        clka,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *)
    output [15:0] dina,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *)
    input  [15:0] douta,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *)
    output        ena,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *)
    output [0:0]  wea,

    // Standalone wave monitor
    output [15:0] wave,

    // =========================================================================
    // AXI-Stream Master Interface -> FIR Compiler (16-bit Real)
    // =========================================================================
    (* X_INTERFACE_MODE = "master" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_FIR TDATA" *)
    output [15:0] m_axis_fir_tdata,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_FIR TVALID" *)
    output        m_axis_fir_tvalid,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_FIR TREADY" *)
    input         m_axis_fir_tready,

    // =========================================================================
    // AXI-Stream Master Interface -> XFFT (32-bit Complex: [31:16] Im, [15:0] Re)
    // =========================================================================
    (* X_INTERFACE_MODE = "master" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_FFT TDATA" *)
    output [31:0] m_axis_fft_tdata,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_FFT TVALID" *)
    output        m_axis_fft_tvalid,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_FFT TREADY" *)
    input         m_axis_fft_tready,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_FFT TLAST" *)
    output        m_axis_fft_tlast
);

    reg [8:0] count;
    reg       dout_valid;

    // Address generator counter
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count      <= 9'h000;
            dout_valid <= 1'b0;
        end else begin
            count      <= count + sw[8:0];
            dout_valid <= 1'b1; // Aligns with BRAM 1-cycle read latency
        end
    end

    // -------------------------------------------------------------------------
    // BRAM Controls
    // -------------------------------------------------------------------------
    assign addrsa = count;
    assign clka   = clk;
    assign dina   = 16'h0000;
    assign ena    = 1'b1;
    assign wea    = 1'b0;
    assign wave   = douta;

    // -------------------------------------------------------------------------
    // AXI-Stream -> FIR Compiler
    // -------------------------------------------------------------------------
    assign m_axis_fir_tdata  = douta;
    assign m_axis_fir_tvalid = dout_valid;

    // -------------------------------------------------------------------------
    // AXI-Stream -> XFFT (douta mapped to Real channel, Imaginary tied to 0)
    // -------------------------------------------------------------------------
    assign m_axis_fft_tdata  = {16'h0000, douta}; 
    assign m_axis_fft_tvalid = dout_valid;

    // TLAST asserted at the end of the frame (count == 511 for a 512-point FFT)
    assign m_axis_fft_tlast  = (count == 9'd511);

endmodule