if {[set vhdlfiles [glob *wrapper.vhd]] eq ""} {
	#dummyif to prevent output
}

set vtrwrapper ""

foreach item $vhdlfiles {
	set rf [open $item r]
		while {[gets $rf line] >= 0} {
			if {$line eq "  component video_to_ram is"} {
				set vtrwrapper $item
			}
		}
	close $rf
}

if {$vtrwrapper ne ""} {
	set rf [open $vtrwrapper r]
	set wf [open wrapperdummy.vhd w]

	gets $rf line
	gets $rf line
	puts $wf "library video_to_ram_v1_00_a;"
	puts $wf "use video_to_ram_v1_00_a.all;"
	while {[gets $rf line] >= 0} {
			puts $wf $line
		}
	close $rf
	close $wf

	if {$tcl_platform(os) eq "Linux"} {
		mv wrapperdummy.vhd $vtrwrapper
	} else {
		copy wrapperdummy.vhd $vtrwrapper
		del  wrapperdummy.vhd
	}
}

echo "Fixed missing video_to_ram binding"