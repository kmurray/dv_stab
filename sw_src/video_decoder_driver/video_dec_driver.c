#include <xbasic_types.h>
#include <xparameters.h>
#include <xiic_l.h>

#include <video_driver.h>


int init_decoder() 
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

    test_corr();
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


