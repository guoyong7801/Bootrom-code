S_OBJS    = $(patsubst %.s,%.o,$(wildcard *.s))
C_OBJS    = $(patsubst %.c,%.o,$(wildcard *.c))
ASM_OBJS    = $(patsubst %.S,%.o,$(wildcard *.S))
build_obj = $(C_OBJS) $(S_OBJS) $(ASM_OBJS)
#CROSS_COMPILE = /opt/pilot3/cleanedup_kernel/Pilot3Hornet/u-boot-2010.03/../../crosstools/arm-unknown-linux-gnu/bin/arm-unknown-linux-gnu-
CROSS_COMPILE=/elx/sandbox/pilot_fw/pilot/vnigade/test/memcpytest/standalone_memtest_app/x-tool-linux-4-9-armv7a-472-hf/bin/arm-aspeed-linux-gnueabi-
#CROSS_COMPILE=/elx/sandbox/pilot_fw/pilot/vnigade/arm-cortex_a7-linux-gnueabihf-linaro_4.9-master/bin/arm-eabi-
#export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
#CROSS_COMPILE=/elx/sandbox/pilot_fw/pilot/vnigade/x-tool/bin/arm-aspeed-eabi-
#export PATH:=/elx/sandbox/pilot_fw/akshay/ARMSMP/ctools/bin/:$(PATH)
CC        = $(CROSS_COMPILE)gcc
AS        = $(CROSS_COMPILE)as
LD        = $(CROSS_COMPILE)ld
AR        = $(CROSS_COMPILE)ar
LIST      = $(CROSS_COMPILE)objdump
OBJCOPY   = $(CROSS_COMPILE)objcopy
ARM_IS    = armv7-a
INCLUDE = include/
CFLAGS += -D__ASSEMBLY__
#ASFLAGS += -mfpu=softfpa
ASFLAGS += -mfpu=vfpv4-d16
#GCCLIB=/elx/sandbox/pilot_fw/akshay/ARMSMP/ctools/lib/gcc/arm-xilinx-linux-gnueabi/4.6.1/
#GCCLIB=/elx/sandbox/pilot_fw/pilot/vnigade/x-tool-3.14.35/lib/gcc/arm-emulex-linux-gnueabi/4.7.2
#GCCLIB=/elx/sandbox/pilot_fw/pilot/vnigade/x-tool/lib/gcc/arm-aspeed-eabi/4.7.2
GCCLIB=/elx/sandbox/pilot_fw/pilot/vnigade/test/memcpytest/standalone_memtest_app/x-tool-linux-4-9-armv7a-472-hf/lib/gcc/arm-aspeed-linux-gnueabi/4.7.2
#GCCLIB=/opt/pilot3/cleanedup_kernel/Pilot3Hornet/u-boot-2010.03/../../crosstools/arm-unknown-linux-gnu/lib/gcc/arm-unknown-linux-gnu/4.3.2/
#GCCLIB=/elx/sandbox/pilot_fw/pilot/vnigade/arm-cortex_a7-linux-gnueabihf-linaro_4.9-master/lib/gcc/arm-cortex_a7-linux-gnueabihf/4.9.4
LDLIB=--library-path=$(GCCLIB) --library=gcc
ELF=$(notdir $(shell pwd))
LDOPT     = -T $(ELF).ld -Map $(ELF).map
CCOPT = -I $(INCLUDE) -g  -Os -fno-common -ffixed-r8 -mfloat-abi=hard -mfpu=vfpv4-d16 -gdwarf-2 -D__KERNEL__ -fno-builtin -ffreestanding -nostdinc -isystem -pipe  -DCONFIG_ARM -D__ARM__ -marm  -mabi=aapcs-linux -mno-thumb-interwork -mcpu=cortex-a7 -Wall -Wstrict-prototypes -fno-stack-protector $(CFLAGS)

#CCOPT = -I $(INCLUDE) -g  -Os -fno-common -ffixed-r8 -msoft-float  -gdwarf-2 -D__KERNEL__ -fno-builtin -ffreestanding -nostdinc -isystem -pipe  -DCONFIG_ARM -D__ARM__ -marm  -mabi=aapcs-linux -mno-thumb-interwork -march=$(ARM_IS) -Wall -Wstrict-prototypes -fno-stack-protector $(CFLAGS)
ASOPT     = -I $(INCLUDE) -march=$(ARM_IS) $(ASFLAGS)

#arm-unknown-linux-gnu-objcopy --gap-fill=0xff -O binary standalone_test_usb standalone_test_usb.bin

export  ASFLAGS CFLAGS

all:clean message $(ELF) $(ELF).bin $(ELF).D

message:
	echo "Building $(ELF) image"
	echo $(build_obj)

%.o: %.c
	$(CC) $(CCOPT) -c $< -o $@

%.o: %.S
	$(CC) $(CCOPT) -c $< -o $@

%.o: %.s
	$(AS) $(ASOPT) $< -o $@
	
$(ELF): $(build_obj)
	echo "ELF=" $(ELF)
	echo $(LDOPT)
	$(LD) $(LDOPT) $(build_obj) -o $@ $(LDLIB)

$(ELF).bin: $(ELF)
	$(OBJCOPY) --gap-fill=0xff -O binary $< $@

$(ELF).D: $(ELF)
	$(LIST) -D $< > $@

clean:
	rm -f *.o $(ELF) $(ELF).bin $(ELF).D $(ELF).map


