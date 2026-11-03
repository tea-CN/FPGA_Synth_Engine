module note_sel_mask(
    input      [15:0] key_mask,
    output reg [13:0]  note_en
);

always @(*) begin
    note_en[0] = key_mask[0]; // S1 C4
    note_en[1] = key_mask[1]; // S2 D4
    note_en[2] = key_mask[2]; // S3 E4
    note_en[3] = key_mask[3]; // S4 F4
    note_en[4] = key_mask[4]; // S5 G4
    note_en[5] = key_mask[5]; // S6 A4
    note_en[6] = key_mask[6]; // S7 B4
    note_en[7] = key_mask[8]; // 
    note_en[8] = key_mask[9]; 
    note_en[9] = key_mask[10]; 
    note_en[10] = key_mask[11]; 
    note_en[11] = key_mask[12]; 
    note_en[12] = key_mask[13]; 
    note_en[13] = key_mask[14]; 
end

endmodule
