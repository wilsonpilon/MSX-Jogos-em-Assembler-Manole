;***** Rotinas principais do programa *****************************************

include source/msxsys.asm
;***** Definicoes do Programa *************************************************
BUFA30  equ 0A000h

;***** Rotina de Entrada ******************************************************
        ORG 0D500h
POSX:   db 12
POSY:   db 6
WIDT:   db 39
HEIG:   db 22
CHAR:   db 20h

MAIN:
        ld hl,CHOICE                    ;Prepara USR0(0) / Rotinas Gerais
        ld (USRTAB),hl
        ld hl,PTSTR                     ;Prepara USR1("") / Impressao
        ld (USRTAB+2),hl
        ld hl,IPTSTR                    ;Prepara USR2("") / Impressao Invertida
        ld (USRTAB+4),hl
        ld hl,BOOK                      ;Prepara USR3(0) / Rotinas do livro
        ld (USRTAB+6),hl
        ret

;***** Escolhe a rotina de acordo com parametro USR(x) ************************
CHOICE:
        ld a,(FACLO)
        cp 0
        jp z,BLOCO
        cp 1
        jp z,SAVSCR
        cp 2
        jp z,LODSCR
        ret


;***** Preenche uma sequencia de caracteres na VRAM ***************************
BLOCO:
        ld a,(POSY)
        ld h,a
        ld e,40
        call MULHXE
        ld a,(POSX)
        ld e,a
        ld d,0
        add hl,de
        ld a,(HEIG)
        ld b,a
_LBLK:
        push hl
        push bc
        ld a,(WIDT)
        ld c,a
        ld b,0
        ld a,(CHAR)
        call FILVRM
        pop bc
        pop hl
        ld e,40
        ld d,0
        add hl,de
        djnz  _LBLK
        ret

SAVSCR:
        ld bc,960
        ld de,SCRN
        ld hl,0
        call LDIRMV
        ret

LODSCR:
        ld bc,960
        ld de,0
        ld hl,SCRN
        call LDIRVM
        ret

;***** Rotina para impressao de String na Screen 0 ****************************
PTSTR:
        cp 3                    ;E String?
        ret nz                  ;nao, volta
        ex de,hl                ;HL descritor STRING
        ld b,(hl)               ;B tamanho
        inc hl
        ld e,(hl)               ;LSB Endereco
        inc hl
        ld d,(hl)               ;MSB DE String
        inc b
        ld hl,STR               ;Armazena localmente
PLOP1:
        dec b                   ;Final?
        jr z, PLOP1S
        ld a,(de)               ;Armazena caractere
        ld (hl),a
        inc hl
        inc de
        jr PLOP1                ;Proximo caractere
PLOP1S:
        ld a,0                  ;Fim de Z-STRING
        ld (hl),a

        ld a,(POSX)             ;Prepara posicao X do Cursor
        inc a                   ;Posix usa 1,1
        ld h,a
        ld a,(POSY)             ;Prepara posicao X do Cursor
        inc a                   ;Posix usa 1,1
        ld l,a
        call POSIT              ;Posiciona o Cursor
        ld de,STR               ;Aponta para STRING
PLOP2:
        ld a,(de)
        cp 0                    ;Fim da String?
        jr z, PSAI              ;sim, encerra
        call CHPUT              ;Imprime
        inc de                  ;Proximo caractere
        jr PLOP2
PSAI:
        ret




;***** Rotina para impressao de Invertida *************************************
IPTSTR:
        cp 3                    ;E String?
        ret nz                  ;nao, volta
        ex de,hl                ;HL descritor STRING
        ld b,(hl)               ;B tamanho
        inc hl
        ld e,(hl)               ;LSB Endereco
        inc hl
        ld d,(hl)               ;MSB DE String
        inc b
        ld hl,STR               ;Armazena localmente
IPLOP1:
        dec b                   ;Final?
        jr z, IPLOP1S
        ld a,(de)               ;Armazena caractere
        add a,128               ;Caracteres Invertidos
        ld (hl),a
        inc hl
        inc de
        jr IPLOP1                ;Proximo caractere
IPLOP1S:
        ld a,0                  ;Fim de Z-STRING
        ld (hl),a

        ld a,(POSX)             ;Prepara posicao X do Cursor
        inc a                   ;Posix usa 1,1
        ld h,a
        ld a,(POSY)             ;Prepara posicao X do Cursor
        inc a                   ;Posix usa 1,1
        ld l,a
        call POSIT              ;Posiciona o Cursor
        ld de,STR               ;Aponta para STRING
IPLOP2:
        ld a,(de)
        cp 0                    ;Fim da String?
        jr z, IPSAI              ;sim, encerra
        call CHPUT              ;Imprime
        inc de                  ;Proximo caractere
        jr IPLOP2
IPSAI:
        ret


;***** Escolhe a rotina apropriada do livro ***********************************
BOOK:
        ld a,(FACLO)
        cp 0
        jp z,BASE
        cp 1
        jp z,COMBATE
        cp 2
        jp z,COMBAUX
        ret


;***** Rotinas comuns do livro ************************************************
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

include source/base.asm
include source/combate.asm


include source/math.asm

STR:    ds 41,0
SCRN:   ds 960,0

;***** Finalizazcao ***********************************************************
END MAIN
