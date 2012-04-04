#include "stdio.h"
#include <xbasic_types.h>
#include <xparameters.h>

#include <data_structs.h>
#include <split_comp_driver.h>

SplitCompModule* split_comp_get_ptr() {
    return (SplitCompModule *) XPAR_SPLIT_COMPENSATE_1_BASEADDR; //TODO: check name
}

Xboolean split_comp_finished(SplitCompModule* split_comp) {
    //First bit of status_reg is the only bit active, and it indicates done
    return (split_comp->status_reg & SPLIT_COMP_STATUS_REG_DONE_MASK);
}


void split_comp_setup(Position offset, Xuint32 fr_src_addr, Xuint32 fr_dest_addr, SplitCompModule* split_comp){
    if (!split_comp_finished(split_comp)) {
        printf("Error: split_comp is not finished, but attempting to set offsets and addresses\r\n");
    }
    
    //setup the src/dest frame addresses
    split_comp->fr_src_addr = fr_src_addr;
    split_comp->fr_dest_addr = fr_dest_addr;
    
    //convert the xy offsets into positive values + direction
    if (offset.x < 0) { //left
        split_comp->x_offset = -offset.x*4;
        split_comp->x_offset_dir = 0; 
    }
    else{ //right
        split_comp->x_offset = offset.x*4;
        split_comp->x_offset_dir = 1; 
    }

    if (offset.y < 0) { //down
        split_comp->y_offset = -offset.y;
        split_comp->y_offset_dir = 1;
    }
    else{ //up
        split_comp->y_offset = offset.y;
        split_comp->y_offset_dir = 0;
    }

}

void split_comp_start(SplitCompModule *split_comp){
    //Check that the split_comp is idle before starting
    if (!split_comp_finished(split_comp)) {
        printf("Error: split_comp is not finished, but attempting to start\r\n");
    }

    //First reset the start bit
    split_comp->cntrl_reg = 0;

    //Set the start bit
    split_comp->cntrl_reg = 1;
    
}



