*
*
* shift left
*
SHleft1
				LDX	YTO
lpY			DEX
				LDA 	YLOOKHI,X			; get line base adress HI-byte
        ORA 	#$20					; HIRES page #1
        STA	fr1+2
        STA	fr2+2
        STA	fr3+2
        STA	fr4+2

				AND	#%11011111
        ORA 	#$40					; HIRES page #2
        STA	to1+2
        STA	to2+2
          	
				LDA 	YLOOKLO,X			; get line base adress LO-byte
				STA	fr1+1
        STA	fr3+1
        STA	fr4+1
        STA	to1+1
        STA	to2+1
        INC							; special treatment -> avoid DEY/INY opcodes
        STA	fr2+1

cc1			LDY	#38
				STX	Temp					; save X-reg
lpX
fr1			LDX	$2000,Y			; get the first byte of the new line
				LDA	TAB1,X			; get LUT value from TAB1
fr2			LDX	$2000,Y			; get byte + 1
				ORA	TAB2,X			; ORA with LUT value from TAB2
to1			STA	$2000,Y
		
				DEY
				BPL	lpX

fr3			LDX	$2000				; special treatment last byte for wrap-around effect!
				LDA	TAB2,X
				LDY	#39
fr4			LDX	$2000,Y
				ORA	TAB1,X
to2			STA	$2000,Y		
					
				LDX	Temp					; retrieve X-reg
				CPX	YFROM
				BNE	lpY					; do for 192 lines -> if X=0 we are done!
				RTS


* setup lookup-tables for fast shift
* table 1: 2 x LSR of a byte

				LDX	#0
lpLUT1	TXA
				LSR
				LSR
				STA	TAB1,X
				INX
				BNE	lpLUT1
						
* table 2: 4 x ROR & AND #%01100000 of a byte
* making the OR-mask for the shifted two bits

				LDX	#0
lpLUT2	TXA
				ROR							; shift them in order to fit in the former byte
				ROR
				ROR
				ROR
				AND	#%01111000			; get only the first two bits
				STA	TAB2,X
				INX
				BNE	lpLUT2
						
