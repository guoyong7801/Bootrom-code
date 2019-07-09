MEMORY
        {
        vectors : ORIGIN = 0x00000000, LENGTH = 0x0FF
/*        ram     : ORIGIN = 0xE0, LENGTH =0x1F  */ }
 
SECTIONS
{

/*        .vectors :
        {
        *(.vectors)
        } > vectors
        startup :
        {
			bootloader.o	(startup)
        *(startup)
        } > vectors
*/

        .text :
        {
			bootloader.o	(startup)
        *(.text)
        } > vectors
/*
        .data :
        {
        *(.data)
        } > ram

        .rodata :
        {
        *(.rodata)
        } > ram

        .rodata.str1.1 :
        {
        *(.rodata)
        } > ram

		. = ALIGN(4);
		__bss_start = .;
        .bss :
        {
        *(.bss)
        } > ram
		__bss_end = .;

        .stack :
        {
        *(.stack)
        _src_addr = .;
        } > ram
	*/
}

