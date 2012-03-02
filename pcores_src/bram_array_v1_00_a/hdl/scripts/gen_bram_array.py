#!/usr/bin/python

filename = 'bram_array.v'
num_brams = 16
addr_width = 9
data_width = 128


with open(filename, 'w') as f:
    print >>f, 'module bram_array('

    print >>f, "\tclk_in,"
    print >>f, "\tclk_out,"
    print >>f, ""

    #Inputs
    for i in xrange(num_brams):
            print >>f, "\tinput  [{0:3d}:0]  bram_{1}_in_addr,".format(addr_width-1, i)
            print >>f, "\tinput  [{0:3d}:0]  bram_{1}_in_data,".format(data_width-1, i)
            print >>f, "\tinput           bram_{0}_wea,".format(i)
            print >>f, "\tinput  [{0:3d}:0]  bram_{1}_out_addr,".format(addr_width-1, i)
            print >>f, "\toutput [{0:3d}:0]  bram_{1}_out_data,".format(addr_width-1, i)
            print >>f, ""
    print >>f, "\t);\n"

    #Input declarations
    for i in xrange(num_brams):
        print >>f, "\t bram bram_%d(" % (i)
        print >>f, "\t\t.addra(bram_%d_in_addr)," % (i)
        print >>f, "\t\t.addrb(bram_%d_out_addr)," % (i)
        print >>f, "\t\t.clka (clk_in),"
        print >>f, "\t\t.clkb (clk_out),"
        print >>f, "\t\t.dina (bram_%d_in_data)," % (i)
        print >>f, "\t\t.doutb(bram_%d_out_addr)," % (i)
        print >>f, "\t\t.wea  (bram_%d_wea));" % (i)
        print >>f, ""



    print >>f, "endmodule"




