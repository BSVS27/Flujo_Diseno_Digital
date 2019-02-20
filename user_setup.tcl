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
#Variables de dirección de la carpeta del proyecto
############################################################################################
set PROY_HOME "../../Flujo_Diseno_Digital"; 
set PROY_HOME_SYN "$PROY_HOME/front_end";		
set DESIGN_NAME "alu";	
set SOURCE_HOME_SYN "$PROY_HOME_SYN/source";
set TOP_FILE "$SOURCE_HOME_SYN/top.sv";
set TOP_MODULE "top";
set TEST_INST_NAME "test_top";
set UUT_INST_NAME "u0";
##########################################################################################
## Variables para el ICC
###########################################################################################
set PROY_HOME_PHY "$PROY_HOME/back_end";
set SOURCE_HOME_PHY "$PROY_HOME_PHY/source";
set DB_HOME_PHY "$PROY_HOME_PHY/db"
##########################################################################################
## El <design>.ddc, <design>.v y <design>.sdc los traemos directamente de las carpetas de sintesis logica
##########################################################################################
set TOP_FILE_SYN "$SOURCE_HOME_SYN/$DESIGN_NAME\_syn.v";
set TOP_FILE_DDC "$PROY_HOME_SYN/db/$DESIGN_NAME.ddc";
set TOP_FILE_SDC "$PROY_HOME_SYN/db/$DESIGN_NAME\_syn.sdc";
set TOP_FILE_SDF "$PROY_HOME_SYN/db/$DESIGN_NAME\_syn.sdf";
##########################################################################################
## Archivos de diseno fisico final
##########################################################################################
set TOP_FILE_PHY "$SOURCE_HOME_PHY/$DESIGN_NAME\_phy.v";
set TOP_FILE_PHY_DDC "$DB_HOME_PHY/$DESIGN_NAME.ddc";
set TOP_FILE_PHY_SDC "$DB_HOME_PHY/$DESIGN_NAME\_phy.sdc";
set TOP_FILE_PHY_SDF "$DB_HOME_PHY/$DESIGN_NAME\_phy.sdf";
set TOP_FILE_PHY_SPEF "$DB_HOME_PHY/$DESIGN_NAME\_phy.spef";
set TOP_FILE_PHY_DEF "$DB_HOME_PHY/$DESIGN_NAME\_phy.def";
set TOP_FILE_GDS "$DB_HOME_PHY/$DESIGN_NAME\_phy.gds";
##########################################################################################
#Vamos a colocar los archivos de mapee MW-gds y de reglas en el directorio donde correra el ICV
##########################################################################################
set TECH_GDS_MAP_FILE "$TECH_ROOT/xh018/synopsys/v6_3/techMW/v6_3_1_2/xh018-synopsys-techMW-v6_3_1_2/xh018_out.map";
set TECH_RUNSET_FILE "$TECH_ROOT/xh018/synopsys/v7_0/ICValidator/v7_0_3/xh018_1143_DRC_MET4_METMID_METTHK.rs" 
set TECH_RUNSET_DIR "$TECH_ROOT/xh018/synopsys/v7_0/ICValidator/v7_0_3" 


#EOF
