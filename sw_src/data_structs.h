#ifndef DATA_STRUCTS_H
#define DATA_STRUCTS_H

#define printf xil_printf


#define NUM_SUBIMAGES 16
#define MAX_X_OFFSET 32
#define MAX_Y_OFFSET 32
#define CENTER_X_OFFSET 16
#define CENTER_Y_OFFSET 16

#define DECAY_FACTOR 0.9
#define MAX_X_COMPENSATION 31 //+/-31
#define MAX_Y_COMPENSATION 31 //+/-31


typedef struct Position {
    Xint32 x;
    Xint32 y;
} Position;

//Stores a potential solution
typedef struct Solution {
    //The motion vector
    Position mv;
    Xuint32 correl_val;
} Solution;

typedef struct FrameLoc {
    Xuint32 curr_frame;
    Xuint32 prev_frame;
} FrameLoc;

#endif
