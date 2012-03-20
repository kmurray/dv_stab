#ifndef VIDEO_DEC_DRIVER_H
#define VIDEO_DEC_DRIVER_H



#define GPO_REG_OFFSET 0x124
#define DECODER_ADDR 0x20 //Read: 0x41, Write: 0x40
#define SEND_CNT 3
#define RECV_CNT 3
#define GPO_RESETS_OFF 1
#define GPO_RESET_IIC 3
#define GPO_RESET_DECODER 0

struct VideoModule {
  Xuint8 addr;
  Xuint8 config_val;
  Xuint8 actual_val;
};



int init_video_decoder(void);

void configDecoder(struct VideoModule *decoder, int config_cnt);

#endif
