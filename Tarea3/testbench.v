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
end

endmodule