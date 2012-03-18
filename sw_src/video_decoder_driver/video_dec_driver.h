#ifndef VIDEO_DEC_DRIVER_H
#define VIDEO_DEC_DRIVER_H



#define GPO_REG_OFFSET 0x124
#define DECODER_ADDR 0x20 //Read: 0x41, Write: 0x40
#define SEND_CNT 3
#define RECV_CNT 3
#define GPO_RESETS_OFF 1
#define GPO_RESET_IIC 3
#define GPO_RESET_DECODER 0

#define printf xil_printf


struct VideoModule {
  Xuint8 addr;
  Xuint8 config_val;
  Xuint8 actual_val;
};

/Composite Configuration constants
#define DECODER_COMP_CONFIG_CNT 18
struct VideoModule decoder_comp[] = { 
  { 0x00, 0x04, 0 },
  { 0x15, 0x00, 0 },
  { 0x17, 0x41, 0 },
  { 0x27, 0x58, 0 },
  { 0x3a, 0x16, 0 }, 
  { 0x50, 0x04, 0 },
  { 0x0e, 0x80, 0 },
  { 0x50, 0x20, 0 },
  { 0x52, 0x18, 0 }, 
  { 0x58, 0xed, 0 },
  { 0x77, 0xc5, 0 },
  { 0x7c, 0x93, 0 },
  { 0x7d, 0x00, 0 },
  { 0xd0, 0x48, 0 },
  { 0xd5, 0xa0, 0 },
  { 0xd7, 0xea, 0 },
  { 0xe4, 0x3e, 0 },
  { 0xea, 0x0f, 0 }, 
  { 0x0e, 0x00, 0 } };

int init_decoder();

void configDecoder(struct VideoModule *decoder, int config_cnt );



#endif
