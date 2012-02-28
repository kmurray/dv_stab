#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define BUFFER_SIZE 100
#define MAX_HEADER_LINE 3
#define BIT_SIZE 8
#define NUM_BYTES_PER_LINE 8
#define NUM_BYTES_RAW 1474560 		//1024*480*3 (LENGTH * WIDTH * (R,G,B))
#define NUM_BYTES_DRAM 1966080		//1024*480*4 (LENGTH * WIDTH * (0,R,G,B)) //0 AS DUMMY

/***************************************************************************
*******	Author: Michael Lee
******* Date: July 18, 2011
******* Summary: DRAM LINEAR MEMORY MAPPING - Read contents of 16 DRAM chips 
*******		 and distribute them in linear order 
*******          
*******
****************************************************************************
****************************************************************************/

/*
@PROGRAM DESCRIPTION: 
	- SKIP THE FIRST THREE HEADER LINES (READ BINARY MEMORY CONTENTS ONLY)
	- BEGIN TO READ FROM THE FOURTH LINE TO THE END OF FILE (OR NEWLINE)
	- PARSE BINARY VALUES BY WHITESPACE " " ON EACH LINE
	- CONVERT STRINGS OF 8BITS (8BYTES) INTO ONE UNSIGNED CHAR OF 8BITS (1BYTE). 
		- BREAKDOWN BUFFER ARRAY INTO "WORDS_PER_LINE" SEGMENTS OF SUB-ARRAY.

	- ALLOCATE MEMORY (MALLOC) FOR 16 LOCAL POINTERS AND THEN ALLOCATE 16X SIZE OF POINTER TO STORE TOTAL MEMORY CONTENTS 
          IN LINEAR ORDER. (FREE 16 LOCAL MEMORY AFTER DONE)

@REVISION LOG:	
	JUL 25 //read_memory & read_memory_byte:
			- THE TESTER FUNCTION "read_memory_byte" CREATED TO DEBUG FUNCTIONALITY OF "read_memory"
			- TEST CASES SUCCESSFUL! 

	JUL 26 //write_memory function: 
			- SO FAR IT WRITES THE FIRST LINE OF MEMORY BLOCKS FROM THE LAST FILE INTO NEW FILE
			- CANNOT WRITE MEMORY BLOCKS FROM MULTIPLE FILES... ONLY THE LAST FILE.

	JUL 27 //write_memory function:
			- THE FUNCTION IS ABLE TO READ ENTIRE MEMORY CONTENTS FROM MULTIPLE FILES
			- EACH FILE IS ACCESSED(READ) ONE AT A TIME AND PROCEED TO THE NEXT FILE.
			- COPY LOCAL CHIP MEMORY BLOCKS INTO GLOBAL MEMORY POINTER FOR EACH FILE LOOP
				- PROBLEM: NEED TO FIND OUT NUMBER OF MEMORY BLOCKS PER CHIP..
				- READ MODELSIM TCL COMMAND MANUAL OR TRY OUT TO SEE IF THEY HAVE THEIR FUNCTION TO PRINT OUT NUMBER OF WORDS(BLOCK)
				  IN THE MEMORY DATA FILE.
			- RECONSTRUCT THE ORDER TO ORGANIZE ALL MEMORY BLOCKS IN LINEAR ORDER (NOT DONE YET...)

	AUG 02 //Main:
			- WRITE_MEMORY FUNCTION IS NOW INCLUDED IN MAIN
			- MEMORY RECONSTRUCTION DISTRIBUTES MEMORY BYTES (BLOCKS) INTO NUMBER OF CHIPS' FILES (8 OR 16) IN LINEAR ORDER

	AUG 08 //Main:
			- INCLUDE "GETOPT" LINUX COMMAND OPTION PARSER FOR USERS TO DECIDE LOCAL MEMORY PARAMETERS


*/

void skip_header(FILE *fpointer_read){

	int line_position = 1;
	char buffer[BUFFER_SIZE];
	
	for (line_position; line_position <= MAX_HEADER_LINE; line_position++){

		fgets(buffer, BUFFER_SIZE, fpointer_read); 			//READ AND SKIP THE FIRST THREE HEADER LINES	
	}

}

unsigned char read_memory(FILE *fpointer_read, unsigned char *memBytes_per_chip, 
			  unsigned int num_bytes, unsigned int Bytes_per_dram_chip){

	unsigned char result_bit = 0x00, i = 0;
	int bit_position;	
	unsigned char blank;
	unsigned int byte_counter = 0, line_counter = 0;
	unsigned char *memory_1byte = (unsigned char *)calloc(1, sizeof(char)); //TEMPORARY MEMORY HOLDER FOR ONE BYTE

	ftell(fpointer_read);	//RETURN CURREUNT FILE POSITION (AT FOURTH LINE)

//	while (!feof(fpointer_read) && byte_counter < num_bytes){
	while (byte_counter < Bytes_per_dram_chip){

	//INITIALIZE TO ZERO
	memBytes_per_chip[byte_counter] = 0;

		//OPERATIONS PER ONE MEMORY BYTE
		for (bit_position = 7; bit_position >= 0; bit_position--){

			memory_1byte[i] = fgetc(fpointer_read);

			if (memory_1byte[i] == '1'){

				result_bit = 1;
			}
			else {
				result_bit = 0;
			}
			memBytes_per_chip[byte_counter] |= (result_bit << bit_position);

			i++;
		}
		//display 1byte memory block in decimal	//printf("%d ", *(memBytes_per_chip + block_counter));

		//REINITIALIZATION FOR NEXT MEMORY BLOCKS
		i = 0; blank = fgetc(fpointer_read);

		if (blank == '\n'){					//COUNT NUMBER OF LINES IN A FILE		
			line_counter++;
		}

		byte_counter++;
	}
	
	return 0;

}

unsigned char write_total_memory(FILE *fpointer_total_memory, unsigned char *memBytes_dram, unsigned char *linear_memBytes,
				 unsigned int num_bytes, unsigned char num_files, unsigned int Bytes_per_dram_chip){

	unsigned char file_counter;
	unsigned int byte_position, write_counter = 0, i = 0, j = 0;

	for (file_counter = 1; file_counter <= num_files; file_counter++){

		for (byte_position = 1; byte_position <= Bytes_per_dram_chip; byte_position++){

				linear_memBytes[j] = memBytes_dram[i + write_counter];
				j++;
				write_counter += num_bytes;	//MOVE TO NEXT CHIP FILE

				if (write_counter == (num_bytes * num_files)){	//AFTER ONE PIXEL, REINITIALIZE

					i++;
					write_counter = 0;

				}
		}

	}
	//fwrite(linear_memBytes, sizeof(char), NUM_BYTES_DRAM, fpointer_total_memory);
	return 0;

}

void main(int argc, char **argv)
{
	//DECLARATIONS FOR LINUX COMMAND-LINE PARSER
	extern char *optarg;
	extern int optind, optopt, opterr;
	int c, index;
	unsigned char num_files, chip_side, chip_num_digits, output_name[100];
	unsigned int num_bytes;

	while ((c = getopt (argc, argv, "s:f:b:o:i")) != -1){
		switch(c){
		case 's'://CHIP SIDE SELECT (FRONT=0 OR BACK=1)
			chip_side = strtoul(optarg,NULL,0);
			break;

		case 'f'://NUMBER OF FILES TO BE READ
			num_files = strtoul(optarg,NULL,0);
			break;

		case 'b'://NUMBER OF BYTES TO BE READ PER FILE
			num_bytes = strtoul(optarg,NULL,0);
			break;

		case 'o'://NAME OF AN OUTPUT FILE
			strcpy(output_name, optarg);
			break;

		case 'i'://NAME OF INPUT CHIP FILES
			break;

		case '?':
			fprintf(stderr, "Option -%c requires an argument.\n", optopt);
			break;
		}
	}

	if (chip_side == 0) //FRONT CHIP SIDE
		chip_num_digits = 2;
	else if (chip_side == 1) //BACK CHIP SIDE
		chip_num_digits = 3;

	//RESERVE MEMORY FOR PROCESSING IMAGE DATA
	unsigned int Bytes_per_dram_chip = NUM_BYTES_DRAM / num_files;	//245760
	unsigned int lines_per_dram_file = Bytes_per_dram_chip / NUM_BYTES_PER_LINE;
	unsigned int raw_bytes_per_chip = NUM_BYTES_RAW / num_files; //184320
	unsigned int num_lines_in_raw = raw_bytes_per_chip / NUM_BYTES_PER_LINE;

	unsigned char *memBytes_per_chip = (unsigned char *)calloc(Bytes_per_dram_chip, sizeof(char)); //MEMORY BYTES IN A SINGLE CHIP
	unsigned char *memBytes_dram = (unsigned char *)calloc(NUM_BYTES_DRAM, sizeof(char)); //TOTAL MEMORY BYTES IN DRAM (ENTIRE CHIPS)
	unsigned char *linear_memBytes = (unsigned char *)calloc(NUM_BYTES_DRAM, sizeof(char)); //TOTAL MEMORY BYTES IN DRAM IN LINEAR ORDER
	unsigned char *mem_output = (unsigned char *)calloc(NUM_BYTES_RAW, sizeof(char)); //OUTPUT RAW FILE

	//VARIABLES
	unsigned char file_name[40];
	unsigned char *file_dir = (unsigned char *)malloc(10);
	unsigned int local_counter, global_counter = 0, lcount = 0, temp, z = 1;

	index = optind;
	for (index = optind; index < argc; index++){
	//READ OPERATION BEGINS
		FILE *fpointer_read;

		sprintf(file_name, "%s", argv[index]);			//RETRIEVE A STRING OF FILE NAME
		//printf("%s\n", file_name);				//TEST: PRINT OUT STRING OF FILE NAME TO CHECK IF THE NAME IS CORRECT

		fpointer_read = fopen(file_name, "r");			//READ MULTIPLE MEMORY FILE CONTENTS

		if (fpointer_read == NULL){
			exit(0);
		}
		rewind(fpointer_read);

		skip_header(fpointer_read);
		read_memory(fpointer_read, memBytes_per_chip, num_bytes, Bytes_per_dram_chip);

		for (local_counter = 0; local_counter < Bytes_per_dram_chip; local_counter++){
	
			memBytes_dram[global_counter] = memBytes_per_chip[local_counter];
			global_counter++;
		}

		fclose(fpointer_read);
	}

	//RECOMBINATION OF ENTIRE MEMORY ACROSS DRAM CHIPS INTO A SINGLE RAW FILE. 
	FILE *fpointer_total_memory;
	
	fpointer_total_memory = fopen(output_name, "wb");
	if (fpointer_total_memory == NULL){
		exit(0);
	}

	//ORGANIZING AND WRITING MEMORY
	write_total_memory(fpointer_total_memory, memBytes_dram, linear_memBytes, num_bytes, num_files, Bytes_per_dram_chip);

	//UNPADDING OF ZEROS OCCURS
	unsigned int i = 0, j = 0;
	for (local_counter = 1; local_counter < NUM_BYTES_DRAM; local_counter++){

		if (local_counter % 4 != 0){
			
			mem_output[i] = linear_memBytes[local_counter];
			i++;
		}
	}
	fwrite(mem_output, sizeof(char), NUM_BYTES_RAW, fpointer_total_memory); //WRITE FULL-SIZED RAW FILE 

	fclose(fpointer_total_memory);

}
