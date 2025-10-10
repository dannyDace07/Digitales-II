module ram (
   // Outputs
   data_out,
   // Inputs
   rst, clk, request, mem_control, address, data_in, carnet
   );

  localparam ESCRITURA = 0;
  localparam LECTURA   = 1;

  input         rst, clk, request, mem_control;
  input [11:0]  address;        // 12 bits de dirección
  output reg [7:0] data_out;    // 8 bits de datos
  input      [7:0] data_in;     // 8 bits de datos
  input [15:0] carnet;          // Últimos 4 dígitos del carné

  reg [7:0] memory[255:0];      // 256 posiciones de 8 bits cada una
  reg initialized;              // Flag para inicializar solo una vez

  // Inicializar memoria con los dígitos del carné
  integer i;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Inicializar toda la memoria a cero
      for (i = 0; i < 256; i = i + 1) begin
        memory[i] <= 8'b0;
      end
      
      // Cargar los últimos 4 dígitos del carné en las primeras 4 posiciones
      // Para carné C33566: memory[0]=3, memory[1]=5, memory[2]=6, memory[3]=6
      memory[0] <= {4'b0000, carnet[15:12]};  // Primer dígito: 3
      memory[1] <= {4'b0000, carnet[11:8]};   // Segundo dígito: 5
      memory[2] <= {4'b0000, carnet[7:4]};    // Tercer dígito: 6
      memory[3] <= {4'b0000, carnet[3:0]};    // Cuarto dígito: 6
      
      data_out <= 8'b0;
      initialized <= 1'b1;  // Marcar como inicializado
    end 
    else begin
      // Solo procesar requests cuando NO estamos en reset
      if (request) begin
        case (mem_control)
          ESCRITURA: begin
            memory[address[7:0]] <= data_in;
            // Mantener data_out en escritura  
          end
          LECTURA: begin
            data_out <= memory[address[7:0]];
          end
        endcase
      end
      // Si no hay request, mantener el último valor de data_out
    end
  end

endmodule