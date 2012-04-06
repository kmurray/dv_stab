#include <xbasic_types.h>
#include <xparameters.h>
#include <init_hw.h>

int main() {
    volatile int* split_ptr = XPAR_SPLIT_COMPENSATE_1_BASEADDR;
    volatile int* vid_out_ptr = XPAR_VIDEO_OUT_SPLB_BASEADDR;
    init_hw();

    *(vid_out_ptr) = 0x41000000;

    //Clear offset and direction registers
    *(split_ptr) = 0;
    *(split_ptr +5 ) = 0; //xoff
    *(split_ptr +6 ) = 0; //yoff
    *(split_ptr +7 ) = 0; //x_dir
    *(split_ptr +8 ) = 0; //y_dir

    //Set read frame base addr
    *(split_ptr +3 ) = 0x40000000;

    //set write frame base addr
    *(split_ptr +4 ) = 0x41000000;

    int i,j,k,a;
    while(1){
	  for (j=0; j<240; j++){
       for (i=0; i<320; i++){
	     *(split_ptr)=0;
	     *(split_ptr+5) = i;
	     *(split_ptr+6) = j;
	     *(split_ptr+7) = 1;
	     *(split_ptr+8) = 0;
	     *(split_ptr)=1;
	     for (k=0; k<200000; k++){
		a=k;
	      }
	      
	  }
       }
    }
}
