#################################################################
# Makefile generated by Xilinx Platform Studio 
# Project:/home/kevin/ece532/dv_stab/proj/system.xmp
#
# WARNING : This file will be re-generated every time a command
# to run a make target is invoked. So, any changes made to this  
# file manually, will be lost when make is invoked next. 
#################################################################

# Name of the Microprocessor system
# The hardware specification of the system is in file :
# /home/kevin/ece532/dv_stab/proj/system.mhs
# The software specification of the system is in file :
# /home/kevin/ece532/dv_stab/proj/system.mss

include system_incl.make

#################################################################
# PHONY TARGETS
#################################################################
.PHONY: dummy
.PHONY: netlistclean
.PHONY: bitsclean
.PHONY: simclean
.PHONY: vpclean

#################################################################
# EXTERNAL TARGETS
#################################################################
all:
	@echo "Makefile to build a Microprocessor system :"
	@echo "Run make with any of the following targets"
	@echo " "
	@echo "  netlist  : Generates the netlist for the given MHS "
	@echo "  bits     : Runs Implementation tools to generate the bitstream"
	@echo " "
	@echo "  libs     : Configures the sw libraries for this system"
	@echo "  program  : Compiles the program sources for all the processor instances"
	@echo " "
	@echo "  init_bram: Initializes bitstream with BRAM data"
	@echo "  ace      : Generate ace file from bitstream and elf"
	@echo "  download : Downloads the bitstream onto the board"
	@echo " "
	@echo "  sim      : Generates HDL simulation models and runs simulator for chosen simulation mode"
	@echo "  simmodel : Generates HDL simulation models for chosen simulation mode"
	@echo "  behavioral_model : Generates behavioral HDL models with BRAM initialization"
	@echo "  structural_model : Generates structural simulation HDL models with BRAM initialization"
	@echo "  timing   : Generates timing simulation HDL models with BRAM initialization"
	@echo "  vp       : Generates virtual platform model"
	@echo " "
	@echo "  netlistclean: Deletes netlist"
	@echo "  bitsclean: Deletes bit, ncd, bmm files"
	@echo "  hwclean  : Deletes implementation dir"
	@echo "  libsclean: Deletes sw libraries"
	@echo "  programclean: Deletes compiled ELF files"
	@echo "  swclean  : Deletes sw libraries and ELF files"
	@echo "  simclean : Deletes simulation dir"
	@echo "  vpclean  : Deletes virtualplatform dir"
	@echo "  clean    : Deletes all generated files/directories"
	@echo " "
	@echo "  make <target> : (Default)"
	@echo "      Creates a Microprocessor system using default initializations"
	@echo "      specified for each processor in MSS file"


bits: $(SYSTEM_BIT)

ace: $(SYSTEM_ACE)

netlist: $(POSTSYN_NETLIST)

libs: $(LIBRARIES)

program: $(ALL_USER_ELF_FILES)

download: $(DOWNLOAD_BIT) dummy
	@echo "*********************************************"
	@echo "Downloading Bitstream onto the target board"
	@echo "*********************************************"
	impact -batch etc/download.cmd

init_bram: $(DOWNLOAD_BIT)

sim: $(DEFAULT_SIM_SCRIPT)
	cd simulation/behavioral; \
	$(SIM_CMD)  &

simmodel: $(DEFAULT_SIM_SCRIPT)

behavioral_model: $(BEHAVIORAL_SIM_SCRIPT)

structural_model: $(STRUCTURAL_SIM_SCRIPT)

vp: $(VPEXEC)

clean: hwclean libsclean programclean simclean vpclean
	rm -f _impact.cmd
	rm -f *.log

hwclean: netlistclean bitsclean
	rm -rf implementation synthesis xst hdl
	rm -rf xst.srp $(SYSTEM).srp

netlistclean:
	rm -f $(POSTSYN_NETLIST)
	rm -f platgen.log
	rm -f $(BMM_FILE)

bitsclean:
	rm -f $(SYSTEM_BIT)
	rm -f implementation/$(SYSTEM).ncd
	rm -f implementation/$(SYSTEM)_bd.bmm 
	rm -f implementation/$(SYSTEM)_map.ncd 
	rm -f __xps/$(SYSTEM)_routed

simclean: 
	rm -rf simulation/behavioral
	rm -f simgen.log

swclean: libsclean programclean
	@echo ""

libsclean: $(LIBSCLEAN_TARGETS)
	rm -f libgen.log

programclean: $(PROGRAMCLEAN_TARGETS)

vpclean:
	rm -rf virtualplatform
	rm -f vpgen.log

#################################################################
# SOFTWARE PLATFORM FLOW
#################################################################


$(LIBRARIES): $(MHSFILE) $(MSSFILE) __xps/libgen.opt
	@echo "*********************************************"
	@echo "Creating software libraries..."
	@echo "*********************************************"
	libgen $(LIBGEN_OPTIONS) $(MSSFILE)


ub_libsclean:
	rm -rf ub/

$(UB_XMDSTUB): $(LIBRARIES)

#################################################################
# SOFTWARE APPLICATION DV_STAB
#################################################################

dv_stab_program: $(DV_STAB_OUTPUT) 

$(DV_STAB_OUTPUT) : $(DV_STAB_SOURCES) $(DV_STAB_HEADERS) $(DV_STAB_LINKER_SCRIPT) \
                    $(LIBRARIES) __xps/dv_stab_compiler.opt
	@mkdir -p $(DV_STAB_OUTPUT_DIR) 
	$(DV_STAB_CC) $(DV_STAB_CC_OPT) $(DV_STAB_SOURCES) -o $(DV_STAB_OUTPUT) \
	$(DV_STAB_OTHER_CC_FLAGS) $(DV_STAB_INCLUDES) $(DV_STAB_LIBPATH) \
	-xl-mode-$(DV_STAB_MODE)  \
	$(DV_STAB_CFLAGS) $(DV_STAB_LFLAGS) 
	$(DV_STAB_CC_SIZE) $(DV_STAB_OUTPUT) 
	@echo ""

dv_stab_programclean:
	rm -f $(DV_STAB_OUTPUT) 

#################################################################
# SOFTWARE APPLICATION SPLIT_CROP_TEST
#################################################################

split_crop_test_program: $(SPLIT_CROP_TEST_OUTPUT) 

$(SPLIT_CROP_TEST_OUTPUT) : $(SPLIT_CROP_TEST_SOURCES) $(SPLIT_CROP_TEST_HEADERS) $(SPLIT_CROP_TEST_LINKER_SCRIPT) \
                    $(LIBRARIES) __xps/split_crop_test_compiler.opt
	@mkdir -p $(SPLIT_CROP_TEST_OUTPUT_DIR) 
	$(SPLIT_CROP_TEST_CC) $(SPLIT_CROP_TEST_CC_OPT) $(SPLIT_CROP_TEST_SOURCES) -o $(SPLIT_CROP_TEST_OUTPUT) \
	$(SPLIT_CROP_TEST_OTHER_CC_FLAGS) $(SPLIT_CROP_TEST_INCLUDES) $(SPLIT_CROP_TEST_LIBPATH) \
	$(SPLIT_CROP_TEST_CFLAGS) $(SPLIT_CROP_TEST_LFLAGS) 
	$(SPLIT_CROP_TEST_CC_SIZE) $(SPLIT_CROP_TEST_OUTPUT) 
	@echo ""

split_crop_test_programclean:
	rm -f $(SPLIT_CROP_TEST_OUTPUT) 

#################################################################
# BOOTLOOP ELF FILES
#################################################################



$(UB_BOOTLOOP): $(MICROBLAZE_BOOTLOOP)
	@mkdir -p $(BOOTLOOP_DIR)
	cp -f $(MICROBLAZE_BOOTLOOP) $(UB_BOOTLOOP)

#################################################################
# HARDWARE IMPLEMENTATION FLOW
#################################################################


$(BMM_FILE) \
$(WRAPPER_NGC_FILES): $(MHSFILE) __xps/platgen.opt \
                      $(CORE_STATE_DEVELOPMENT_FILES)
	@echo "****************************************************"
	@echo "Creating system netlist for hardware specification.."
	@echo "****************************************************"
	platgen $(PLATGEN_OPTIONS) $(MHSFILE)

$(POSTSYN_NETLIST): $(WRAPPER_NGC_FILES)
	@echo "Running synthesis..."
	bash -c "cd synthesis; ./synthesis.sh"

__xps/$(SYSTEM)_routed: $(FPGA_IMP_DEPENDENCY)
	@echo "*********************************************"
	@echo "Running Xilinx Implementation tools.."
	@echo "*********************************************"
	@cp -f $(UCF_FILE) implementation/$(SYSTEM).ucf
	xilperl $(NON_CYG_XILINX_EDK_DIR)/data/fpga_impl/manage_fastruntime_opt.pl $(MANAGE_FASTRT_OPTIONS)
	xflow -wd implementation -p $(DEVICE) -implement xflow.opt $(SYSTEM).ngc
	touch __xps/$(SYSTEM)_routed

$(SYSTEM_BIT): __xps/$(SYSTEM)_routed $(BITGEN_UT_FILE)
	xilperl $(NON_CYG_XILINX_EDK_DIR)/data/fpga_impl/observe_par.pl $(OBSERVE_PAR_OPTIONS) implementation/$(SYSTEM).par
	@echo "*********************************************"
	@echo "Running Bitgen.."
	@echo "*********************************************"
	@cp -f $(BITGEN_UT_FILE) implementation/bitgen.ut
	cd implementation; bitgen -w -f bitgen.ut $(SYSTEM)

$(DOWNLOAD_BIT): $(SYSTEM_BIT) $(BRAMINIT_ELF_FILES) __xps/bitinit.opt
	@cp -f implementation/$(SYSTEM)_bd.bmm .
	@echo "*********************************************"
	@echo "Initializing BRAM contents of the bitstream"
	@echo "*********************************************"
	@echo "Processor uB has XMDSTUB-mode applications, but xmdstub.elf is not marked for download"
	bitinit $(MHSFILE) $(SEARCHPATHOPT) $(BRAMINIT_ELF_FILE_ARGS) \
	-bt $(SYSTEM_BIT) -o $(DOWNLOAD_BIT)
	@rm -f $(SYSTEM)_bd.bmm

$(SYSTEM_ACE):
	@echo "In order to generate ace file, you must have:-"
	@echo "- exactly one processor."
	@echo "- opb_mdm, if using microblaze."

#################################################################
# SIMULATION FLOW
#################################################################


################## BEHAVIORAL SIMULATION ##################

$(BEHAVIORAL_SIM_SCRIPT): $(MHSFILE) __xps/simgen.opt \
                          $(BRAMINIT_ELF_FILES)
	@echo "*********************************************"
	@echo "Creating behavioral simulation models..."
	@echo "*********************************************"
	simgen $(SIMGEN_OPTIONS) -m behavioral $(MHSFILE)

################## STRUCTURAL SIMULATION ##################

$(STRUCTURAL_SIM_SCRIPT): $(WRAPPER_NGC_FILES) __xps/simgen.opt \
                          $(BRAMINIT_ELF_FILES)
	@echo "*********************************************"
	@echo "Creating structural simulation models..."
	@echo "*********************************************"
	simgen $(SIMGEN_OPTIONS) -sd implementation -m structural $(MHSFILE)


################## TIMING SIMULATION ##################

$(TIMING_SIM_SCRIPT): $(SYSTEM_BIT) __xps/simgen.opt \
                      $(BRAMINIT_ELF_FILES)
	@echo "*********************************************"
	@echo "Creating timing simulation models..."
	@echo "*********************************************"
	simgen $(SIMGEN_OPTIONS) -sd implementation -m timing $(MHSFILE)

#################################################################
# VIRTUAL PLATFORM FLOW
#################################################################


$(VPEXEC): $(MHSFILE) __xps/vpgen.opt
	@echo "****************************************************"
	@echo "Creating virtual platform for hardware specification.."
	@echo "****************************************************"
	vpgen $(VPGEN_OPTIONS) $(MHSFILE)

dummy:
	@echo ""

