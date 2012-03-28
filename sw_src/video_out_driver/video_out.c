#include <xbasic_types.h>
#include <xparameters.h>

#include <data_structs.h>
#include <correlator_driver.h>
#include <video_out.h>

VideoOutModule* video_out_get_ptr(void){ 
    return (VideoOutModule *) XPAR_TFT_0_DEFAULT_TFT_BASE_ADDR;
}

void setOutputBuffer(Xuint32 base_addr) {

    //Get the pointer to the video output module
    VideoOutModule* video_out_ptr = video_out_get_ptr();

    //Store the new address, this flips the buffer
    video_out_ptr->frame_base_addr = base_addr;
}

