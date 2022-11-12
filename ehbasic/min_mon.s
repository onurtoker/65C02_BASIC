; minimal monitor for EhBASIC and 6502 simulator V1.05
; tabs converted to space, tabwidth=6

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

      .include "basic.s"

; put the IRQ and MNI code in RAM so that it can be changed

IRQ_vec     = VEC_SV+2        ; IRQ code vector
NMI_vec     = IRQ_vec+$0A     ; NMI code vector

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

      .segment "CODE"         ; pretend this is in a 1/8K ROM

; reset vector points here

RES_vec
      CLD                     ; clear decimal mode
      LDX   #$FF              ; empty stack
      TXS                     ; set the stack
      JSR ACIAsetup

; set up vectors and interrupt code, copy them to page 2

      LDY   #END_CODE-LAB_vec ; set index/count
LAB_stlp
      LDA   LAB_vec-1,Y       ; get byte from interrupt code
      STA   VEC_IN-1,Y        ; save to RAM
      DEY                     ; decrement index/count
      BNE   LAB_stlp          ; loop if more to do

; now do the signon message, Y = $00 here

LAB_signon
      LDA   LAB_mess,Y        ; get byte from sign on message
      BEQ   LAB_nokey         ; exit loop if done

      JSR   V_OUTP            ; output character
      INY                     ; increment index
      BNE   LAB_signon        ; loop, branch always

LAB_nokey
      JSR   V_INPT            ; call scan input device
      BCC   LAB_nokey         ; loop if no key

      AND   #$DF              ; mask xx0x xxxx, ensure upper case
      CMP   #'W'              ; compare with [W]arm start
      BEQ   LAB_dowarm        ; branch if [W]arm start

      CMP   #'C'              ; compare with [C]old start
      BNE   RES_vec           ; loop if not [C]old start

      JMP   LAB_COLD          ; do EhBASIC cold start

LAB_dowarm
      JMP   LAB_WARM          ; do EhBASIC warm start

; Polled 65c51 I/O routines adapted to EhBASIC. Delay routine from
; http://forum.6502.org/viewtopic.php?f=4&t=2543&start=30#p29795
ACIA_RX      = $8400
ACIA_TX      = $8400
ACIA_STATUS  = $8401

ACIAsetup
      RTS					  ; ACIA is preconfigured in Verilog

ACIAout
      PHA
WAIT_ACIA_TX:
      LDA ACIA_STATUS         ; get ACIA status
      AND #$02                ; mask tx buffer status flag
      BEQ WAIT_ACIA_TX
      PLA
      STA ACIA_TX             ; write byte
      RTS 

ACIAin
      LDA ACIA_STATUS         ; get ACIA status
      AND #$01                ; mask rx buffer status flag
      BEQ LAB_nobyw           ; branch if no byte waiting
      LDA ACIA_RX             ; get byte from ACIA data port
      SEC
      RTS

;      ; begin: is valid 
;
;      CMP #00			      ; reject if MSB is 1 
;      BMI LAB_reject
;
;      CMP #00
;      BEQ LAB_accept		; accept 0x00, i.e. NUL
;      CMP #08
;      BEQ LAB_accept		; accept 0x08, i.e. BACKSPACE
;      CMP #10
;      BEQ LAB_accept		; accept 0x0A, i.e. LF
;      CMP #13
;      BEQ LAB_accept		; accept 0x0D, i.e. CR
;
;      CMP #32
;      BMI LAB_reject		; reject is less than 0x20
;
;      CMP #$7F
;      BEQ LAB_reject		; reject 0x7f, i.e. DEL
;      
;      JMP LAB_accept		; accept
;      ; end: is valid

LAB_nobyw
      CLC                     ; flag no byte received
no_load                       ; empty load vector for EhBASIC
no_save                       ; empty save vector for EhBASIC
      RTS

;LAB_accept_acia
;      SEC                     ; flag byte received
;      RTS

;LAB_reject_acia
;      LDA #63
;      SEC		                  ; remap to ?
;      RTS

; vector tables

LAB_vec
      .word ACIAin            ; byte in from simulated ACIA
      .word ACIAout           ; byte out to simulated ACIA
      .word no_load           ; null load vector for EhBASIC
      .word no_save           ; null save vector for EhBASIC

; EhBASIC IRQ support 

IRQ_CODE
      PHA                     ; save A
      LDA   IrqBase           ; get the IRQ flag byte
      LSR                     ; shift the set b7 to b6, and on down ...
      ORA   IrqBase           ; OR the original back in
      STA   IrqBase           ; save the new IRQ flag byte
      PLA                     ; restore A
      RTI

; EhBASIC NMI support

NMI_CODE
      PHA                     ; save A
      LDA   NmiBase           ; get the NMI flag byte
      LSR                     ; shift the set b7 to b6, and on down ...
      ORA   NmiBase           ; OR the original back in
      STA   NmiBase           ; save the new NMI flag byte
      PLA                     ; restore A
      RTI

END_CODE

LAB_mess
      .byte $0D,$0A,"6502 EhBASIC [C]old/[W]arm ?",$00
                              ; sign on string

; system vectors

      .segment "VECTORS"

      .word NMI_vec           ; NMI vector
      .word RES_vec           ; RESET vector
      .word IRQ_vec           ; IRQ vector

      .end RES_vec            ; set start at reset vector
      
