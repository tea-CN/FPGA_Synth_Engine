module key_debounce(
    input               clk,
    input               rst_n,
    output reg [3:0]    col,    
    input      [3:0]    row,    
    output reg [15:0]   key_mask
);

// 简单的列扫描（1ms切换）
reg [15:0] scan_cnt;
reg [1:0]  scan_sel;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        scan_cnt <= 16'd0;
        scan_sel <= 2'd0;
    end
    else begin
        scan_cnt <= scan_cnt + 16'd1;
        if(scan_cnt == 16'd27000) begin
            scan_cnt <= 16'd0;
            scan_sel <= scan_sel + 2'd1;
        end
    end
end

always @(*) begin
    case(scan_sel)
        2'd0: col = 4'b1110;
        2'd1: col = 4'b1101;
        2'd2: col = 4'b1011;
        2'd3: col = 4'b0111;
    endcase
end

// 消抖缓存
reg [15:0] key_sync;
reg [19:0] debounce_cnt;
localparam DEB_WAIT = 270000; // 10ms@27M

// 临时用最简单的逻辑：直接把 row 的值锁存进 key_mask
// 注意：这里为了不被优化，必须让 key_mask 的每一位都真正受到 row 变化的影响
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
key_sync <= 16'd0;
        key_mask <= 16'd0;
        debounce_cnt <= 20'd0;
    end
    else begin
        // 采样当前扫描列
        case(scan_sel)
            2'd0: key_sync[3:0]   <= ~row;
            2'd1: key_sync[7:4]   <= ~row;
            2'd2: key_sync[11:8]  <= ~row;
            2'd3: key_sync[15:12] <= ~row;
        endcase

        if(key_sync != key_mask) begin
            debounce_cnt <= debounce_cnt + 1'd1;
            if(debounce_cnt >= DEB_WAIT) begin
                key_mask <= key_sync;
                debounce_cnt <= 20'd0;
            end
        end
        else begin
            debounce_cnt <= 20'd0;
        end
    end
end

endmodule