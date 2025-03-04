.model small
.stack 100h

.data
    seed_low DW ?       ; lower part of the 32-bit seed
    seed_high DW ?      ; higher part of the 32-bit seed
    bitsPrinted DB 0    ; counter for the bits printed

.code
main PROC
    mov ax, @data
    mov ds, ax

    ; we XOR the values from the BIOS area and create the initial seed
    mov ax, [0040h:0010h] ; 16 bits of Equipment List
    mov dx, [0040h:0018h] ; 16 bits of Keyboard Extended Shift Status
    xor ax, dx
    mov seed_low, ax
    mov seed_high, ax


    ; we call LFSR procedure 100 times to generate 100 bits
    mov cx, 100
generate_bits:
    call LFSR
    loop generate_bits      

    mov ax, 4C00h
    int 21h
main ENDP

LFSR PROC
	push cx				; save the CX register as it will be used also below
    ; we load the current seed - 32bit composed of two 16bit registers
    mov ax, seed_low
    mov dx, seed_high

    ; calculate feedback bit using polynomial x^32 + x^22 + x^2 + x^1 + 1
    ; feedback bit is the XOR of bit positions 31, 21, 1, 0 of the full 32-bit value
    xor bx, bx             ; clear bx for feedback result
    mov cx, ax             ; copy low seed to cx for manipulation
    and cx, 1              ; isolate bit 0
    xor bx, cx             ; XOR into feedback result in bx
    shr ax, 1              ; shift right to get bit 1
    and ax, 1
    xor bx, ax
    mov ax, seed_high      ; get high part again
    mov cl, 5
	shr ax, cl              ; position 21 in dx becomes 5 in ax after 16bit shift
	mov cx, ax
    and cx, 1
    xor bx, cx
	mov cl, 10
    shr ax, cl             ; get bit 31 (bit 11 in high part after shift)
    and ax, 1
    xor bx, ax             ; final feedback result in bx

    ; shift 32bit seed right by 1
    rcr seed_low, 1          
    rcr seed_high, 1
    mov cl, 15
	shl bx, cl             ; move feedback result to the MSB of low part of seed
	mov cx, seed_high
	shr cx, cl
	shl cx, cl
    or seed_low, cx            ; update low part seed with new feedback bit
	or seed_high, bx

	
	pop cx

    ; print the LSB of seed as a bit on the screen
    mov ah, 2              ; function to set cursor position
    mov dh, 24              ; last row
    mov dl, bitsPrinted    ; column based on bitsPrinted
    mov bh, 0              ; page number
    int 10h                ; BIOS video interrupt

    mov ah, 0Eh            ; function to print character to TTY
    mov al, '0'            ; assume bit is 0
    test seed_low, 1           ; check if least significant bit is 1
    jz print_bit
    mov al, '1'            ; change to '1' if it's 1
print_bit:
    int 10h                ; print the character
    inc bitsPrinted        ; increment the bits printed counter
	
	;reset for screen width limit reached
	cmp bitsPrinted, 80
	jb no_reset
	mov bitsPrinted, 0
	no_reset:
	
	

    ret
LFSR ENDP

end main
