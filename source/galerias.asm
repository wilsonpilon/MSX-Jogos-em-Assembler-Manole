;***** Rotinas principais do programa *****************************************
include source/msxsys.asm
WIDT:   equ #D502


	org	#CA60

GALERIA:
	ld	hl,#1860			;Area inicial (SCREEN 1, terceira linha)
	ld	a,#f8				;Caracter de preenchimento
	ld	bc,#02a0			;21 linhas
	call	FILVRM				;Preenche VRAM
	ld	hl,#010b			;linha 1, coluna 11
MGAL:	
	push	hl				;Salva Registro
	ld	a,(WIDT)			;Programa BAS ajusta largura
GAPAGA:
	push	af				;Salva Registradores
	call	POSIT				;Posiciona cursor
	ld	a,#20				;Espaco
	call	CHPUT				;Imprime caracter
	inc	l				;Proxima linha
	pop	af				;Restaura Registradores
	dec	a				;Decrementa largura
	cp	#ff				;Fim da Largura corrente?
	jr	nz,GAPAGA			;Nao, Continua apagando
	pop	hl				;Restaura Registro
	ld	bc,#0100			;Proxima linha
	add	hl,bc
	ld	a,h
	cp	#21				;Linha 21?
	ret	z				;Sim, encerra
	ld	a,r				;Contador de instrucoes?
	cp	#40				;64?
	jr	c,GALAUX			;Rotina Obscura
MGCTRL:	
	inc	l				;Ainda sera descrita
	ld	a,(WIDT)
	add	a,l
	cp	#18
	jr	nz,MGAL
GALAUX:	
	dec	l
	ld	a,l
	cp	#04
	jr	nz,MGAL
	jp	MGCTRL

	end