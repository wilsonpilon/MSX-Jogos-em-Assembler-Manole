;***** Pacote matematico para Z80 *********************************************
;***** MULHXE *****************************************************************
; Funcao: Multiplica H por E prioriza tamanho a velocidade
; Entrada: H e E operandos
; Saida: HL produto
;        D zero
;        A, E, B, C preservados
MULHXE:
        ld d,0
        ld l,d
        ld b,8
_MULHE:
        add hl,hl
        jr nc,$+3
        add hl,de
        djnz _MULHE
        ret