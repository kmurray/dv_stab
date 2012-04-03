#include <xbasic_types.h>
#include <xparameters.h>

int main() {
    volatile int* split_ptr = XPAR_SPLIT_COMPENSATE_1_BASEADDR;

    int i, a;

    for (i=0; i < 10000; i++) {
        a = i;
    }

    //Clear offset and direction registers
//    *(split_ptr +5 ) = 0;
//    *(split_ptr +6 ) = 0;
//    *(split_ptr +7 ) = 0;
//    *(split_ptr +8 ) = 0;

    //Set read frame base addr
    *(split_ptr +3 ) = 0x40000000;

    //set write frame base addr
    *(split_ptr +4 ) = 0x41000000;

    //Start the block
    *(split_ptr)     = 1;
}
