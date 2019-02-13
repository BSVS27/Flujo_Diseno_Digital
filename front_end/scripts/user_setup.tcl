##################################################################################
# Title:	user_setup.tcl
# Description:	Script que contiene definidas las variables para configurar el 	
# 		proyecto de sintesis de un usuario 
# Dependencies: dc_setup.tcl, analyze_rtl.tcl.
# Library:	XFAB-180nm (xh018)
# Tools:	DC L-2016.03-SP3 | ICC L-2016.03-SP3 | PT K-2015.06-SP3-3							
# Project:	TEC_RISCV								
# Author:	Reinaldo Castro Gonzalez					
# Institution:	Instituto Tecnológico de Costa Rica. DCILab.			
# Date:		17 de Mayo de 2018						
# Notes:	Basado en los scripts de la metodologia sugerida por Synopsys	
#	
# Version:	1.01								
# Revision:	31/07/2018 ACR							
#										
##################################################################################

puts "RM-Info: Running script [info script]\n"

##########################################################################################
## Library Setup Variables
###########################################################################################

###
# Para las siguientes variables, use un espacio en blanco para separar los nombres que ingresa.
###

# Directorio raiz del arbol de directorios de la tecnologia

# Ingrese la direccion absoluta al directorio base del proyecto
# Ejemplo: set PROY_HOME "/mnt/vol_NFS_Zener/WD_ESPEC/$user_name/repositorios/TEC_RISCV/Integration";
set PROY_HOME "/mnt/vol_NFS_Zener/WD_ESPEC/achacon/imd/micro_hdl/TEC_RISCV/ALU_Phy"; 		
set DESIGN_NAME "alu";	# Ingrese el nombre del proyecto. Ejemplo "ac97";
set SOURCE_HOME "$PROY_HOME/front_end/source";
set TOP_FILE "$SOURCE_HOME/top.sv";
set TOP_MODULE "top";
set TEST_INST_NAME "test";
set UUT_INST_NAME "u0";
#EOF
