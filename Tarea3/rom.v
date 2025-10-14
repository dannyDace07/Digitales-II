module rom (
    input [11:0] address,        // 12 bits de dirección
    output reg [15:0] data,
    output [3:0] opcode,
    output ab_select,
    output [7:0] op_address      // 8 bits para dirección de operando
);

    assign opcode      = data[15:12];
    assign ab_select   = data[11];
    assign op_address  = data[7:0]; 
    always @(*) begin
        // Formato de instrucción: [OPCODE(4)][A/B(1)][sin_usar(3)][OP_ADDR(8)]
        case (address)
            // Programa de ejemplo de la Tabla #2 (modificado para usar valores del carné)
            12'd0 : data = 16'b0011_0_000_00000000;  // LOAD A desde 000 (carné[0] = 3)
            12'd1 : data = 16'b0011_1_000_00000001;  // LOAD B desde 001 (carné[1] = 5)
            12'd2 : data = 16'b1001_0_000_00000000;  // ADD A mas B (3+5=8)
            12'd3 : data = 16'b0100_1_000_00001111;  // STORE B en 015 (guarda 8)
            
            // Prueba con otros dígitos del carné
            12'd4 : data = 16'b0011_0_000_00000010;  // LOAD A desde 002 (carné[2] = 6)
            12'd5 : data = 16'b0011_1_000_00000011;  // LOAD B desde 003 (carné[3] = 6)
            12'd6 : data = 16'b1010_0_000_00000000;  // SUB A menos B (6-6=0)
            12'd7 : data = 16'b0100_1_000_00010000;  // STORE B en 016 (guarda 0)
            
            // Prueba OR
            12'd8 : data = 16'b0011_0_000_00000000;  // LOAD A desde 000 (3)
            12'd9 : data = 16'b0011_1_000_00000001;  // LOAD B desde 001 (5)
            12'd10: data = 16'b0001_0_000_00000000;  // OR A or B (3|5=7)
            12'd11: data = 16'b0100_1_000_00010001;  // STORE B en 017 (guarda 7)
            
            // Prueba AND
            12'd12: data = 16'b0010_0_000_00000000;  // AND A and B (3&5=1)
            12'd13: data = 16'b0100_1_000_00010010;  // STORE B en 018 (guarda 1)
            
            // Prueba EQUAL (comparar valores iguales)
            12'd14: data = 16'b0011_1_000_00010001;  // LOAD B desde 017 (7)
            12'd15: data = 16'b0011_0_000_00010001;  // LOAD A desde 017 (7)
            12'd16: data = 16'b0101_0_000_00000000;  // EQUAL A equals B (7==7, debería terminar con equal=1)
            
            default: data = 16'b0000_0_000_00000000; // instrucción inválida
        endcase
    end
endmodule