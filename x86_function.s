	section .text	

	global x86_function

x86_function:
	push rbp
	mov rbp, rsp

; registers:
	; rdi - buffer
	; rsi - width
	; rdx - height
	; xmm0 - coord_width
	; xmm1 + 16 - escape_radius
	; xmm2 - center_x
	; xmm3 - center_y

	sub rsp, 128
	
	movsd [rbp - 8], xmm3	; center_y (y0)
	movsd [rbp - 16], xmm2	; center_x (x0)
	movsd [rbp - 24], xmm1	; escape_radius
	movsd [rbp - 32], xmm0	; coord_width
	mov [rbp - 40], rdx	; height
	mov [rbp - 48], rsi	; width
	
	fld QWORD[rbp - 32]	; load coord_width
	fild QWORD [rbp - 40]	; load height	
	fdivp			; divide by height

	fstp QWORD [rbp - 56]	; y_scale

	fld QWORD[rbp - 32]	; load coord_width
	fild QWORD [rbp - 48]	; load width	
	fdivp			; divide by width

	fstp QWORD [rbp - 64]	; x_scale	

	mov r9, 0		; y counter

height_alg_loop:
	mov r8, 0		; x counter	

	mov [rbp - 72], r9
	fld QWORD [rbp - 8]	; load y0
	fild QWORD [rbp - 72]	; load y 
	fsubp			; y0-y
	fld QWORD [rbp - 56]	; load y_scale 
	fmulp			; (y0-y)*scale				
	
	fstp QWORD [rbp - 72]	; (y0-y)*scale

width_alg_loop:
	mov [rbp - 80], r8
	fild QWORD [rbp - 80]	; load x
	fld QWORD [rbp - 16]	; load x0

	fsubp			; x-x0
	fld QWORD [rbp - 64]	; load x_scale
	fmulp			; (x-x0)*scale

	fstp QWORD [rbp - 80]	; (x-x0)*scale

	mov QWORD [rbp - 88], 0
	mov QWORD [rbp - 96], 0
	mov QWORD [rbp - 104], 0
	mov QWORD [rbp - 112], 0

	mov r10, 0		; number of iterations	

algorythm:
	fld QWORD [rbp - 96]	; load zI
	fld QWORD [rbp - 88]	; load zR 
	fmulp			; zIR
	fld st0
	faddp 			; 2zIR

	fld QWORD [rbp - 112]	; load zR^2
	fld QWORD [rbp - 104]	; load zI^2
	fsubp			; zR

	fld QWORD [rbp - 80]	; (x-x0)*scale
	faddp 			; (x-x0)*scale+zR
	fstp QWORD [rbp - 88]	; (x-x0)*scale+zR
	
	fld QWORD [rbp - 72]	; load (y0-y)*scale
	faddp  			; (y0-y)*scale + 2zIR = new zI
	fst QWORD [rbp - 96]
	fld st0 	
	fmulp
	fst QWORD [rbp - 104] 	; new zI^2

	fld QWORD [rbp - 88]	; load (x-x0)*scale+zR
	fld st0
	fmulp			; new zR^2
	fst QWORD [rbp - 112] 	; st0 = new zR^2, st1 = new zI^2

	faddp			; new zR^2 + new zI^2
	fsqrt			; sqrt(new zR^2 + new zI^2)

	fstp QWORD [rbp - 120]	; sqrt(new zR^2 + new zI^2)

	inc r10
	cmp r10, 32
	je black_pix

	fild QWORD [rbp - 24] 	; escape_radius
	fld QWORD [rbp - 120]	; sqrt(new zR^2 + new zI^2)
	fcompp
	fstsw ax
	sahf
	jb algorythm

	cmp r10, 22
	jb blue_pix	
	
	cmp r10, 26
	jb white_pix

pink_pix:
	mov byte [rdi], 0xFF
	mov byte [rdi+1], 0x99	
	mov byte [rdi+2], 0xFF 
	jmp next

blue_pix:
	mov byte [rdi], 0
	mov byte [rdi+1], 0
	mov byte [rdi+2], 0xA1
	jmp next

white_pix:
	mov byte [rdi], 0xFF
	mov byte [rdi+1], 0xFF	
	mov byte [rdi+2], 0xFF 
	jmp next

black_pix:
	mov byte [rdi], 0
	mov byte [rdi+1], 0	
	mov byte [rdi+2], 0
next:
	mov byte [rdi+3], 0	
	add rdi, 4
	inc r8
	cmp r8, [rbp - 48]
	jb width_alg_loop
	
end_line:
	inc r9
	cmp r9, [rbp - 40]
	jb height_alg_loop
end:
	mov rsp, rbp
	pop rbp
	ret
