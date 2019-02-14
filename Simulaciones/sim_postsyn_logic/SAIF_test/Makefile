
all:	sim gen convert clean
SHELL = /bin/bash
MS="-s"

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR= ../../../front_end/source
TECH_SRC_DIR=/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/diglibs/D_CELLS_HDLL/v2_1/verilog/v2_1_0/
_TARGETS_=	$(TECH_SRC_DIR)/VLG_PRIMITIVES.v   \
			$(TECH_SRC_DIR)/D_CELLS_HDLL.v   \
			$(DUT_SRC_DIR)/alu_syn.v 
	

##########################################################################
#
# Test Bench Sources
#
##########################################################################
TB_SRC_DIR=../SAIF_test
_TB_=		$(TB_SRC_DIR)/test_top.sv		

		

##########################################################################
#
# Misc Variables
#
##########################################################################

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
	vcd2saif -64 -input top.vcd -output ../../../back_end/source/alu.saif

clean:
	rm -rf	./csrc ./DVEfiles ./simv.daidir		\
		./opendatabase.log ./simv ./ucli.key ./simulation.log	\
		./swave_compile_done ./top.vpd ./top.vcd  ./vcs.log	\

##########################################################################

