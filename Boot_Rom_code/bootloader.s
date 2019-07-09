@@*******************************************************************************
@
@  MM2BootCode.arm - 128 byte bootstrap for F0-F1 and Zynq-F1            [implementation]
@
@  Copyright ©2019, AspeedTech India Pvt ltd.  All rights reserved.
@
@  REGISTER USAGE:
@     r0    - ReadBuffer start address inside routine
@     r1    - ReadBuffer length inside routine
@     r2    - inter-character timeout value
@     r3    - ReadBuffer most recent LSR value
@     r4    - ReadBuffer most recent byte read from the serial port
@     r5    - ReadBuffer current timeout value
@     r6    - available
@     r7    - available
@     r8    - available
@     r9    - available
@     r10   - temporary variable
@     r11   - temporary variable 
@     r12   - UART base address for serial port being used
@     r13   - available  
@     r14   - link register, contains the return address (lr)
@     r15   - program counter, contains the address being executed - 8 (pc)
@
@ NOTE: The UART base *should* be the only load that requires two instructions.
@
@*******************************************************************************


	.equ zynq_f1, 0
	.equ  DEBUG, 0
	.equ DivisorValue, 1
	.equ PromptTimeout, 0x7000             
	@ Time to wait before reissuing prompt character
.if zynq_f1
	.equ PromptChar, '#'
	.equ SCRATCHPAD_BASE,	0x5E720000
	.equ DBGUART_BASE,	0x5E784000
.else
	.equ PromptChar, '$'
	.equ SCRATCHPAD_BASE,	0x1E720000
	.equ DBGUART_BASE,	0x1E784000
	.equ ICACHE_EN,		1
.endif
	
	
	.equ FCROff,		0x08	//2
	.equ LCROff,		0x0C	//3
	.equ LSROff,		0x14	//5
	.equ DLLOff,		0x00
	.equ THROff,		0x00
	.equ RBROff,		0x00

	.equ DataRDY,		0x1
	.equ FIFOEN,		0x1
	.equ RXFRST,		(1<<1)
	.equ TXFRST,		(1<<2)
	.equ WordLength8,	0x3
	.equ DLAB,		(1<<7)
	.equ FCRVALUE,		(FIFOEN|RXFRST|TXFRST)				@ TURN ON fifo
	.equ UART_DLAB_8N1,	(DLAB|WordLength8)				@ TURN ON DIVISOR LATCH
	.equ UART_TXRX_8N1,	WordLength8					@ 8N1 with divisor latch (DLAB) disabled

Entry:
	@; ----------------------------------------
	@; Put Core1 in sleep right away
	@; ----------------------------------------
	mrc     p15, 0, r0, c0, c0, 5                          @; Read CPU ID register
	ands    r0, r0, #0x03                                  @; Mask off, leaving the CPU ID field
	beq     CORE0_EXEC
	b       CORE01_EXE

CORE0_EXEC:

@ Set constant values: inter-character timeout value (r2) and UART base (r12)
	ldr         r12, =DBGUART_BASE                             @ r12 = base address for the serial port **2 INSTRUCTION SLOTS**
	MOV	       r2, #PromptTimeout                           @ r2 = inter-character timeout value


	@ Enable the FIFO
	MOV	      r11, #FCRVALUE		                           @ Load the FIFO control value for ON, Tx/Rx
	STRB	      r11, [r12, #FCROff]		                     @ Update the UART FCR



@Set the baud rate (divisor)
	MOV         r11, #DivisorValue                           @ Load the divisor for 115200bps
	MOV         r10, #UART_DLAB_8N1                          @ Select the divisor register, no BREAK, no parity, 1 STOP bit and 8 bits per byte
	STRB        r10, [r12, #LCROff]                 @    Enable the divisor latch


	STRB        r11, [r12, #DLLOff]             @    Set the divisor offset for the UART

	MOV         r10, #UART_TXRX_8N1                          @ Select Tx/Rx/IER, no BREAK, no parity, 1 STOP bit and 8 bits per byte
	STRB        r10, [r12, #LCROff]                 @    Disable divisor latch

.if ICACHE_EN
	MRC     p15, 0, r10, c1, c0, 0       @; Read CP15 System Control register
	ORR     r10, r10, #(0x1 << 12)        @; Clear I, bit 12, to disable I Cache
	MCR     p15, 0, r10, c1, c0, 0       @; Read CP15 System Control register
.endif

LoadBootstrap:   
	@ Send the prompt character
	LDR	      r11,=PromptChar                             @ Load the prompt character
	STRB	      r11, [r12,#THROff]		                     @ Send the prompt character to the UART


	@ Retrieve the length of the bootstrap (4 bytes) into first DWORD of 24K internal RAM
	mov         r1, #4                                       @ r1 = # bytes needed
	LDR         r0,=SCRATCHPAD_BASE                         @ r0 = first DWORD of scratchpad (should be 0x4000000)
	BL          ReadBuffer                                   @ Read 4 bytes into the scratchpad base
	SUBS        r0, r0, #4                                   @ r0 points to the end of the buffer.  Move it back to the beginning.
	LDR         r1, [r0]                                     @ r1 = length read in.  r0 = scratchpad address
.if DEBUG
	LDR	      r11,='y'						@ Load the prompt character
	STRB	      r11, [r12,#THROff]		                     @ Send the prompt character to the UART
.endif
	@ Retrieve the bootstrap
	BL          ReadBuffer                                   @ Load the bootstrap program

StartBootstrap:
	LDR      r15,=SCRATCHPAD_BASE                           @ Begin execution of the bootstrap

	@-------------------------------------------------------------------------------
	@
	@ ReadBuffer - reads a buffer from the UART.  Jumps to LoadBootstrap on timeout
	@
	@  Parameters:
	@     r0 - start address for the buffer
	@     r1 - length of the buffer
	@     r2 - timeout value
	@
	@  Returns:
	@     r0 - points to one past the end of the buffer
	@     r1 - 0
	@
	@  Alters:
	@     r3 - most recent LSR value
	@     r4 - most recent byte read from the serial port
	@     r5 - current timeout value
	@
	@  NOTE: Timeout value measures delay between bytes received.  
	@
	@-------------------------------------------------------------------------------

ReadBuffer:	
	MOV         r5, r2                                       @ Copy the timeout value
	MOV         r8,r12
WaitForNextUARTByte:
	SUBS        r5, r5, #1                                   @ Decrement the timeout value.  Out of time?
	BEQ         LoadBootstrap                                @    Yes: Go back to the prompt

sts_wait:		           
	LDR         r3, [r8, #LSROff]                           @ Load the line status register (LSR)
	TST         r3, #DataRDY                           @ Is the next byte ready?
	BEQ         WaitForNextUARTByte			   @    No: Continue waiting
read_data:
	MOV         r5, r2                                       @ Copy the timeout value
	LDRB        r4, [r8, #RBROff]                           @ Get the byte from the serial receiving register
	STRB        r4, [r0], #1                                 @ Store into the next location of the buffer
	//STRB	    r4, [r12,#THROff]		                     @ Send the prompt character to the UART
	SUBS        r1, r1, #1                                   @ Decrement the number of bytes remaining in the bootstrap.  Do bytes remain?
	BNE         sts_wait
	MOV         r15, r14                                     @    No: Return to caller

ChkForScndUART:
	mov	    r8,r12
	B           WaitForNextUARTByte

CORE01_EXE:
	WFE
	B   CORE01_EXE


