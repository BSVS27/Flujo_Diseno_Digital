
all:	sim gen convert clean
SHELL = /bin/bash
MS="-s"

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR= ../../../front_end/source/

_TARGETS_=	$(DUT_SRC_DIR)/ALU_2.sv         \
			$(DUT_SRC_DIR)/CSK_sin_mux.sv         \
			$(DUT_SRC_DIR)/csk_bloque.sv         \
			$(DUT_SRC_DIR)/Barrel_Shifter.sv         \
			$(DUT_SRC_DIR)/top.sv         
	

##########################################################################
#
# Test Bench Sources
#
##########################################################################
TB_SRC_DIR=../SAIF_test/
_TB_=		$(TB_SRC_DIR)/ test_top.sv		

		

##########################################################################
#
# Misc Variables
#
##########################################################################
TECH_SRC_DIR=/mnt/vol_NFS_Zener/tools/synopsys/pdks/xt018-ams/xt018/\
	diglibs/D_CELLS_LL/v2_0/verilog/v2_0_0/
#INCDIR=-y $TECH_SRC_DIR +libext+.v+.V; Util para simulaciones post sintesis
LOGF=-l vcs.log
FILE=./vcdplus.vpd

##########################################################################
#
# Make Targets
#
##########################################################################

sim:
	vcs -full64 -debug_access+all +v2k +vcs+vcdpluson +systemverilogext+sv \
	 $(_TARGETS_) $(_TB_) $(LOGF) 

gen:
	./simv > simulation.log

convert:
	mv vcdplus.vpd top.vpd
	vpd2vcd -full64 top.vpd top.vcd
	vcd2saif -64 -input top.vcd -output ../../../front_end/source/alu.saif

clean:
	rm -rf	./csrc ./DVEfiles ./simv.daidir		\
		./opendatabase.log ./simv ./ucli.key ./simulation.log	\
		./swave_compile_done ./top.vpd ./top.vcd  ./vcs.log	\

##########################################################################

