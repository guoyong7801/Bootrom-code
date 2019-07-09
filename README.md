# Bootrom-code
Hardware Strap bootrom code for F0-F1 and Zynq-F1.
Select the board from bootloader.s file.

Example:
  .equ zynq_f1, 0       //For Zynq-F1 make it One 
  
  or make this flag as zero for F0-F1.

Default code compiles for F0-F1.
For making image please modify two env variables (CROSS_COMPILE and GCC_LIB) according to your toolchain.
Example:
  1. CROSS_COMPILE = /elx/sandbox/pilot_fw/pilot/vnigade/test/memcpytest/standalone_memtest_app/x-tool-linux-4-9-armv7a-472-hf/bin/arm-aspeed-linux-gnueabi-
  2. GCC_LIB = /elx/sandbox/pilot_fw/pilot/vnigade/test/memcpytest/standalone_memtest_app/x-tool-linux-4-9-armv7a-472-hf/lib/gcc/arm-aspeed-linux-gnueabi/4.7.2
  
then do make (:
