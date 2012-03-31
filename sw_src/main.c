#include "stdio.h"
#include <xbasic_types.h>
#include <xparameters.h>
#include <data_structs.h>
#include <correlator_driver.h>
#include <calcMotionVector.h>
#include <calcCompensationVector.h>
#include <video_out.h>
#include <main.h>
#include <init_hw.h>
 

int main() {

    //Initialize software data structures
    //init_sw();

    //Initialize hardware blocks
    init_hw();


    CorrelatorModule* correlator_ptr = correlator_get_ptr();

    //Some per interation declarations
    Solution globalMotionVector;
    Solution prevGlobalMotionVector;
    Solution compensationVector, prevCompensationVector; 

    //initialize the compensationVector
    compensationVector.mv.x = 0;
    compensationVector.mv.y = 0;

    int Fr_num = 0;

    //Main processing loop
    while(1) {
        if (Fr_num == 30) {
            printf("1 second has passed\r\n");
            Fr_num = 0;
        }
        //Check for and impliment config changes that come over uart
        //checkForConfigChanges();
        
        //Synchronize so we only start calculations when we have a new frame
        synchronize_new_frame(correlator_ptr);

        //Swap output buffer


        //Save the old motionvector
        prevGlobalMotionVector = globalMotionVector;

        //Find motionvector - uses the correlator module
        globalMotionVector = calcMotionVector(correlator_ptr);

        //Calculate the compensation vector
        prevCompensationVector = compensationVector;
        compensationVector = calcCompensationVector(globalMotionVector, prevCompensationVector);

        //Send final motion vector to split/crop block
        //compensateFrame(compensationVector);
       
        //Swap the output buffers
        //setOutputBuffer();


        if ((prevCompensationVector.mv.x != compensationVector.mv.x) || (prevCompensationVector.mv.y !=  compensationVector.mv.y)) {
            //printf("\tFr: %d Motion Vector: (%d, %d)\t Correl_val: %d\t Compensation Vectors: (%d, %d)\r\n", Fr_num, globalMotionVector.mv.x, globalMotionVector.mv.y, globalMotionVector.correl_val, compensationVector.mv.x, compensationVector.mv.y);
            printf("Fr: %d MV: (%d, %d) \t Corr: %d \t CV: (%d, %d)\r\n", Fr_num, globalMotionVector.mv.x-CENTER_X_OFFSET, globalMotionVector.mv.y-CENTER_Y_OFFSET, globalMotionVector.correl_val, compensationVector.mv.x, compensationVector.mv.y);
        }
        Fr_num++;
    }

    printf("ERROR: reached end of main function, should not happen\r\n");

}

/*
    This function synchronizes the main program loop to start of new frames

    By querying the correlator module for frame buffers we can detect
    new frames (when frame buffers switch).

    We also check the correlator status to ensure that it is finished.
    If it is still busy then something has gone wrong (i.e. The 
    correlator should be idle by the time the next frame starts, if
    the system is working in real time).
    
 */
void synchronize_new_frame(CorrelatorModule* correlator_ptr) {
    
    //Wait for a new frame
    FrameLoc old_frame_loc;
    FrameLoc new_frame_loc;

    //Initialize so we enter the loop on the first iteration
    new_frame_loc = correlator_get_frame_loc(correlator_ptr);
    old_frame_loc = new_frame_loc;

    //This loop will exit only on a buffer swap - which indicates a new frame
    while(new_frame_loc.curr_frame == old_frame_loc.curr_frame) {
        //Discard the old value
        old_frame_loc = new_frame_loc;

        //Update frame buffer loc
        new_frame_loc = correlator_get_frame_loc(correlator_ptr);
    }
   
    //This loop shoud never be entered - the correlator should finish well
    // before the next frame starts

    /* //TODO: FIX Currently broken, initially the correlator does not indicate finished
    while(!correlator_finished(correlator_ptr)) {
        printf("ERROR: new frame ready, but correlator busy!\r\n");
    }
    */

}
