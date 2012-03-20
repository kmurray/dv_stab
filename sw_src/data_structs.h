#ifndef DATA_STRUCTS_H
#define DATA_STRUCTS_H

#define printf xil_printf


#define NUM_SUBIMAGES 16
#define MAX_X_OFFSET 32
#define MAX_Y_OFFSET 32

typedef struct Position {
    Xuint32 x;
    Xuint32 y;
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
