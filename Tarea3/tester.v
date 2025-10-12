// ============================================================================
// PROBADOR DE CPU
// Genera reloj y aplica reset inicial.
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
    clk = 0;
    rst = 1;         // Reset inicial
    #20 rst = 0;     // Quitar reset -> CPU empieza
    
    // Esperar tiempo suficiente para la simulación
    #900;
    
    $finish;
  end

endmodule