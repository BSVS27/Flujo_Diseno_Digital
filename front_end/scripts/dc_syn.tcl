##################################################################################
# Title:        dc_syn.tcl
# Description:	Flujo de sintesis logica en Design Compiler
# Dependencies: Ninguna.
# Library:	XFAB-180nm xh018 High Density Low Leakage
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:		23 de Mayo de 2018
# Notes:	Basado en los scripts del Dr. Juan Agustin Rodriguez para la
#		integración del proyecto SiRPA. 2014
# Version:	1.01 
# Revision:	30-07-18 ACR
#
###################################################################################
puts "RM-Info: Running script [info script]\n"
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
# Se suprimen algunos mensajes de alarmas los cuales se considera, pueden dejarse pasar.
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
suppress_message {VER-130 LINT-1 LINT-28 LINT-29 LINT-31 LINT-33 LINT-52 OPT-112 TIM-134\
				 PWR-6 PWR-410 PWR-428 PWR-412 UID-401};
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
# El siguiente comando linkea los verilog entre sí, muchos de ellos se referencian entre ellos.
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
link > reports/link.txt; 
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
# check_design revisa la consistencia del diseño.
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
check_design > reports/check_dsgn.txt;
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
# Escribe el netlist o esquemático con el formato deseado en algun espacio indicado de la memoria.
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
write -hierarchy -format ddc -output "$PROY_HOME_SYN/db/$DESIGN_NAME\_pre_compile.ddc";
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
# Los dos siguientes comandos crean todas la variables y restricciones que la herramienta debe 
#considerar al ejecutar la síntesis. El segundo las propaga por el diseño( las ejecuta)
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
source -verbose -echo "$PROY_HOME_SYN/scripts/$DESIGN_NAME\_constraints.tcl";
propagate_constraints;
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
#Le inidica que se va hacer una estimacion de portencia durante el compile_ultra o
#compile_ultra -incremental solo funciona con modo topográfico.
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
if {[shell_is_in_topographical_mode]} {
	set_power_prediction; 		
} else {
	propagate_switching_activity; 
}
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#								Compilacion
#           Parte más importante es donde se realiza la sintesis
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
compile_ultra -no_autoungroup -exact_map > reports/compile.txt; 

#------------------------------------------------------------------------------
#								Lectura saif
#------------------------------------------------------------------------------
#En esta parte se realiza la lectura del saif, si se desea se le puede dar en 
# un comprimido tgz. Con -auto_map_names se le indica que infiera aquellos nodos
#no encontrados.
#-------------------------------------------------------------------------------
if {[shell_is_in_topographical_mode]} {
	read_saif -input "$PROY_HOME/front_end/source/$DESIGN_NAME.saif" \
 -instance_name $TEST_INST_NAME/inst_top -auto_map_names;
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Declara las variables de tercer estados como wire en ves de tri.
#------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
set verilogout_no_tri true
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Cambia los nombres de los puertos dentro del diseño.
#------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
change_names -hierarchy -rules verilog 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Se generan y guardan los reportes de potencia, area, timing entre otros.
#------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
report_power -analysis_effort high > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_power.txt";
report_area >  "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_area.txt";
report_qor > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_qor.txt";
report_timing > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_timing.txt";
report_port > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_port.txt";
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Se Guardan los archivos de salida.
#------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
write -hierarchy -format ddc -output "$TOP_FILE_DDC";
write -format verilog -hierarchy -output "$TOP_FILE_SYN";
write_sdc "$TOP_FILE_SDC";
write_sdf "$TOP_FILE_SDF";
puts "RM-Info: Completed script [info script]\n";
