; Online assembler
; https://www.masswerk.at/6502/assembler.html

; Simple test program

	.ORG $8000
	NOP
	LDY #$00
L8003:	INY
	NOP
	JMP L8003

; RESET VECTOR
	.ORG $FFFC
	.BYTE $00 $80

	.END