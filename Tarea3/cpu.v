module cpu (
  input  wire clk,
  input  wire rst,

  // Señales de ROM
  output reg  request_rom,
  output reg  [11:0] contador,     // Dirección en ROM (contador de programa)
  input  wire [15:0] rom_data,     // Instrucción completa desde ROM

  // Señales de RAM
  output reg  ram_request,
  output reg  mem_control,         // 0 = Escritura, 1 = Lectura
  output reg  [11:0] address,      // Dirección de RAM
  output reg  [7:0] ram_data_in,   
  input  wire [7:0] ram_data_out,  

  // Salida de comparación
  output reg  equal,
  output reg [2:0] estado, 
  output reg [2:0] proximo_estado
);

  // --------------------------
  // Estados
  // --------------------------
  localparam BUSCAR               = 3'b000;
  localparam DECODIFICAR          = 3'b001;
  localparam EJECUTAR             = 3'b010;
  localparam ESPERAR_RAM          = 3'b011;
  localparam ESCRIBIR             = 3'b100;
  localparam INCREMENTAR_CONTADOR = 3'b101;
  localparam DETENER              = 3'b110;


  // --------------------------
  // Registros internos
  // --------------------------
  reg [7:0] regA, regB;           // Registros A y B 
  reg [3:0]  opcode;
  reg        ab_select;
  reg [7:0]  op_address;          // Dirección de operando de 8 bits

  // ================================================================
  // LÓGICA SECUENCIAL: actualizar estado y registros
  // ================================================================
  always @(posedge clk) begin
    if (rst) begin
      estado       <= BUSCAR;
      contador     <= 0;
      regA         <= 0;
      regB         <= 0;
      opcode       <= 0;
      ab_select    <= 0;
      op_address   <= 0;
      equal        <= 0;
    end else begin
      estado <= proximo_estado;

      case (estado)
        DECODIFICAR: begin
          opcode      <= rom_data[15:12];
          ab_select   <= rom_data[11];
          op_address  <= rom_data[7:0];
        end

        EJECUTAR: begin
          case (opcode)
            4'b1001: regB <= regA + regB;   // ADD
            4'b1010: regB <= regA - regB;   // SUB
            4'b0001: regB <= regA | regB;   // OR
            4'b0010: regB <= regA & regB;   // AND
            4'b0101: equal <= (regA == regB); // EQUAL
            default: ; 
          endcase
        end

        ESCRIBIR: begin
          // Cargar dato de RAM al registro
          if (ab_select == 1'b0)
            regA <= ram_data_out;
          else
            regB <= ram_data_out;
        end

        INCREMENTAR_CONTADOR: begin
          contador <= contador + 1;
        end
      endcase
    end
  end

  // ================================================================
  // LÓGICA COMBINACIONAL: decidir el próximo estado y señales
  // ================================================================
  always @(*) begin
    proximo_estado = estado;
    request_rom    = 0;
    ram_request    = 0;
    mem_control    = 0;
    address        = {4'b0000, op_address};
    ram_data_in    = 0;

    case (estado)
      // ----------------------------------------
      BUSCAR: begin
        request_rom    = 1;
        proximo_estado = DECODIFICAR;
      end

      // ----------------------------------------
      DECODIFICAR: begin
        request_rom    = 0;
        proximo_estado = EJECUTAR;
      end

      // ----------------------------------------
      EJECUTAR: begin
        case (opcode)
          4'b0011: begin // LOAD
            ram_request    = 1;
            mem_control    = 1;
            address        = {4'b0000, op_address};
            proximo_estado = ESPERAR_RAM;  // Dar tiempo a la RAM
          end

          4'b0100: begin // STORE
            ram_request    = 1;
            mem_control    = 0;
            address        = {4'b0000, op_address};
            ram_data_in    = (ab_select) ? regB : regA;
            proximo_estado = INCREMENTAR_CONTADOR;
          end

          4'b0101: begin // EQUAL
            if (regA == regB) begin
              proximo_estado = DETENER;
            end else begin
              proximo_estado = INCREMENTAR_CONTADOR;
            end
          end

          4'b1001, 4'b1010, 4'b0001, 4'b0010: begin
            proximo_estado = INCREMENTAR_CONTADOR;
          end

          default: begin
            proximo_estado = INCREMENTAR_CONTADOR;
          end
        endcase
      end

      // ----------------------------------------
      ESPERAR_RAM: begin
        // Mantener señales activas para que la RAM responda
        ram_request    = 1;
        mem_control    = 1;
        address        = {4'b0000, op_address};
        proximo_estado = ESCRIBIR;
      end

      // ----------------------------------------
      ESCRIBIR: begin
        // La RAM ya respondió, ahora leer el dato
        ram_request    = 0;
        mem_control    = 0;
        proximo_estado = INCREMENTAR_CONTADOR;
      end

      // ----------------------------------------
      INCREMENTAR_CONTADOR: begin
        if (opcode == 4'b0101 && equal) begin
          proximo_estado = DETENER;
        end else begin
          proximo_estado = BUSCAR;
        end
      end

      // ----------------------------------------
      DETENER: begin
        request_rom    = 0;
        ram_request    = 0;
        mem_control    = 0;
        proximo_estado = DETENER;
      end
    endcase
  end
endmodule