`define REG_WIDTH 32

`define BRAM_DATA_WIDTH 128
`define BRAM_DEPTH 512 //NOT USED
`define BRAM_ADDR_WIDTH 9
`define LINE_BITSUM_WIDTH 8 //max value of bitsum is 128; need max 256

`define FRAME_BITSUM_WIDTH 15 //128X128=16K just to be safe; need max 32k

`define MAX_OFFSET 32  //coordinate at corner of subimage
`define CENTERING_OFFSET 16 //offset needed to center the search area; Half of max
`define MAX_OFFSET_WIDTH 6 //Need 6 bits for offset val of 32

//subimage sizes
`define SUBIMAGE_W `BRAM_DATA_WIDTH
`define SUBIMAGE_H 64
`define SUBIMAGE_H_WIDTH 6

//search area sizes
`define SEARCH_AREA_W (`SUBIMAGE_W - `MAX_OFFSET) //96
`define SEARCH_AREA_H (`SUBIMAGE_H - `MAX_OFFSET) //32

`define BRAM_FRAME_ADDR_OFFSET 128 //word addressable
`define BRAM_FRAME_ADDR_OFFSET_SHIFT 7
`define BRAM_FRAME_ADDR_OFFSET_WIDTH 8



