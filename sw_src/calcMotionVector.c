#include "stdio.h"
#include <xbasic_types.h>
#include <data_structs.h>
#include <correlator_driver.h>
#include <calcMotionVector.h>

#define NUM_SUBIMAGES 16
#define MAX_X_OFFSET 32
#define MAX_Y_OFFSET 32



/*
    Calculate the motion vector of the current frame
*/
Solution calcMotionVector(CorrelatorModule* correlator_ptr) {
    
    //printf("Starting motion vector correlation\r\n");

    //The array of local motion vectors
    Solution LocalMotionVec[NUM_SUBIMAGES];
    int subimage_cnt;
    //Initialize
    for(subimage_cnt = 0; subimage_cnt < NUM_SUBIMAGES; subimage_cnt++) {
        LocalMotionVec[subimage_cnt].correl_val = -1;
    }

    //Generate the local motion vectors (brute force search + correlator block evaluation)
    calcLocalMotionVectors(LocalMotionVec, correlator_ptr);

    //The frame/global motion vector is the median of all the local motion vectors
    Solution globalMotionVector = median(LocalMotionVec, NUM_SUBIMAGES);

    return globalMotionVector;
 
}

#define DEBUG_PRINT(x, ...) if(x) { printf( __VA_ARGS__ ); }

/*
    Calculate the motion vectors of each sub image

    This function loops through the various x,y offset combinations using
    the correlator block to perform the heavy computaion to get the 
    correlation values.

    It returns the solutions for each sub image through the array passed
    as an argument.
*/
void calcLocalMotionVectors(Solution BestSolns[], CorrelatorModule* correlator_ptr) {

    int x_offset, y_offset;
    int print_verbose = FALSE;

    //Search 32 pixels in each direction
    for (x_offset = 0; x_offset < MAX_X_OFFSET; x_offset++){
        for (y_offset = 0; y_offset < MAX_Y_OFFSET; y_offset++){
            
            //The offset
            Position offset;
            offset.x = x_offset;
            offset.y = y_offset;
            
            DEBUG_PRINT(print_verbose, "Setting offset.x: %d, offset.y: %d\r\n", offset.x, offset.y); 

            //The correlaiton results
            int correl_vals[NUM_SUBIMAGES];

            //Set the search co-ords for the correlator
            correlator_set_offset(offset, correlator_ptr);

            //Start the correlator
            correlator_start(correlator_ptr);

            //Busy wait until finished
            while(!correlator_finished(correlator_ptr)) {
                //nop
            }
            
            //Grab the results
            correlator_get_results(correl_vals, correlator_ptr);
            

            int subimage_num;

            //Check each sub image
            for (subimage_num = 0; subimage_num < NUM_SUBIMAGES; subimage_num++) {
                DEBUG_PRINT(print_verbose, "Correlator %d result: %d\r\n", subimage_num, correl_vals[subimage_num]); 
                //Keep the lowest correlation value for each subimage, the offest 
                //that generates this is the local motion vector for the sub image
                // -1 is the initialized solution value
                if ((BestSolns[subimage_num].correl_val == -1 ) || \
                    (BestSolns[subimage_num].correl_val > correl_vals[subimage_num])) {
                    
                    BestSolns[subimage_num].mv = offset;
                    BestSolns[subimage_num].correl_val = correl_vals[subimage_num];
                }
            } //sub images
        } //y offsets
    } // x offsets
}

/*
    Returns the median of the array
*/
Solution median(Solution solns[], int size) {

    //Sort the solutions
    selectionSort(solns, size); 

    Solution medianSoln;
    /* 
        Calculate the median
        
        Median is defined as the (n+1)/2 item
            For odd 'size' this works out to be an integer

            For even 'size' we need to calculate it as the average
            between the n/2 and n/2 + 1 items
     */
    if (size % 2 == 0) {
        //Even

        /* 
            XXX: This uses integer not floating point division

            TODO: Make this use floating point division and round to integers,
                  if it isn't too slow on microblaze....
         */
        medianSoln.correl_val = 0.5*(solns[(size-1)/2].correl_val + solns[(size-1)/2 +1].correl_val);

        medianSoln.mv.x =  0.5*(solns[(size-1)/2].mv.x + solns[(size-1)/2 +1].mv.x);
        medianSoln.mv.y =  0.5*(solns[(size-1)/2].mv.y + solns[(size-1)/2 +1].mv.y);

        
    } else {
        //Odd, should not happen?
        medianSoln = solns[(size)/2];
    }

    return medianSoln;
}

/*
    Selection sort is nice since it sorts in place

    TODO: fix this crappy O(n^2) sort, it only works because our list is small
 */
void selectionSort(Solution solns[], int size) {

    //current position we are sorting based on
    int pos;

    //The minimum value we are comparing to
    int pos_min;

    //Inner loop counter
    int i;

    //Through all the elments
    for(pos = 0; pos < size; pos++) {
        //Find the smallest element in the unsorted remainder solns[pos .. size-1]

        //Assume first element is min
        pos_min = pos;

        //check all the other elements after pos
        for(i = pos+1; i < size; i++) {
            //If a latter element is smaller it should be the new min
            if(solns[i].correl_val < solns[pos_min].correl_val) {
                //New minimum - save its position
                pos_min = i;
            }
        }

        //If the first element wasn't the smallest, swap it with the smallest
        if (pos_min != pos) {
            swap(solns, pos, pos_min);
        }

    }
}

/* 
    Swap two elements in the array

    Assumes pos and pos_min are valid, does no error checking
*/
void swap(Solution solns[], int pos, int pos_min) {
    //Temp var
    Solution temp;
    
    //Save pos
    temp = solns[pos];

    //Move pos_min to pos
    solns[pos] = solns[pos_min];

    //Move saved pos to pos_min
    solns[pos_min] = temp;

}
