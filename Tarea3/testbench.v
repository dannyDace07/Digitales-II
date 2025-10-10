`include "cmos_cells.v"

module tb_cpu;

wire clk;
wire rst;

// Señales CPU <-> ROM
wire [11:0] contador;         // 12 bits
wire [15:0] rom_data;

// Señales CPU <-> RAM
wire ram_request;
wire mem_control;
wire [11:0] address;          // 12 bits
wire [7:0] ram_data_in;       // 8 bits
wire [7:0] ram_data_out;      // 8 bits

// Señal de comparación final
wire equal;
wire reg [2:0] estado;
wire reg [2:0] proximo_estado;

// Carné para inicializar RAM: C33566
// Usar los últimos 4 dígitos: 3566
parameter CARNET = 16'h3566;  // Carné C33566

// ============================================================================
// Instanciación del probador
// ============================================================================
probador_cpu tester (
  .clk(clk),
  .rst(rst),
  .contador(contador),
  .equal(equal),
  .opcode(rom_data[15:12]),
  .regA(CPU0.regA),           // Para monitorear registros
  .regB(CPU0.regB)
);

// ============================================================================
// Instanciación de la ROM
// ============================================================================
rom ROM0 (
  .address(contador),
  .data(rom_data)
);

// ============================================================================
// Instanciación de la RAM
// ============================================================================
ram RAM0 (
  .rst(rst),
  .clk(clk),
  .request(ram_request),
  .mem_control(mem_control),
  .address(address),
  .data_in(ram_data_in),
  .data_out(ram_data_out),
  .carnet(CARNET)            // Pasar el carné para inicialización
);

// ============================================================================
// Instanciación de la CPU
// ============================================================================
cpu CPU0 (
  .clk(clk),
  .rst(rst),
  .request_rom(), 
  .contador(contador),
  .rom_data(rom_data),
  .ram_request(ram_request),
  .mem_control(mem_control),
  .address(address),
  .ram_data_in(ram_data_in),
  .ram_data_out(ram_data_out),
  .equal(equal),
  .estado(estado),
  .proximo_estado(proximo_estado)
);

// ============================================================================
// Configuración de simulación
// ============================================================================
initial begin
  $dumpfile("cpu_test.vcd");
  $dumpvars(0, tb_cpu);
  
  // Mostrar valores iniciales de RAM para carné C33566
  $display("=== Valores iniciales en RAM (Carné: C33566) ===");
  #25; // Esperar después del reset
  $display("RAM[0] = %d (primer dígito: 3)", RAM0.memory[0]);
  $display("RAM[1] = %d (segundo dígito: 5)", RAM0.memory[1]);
  $display("RAM[2] = %d (tercer dígito: 6)", RAM0.memory[2]);
  $display("RAM[3] = %d (cuarto dígito: 6)", RAM0.memory[3]);
  $display("================================================");
  $display("\nValores esperados de las operaciones:");
  $display("ADD: 3 + 5 = 8");
  $display("SUB: 6 - 6 = 0");
  $display("OR:  3 | 5 = 7");
  $display("AND: 3 & 5 = 1");
  $display("EQUAL: 6 == 6 = true (programa debe terminar)");
  $display("================================================\n");
end

endmodule