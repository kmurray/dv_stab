#include "stdio.h"
#include <xbasic_types.h>
#include <data_structs.h>
#include <correlator_driver.h>
#include <calcCompensationVector.h>

//Calculate the compensation vector
Solution calcCompensationVector(Solution globalMotionVector, Solution prevCompensationVector){

    //Convert globalmotionvector (0 to 31  where 16=static) to actual offsets (-16 to 15),
    //and add exponential decay
    //Also subtract to "compensate"
    //TODO: floating point
    Solution compensationVector;
    compensationVector.mv.x = prevCompensationVector.mv.x * DECAY_FACTOR 
                                - (globalMotionVector.mv.x - CENTER_X_OFFSET);

    compensationVector.mv.y = prevCompensationVector.mv.y * DECAY_FACTOR 
                                - (globalMotionVector.mv.y - CENTER_Y_OFFSET);

    //printf("computed vectors: (%d, %d)",  compensationVector.mv.x, compensationVector.mv.y);
    //If compensation is too large - likely panning. TODO verify this
    if (compensationVector.mv.x > MAX_X_COMPENSATION){
        compensationVector.mv.x = MAX_X_COMPENSATION;
    }
    else if (compensationVector.mv.x < ((-1)*MAX_X_COMPENSATION) ){
        compensationVector.mv.x = (-1)* MAX_X_COMPENSATION;
    }

    
    if (compensationVector.mv.y > MAX_Y_COMPENSATION){
        compensationVector.mv.y = MAX_Y_COMPENSATION;
    }
    else if (compensationVector.mv.y < ((-1)*MAX_Y_COMPENSATION) ){
        compensationVector.mv.y = (-1)* MAX_Y_COMPENSATION;
    }

    return compensationVector;   
}

