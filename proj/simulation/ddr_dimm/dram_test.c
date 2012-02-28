#include "xparameters.h"

#include "stdio.h"

#include "xutil.h"

//====================================================

int main (void) {

	volatile Xuint32 *memptr32 = (Xuint32*)XPAR_DDR_SDRAM_MPMC_BASEADDR;
	volatile Xuint16 *memptr16 = (Xuint16*)XPAR_DDR_SDRAM_MPMC_BASEADDR;
	volatile Xuint8  *memptr8  = (Xuint8*) XPAR_DDR_SDRAM_MPMC_BASEADDR;

	volatile Xuint32 reader;

   /* Testing MPMC Memory (DDR_SDRAM)*/
   {
	  int t;
	  
	  // Byte access
	  for(t=0;t<20;t++)
		memptr8[t] = t;
		
	  for(t=0;t<20;t++)
		reader = memptr8[t];
		
	  // Half-word access
	  for(t=0;t<10;t++)
		memptr16[t] = (t << 9) | (t << 1) ;
		
	  for(t=0;t<10;t++)
		reader = memptr16[t];
		
	  // Word access
	  for(t=0;t<5;t++)
		memptr32[t] = (t << 26) | (t << 18) | (t << 10) | (t << 2);
		
	  for(t=0;t<5;t++)
		reader = memptr32[t];
		
   }
   return 0;
}

