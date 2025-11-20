`default_nettype none

module debouncer #(
    parameter integer CLK_FREQ         = 12_000_000,
    parameter integer DEBOUNCE_TIME_MS = 20
)(
    input  wire clk_i,
    input  wire button_i,
    output reg  r_button_o = 0
);

localparam integer CounterMax   = (CLK_FREQ / 1000) * DEBOUNCE_TIME_MS;
localparam integer CounterWidth = $clog2(CounterMax + 1);

reg [CounterWidth-1:0] counter         = 0;
reg                    r_button_sync_0 = 0;
reg                    r_button_sync_1 = 0;
reg                    r_button_sync_2 = 0;

// Double flip-flop synchronizer to avoid metastability
always @ (posedge clk_i) begin
    r_button_sync_0 <= button_i;
    r_button_sync_1 <= r_button_sync_0;
    r_button_sync_2 <= r_button_sync_1;
end

// Debounce
always @ (posedge clk_i) begin
    if (r_button_sync_2 != r_button_o) begin
        counter <= counter + 1;
        if (counter >= CounterMax) begin
            r_button_o <= r_button_sync_2;
            counter <= 0;
        end
    end else begin
        counter <= 0;
    end
end

endmodule
