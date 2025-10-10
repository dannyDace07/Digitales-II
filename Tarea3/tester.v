// ============================================================================
// PROBADOR DE CPU
// Genera reloj, aplica reset inicial, y muestra señales clave.
// ============================================================================

module probador_cpu (
  output reg clk,
  output reg rst,
  input [11:0] contador,      // 12 bits
  input [3:0] opcode,
  input equal,
  input [7:0] regA,           
  input [7:0] regB
);

  // Generar el reloj (período 10 unidades)
  always #5 clk = ~clk;

  // Secuencia de pruebas
  initial begin
    $display("===== INICIO DE SIMULACIÓN =====");
    $display("Tiempo | PC   | Opcode | A/B | RegA | RegB | Equal | Instrucción");
    $display("-------|------|--------|-----|------|------|-------|-------------");
    
    clk = 0;
    rst = 1;         // Reset inicial
    #20 rst = 0;     // Quitar reset -> CPU empieza
    $display(">>> Reset finalizado, CPU corriendo...\n");

    // Esperar a que se ejecute EQUAL o timeout
    #900;
    
    if (equal) begin
      $display("\n>>> Programa terminó con EQUAL=1 en t=%0t", $time);
    end else begin
      $display("\n>>> Simulación terminó por timeout en t=%0t", $time);
    end
    
    $display("\n===== FIN DE SIMULACIÓN =====");
    $finish;
  end

  // Mostrar valores de control en cada flanco de reloj
  always @(posedge clk) begin
    if (!rst) begin
      case(opcode)
        4'b0011: $display("%6t | %4d | %4b | %s | %4d | %4d | %5b | LOAD", 
                         $time, contador, opcode, "X", regA, regB, equal);
        4'b0100: $display("%6t | %4d | %4b | %s | %4d | %4d | %5b | STORE", 
                         $time, contador, opcode, "X", regA, regB, equal);
        4'b1001: $display("%6t | %4d | %4b | %s | %4d | %4d | %5b | ADD", 
                         $time, contador, opcode, "-", regA, regB, equal);
        4'b1010: $display("%6t | %4d | %4b | %s | %4d | %4d | %5b | SUB", 
                         $time, contador, opcode, "-", regA, regB, equal);
        4'b0001: $display("%6t | %4d | %4b | %s | %4d | %4d | %5b | OR", 
                         $time, contador, opcode, "-", regA, regB, equal);
        4'b0010: $display("%6t | %4d | %4b | %s | %4d | %4d | %5b | AND", 
                         $time, contador, opcode, "-", regA, regB, equal);
        4'b0101: $display("%6t | %4d | %4b | %s | %4d | %4d | %5b | EQUAL", 
                         $time, contador, opcode, "-", regA, regB, equal);
        default: $display("%6t | %4d | %4b | %s | %4d | %4d | %5b | ???", 
                         $time, contador, opcode, "?", regA, regB, equal);
      endcase
    end
  end

  // Plan de pruebas detallado
  initial begin
    #25; // Esperar después del reset
    $display("\n=== PLAN DE PRUEBAS ===");
    $display("1. LOAD A y B desde memoria - Verificar carga de registros");
    $display("2. ADD A+B - Verificar suma aritmética");
    $display("3. SUB A-B - Verificar resta aritmética");
    $display("4. OR A|B - Verificar operación lógica OR");
    $display("5. AND A&B - Verificar operación lógica AND");
    $display("6. STORE - Verificar escritura en memoria");
    $display("7. EQUAL - Verificar comparación y terminación del programa");
    $display("========================\n");
  end

endmodule