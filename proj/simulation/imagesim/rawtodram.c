#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define NUM_BYTES_RAW 1474560 		//1024*480*3 (LENGTH * WIDTH * (R,G,B))
#define NUM_BYTES_DRAM 1966080		//1024*480*4 (LENGTH * WIDTH * (0,R,G,B)) //0 AS DUMMY
#define NUM_BYTES_PER_LINE 8
#define BIT_SIZE 8

/***************************************************************************
*******	Author: Michael Lee
******* Date: AUG 9, 2011
******* Summary: RAW IMAGE DATA PROCESSOR ON DRAM 
*******		  
*******          
*******
****************************************************************************
****************************************************************************/

/*
@PROGRAM DESCRIPTION: 
	- READ .RAW (PANASONIC FORMAT) IMAGE FORMAT AND DISTRIBUTE DATA INTO DDR DIMM CHIPS (U1, U2, U3, U4, U6, U7, U8, U9)
	- WHEN DISTRIBUTING TO THESE CHIPS, U1 AND U6 FEEDS DUMMY DATA (I.E. 0) AND THE REST IS STORED IN LINEAR ORDER
	- AFTER DISTRIBUTING, THE PROGRAM COLLECTS ALL DATA FROM THESE CHIPS AND CREATE OUTPUT; WHICH IS EXACT REPLICA OF THE INPUT 

	NOTE: 
	 - WHEN DISTRIBUTING THE ORIGINAL RAW DATA INTO DDR DIMM, THE DATA SIZE EXPANDS: (R,G,B) -> (0,R,G,B) 
	 - THE METHOD TO DISTRIBUTE RAW DATA INTO #CHIP FILES IS SAME AS DRAM LINEAR MAPPING PROGRAM. 
*/

//READ RAW IMAGE AND LOAD ITS DATA
void read_raw(FILE *fptr_raw, unsigned char *RAW_ptr, int *g){

	unsigned int global = 0;

	while (!feof(fptr_raw)){

		RAW_ptr[global] = fgetc(fptr_raw);

		global++;
	}	
	global--;

	// printf("%d ", counter);

	/*	TESTER: PRINT ALL RAW IMAGE BITS (PUT IN WHILE LOOP TO TEST)
		printf("%d ", RAW_ptr[global_counter]);

		if (global_counter > 0 && global_counter % 8 == 0)
			printf("\n");
	*/

	//printf("%d\n", global);
	*g = global; 

}

//EXPAND RAW DATA (R,G,B) INTO SIZE OF DRAM CHIP MODULES (0,R,G,B)
void write_to_dram(unsigned char *RAW_ptr, unsigned char *RAW_organized_ptr, unsigned char num_chips, 
		   unsigned int DRAM_BYTES_PER_NUM_CHIPS, unsigned int *g){

	unsigned int byte_counter = 0, temp = 0, i, global_counter = 0;

	for (i = 0; i < num_chips; i++){

		while (byte_counter < DRAM_BYTES_PER_NUM_CHIPS){ //1024*480*4 / #chip

			//Zero-padding for modelsim (U1 and U6 fills with zeros)	
			if (byte_counter % 4 == 0){

				RAW_organized_ptr[i*DRAM_BYTES_PER_NUM_CHIPS + byte_counter] = 0;
			}

			//Original Data distributed across the rest of chips
			else{
				RAW_organized_ptr[i*DRAM_BYTES_PER_NUM_CHIPS + byte_counter] = RAW_ptr[temp];
				temp++;
			}

		byte_counter++;
		global_counter++;
		}

	byte_counter = 0;
	}

	*g = global_counter;

}

//SORTING MEMORY BYTES
void sort_raw(FILE *fptr_raw, unsigned char *RAW_organized_ptr, unsigned char *DRAM_chip_ptr, unsigned int global_counter, 
	      unsigned char num_chips, unsigned int RAW_BYTES_PER_NUM_CHIPS){

	unsigned int i = 0, j = 0, byte_position = 0, write_counter = 0;

	for (byte_position = 0; byte_position < global_counter; byte_position++){

		DRAM_chip_ptr[i] = RAW_organized_ptr[j + write_counter];

		i++;	

		write_counter += num_chips;
		if (write_counter == NUM_BYTES_DRAM){ //== 245760

			j++;
			write_counter = 0;
		}

	}

}

int main(int argc, char **argv)
{
	//DECLARATIONS FOR LINUX COMMAND-LINE PARSER
	extern char *optarg;
	extern int optind, optopt, opterr;
	int c, index;
	unsigned char raw_input[100], num_chips, chip_side, chip_num_digits;

	while ((c = getopt (argc, argv, "i:s:n:o")) != -1){
		switch(c){
		case 'i'://SINGLE INPUT RAW FILE NAME
			strcpy(raw_input, optarg);
			break;

		case 's'://CHIP SIDE SELECT (FRONT=0 OR BACK=1)
			chip_side = strtoul(optarg,NULL,0);
			break;

		case 'n'://NUMBER OF CHIP FILES ON DRAM
			num_chips = strtoul(optarg,NULL,0);
			break;

		case 'o'://OUTPUT DRAM FILES ACROSS #CHIPS
			break;

		case '?':
			fprintf(stderr, "Option -%c requires an argument.\n", optopt);
			break;
		}
	}

	index = optind;

	if (chip_side == 0) //FRONT SIDE OF DRAM
		chip_num_digits = 2;
	else if (chip_side == 1) //BACK SIDE OF DRAM
		chip_num_digits = 3;

	//RESERVE MEMORY FOR PROCESSING RAW IMAGE FILE
	unsigned char *RAW_ptr = (unsigned char *)calloc(NUM_BYTES_RAW, sizeof(char)); //SIZE = 1024*480*3/#chip, USED FOR READING RAW
	unsigned char *RAW_organized_ptr = (unsigned char *)calloc(NUM_BYTES_DRAM, sizeof(char)); //SIZE = 1024*480*4/#chip, LINEARLY SORTED
	unsigned char *DRAM_chip_ptr = (unsigned char *)calloc(NUM_BYTES_DRAM, sizeof(char)); //SIZE = 1024*480*4/#chip, USED FOR CHIP DISTRIBUTION

	unsigned int DRAM_BYTES_PER_NUM_CHIPS = NUM_BYTES_DRAM / num_chips;
	unsigned int RAW_BYTES_PER_NUM_CHIPS = NUM_BYTES_RAW / num_chips;

	//VARIABLES
	unsigned char chip_name[10], raw_name[10]; 
	unsigned char *file_dir = (unsigned char *)malloc(10);
	unsigned int global_counter, local_counter = 0, raw_counter = 0, file_counter = 0, i;

	//READING RAW IMAGE	
	FILE *fptr_raw = fopen(raw_input, "rb");
	if (fptr_raw == NULL){
		exit(0);	
	}
	rewind(fptr_raw);

	read_raw(fptr_raw, RAW_ptr, &global_counter);
	raw_counter = global_counter;

	fclose(fptr_raw);
	//DONE READING RAW	

	//EXPAND RAW DATA (R,G,B) INTO SIZE OF DRAM CHIP MODULES (0,R,G,B)
	write_to_dram(RAW_ptr, RAW_organized_ptr, num_chips, DRAM_BYTES_PER_NUM_CHIPS, &global_counter);

	//SORT RAW IMAGE FOR MODELSIM MEMLOAD
	sort_raw(fptr_raw, RAW_organized_ptr, DRAM_chip_ptr, global_counter, num_chips, RAW_BYTES_PER_NUM_CHIPS);
	file_counter = 0;

	//DISTRIBUTE SORTED RAW DATA INTO DRAM ACROSS #CHIPS
	for (i = index; i < argc; i++){

		FILE *fpointer_modelsim;
		strncpy(file_dir, argv[i], chip_num_digits);
		
		sprintf(chip_name, "%s.binl", file_dir);	
		fpointer_modelsim = fopen(chip_name, "w");
		if (fpointer_modelsim == NULL){
			exit(0);
		}
		rewind(fpointer_modelsim); //REWIND FILE POSITION TO THE ORIGIN

		//USE DRAM LINEAR MEMORY DISTRIBUTOR FUNCTION TO CHANGE BINARY DATA TO READABLE BINARY TEXT FILE.
		//FORMAT MUST BE TEXT FILE SO THAT MODELSIM CAN LOAD MEMORY.

		//BEGIN: WRITE A THREE LINES OF HEADER INFORMATION (REQUIRED FOR USE OF MODELSIM TCL COMMANDS)
		fprintf(fpointer_modelsim, "// memory data file (do not edit the following line - required for mem load use)\n");
		fprintf(fpointer_modelsim, "// instance=/system_tb/dram/%s/mem_array\n", file_dir);
		fprintf(fpointer_modelsim, "// format=bin addressradix=h dataradix=b version=1.0 wordsperline=8 noaddress\n"); 
		//END WRITING HEADER INFO

		ftell(fpointer_modelsim);

		unsigned int byte_position, line_position, bit_position, memory_byte_holder[BIT_SIZE]; 
		unsigned int i = 0, temp;

		for (line_position = 1; line_position <= (DRAM_BYTES_PER_NUM_CHIPS / NUM_BYTES_PER_LINE); line_position++){
		
			for (byte_position = 1; byte_position <= NUM_BYTES_PER_LINE; byte_position++){

				for (bit_position = 0; bit_position < BIT_SIZE; bit_position++){
		
					temp = pow(2, BIT_SIZE - bit_position - 1);
					memory_byte_holder[bit_position] = DRAM_chip_ptr[local_counter] / temp;
					fprintf(fpointer_modelsim, "%d", memory_byte_holder[bit_position]);
		
					DRAM_chip_ptr[local_counter] = DRAM_chip_ptr[local_counter] % temp;
					
				}						
				fprintf(fpointer_modelsim, " ");
				bit_position++;
				local_counter++;
			}
			fprintf(fpointer_modelsim, "\n");
		}


	fclose(fpointer_modelsim);
	}
	return 0;

}


