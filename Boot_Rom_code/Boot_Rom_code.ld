MEMORY
        {
        vectors : ORIGIN = 0x00000000, LENGTH = 0x0FF
	} 
SECTIONS
{
        .text :
        {
			bootloader.o	(startup)
        *(.text)
        } > vectors
}

