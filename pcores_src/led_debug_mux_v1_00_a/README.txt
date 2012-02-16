#################################################
##      
##      LED Debux Mux for XUPV2P
##
##      README
##
##      Created By: Jeffrey Goeders
##
##      Date: January 19, 2010
##
#################################################

This core is used to mux debug signals to output on the LEDs of the XUPV2P
board.  The mux selector is designed to be controlled by the dip switches 
on the board.

The core takes into account the fact that the LEDs and Dip Switches on the XUPV2P
board are active low.

The core contains one parameter - C_NUM_INPUTS.  This is used to specify the 
number of input signals to be muxed.  

Only the minimum number of necessary bits of the
selector signal will be used.  For example, if you have 4 inputs, 
only the lowest 2 significant bits of the selector will
be used.  



Example From .ucf file
------------------------------------------------------------------

########################## LEDs ####################
Net LED_pin<0> LOC=AC4;
Net LED_pin<1> LOC=AC3;
Net LED_pin<2> LOC=AA6;
Net LED_pin<3> LOC=AA5;
Net LED_pin<*> IOSTANDARD = LVTTL | SLEW = SLOW | DRIVE = 12;


########################## DIP SWITCHES ############

Net DIP_SW_pin<0> LOC=AC11;
Net DIP_SW_pin<1> LOC=AD11;
Net DIP_SW_pin<2> LOC=AF8;
Net DIP_SW_pin<3> LOC=AF9;
Net DIP_SW_pin<*> IOSTANDARD = LVCMOS25;



Example From .mhs file
------------------------------------------------------------------

# LEDs
 PORT LED_pin = LED, DIR = O, VEC = [3:0]
# Dip Switches
 PORT DIP_SW_pin = DIP_SW, DIR = I, VEC = [3:0]

BEGIN led_debug_mux
 PARAMETER INSTANCE = led_debug_mux_0
 PARAMETER HW_VER = 1.00.a
 PARAMETER C_NUM_INPUTS = 2
 PORT SELECTOR = DIP_SW
 PORT LED_OUT = LED
 PORT IN_0 = xxx_your_input_0_xxx
 PORT IN_1 = xxx_your_input_1_xxx
END