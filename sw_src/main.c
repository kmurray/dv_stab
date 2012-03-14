#include <xbasic_types.h>
#include <xparameters.h>

int main() {

    //Initialize software data structures
    init_sw();

    //Initialize hardware blocks
    init_hw();

    //Main processing loop
    while(1) {
        
        //Check for and impliment config changes that come over uart
        checkForConfigChanges();

        //Poll correllator for ready status
        waitForCorrelatorReady();

        //Find motionvector
        motionVector = calcMotionVector();

        //Calculate the compensation vector
        compensationVector = calcCompensationVector();

        //Send final motion vector to split/crop block
        compensateFrame(compensationVector);

    }

    printf("ERROR: reached end of main function, should not happen\n");

}


void waitForCorrelatorRead() {
    while(!CorrelatorFinished()){
        //Poll for status
    }
 
}
