# Nombre del ejecutable temporal
OUT = sim.vvp

# Archivos fuente
SRC = Cajero_synth_1.v Tester.v Testbench.v
#SRC = Cajero_synth_1.v Tester_original.v Testbench.v
#SRC = Cajero_rtlil_1.v Tester_original.v Testbench.v
#SRC = Cajero.v Tester_original.v Testbench.v

# Regla por defecto
all:
	iverilog -o $(OUT) $(SRC)
	vvp $(OUT)
	# gtkwave Deposito.gtkw &  #0 a 504
	# gtkwave Retiro.gtkw &  #500 a 936
	# gtkwave Bloqueo.gtkw & #935 a 1980
	# gtkwave Fondos.gtkw &  #1975 a 2574
	gtkwave Completo.gtkw &
# Para probar comente y descomente la sección superior según cada caso
	
# Limpiar archivos generados
clean:
	rm -f $(OUT) cajero.vcd
