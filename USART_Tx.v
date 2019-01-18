`ifndef __USART_TX_V__ // 미완성
`define __USART_TX_V__

module USART_Tx # (
    parameter CLK_FREQ = 100000000, // 100MHz
    parameter BAUD_RATE = 115200, // 115200
	parameter DATA_BIT = 8,
	parameter NUM_OF_BUFS = 16
	)	(
	input clk,
	input reset,
	output tx,
	input [7:0] data
	)

    localparam CLKS_TO_SEND = CLK_FREQ / BAUD_RATE; // 1비트를 전송하기 위해 기다려야 하는 클럭 수

	reg [11:0] tx_clk_count; // clock count-  tx_clk_count는
	reg [3:0] tx_bit_count; // 쓰기 시작할 때 0~9까지 이동한다.
	reg [7:0] tx_data; //  count=0 때 데이터를 data_buffer에서 가져옴
	reg tx_bit; // 써야 하는 비트, tx_data에서 한 비트씩 가져옴

	assign tx = tx_bit;
	
	initial
	begin
		tx_clk_count <= 0;
		tx_bit_count <= 0;
		tx_bit <= 1'b1;
		tx_data <= 0;
	end

	// Transmitter Process at every rising edge of the clock
	always @ (posedge clk)
	begin
		if (reset)
		begin
			tx_clk_count <= 0;
			tx_bit_count <= 0;
			tx_bit <= 1'b1; // set idle
			tx_data <= 0;
		end
		else begin
			// transmit data until the index became the same with the base index
			if (tx_clk_count == CLKS_TO_SEND)
			begin
				if (tx_bit_count == 0) // to be stable
				begin
					tx_bit = 1; // idle bit
					tx_bit_count = 1;
					tx_data = data;
				end
				else if (tx_bit_count == 1)
				begin
					tx_bit = 0; // start bit
					tx_bit_count = 2;
				end
				else if (tx_bit_count < DATA_BIT + 2)
				begin
					tx_bit = tx_data[tx_bit_count-2]; // data bits
					tx_bit_count = tx_bit_count + 1;
				end
				else
				begin
					tx_bit = 1; // stop bit
					tx_bit_count = 0;
				end
				tx_clk_count = 0; // reset clock count
			end

			tx_clk_count = tx_clk_count + 1; // increase clock count
		end
	end

endmodule

`endif /*__USART_TX_V__*/
