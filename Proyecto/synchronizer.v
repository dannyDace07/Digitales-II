/* ================================================================
 * Módulo: Synchronizer (Cláusula 36 IEEE 802.3)
 * Descripción:
 *   Implementación completa de sincronización PCS con:
 *   - Detección de 3 commas consecutivos
 *   - Contador de errores (0-4)
 *   - Validación de comma en posición impar
 *   - Recuperación con 4 code-groups válidos
 *
 * Entradas:
 *   - reset            : Señal de reinicio activo bajo
 *   - rx_clk           : Reloj de recepción
 *   - rx_code_group    : Code-group de entrada (10 bits)
 *
 * Salidas:
 *   - SUDI             : {rx_even, code-group} (11 bits)
 *   - sync_status      : Estado de sincronización (OK/FAIL)
 * ================================================================
 */

`include "pcs_cg_defs.vh"
`include "pcs_defs.vh"

module Synchronizer(
    input wire reset,
    input wire rx_clk,
    input wire [9:0] rx_code_group,
    output reg [10:0] SUDI,
    output reg sync_status
);

    // Declaración de variables de estado
    reg next_sync_status;
    reg rx_even, next_rx_even;
    reg [2:0] good_cgs, next_good_cgs;
    reg [2:0] error_count, next_error_count;
    reg [15:0] state, next_state;

    // Declaración de estados (one-hot encoding)
    parameter LOSS_OF_SYNC    = 16'b0000_0000_0000_0001;
    parameter COMMA_DETECT_1  = 16'b0000_0000_0000_0010;
    parameter ACQUIRE_SYNC_1  = 16'b0000_0000_0000_0100;
    parameter COMMA_DETECT_2  = 16'b0000_0000_0000_1000;
    parameter ACQUIRE_SYNC_2  = 16'b0000_0000_0001_0000;
    parameter COMMA_DETECT_3  = 16'b0000_0000_0010_0000;
    parameter SYNC_ACQUIRED_1 = 16'b0000_0000_0100_0000;
    parameter SYNC_ACQUIRED_2 = 16'b0000_0000_1000_0000;
    parameter SYNC_ACQUIRED_2A= 16'b0000_0001_0000_0000;
    parameter SYNC_ACQUIRED_3 = 16'b0000_0010_0000_0000;
    parameter SYNC_ACQUIRED_3A= 16'b0000_0100_0000_0000;
    parameter SYNC_ACQUIRED_4 = 16'b0000_1000_0000_0000;
    parameter SYNC_ACQUIRED_4A= 16'b0001_0000_0000_0000;

    // Constantes
    parameter FAIL = 1'b0;
    parameter OK   = 1'b1;
    parameter FALSE = 1'b0;
    parameter TRUE  = 1'b1;
    parameter ODD   = 1'b0;
    parameter EVEN  = 1'b1;

    // ================================================================
    // Lógica secuencial con flip-flops
    // ================================================================
    always @(posedge rx_clk) begin
        if (~reset) begin
            state        <= LOSS_OF_SYNC;
            rx_even      <= TRUE;
            sync_status  <= FAIL;
            good_cgs     <= 3'd0;
            error_count  <= 3'd0;
        end
        else begin
            state        <= next_state;
            rx_even      <= next_rx_even;
            sync_status  <= next_sync_status;
            good_cgs     <= next_good_cgs;
            error_count  <= next_error_count;
        end
    end

    
    // ================================================================
    // Función: data_valid
    // Verifica si un code-group es válido (D o K válidos)
    // ================================================================
    function data_valid;
        input [9:0] codegroup_data;
        begin
            case (codegroup_data)
                // Datos D0.0 - D9.0
                `D0_0_decmenos,  `D0_0_decmas,
                `D1_0_decmenos,  `D1_0_decmas,
                `D2_0_decmenos,  `D2_0_decmas,
                `D3_0_decmenos,  `D3_0_decmas,
                `D4_0_decmenos,  `D4_0_decmas,
                `D5_0_decmenos,  `D5_0_decmas,
                `D6_0_decmenos,  `D6_0_decmas,
                `D7_0_decmenos,  `D7_0_decmas,
                `D8_0_decmenos,  `D8_0_decmas,
                `D9_0_decmenos,  `D9_0_decmas,
                // Datos especiales
                `D5_6_decmenos,  `D5_6_decmas,
                `D16_2_decmenos, `D16_2_decmas,
                // K-codes especiales
                `K23_7_RDN,      `K23_7_RDP,
                `K27_7_RDN,      `K27_7_RDP,
                `K29_7_RDN,      `K29_7_RDP:
                    data_valid = 1'b1;
                default:
                    data_valid = 1'b0;
            endcase
        end
    endfunction
    
    // ================================================================
    // Función: code_group_comma
    // Detecta si un code-group contiene comma (K28.5)
    // ================================================================
    function code_group_comma;
        input [9:0] posible_comma;
        begin
            code_group_comma = (posible_comma == `K28_5_decmenos) || 
                               (posible_comma == `K28_5_decmas);
        end
    endfunction
    

    
    // ================================================================
    // Función: cggood (CORREGIDA)
    // Un code-group es "bueno" si:
    // - Es válido (data_valid), O
    // - Es comma en posición PAR (rx_even = TRUE)
    // ================================================================
    function cggood;
        input [9:0] data;
        input is_even;
        begin
            cggood = data_valid(data) || 
                     (code_group_comma(data) && is_even);
        end
    endfunction
    

    
    // ================================================================
    // Función: sync_unitdata_indicate
    // Genera salida SUDI = {rx_even, code_group}
    // ================================================================
    function [10:0] sync_unitdata_indicate;
        input [9:0] latched_value_code_group;
        input latched_state_rx_even;
        begin
            if (latched_state_rx_even == TRUE)
                sync_unitdata_indicate = {EVEN, latched_value_code_group};
            else
                sync_unitdata_indicate = {ODD, latched_value_code_group};
        end
    endfunction

    // ================================================================
    // Lógica combinacional - Máquina de estados
    // ================================================================
    always @(*) begin
        // Valores por defecto
        next_state       = state;
        next_rx_even     = rx_even;
        next_sync_status = sync_status;
        next_good_cgs    = good_cgs;
        next_error_count = error_count;
        SUDI             = sync_unitdata_indicate(rx_code_group, rx_even);

        case (state)
            // ========================================================
            // LOSS_OF_SYNC: Esperando primer comma
            // ========================================================
            LOSS_OF_SYNC: begin
                next_sync_status = FAIL;
                next_rx_even     = ~rx_even;
                next_error_count = 3'd0;
                next_good_cgs    = 3'd0;

                if (code_group_comma(rx_code_group)) begin
                    next_state = COMMA_DETECT_1;
                end
                else begin
                    next_state = LOSS_OF_SYNC;
                end
            end

            // ========================================================
            // COMMA_DETECT_1: Validar /D/ tras primer comma
            // ========================================================
            COMMA_DETECT_1: begin
                next_rx_even = TRUE;
                
                if (data_valid(rx_code_group)) begin
                    next_state = ACQUIRE_SYNC_1;
                end
                else begin
                    next_state = LOSS_OF_SYNC;
                end
            end

            // ========================================================
            // ACQUIRE_SYNC_1: Esperar segundo comma
            // ========================================================
            ACQUIRE_SYNC_1: begin
                next_rx_even = ~rx_even;
                
                if (code_group_comma(rx_code_group) && rx_even) begin
                    next_state = COMMA_DETECT_2;
                end
                else if (data_valid(rx_code_group)) begin
                    next_state = ACQUIRE_SYNC_1;
                end
                else begin
                    next_state = LOSS_OF_SYNC;
                end
            end

            // ========================================================
            // COMMA_DETECT_2: Validar /D/ tras segundo comma
            // ========================================================
            COMMA_DETECT_2: begin
                next_rx_even = TRUE;
                
                if (data_valid(rx_code_group)) begin
                    next_state = ACQUIRE_SYNC_2;
                end
                else begin
                    next_state = LOSS_OF_SYNC;
                end
            end

            // ========================================================
            // ACQUIRE_SYNC_2: Esperar tercer comma
            // ========================================================
            ACQUIRE_SYNC_2: begin
                next_rx_even = ~rx_even;
                
                if (code_group_comma(rx_code_group) && rx_even) begin
                    next_state = COMMA_DETECT_3;
                end
                else if (data_valid(rx_code_group)) begin
                    next_state = ACQUIRE_SYNC_2;
                end
                else begin
                    next_state = LOSS_OF_SYNC;
                end
            end

            // ========================================================
            // COMMA_DETECT_3: Validar /D/ tras tercer comma
            // ========================================================
            COMMA_DETECT_3: begin
                next_rx_even = TRUE;
                
                if (data_valid(rx_code_group)) begin
                    next_state = SYNC_ACQUIRED_1;
                    next_sync_status = OK;
                end
                else begin
                    next_state = LOSS_OF_SYNC;
                end
            end

            // ========================================================
            // SYNC_ACQUIRED_1: Sincronización lograda
            // ========================================================
            SYNC_ACQUIRED_1: begin
                next_rx_even     = ~rx_even;
                
                // Comma en posición impar = ERROR
                if (code_group_comma(rx_code_group) && !rx_even) begin
                    next_state       = SYNC_ACQUIRED_2;
                    next_good_cgs    = 3'd0;
                    next_error_count = 3'd1;
                end
                // Code-group bueno (válido o comma en par)
                else if (cggood(rx_code_group, rx_even)) begin
                    next_state = SYNC_ACQUIRED_1;
                end
                // Code-group inválido
                else begin
                    next_state       = SYNC_ACQUIRED_2;
                    next_good_cgs    = 3'd0;
                    next_error_count = 3'd1;
                end
            end

            // ========================================================
            // SYNC_ACQUIRED_2: Primer error detectado
            // ========================================================
            SYNC_ACQUIRED_2: begin
                next_rx_even  = ~rx_even;
                next_good_cgs = 3'd0;
                
                if (cggood(rx_code_group, rx_even)) begin
                    next_state    = SYNC_ACQUIRED_2A;
                    next_good_cgs = 3'd1;
                end
                else begin
                    next_state       = SYNC_ACQUIRED_3;
                    next_error_count = 3'd2;
                end
            end

            // ========================================================
            // SYNC_ACQUIRED_2A: Recuperación desde SA2
            // ========================================================
            SYNC_ACQUIRED_2A: begin
                next_rx_even = ~rx_even;
                
                if (cggood(rx_code_group, rx_even)) begin
                    next_good_cgs = good_cgs + 3'd1;
                    
                    // 4 code-groups buenos → decrementar error
                    if (good_cgs >= 3'd3) begin
                        next_state       = SYNC_ACQUIRED_1;
                        next_error_count = (error_count > 0) ? error_count - 3'd1 : 3'd0;
                        next_good_cgs    = 3'd0;
                    end
                    else begin
                        next_state = SYNC_ACQUIRED_2A;
                    end
                end
                else begin
                    next_state       = SYNC_ACQUIRED_3;
                    next_good_cgs    = 3'd0;
                    next_error_count = 3'd2;
                end
            end

            // ========================================================
            // SYNC_ACQUIRED_3: Segundo error detectado
            // ========================================================
            SYNC_ACQUIRED_3: begin
                next_rx_even  = ~rx_even;
                next_good_cgs = 3'd0;
                
                if (cggood(rx_code_group, rx_even)) begin
                    next_state    = SYNC_ACQUIRED_3A;
                    next_good_cgs = 3'd1;
                end
                else begin
                    next_state       = SYNC_ACQUIRED_4;
                    next_error_count = 3'd3;
                end
            end

            // ========================================================
            // SYNC_ACQUIRED_3A: Recuperación desde SA3
            // ========================================================
            SYNC_ACQUIRED_3A: begin
                next_rx_even = ~rx_even;
                
                if (cggood(rx_code_group, rx_even)) begin
                    next_good_cgs = good_cgs + 3'd1;
                    
                    if (good_cgs >= 3'd3) begin
                        next_state       = SYNC_ACQUIRED_2;
                        next_error_count = (error_count > 0) ? error_count - 3'd1 : 3'd0;
                        next_good_cgs    = 3'd0;
                    end
                    else begin
                        next_state = SYNC_ACQUIRED_3A;
                    end
                end
                else begin
                    next_state       = SYNC_ACQUIRED_4;
                    next_good_cgs    = 3'd0;
                    next_error_count = 3'd3;
                end
            end

            // ========================================================
            // SYNC_ACQUIRED_4: Tercer error detectado
            // ========================================================
            SYNC_ACQUIRED_4: begin
                next_rx_even  = ~rx_even;
                next_good_cgs = 3'd0;
                
                if (cggood(rx_code_group, rx_even)) begin
                    next_state    = SYNC_ACQUIRED_4A;
                    next_good_cgs = 3'd1;
                end
                else begin
                    // Cuarto error → Pérdida de sincronización
                    next_state       = LOSS_OF_SYNC;
                    next_sync_status = FAIL;
                    next_error_count = 3'd0;
                end
            end

            // ========================================================
            // SYNC_ACQUIRED_4A: Recuperación desde SA4
            // ========================================================
            SYNC_ACQUIRED_4A: begin
                next_rx_even = ~rx_even;
                
                if (cggood(rx_code_group, rx_even)) begin
                    next_good_cgs = good_cgs + 3'd1;
                    
                    if (good_cgs >= 3'd3) begin
                        next_state       = SYNC_ACQUIRED_3;
                        next_error_count = (error_count > 0) ? error_count - 3'd1 : 3'd0;
                        next_good_cgs    = 3'd0;
                    end
                    else begin
                        next_state = SYNC_ACQUIRED_4A;
                    end
                end
                else begin
                    // Cuarto error → Pérdida de sincronización
                    next_state       = LOSS_OF_SYNC;
                    next_sync_status = FAIL;
                    next_error_count = 3'd0;
                end
            end

            // Estado por defecto
            default: begin
                next_state = LOSS_OF_SYNC;
            end
        endcase
    end

endmodule