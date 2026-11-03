module chord_generator(
    input  [15:0] key_mask,   
    output reg [16:0] t0, t1, t2, t3, t4, t5, t6, // 左边：三角波（和弦）
    output reg [16:0] f0, f1, f2, f3, f4, f5, f6  // 右边：锯齿波（单音）
);

always @(*) begin
    // 默认全部静音
    t0 = 17'd0; t1 = 17'd0; t2 = 17'd0; t3 = 17'd0; t4 = 17'd0; t5 = 17'd0; t6 = 17'd0;
    f0 = 17'd0; f1 = 17'd0; f2 = 17'd0; f3 = 17'd0; f4 = 17'd0; f5 = 17'd0; f6 = 17'd0;

    // ============ 左边组（三角波）：触发和弦 ============
    // 键[0]：C 大和弦 (Do + Mi + Sol + 高音Do)
        if (key_mask[0]) begin
        t0 = 17'd25400; // Do
        t1 = 17'd32000; // Mi
        t2 = 17'd38000; // Sol
        t3 = 17'd50800; // 高音 Do
        t4 = 17'd64000; // 高音 Mi (这时 u_adsr4 就被用上了)
        t5 = 17'd76000; // 高音 Sol (这时 u_adsr5 就被用上了)
        t6 = 17'd85400; // 高音 Do (这时 u_adsr6 就被用上了)
    end
    // 键[1]：F 大和弦 (Fa + La + Do' + Fa')
    else if (key_mask[1]) begin
        t0 = 17'd33900; t1 = 17'd42700; t2 = 17'd50800; t3 = 17'd67800;
    end
    // 键[2]：G 大和弦 (Sol + Si + Re' + Sol')
    else if (key_mask[2]) begin
        t0 = 17'd38000; t1 = 17'd47900; t2 = 17'd57000; t3 = 17'd76000;
    end
    // 键[3]：A 小和弦 (La + Do' + Mi' + La')
    else if (key_mask[3]) begin
        t0 = 17'd42700; t1 = 17'd50800; t2 = 17'd64000; t3 = 17'd85400;
    end
        // 键[4]：D 小和弦（Re + Fa + La）
    else if (key_mask[4]) begin
        t0 = 17'd28500; // Re
        t1 = 17'd33900; // Fa
        t2 = 17'd42700; // La
        t4 = 17'd28500; // 这里给 t4 赋值，保住 u_adsr4
    end
    // 键[5]：E 小和弦（Mi + Sol + Si）
    else if (key_mask[5]) begin
        t0 = 17'd32000; // Mi
        t1 = 17'd38000; // Sol
        t2 = 17'd47900; // Si
        t5 = 17'd32000; // 这里给 t5 赋值，保住 u_adsr5
    end
    // 键[6]：G 大和弦（Sol + Si + Re'）
    else if (key_mask[6]) begin
        t0 = 17'd38000; // Sol
        t1 = 17'd47900; // Si
        t2 = 17'd57000; // Re'
        t6 = 17'd38000; // 这里给 t6 赋值，保住 u_adsr6
    end

    // ============ 右边组（锯齿波）：触发单音旋律 ============
    // 假设右边按键是 8 到 14
    if (key_mask[8])  f0 = 17'd25400; // Do
    if (key_mask[9])  f1 = 17'd28500; // Re
    if (key_mask[10]) f2 = 17'd32000; // Mi
    if (key_mask[11]) f3 = 17'd33900; // Fa
    if (key_mask[12]) f4 = 17'd38000; // Sol
    if (key_mask[13]) f5 = 17'd42700; // La
    if (key_mask[14]) f6 = 17'd47900; // Si
end
endmodule