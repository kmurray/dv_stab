### convert images
set rtvarg ""

for {set i 1} {$i <= $argc} {incr i} {
	set looparg [subst $$i]
	convert -size 720x480 -depth 8 ../videoin/$looparg rgb:../videoin/$looparg.raw

	append rtvarg "../videoin/"
	append rtvarg $looparg.raw
	append rtvarg " "

}
eval [list exec ../videoin/rawtovid] $rtvarg

echo "Converted Image files"

#### add video decoder instance

if {[set rf [open ../behavioral/system_tb.v r]]==0} { }
if {[set wf [open ../behavioral/system_tb.v_ w]]==0} { }
if {[set inst_exists 0]==0} { }

while {[gets $rf line] >= 0} {

	if { [string first "num_frames" [string tolower $line]] != -1 } {
		puts $wf [format "    #(  .NUM_FRAMES(%u)  )    " $argc]
		set inst_exists 1
	} else {
		if {($line eq "endmodule") && ($inst_exists==0)} {
			puts $wf "  pullup pl1(IIC_Scl_pin);"
			puts $wf "  pullup pl2(IIC_Sda_pin);"
			puts $wf "  "
			puts $wf "  wire LLC1_pin;"
			puts $wf "  wire \[9:2\] P15_8_pin;"
			puts $wf "  "
			puts $wf "  ADV7183B"
			puts $wf [format "    #(  .NUM_FRAMES(%u)  )    " $argc]
			puts $wf "    video_dec ("
			puts $wf "      .nRESET ( sys_rst_pin ),"
			puts $wf "      .LLC1 ( LLC1_pin ),"
			puts $wf "      .P15_8 ( P15_8_pin ),"
			puts $wf "      .SCLK ( IIC_Scl_pin ),"
			puts $wf "      .SDA ( IIC_Sda_pin )"
			puts $wf "    );"
			puts $wf "  "
			puts $wf "  always \@(LLC1_pin) LLC_CLOCK_pin = LLC1_pin;"
			puts $wf "  always \@(P15_8_pin) YCrCb_in_pin = P15_8_pin;"
			puts $wf "  "
			#puts $wf "endmodule"
		}
			puts $wf $line
	}
}
close $rf
close $wf
echo "Added video decoder instance to system_tb.v"

if {$tcl_platform(os) eq "Linux"} {
	mv system_tb.v_ system_tb.v
} else {
	copy system_tb.v_ system_tb.v
	del  system_tb.v_
}

#### add video decoder compile

if {[set rf [open ../behavioral/system.do r]]==0} { }
if {[set wf [open ../behavioral/system.do_ w]]==0} { }
if {[set wr_done {0}]==0} { }

while {[gets $rf line] >= 0} {
		puts $wf $line
		if {$line eq "vlog ../videoin/ADV7183B.v"} {
		    set wr_done 1
	    }
    }
if {$wr_done==0} {
	puts $wf "vlog ../videoin/ADV7183B.v"
}
echo "Added video decoder compile to system.do"

close $rf
close $wf

if {$tcl_platform(os) eq "Linux"} {
	mv system.do_ system.do
} else {
	copy system.do_ system.do
	del  system.do_
}

#### do binding fix

do ../videoin/fix_vtoram_binding.do

