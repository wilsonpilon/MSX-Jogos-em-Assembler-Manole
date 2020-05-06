;***** Rotinas principais do programa *****************************************
COMBATE:
        ld a,#03                    ;Sprite inicial
        ld c,#fc                    ;DX
        call MOVESPR                ;Move
        ld c,#03                    ;DX
        call MOVESPR                ;Move
        ld c,#fe                    ;DX
        call MOVESPR                ;Move
        ld c,#01                    ;DX
        call MOVESPR                ;Move
        ld c,#ff                    ;DX
        call MOVESPR                ;Move
        ret

;***** Copia dados dos sprites para Buffer em &HA000 **************************
COMBAUX:
        ld a,#03                    ;Sprite inicial
        ld bc,BUFA30                ;&HA000
CMBLOP: 
        push af                     ;Salva registro
        call CALATR                 ;Busca tabela de atributos dos sprites
        call RDVRM                  ;Le VRAM
        ld (bc),a                   ;Salva no buffer Y
        inc bc                      ;Proximo endereco buffer
        inc hl                      ;Proximo Atributo
        call RDVRM                  ;Le VRAM
        ld (bc),a                   ;Salva no buffer X
        inc bc                      ;Proximo Sprite
        pop af                      ;Restaura registro
        inc a                       ;Proximo SPRITE
        cp #12                      ;todos os 12?
        jr nz,CMBLOP                ;nao, le o resto
        ret
