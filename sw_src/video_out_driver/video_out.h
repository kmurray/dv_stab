#ifndef VIDEO_OUT_H
#define VIDEO_OUT_H

#define C_VIDEO_RAM_BUF_OFFSET 0x00200000
#define VIDEO_RAM_BASE_ADDR XPAR_DDR_SDRAM_MPMC_BASEADDR
#define NUM_BUFFS 3

typedef struct VideoOutModule {
    Xuint32 frame_base_addr;
} VideoOutModule;

VideoOutModule* video_out_get_ptr(void);

void setOutputBuffer(Xuint32 base_addr);

#endif
