#ifndef SPLIT_COMP_DRIVER_H
#define SPLIT_COMP_DRIVER_H

#define SPLIT_COMP_STATUS_REG_DONE_MASK 0x1 //Bit 0

typedef struct SplitCompModule {
    volatile Xuint32 start_go_reg; //unused
    volatile Xuint32 status_reg;
    volatile Xuint32 cntrl_reg;
    volatile Xuint32 fr_src_addr;
    volatile Xuint32 fr_dest_addr;
    volatile Xuint32 x_offset;
    volatile Xuint32 y_offset;
    volatile Xuint32 x_offset_dir;
    volatile Xuint32 y_offset_dir;
    volatile Xuint32 unused_reg;

} SplitCompModule;


SplitCompModule* split_comp_get_ptr(void);

Xboolean split_comp_finished(SplitCompModule *split_comp);

void split_comp_setup(Position offset, Xuint32 fr_src_addr, Xuint32 fr_dest_addr, SplitCompModule* split_comp);

void split_comp_start(SplitCompModule *split_comp);



#endif
