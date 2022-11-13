# 65C02_BASIC

65C02 on DE2-115 with Enhanced Basic Interpreter. Built by Quartus Lite 21.1

This is a synchoronous 65C02 design. All FFs use the 50 MHz XTAL clock.

The 65C02 is based on Arlet Ottens's design with Jürgen Müller's modifications.

The ACIA is a simple UART adopted from Pong P. Chu's book.

EhBASIC's I/O routines, min_mon.s, are revised for this ACIA.

Future work: Add serial terminal hardware, e.g. https://github.com/AndresNavarro82/vt52-fpga

All strict synchoronous design suggestions are welcome.

![plot](completeSystem.png)

A complete computer system with keyboard, monitor, and BASIC interpreter.

This system does not need FreeRTOS, embedded linux, Raspberry Pi, laptop, tablet or similar advanced technologies. It is a minimalist design.

The VT100 box is PIC24MX microcontroller system purchased from eBay, functionally similar to vt52-fpga.

You can also use your laptop as a VT100 emulator (Use PuTTY or its variants), but without a laptop it looks more "organic".



