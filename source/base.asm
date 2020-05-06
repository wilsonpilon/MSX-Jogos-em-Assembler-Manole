;***** Rotina de execucao do programa *****************************************
BASE:
        ld a,#02                        ;Sprite inicial
        ld c,#02                        ;DX
        call MOVESPR                    ;Move
        ld c,#ff                        ;DX
        call MOVESPR                    ;Move
        ld c,#03                        ;DX
        call MOVESPR                    ;Move
        ld c,#fe                        ;DX
        call MOVESPR                    ;Move
        ld c,#01                        ;DX
        call MOVESPR                    ;Move
        ret

