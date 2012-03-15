#include "xparameters.h"
#define printf xil_printf   /* a smaller footprint printf */

int main(){
    volatile int * corr_base_ptr = (int *) XPAR_CORRELATOR_XOR_0_BASEADDR;

    int x_offset, y_offset;
    int corr_sum;
    for (x_offset = 0; x_offset < 32; x_offset++){
        for (y_offset = 0; y_offset < 32; y_offset++){

            *(corr_base_ptr+1) = x_offset;
            *(corr_base_ptr+2) = y_offset;
            *(corr_base_ptr) = 1; //start

            while ( *(corr_base_ptr+3) == 0 ) {} //poll for done
            corr_sum = *(corr_base_ptr+4);
            *(corr_base_ptr) = 0; //reset the start signal to ack read
        }
    }
    //printf ("corrsum = %d\n", corr_sum);


    /*
    //test the perfect offset
    x_offset = 12;
    y_offset = 14;
    //test the not so perfect offset
    x_offset = 12;
    y_offset = 15;
    */
}
