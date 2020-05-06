;***** Rotinas principais do programa *****************************************
include source/msxsys.asm

BUF     equ #A000

        org #CA60

        ld a,#03
        ld c,#fc
        call MOVESPR
        ld c,#03
        call MOVESPR
        ld c,#fe
        call MOVESPR
        ld c,#01
        call MOVESPR
        ld c,#ff
        call MOVESPR
        ret

MOVESPR:
        push af                         ;Salva registros
        ld b,#03                        ;3 proximos sprites
MVLOP:  
        call CALATR                     ;Busca tabela atributos Sprites
        inc hl                          ;coordenada X
        call RDVRM                      ;Le da VRAM
        sub c                           ;esquerda
        call WRTVRM                     ;Grava na VRAM
        pop af                          ;Restaura registros
        inc a                           ;Proximo Sprite
        push af                         ;Salva registros
        djnz MVLOP                      ;Laco
        pop af                          ;Recupera registro
        ret

cea91:
        ld a,#03
        ld bc,BUF
jea96: 
        push af
        call CALATR
        call RDVRM
        ld (bc),a
        inc bc
        inc hl
        call RDVRM
        ld (bc),a
        inc bc
        pop af
        inc a
        cp #12
        jr nz,jea96
        ret

end
