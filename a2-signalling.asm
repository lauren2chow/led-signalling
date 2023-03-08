; a2-signalling.asm
; University of Victoria
; CSC 230: Spring 2023
; Instructor: Ahmad Abdullah
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2 
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************


	.def counter=r17 ;counter for set_leds
	.def portl_bin=r18 ;leds 4-6
	.def portb_bin=r19 ;leds 1-2
	.def onled=r16
	.def count=r21 ;counter for encode_letter


; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_e
	; Test code


test_part_a:
	ldi r16, 0b00100001 
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

set_leds:
	sts DDRL, r16
	out DDRB, r16

	ldi counter,0
	ldi portl_bin, 0b00000000
	ldi portb_bin, 0b00000000


loop: 
	;shifts number to the right and checks to see if 
	;the led of the corresponding bit should be turned on
	clc
	inc counter
	lsr r16
	brcs set_bit
	cpi counter,6
	breq done
	rjmp loop

set_bit:
	cpi counter, 1
	breq set__led6

	cpi counter, 2
	breq set__led5

	cpi counter, 3
	breq set__led4

	cpi counter, 4
	breq set__led3

	cpi counter, 5
	breq set__led2

	cpi counter, 6
	breq set__led1
	

set__led1:
	ldi r20, 0b00000010
	add portb_bin,r20
	rjmp done

set__led2:
	ldi r20, 0b00001000
	add portb_bin,r20
	rjmp loop

set__led3:
	ldi r20, 0b00000010
	add portl_bin,r20
	rjmp loop
set__led4:
	ldi r20, 0b00001000
	add portl_bin,r20
	rjmp loop
set__led5:
	ldi r20, 0b00100000
	add portl_bin,r20
	rjmp loop
set__led6:
	ldi r20, 0b10000000
	add portl_bin,r20
	rjmp loop

done: 
	sts PORTL, portl_bin
	out PORTB, portb_bin
	ret


slow_leds:
	mov r16, r17
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	ret


fast_leds:
	mov r16, r17
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	ret


leds_with_speed:
	in YL, SPL
	in YH, SPH

	ldd r17, Y+4
	mov r18, r17

	lsl r18
	brcs led_slow
	rcall fast_leds
	rjmp exit
led_slow:
	rcall slow_leds

exit:
 ret


; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:
	ldi r25,0x00
	ldi onled, 0x6F
	ldi ZH, High(PATTERNS<<1)
	ldi ZL, Low(PATTERNS<<1)

	ldi count,0
	
	in YL, SPL
	in YH, SPH

	ldd r17, Y+4

Pattern_loop:
	lpm r15, Z+
	cp r17,r15
	breq found
	lpm r15, Z+
	lpm r15, Z+
	lpm r15, Z+
	lpm r15, Z+
	lpm r15, Z+
	lpm r15, Z+
	lpm r15, Z+
	rjmp Pattern_loop

found:
	inc count
	lpm r15, Z+
	cpi count,7
	breq speed
	cp r15, r16
	breq led_on
	rjmp found
	
	

led_on:
	cpi count, 1
	breq set__led1a

	cpi count, 2
	breq set__led2a

	cpi count, 3
	breq set__led3a

	cpi count, 4
	breq set__led4a

	cpi count, 5
	breq set__led5a

	cpi count, 6
	breq set__led6a
	

set__led1a:
	ldi r20, 0b00100000
	add r25,r20
	rjmp found

set__led2a:
	ldi r20, 0b00010000
	add r25,r20
	rjmp found

set__led3a:
	ldi r20, 0b00001000
	add r25,r20
	rjmp found
set__led4a:
	ldi r20, 0b00000100
	add r25,r20
	rjmp found
set__led5a:
	ldi r20, 0b00000010
	add r25,r20
	rjmp found
set__led6a:
	ldi r20, 0b00000001
	add r25,r20
	rjmp found

speed:
	ldi r16,0x02
	cp r15,r16
	breq finish
	ldi r20,0b11000000
	add r25,r20

finish:
	ret


display_message:
	mov r4, r25
	mov r5, r24
	
word_iterate:
	ldi r22, 0x00
	mov ZH, r4
	mov ZL, r5
	lpm r26, Z+
	mov r4, ZH
	mov r5, ZL
	cp r26,r16
	breq freedom
	push r26
	rcall encode_letter
	push r25
	rcall leds_with_speed
	pop r25
	pop r26
	rcall delay_short
	rjmp word_iterate

freedom:
	ret


; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
;.cseg
;.org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "W", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

