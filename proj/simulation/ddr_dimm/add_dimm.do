set rf [open ../behavioral/system_tb.v r]
set wf [open ../behavioral/system_tb.v_ w]
set wr_done {0}

while {[gets $rf line] >= 0} {
		puts $wf $line
	if {$line eq "  // END USER CODE (Do not remove this line)"} {
	    gets $rf line
	    if {$line ne "  ddr_dimm"} {
        		puts $wf "  ddr_dimm"
        		puts $wf "    dram ("
        		puts $wf "      .ck ( fpga_0_DDR_SDRAM_DDR_Clk_pin ),"
        		puts $wf "      .ck_n ( fpga_0_DDR_SDRAM_DDR_Clk_n_pin ),"
        		puts $wf "      .addr ( fpga_0_DDR_SDRAM_DDR_Addr_pin ),"
        		puts $wf "      .ba ( fpga_0_DDR_SDRAM_DDR_BankAddr_pin ),"
        		puts $wf "      .cas_n ( fpga_0_DDR_SDRAM_DDR_CAS_n_pin ),"
        		puts $wf "      .cke ( fpga_0_DDR_SDRAM_DDR_CE_pin ),"
        		puts $wf "      .s_n ( fpga_0_DDR_SDRAM_DDR_CS_n_pin ),"
        		puts $wf "      .ras_n ( fpga_0_DDR_SDRAM_DDR_RAS_n_pin ),"
        		puts $wf "      .we_n ( fpga_0_DDR_SDRAM_DDR_WE_n_pin ),"
        		puts $wf "      .dm ( fpga_0_DDR_SDRAM_DDR_DM_pin ),"
        		puts $wf "      .dqs ( fpga_0_DDR_SDRAM_DDR_DQS ),"
        		puts $wf "      .dq ( fpga_0_DDR_SDRAM_DDR_DQ )"
        		puts $wf "    );"
        		echo "Added DRAM instance to system_tb.v"

  		} else {
          		echo "DRAM instance already included in system_tb.v"
  		}
        puts $wf $line
	}
}
close $rf
close $wf

if {$tcl_platform(os) eq "Linux"} {
	mv system_tb.v_ system_tb.v
} else {
	copy system_tb.v_ system_tb.v
	del  system_tb.v_
}

set rf [open ../behavioral/system.do r]
set wf [open ../behavioral/system.do_ w]

while {[gets $rf line] >= 0} {
		puts $wf $line
		if {$line eq "vlog +incdir+../ddr_dimm +define+FULL_MEM+kvcl3+x8+DEBUG=0 ../ddr_dimm/ddr.v"} {
		    set wr_done 512
	    }
		if {$line eq "vlog +incdir+../ddr_dimm +define+FULL_MEM+kvcl25+x8+DEBUG=0 ../ddr_dimm/ddr.v"} {
		    set wr_done 256
	    }
    }

echo $wr_done
    

    if {( $argc == 1 ) && ([string toupper $1] == "512MB")} {
         if {($wr_done != 512)} {
		      puts $wf "vlog +incdir+../ddr_dimm +define+FULL_MEM+kvcl3+x8+DEBUG=0 ../ddr_dimm/ddr.v"
    		      puts $wf "vlog +incdir+../ddr_dimm +define+DUAL_RANK+kvcl3+x8+DEBUG=0 ../ddr_dimm/ddr_dimm.v"
		      echo "Added 512MB DRAM compile to system.do"
		 } else {
              echo "DRAM compile already included in system.do"
		 }
	   } else {
	     if {($wr_done != 256)} {
		      puts $wf "vlog +incdir+../ddr_dimm +define+FULL_MEM+kvcl25+x8+DEBUG=0 ../ddr_dimm/ddr.v"
		      puts $wf "vlog +incdir+../ddr_dimm +define+kvcl25+x8+DEBUG=0 ../ddr_dimm/ddr_dimm.v"
		      echo "Added 256MB DRAM compile to system.do"
         } else {
              echo "DRAM compile already included in system.do"
         }
       }



close $rf
close $wf

if {$tcl_platform(os) eq "Linux"} {
	mv system.do_ system.do
} else {
	copy system.do_ system.do
	del  system.do_
}
