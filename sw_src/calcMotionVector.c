#define NEIGHBORHOOD_X 5
#define NEIGHBORHOOD_Y 5
#define NUM_SUBIMAGES 16

#define MAX_TRIES 2
#define T_MAX 0.7
#define T_MIN 0.01
#define T_DECAY_RATE 0.09

//For the exp() f'n
#include <math.h>

//Stores a potential solution
typedef struct Solution {
    int x;
    int y;
    int correlationValue = NULL;
} Solution;


void* calcMotionVectorSA () {
    //Where each of the 16 sub images are currently searching
    Solution currentSolns[NUM_SUBIMAGES];
    //The best solution found for each of the sub images
    Solution bestSolns[NUM_SUBIMAGES];
    //Number of outer algorithm iterations
    int tries;

    for (tries = 0; tries < MAX_TRIES; tries++) {
    
        //Random starting positions
        int subImageNum;
        for(subImageNum = 0; subImageNum < NUM_SUBIMAGES; subImageNum++) {
            //TODO: use a single rand int if this is too slow
            currentSolns[subImageNum].x = randi(SUBIMAGE_WIDTH);
            currentSolns[subImageNum].y = randi(SUBIMAGE_HEIGHT);
        }
        
        //Evaluate solutions
        evalSolns(currentSolns, NUM_SUBIMAGES);

        //If this is the first (or a better) solution accept it as best
        for(subImageNum = 0; subImageNum < NUM_SUBIMAGES; subImageNum++) {
            if ( (currentSolns[subImageNum].correlationValue == NULL) ||
                 (currentSolns[subImageNum].correlationValue < bestSolns[subImageNum].correlationValue) ) {

                bestSolns[subImageNum] = currentSolns[subImageNum];
            }
        }

        //Init temperature
        float t = T_MAX;
        //Init cooling counter
        int j = 0;

        //Cool unitl T_MIN
        while (t > T_MIN) {
            
            //Cool
            t = tMax*exp(-j*tDecayRate);

            //Generate new solutions in the neighborhood of the current solutions
            neighborSoln = getNeighbor(currentSolns, NEIGHBORHOOD_X, NEIGHBORHOOD_Y)

            //Evaluate
            evalSolns(&neighborSoln, NUM_SUBIMAGES);

            for(subImageNum = 0; subImageNum < NUM_SUBIMAGES; subImageNum++) {
                
                //Keep the best solution
                if(neighborSoln[subImageNum].correlationValue < bestSoln[subImageNum].correlationValue) {
                    bestSolns[subImageNum] = neighborSoln[subImageNum];
                }

                //probabilistically accept the neighbor solution as the currentPosition
                if ( porbabilisticAccept(currentsoln[subImageNum].correlationValue, neighborSoln[subImageNum].correlationValue, t) ) {
                    currentSoln[subImageNum] = neighborSoln[subImageNum];
                }
            }
            
            //Cooling increment
            j = j + 1;

        } //temperature

    } //tries


    //Take the median of the motion vectors
    Solution motionVector = median(bestSolns, NUM_SUBIMAGES);


    return motionVector;
}

int median(Solution solns[], int size) {
    


    return medianSoln;
}

/*
    Accept the neighbor solution, randomly, but biased towards accepting
    better solutions by the correlation value difference and temperature
 */
int probabilisticAccept(currentCorrelationValue, neighborCorrelationValue, temperature) {
    int accept;

    /*
        Semi-random acceptance rate, a significantly better solution is
        much more likely to be accepted than one that is worse.  As the 
        temparture decreases this emphasis is increased
     */

    //Random value between 0 and 1
    // FIXME: not a good implimentation...
    float randValue = (float) rand()/RAND_MAX;

    //Acceptance threshold
    float acceptanceValue = exp((currentCorrelationValue - neighborCorrelationValue)/t);

    //Evaluate
    accept = (randValue < acceptacneValue);

    return accept;
}

/*
    Given a list of solution structs, load the co-ordinates
    into the correlator registers, wait for the result
    and finally retireve the correlationvalues

    TODO: use real functions...
 */
void evalSolns (Solution soln[], int size) {
    //Build correlator co-ordinates struct
    searchCoordsStruct = CorrelatorGenCoordsStruct(size);
   
    int subImageNum;
    for(subImageNum = 0; subImageNum < size; subImageNum++) {
        searchCoords[subImageNum].x = soln[subImageNum].x
        searchCoords[subImageNum].y = soln[subImageNum].y
    }

    /* 
        Store coords and start correlator

        The correlator hardware block processes all 16 subimages in parrallel
     */
    CorrelatorStart(searchCoords);

    while(!CorrelatorFinished()){
    //Poll for status
    }

    //Load results
    correlationResults = CorrelatorGetResults();

    //Add correlation values to soln
    for(subImageNum = 0; subImageNum < size; subImageNum++) {
        soln[subImageNum].correlationValue = correlationResults[subImageNum];
    }

}

/*
    Generate a random integer from 0 to range
 */
int randi(int range) {
    return rand() % range;
}
