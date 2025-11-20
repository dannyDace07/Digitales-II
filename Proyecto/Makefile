# ================================================================
# Makefile para simulación del Sincronizador PCS (Modo TFF)
# Herramientas: Icarus Verilog + GTKWave
# ================================================================

# Variables
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Archivos fuente
SRC = synchronizer.v synchronizer_tester.v synchronizer_tb.v
INCLUDES = pcs_defs.vh pcs_cg_defs.vh

# Archivos de datos requeridos
DATA_FILES = code_groups.txt SUDI.tff sync_state.txt

# Archivos de salida
OUT = synchronizer_sim
VCD = synchronizer_waveform.vcd

# ================================================================
# Targets
# ================================================================

# Compilar y ejecutar simulación
all: compile simulate

# Compilar con Icarus Verilog
compile: check_data
	@echo "================================================"
	@echo "  Compilando Sincronizador PCS..."
	@echo "================================================"
	$(IVERILOG) -o $(OUT) $(SRC) -I.
	@echo "✓ Compilación exitosa\n"

# Ejecutar simulación
simulate:
	@echo "================================================"
	@echo "  Ejecutando simulación..."
	@echo "================================================"
	$(VVP) $(OUT)
	@echo "\n✓ Simulación completada"
	@echo "  Archivo VCD generado: $(VCD)\n"

# Visualizar formas de onda
wave:
	@echo "================================================"
	@echo "  Abriendo GTKWave..."
	@echo "================================================"
	@if [ -f waves.gtkw ]; then \
		$(GTKWAVE) $(VCD) waves.gtkw & \
	else \
		$(GTKWAVE) $(VCD) & \
	fi

# Limpiar archivos generados
clean:
	@echo "Limpiando archivos temporales..."
	rm -f $(OUT) $(VCD)
	@echo "✓ Limpieza completada"

# Ejecutar todo (compilar, simular, visualizar)
run: all wave

# Verificar archivos de datos
check_data:
	@echo "Verificando archivos de datos..."
	@for file in $(DATA_FILES); do \
		if [ -f $$file ]; then \
			echo "  ✓ $$file encontrado"; \
		else \
			echo "  ⚠ $$file NO encontrado (opcional)"; \
		fi \
	done
	@if [ ! -f code_groups.txt ]; then \
		echo "  ✗ ERROR: code_groups.txt es REQUERIDO"; \
		exit 1; \
	fi
	@echo ""

# Ayuda
help:
	@echo "================================================"
	@echo "  Makefile - Sincronizador PCS (Modo TFF)"
	@echo "================================================"
	@echo "Targets disponibles:"
	@echo "  make all        - Compilar y simular"
	@echo "  make compile    - Solo compilar"
	@echo "  make simulate   - Solo simular"
	@echo "  make wave       - Abrir GTKWave"
	@echo "  make run        - Compilar + simular + visualizar"
	@echo "  make clean      - Limpiar archivos generados"
	@echo "  make check_data - Verificar archivos TFF"
	@echo "  make help       - Mostrar esta ayuda"
	@echo ""
	@echo "Archivos requeridos:"
	@echo "  - code_groups.txt (OBLIGATORIO)"
	@echo "  - SUDI.tff (opcional)"
	@echo "  - sync_state.txt (opcional)"
	@echo "================================================"

.PHONY: all compile simulate wave clean run check_data help