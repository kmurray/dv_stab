#include <xbasic_types.h>
#include <xparameters.h>
#include <xiic_l.h>

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


//Composite Configuration constants
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


void configDecoder(struct VideoModule *decoder, int config_cnt );

int main() 
{
	Xuint8 start_addr = 0;
	Xuint8 send_data[SEND_CNT] = {0};
	Xuint32 send_cnt;
	Xuint8 recv_data[RECV_CNT] = {0};
	Xuint32 recv_cnt;
	Xuint8 i;

   recv_cnt = 0;
	
	print("\r\nBeginning Setup\r\n");
	configDecoder(decoder_comp, DECODER_COMP_CONFIG_CNT);
	print("\r\nSetup Complete!\r\n\r\n");
} 


void configDecoder(struct VideoModule *decoder, int config_cnt ) 
{
  Xuint16 send_cnt, i;
  Xuint8 send_data[2] = {0};
  Xuint8 success = 1;
  send_cnt = 2;
  xil_printf("  Configuring Decoder...\t");
  //read in configuration constants and send them to the VDEC one by one
  for( i = 0; i < config_cnt; i++ )
   {

    send_data[0] = decoder[i].addr;

    send_data[1] = decoder[i].config_val;

    send_cnt = XIic_Send(XPAR_IIC_BASEADDR, DECODER_ADDR, send_data, 2,XIIC_STOP );

    if( send_cnt != 2 ) 
	 {
      xil_printf("Error writing to address %02x\r\n", decoder[i].addr);
      success = 0;
      break;
     }
   }

  if( success )
    xil_printf("SUCCESS!\r\n");

}
