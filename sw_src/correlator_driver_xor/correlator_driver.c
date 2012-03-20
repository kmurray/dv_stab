#include <xbasic_types.h>
#include <xparameters.h>

#include <data_structs.h>
#include <correlator_driver.h>

CorrelatorModule* correlator_get_ptr() {
    return (CorrelatorModule *) XPAR_CORRELATOR_XOR_0_BASEADDR;
}

Xboolean correlator_finished(CorrelatorModule* correlator) {
    //First bit of status_reg is the only bit active, and it indicates done
    if (correlator->status_reg & CORRELATOR_STATUS_REG_DONE_MASK) {
        return TRUE;
    } else {
        return FALSE;
    }
}

void correlator_set_offset(Position offset, CorrelatorModule* correlator) {
    
    if (!correlator_finished(correlator)) {
        printf("Error: correlator is not finished, but attempting to set offset\r\n");
    }
    correlator->x_offset = offset.x;
    correlator->y_offset = offset.y;

}

void correlator_start(CorrelatorModule* correlator) {
    //Check that the correlator is idle before starting
    if (!correlator_finished(correlator)) {
        printf("Error: correlator is not finished, but attempting to start\r\n");
    }

    //First reset the start bit
    correlator->cntrl_reg = 0;

    //Set the start bit
    correlator->cntrl_reg = (correlator->cntrl_reg | CORRELATOR_CNTRL_REG_START_MASK);
    
}
/*
    Note assumes results is an array of size NUM_SUBIMAGES
*/
void correlator_get_results(int* results, CorrelatorModule* correlator) {
    if (!correlator_finished(correlator)) {
        printf("Error: correlator is not finished, but attempting to read correlation results\r\n");
    }

    int sub_image_cnt;
    for (sub_image_cnt = 0; sub_image_cnt < NUM_SUBIMAGES; sub_image_cnt++) {
        results[sub_image_cnt] = correlator->correlation_values[sub_image_cnt];
    }

}

/*
    Gets information from status register about the locations of the current
    and previous frames (from the correlators perspective).

    These locations are numbers corresponding to which buffer the frame is
    located in.

    Since there are only 3 buffers, valid values are '0', '1', '2'
 */
FrameLoc correlator_get_frame_loc(CorrelatorModule* correlator){
    //Load the status register once
    Xuint32 status_reg =  correlator->status_reg;

    FrameLoc loc;

    loc.curr_frame = CURR_FRAME_LOC_FROM_REG(status_reg);
    loc.prev_frame = PREV_FRAME_LOC_FROM_REG(status_reg);

    return loc;
}

