!AleAle Rodriguez Sanchez Ing. Computacionion
	.begin
	.macro push arg
		addcc %r14, -4, %r14
		st arg, %r14	
	.endmacro
	.macro pop arg
		ld [%r14], arg
		addcc %r14, 4, %r14
	.endmacro
	.org 2048
main:	ld [stack], %r14
	ld [x], %r1  		!carga de operando 1
	ld [y], %r2		!carga de operando 2
	ld [mase], %r3		!carga de mascara para exponente
	ld [masm], %r4		!carga de mascara para mantiza
	ld [biti], %r5		!carga de mascara para bit implicito
	srl %r1, 31, %r6	!separacion de signo, op1
	srl %r2, 31, %r7	!separacion de signo, op2
	andcc %r3, %r1, %r8	!separacion del exponente, op1
	srl %r8, 23, %r8	!colocacion del exponente en la parte mas baja
	andcc %r3, %r2, %r9	!separacion del exponente, op2
	srl %r9, 23, %r9	!colocacion del exponente en la parte mas baja
	andcc %r4, %r1, %r10	!separacion de la mantiza, op1
	orcc %r10, %r5, %r10	!clocacion del bit implicito
	andcc %r4, %r2, %r11	!separacion de la mantiza, op2
	orcc %r11, %r5, %r11	!colocacion del bit implicito
	orncc %r0,%r8, %r12	!complemento a 1 del exponente del op1 
	addcc %r12, 1, %r12	!complemento a 2 del exponente del op1 
	ld [nega], %r16		!carga los 8 bits correspondientes al signo extendido
	ld [sig], %r17		!carga un -1 para identificar si algun operando es negativo
	addcc %r9,%r12,%r13	!diferencia de exponentes, exp2-exp1
	bneg diferencia2	!salta si el resultado de la resta es negativo
	srl %r10, %r13, %r10	!corrimiento de la mantiza, op1	
	orcc %r9, %r0, %r21	!coloca en el reg 21 el exponente que sera empaquetado
	addcc %r17, %r6, %r0	!identificacion del signo del op1
	be op1nega		!salta si el signo del op1 es negativo
	addcc %r17, %r7, %r0	!identificacion del signo del op2
	be op2nega		!salta si el signo del op2 es negativo 
	addcc %r10, %r11, %r18	!suma de mantizas
	push %r15		!almacena en la pila el valor pc
	push %r18		!almacena en la pila el resultado de la suma
	call normal		!llama a la subrutina para normalizar
	pop %r15		!recupera el pc
	jmpl %r15+4, %r0	!return
diferencia2:  			
	orncc %r0,%r9,%r12 	!complemento a 1 del exponente del op2
	addcc %r12, 1, %r12	!complemento a 2 del exponente del op2 
	addcc %r8, %r12, %r13	!diferencia de exponentes, exp1-exp2
	srl %r11, %r13, %r11	!corrimiento de la mantiza, op2
	orcc %r8, %r0, %r21	!coloca en el reg 21 el exponente que sera empaquetado 
	addcc %r17, %r6, %r0	!identificacion del signo del op1
	be op1nega		!salta si el signo del op1 es negativo
	addcc %r17, %r7, %r0	!identificacion del signo del op2
	be op2nega		!salta si el signo del op2 es negativo 
	addcc %r10, %r11, %r18	!suma de mantizas
	push %r15		!almacena en la pila el valor del pc 
	push %r18		!almacena en la pila el resultado de la suma
	call normal		!llama a la subrutina para normalizar 
	pop %r15		!recupera el pc
	jmpl %r15+4, %r0	!return 
op1nega:
	orncc %r0, %r10, %r10	!mantiza del op1 en complemento a 1
	addcc %r10, 1, %r10	!mantiza del op1 en complemento a 2
	orcc %r16, %r10,%r10	!extencion de signo 
	addcc %r17, %r7, %r0	!identificacion de signo del op2
	be op2nega		!salta si el signo del op2 es negativo
	addcc %r10,%r11,%r18	!suma de mantizas
	push %r15		!almacena en la pila el valor del pc 
	push %r18		!almacena en la pila el resultado de la suma
	call normal		!llama a la subrutina para normalizar
	pop %r15		!recupera el pc
	jmpl %r15+4, %r0	!return 
op2nega:
	orncc %r0, %r11, %r11	!mantiza del op2 en complemento a 1
	addcc %r11, 1, %r11	!mantiza del op2 en complemento a 2
	orcc %r16, %r11, %r11 	!extencion de signo
	addcc %r10, %r11, %r18	!suma de mantizas
	push %r15		!almacena en la pila el valor del pc
	push %r18		!almacena en la pila el resultado de la suma
	call normal		!llama a la subrutina para normalizar
	pop %r15		!recupera el pc
	jmpl %r15+4, %r0	!return
normal:
	pop %r19		!sacar de la pila la suma
	srl %r19, 24, %r20	!extraer el signo de la suma
	andcc %r0, %r22, %r22	!cargar un 0 en el reg 22
	orcc %r22, 24, %r22	!cargar un 24 en el reg 22
	orncc %r0, %r22, %r22	!complemento a 1 del 24
	addcc %r22, 1, %r22	!complemento a 2 del 24
	ba prueba		!inicio del ciclo
si:	addcc %r21, %r21, %r21	!corrimiento del exponente a la izq
prueba:	addcc %r22, 1, %r22	!condicion
	bneg si			!salto al inicio del ciclo
	addcc %r17, %r20, %r0	!identifica si el signo de la suma es negativo
	be signega		!salta si la suma es negativa
	andcc %r0, %r22, %r22	!cargar un 0 en el reg 22
	orcc %r22, 32, %r22	!cargar un 32 en el reg 22
	orncc %r0, %r22, %r22	!complemento a 1 del 32
	addcc %r22, 1, %r22	!complemento a 2 del 32
	ba prueba1		!inicio del ciclo
si1:	addcc %r20, %r20, %r20	!corrimiento del exponente a la izq
prueba1:addcc %r22, 1, %r22	!condicion
	bneg si1		!salto al inicio del ciclo
	orcc %r20, %r21, %r21	!une el signo y el exponente
	andcc %r4, %r19, %r23	!extrae la mantiza que sera empaquetada
	orcc %r21, %r23, %r24	!numero empaquetado
	st %r24, [z]		!lleva a la memoria el numero empaquetado
	jmpl %r15+4, %r0	!return
signega: 
	andcc %r0, %r22, %r22	!cargar un 0 en el reg 22
	orcc %r22, 32, %r22	!cargar un 31 en el reg 22
	orncc %r0, %r22, %r22	!complemento a 1 del 31
	addcc %r22, 1, %r22	!complemento a 2 del 31
	ba prueba2		!inicio del ciclo
si2:	addcc %r20, %r20, %r20	!corrimiento del exponente a la izq
prueba2:addcc %r22, 1, %r22	!condicion
	bneg si2		!salto al inicio del ciclo
	orcc %r20, %r21, %r21	!une el signo con el exponente
	andcc %r4, %r19, %r23	!extrae la mantiza 
	orncc %r0, %r23, %r23	!mantiza en complemento a 1
	addcc %r23, 1, %r23	!mantiza en complemento a 2
	orcc %r21, %r23, %r24	!numero empaquetado
	st %r24, [z]		!lleva a la memoria el numero empaquetado  
 	jmpl %r15+4, %r0	!return

	x: 0x40A00000
	y: 0xBF400000
	z: 0
	mase: 0x7F800000
	masm: 0x007FFFFF
	biti: 0x00800000
	sig: 0xFFFFFFFF
	nega: 0xFF000000
	stack: 0  	
	.end
