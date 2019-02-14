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

# Analisis de los modulos/dependencias del disenno. Lluego se elabora el modulo principal que corresponde al  
# disenno en la variable $TOP_MODULE del script user_setup.tcl.

# En caso de estar corriendo en el modo topografico, se debe crear una biblioteca MW.
#------------------------------------------------------------------------------------

if {[shell_is_in_topographical_mode]} {
	# Se abre la biblioteca de trabajo Milkyway. En caso de que la misma no exista se crea.
	source -echo -verbose "$PROY_HOME_SYN/scripts/crear_mw.tcl";
}

# El siguiente proceso implementa un algoritmo recursivo el cual genera 2 listas, una para todos los directorios
# que se encuentran en la ruta de archivos fuente y otra para los archivos verilog en dichos directorios, con la
# segunda lista, se analizan los archivos fuente. Si el directorio base no contiene mas directorios, se leen los
# archivos fuente desde este.
# El readfile se genera con el gui para generar la lista completa
#------------------------------------------------------------------------------------


read_file -format sverilog {/mnt/vol_NFS_Zener/WD_ESPEC/moviedo/GDS/nuevo/ALU_Phy/front_end/source/top.sv /mnt/vol_NFS_Zener/WD_ESPEC/moviedo/GDS/nuevo/ALU_Phy/front_end/source/ALU_2.sv /mnt/vol_NFS_Zener/WD_ESPEC/moviedo/GDS/nuevo/ALU_Phy/front_end/source/Barrel_Shifter.sv /mnt/vol_NFS_Zener/WD_ESPEC/moviedo/GDS/nuevo/ALU_Phy/front_end/source/csk_bloque.sv /mnt/vol_NFS_Zener/WD_ESPEC/moviedo/GDS/nuevo/ALU_Phy/front_end/source/CSK_sin_mux.sv};

analyze -library WORK -format sverilog $TOP_FILE > reports/analyze.txt;
#Despues de este comando se puede poner list_designs 

# Este script hcho por RCG carga recursivamente todos los archivos .v en el directorio "source". Hay que probarlo (ACR)

#set directorios [ls -d "$SOURCE_HOME"];					# Lista 1: Directorios Fuente.
# -------------------------------------------------		  Ciclo 1: indexacion de directorios
#if {[string trimleft $directorios] != "$SOURCE_HOME"} {
#   	foreach i $directorios {			
#		set archivos [ls "$i/*.*v"]	;					# Lista 2: Archivos fuente verilog/system verilog.
#--------------------------------------------------		  Ciclo 2: indexacion de archivos.
#		foreach n $archivos {			
#	        analyze -format sverilog -library WORK "$n";	# Analisis de los archivos fuente.
#	    };												# Fin de Ciclo 2.
#	};													# Fin de Ciclo 1.
#} else {
#	set archivos [ls "$SOURCE_HOME/*.*v"];				# Lista 2: Archivos fuente verilog/system verilog.
#--------------------------------------------------		  Ciclo 2: indexacion de archivos.
#	foreach n $archivos {
#		analyze -format sverilog -library WORK "$n";		# Analisis de los archivos fuente.
#	};
#}

# Elaboracion del modulo principal del disenno
elaborate $TOP_MODULE -architecture verilog -library WORK > reports/elaborate.txt;

#set current_design $TOP_MODULE;

# Definimos las direcciones de enrutamiento p
if {[shell_is_in_topographical_mode]} {
set_preferred_routing_direction -layers {MET1 MET3 METTP} -direction horizontal;
set_preferred_routing_direction -layers {MET2 MET4 METTPL} -direction vertical;
}




