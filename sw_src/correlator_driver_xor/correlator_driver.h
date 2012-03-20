#ifndef CORRELATOR_DRIVER_H
#define CORRELATOR_DRIVER_H

#define CORRELATOR_CNTRL_REG_START_MASK 0x1 //Bit 0

#define CORRELATOR_STATUS_REG_DONE_MASK 0x1 //Bit 0
#define CORRELATOR_STATUS_REG_CURR_FRAME_MASK 0x000C0000 //Bits 19,18
#define CORRELATOR_STATUS_REG_PREV_FRAME_MASK 0x00030000 //Bits 17,16
#define CURR_FRAME_LOC_FROM_REG(x) ((x & CORRELATOR_STATUS_REG_CURR_FRAME_MASK) >> 18)
#define PREV_FRAME_LOC_FROM_REG(x) ((x & CORRELATOR_STATUS_REG_PREV_FRAME_MASK) >> 16)

#define NUM_SUBIMAGES 16
#define NUM_UNUSED_CORRELATOR_REG 5

typedef struct CorrelatorModule {
    //Writeable registers
    volatile Xuint32 cntrl_reg;
    volatile Xuint32 x_offset;
    volatile Xuint32 y_offset;
    
    //Read-only registers
    volatile const Xuint32 status_reg;
    volatile const Xuint32 correlation_values[NUM_SUBIMAGES];

    //Unused registers
    volatile Xuint32 unused_regs[NUM_UNUSED_CORRELATOR_REG];

} CorrelatorModule;


CorrelatorModule* correlator_get_ptr(void);

Xboolean correlator_finished(CorrelatorModule* correlator);

void correlator_set_offset(Position offset, CorrelatorModule* correlator);

void correlator_start(CorrelatorModule* correlator);

void correlator_get_results(int* results, CorrelatorModule* correlator);

FrameLoc correlator_get_frame_loc(CorrelatorModule* correlator);

#endif
