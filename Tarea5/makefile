.PHONY: all simulate clean view help

# Variables
VERILOG_FILES = master.v slave.v testbench.v
VVP_FILE = spi.vvp
VCD_FILE = spi_chain.vcd
GTKW_FILE = completo.gtkw

all: view

simulate: $(VVP_FILE)
	@echo "🚀 Simulando SPI..."
	vvp $(VVP_FILE)

$(VVP_FILE): $(VERILOG_FILES)
	@echo "🔧 Compilando SPI..."
	iverilog -o $(VVP_FILE) $(VERILOG_FILES)

view: simulate
	@echo "📊 Abriendo GTKWave..."
	@if [ -f $(GTKW_FILE) ]; then \
		gtkwave $(VCD_FILE) $(GTKW_FILE) & \
	else \
		gtkwave $(VCD_FILE) & \
		echo "⚠️  Archivo $(GTKW_FILE) no encontrado. GTKWave abierto sin configuración."; \
	fi

clean:
	@echo "🧹 Limpiando archivos..."
	rm -f $(VVP_FILE) $(VCD_FILE) *.vvp *.vcd

help:
	@echo "╔════════════════════════════════════════╗"
	@echo "║        SPI Makefile - Comandos         ║"
	@echo "╚════════════════════════════════════════╝"
	@echo ""
	@echo "Comandos disponibles:"
	@echo "  make              - Compila, simula y abre GTKWave"
	@echo "  make simulate     - Solo compila y simula"
	@echo "  make view         - Compila, simula y abre GTKWave"
	@echo "  make clean        - Elimina archivos generados"
	@echo "  make help         - Muestra esta ayuda"
	@echo ""
	@echo "Requisitos:"
	@echo "  - iverilog (para compilación)"
	@echo "  - vvp (para simulación)"
	@echo "  - gtkwave (para visualización)"
	@echo "  - complete.gtkw (archivo de configuración GTKWave, opcional)"