##################################################################################
# Title:        analyze_rtl.tcl
# Description:  Script de lectura de las unidades verilog 
# Dependencies: design_syn.tcl
# Library:	XFAB-180nm (xh018) HDLL
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:		01 de Octubre de 2017
# Notes:	Basado en los scripts del Dr. Juan Agustín Rodríguez para la
#		integración del proyecto SiRPA. 2014
# Version:	2.0
# Revision:	31/07/2018 (ACR)
#
##################################################################################
#------------------------------------------------------------------------------------
# En el modo topográfico es necesa
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
#Activa tambien el mapeo del saif, el mismo debe hacer antes de llamar al diseño para 
# este preparado de mapear los nombre.
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
if {[shell_is_in_topographical_mode]} {
	source -echo -verbose "$PROY_HOME_SYN/scripts/crear_mw.tcl";
	saif_map -start; 	
}
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
# El proximo comando lee los archivos verilog para abrirlos en la herramienta.
#Para ver los diseños enlistados se utiliza el comando list_designs.
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
read_file -format sverilog {$PROY_HOME_SYN/source/top.sv $PROY_HOME_SYN/source/ALU_2.sv $PROY_HOME_SYN/source/Barrel_Shifter.sv $PROY_HOME_SYN/source/csk_bloque.sv $PROY_HOME_SYN/source/CSK_sin_mux.sv};
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
# Analiza el HDL para ver su estado se le indica la libreria con la que se trabajara (-library)
# tambien se le especifica el formato del HDL (-format)
# Al final se le da el nombre del que se analizara que usualmente es el top design.
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
analyze -library WORK -format sverilog $TOP_FILE > reports/analyze.txt;
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
# Construye el diseño que se le indique.
# Con -architecture se le indica el formato que en este caso se llama sverilog.
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
elaborate $TOP_MODULE -architecture verilog -library WORK > reports/elaborate.txt;
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
# Los proximos comandos son para el modo topografico que hacen un prelayout
#Le dicen a la herramienta cuales metales son preferidos para lineas veritcales 
# y cuales otros para horizontales
#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
if {[shell_is_in_topographical_mode]} {
set_preferred_routing_direction -layers {MET1 MET3 METTP} -direction horizontal;
set_preferred_routing_direction -layers {MET2 MET4 METTPL} -direction vertical;
}




