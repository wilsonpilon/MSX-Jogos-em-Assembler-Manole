10 POKE-1,(NOT(PEEK(-1))AND240)*1.0625:KEYOFF:WIDTH39:COLOR15,4,4:SCREEN2:POKE&HFCAB,255:BLOAD"GRAPHOS.BIN",R
20 BLOAD"GRAPHOS.CMD":A$=CHR$(0)+"????????   "+STRING$(24,0):FORI=1TO36:POKE&HF6E7+I,ASC(MID$(A$,I,1)):NEXT:RESTORE:FORI=1TO5:READA:POKE&H8400+A,PEEK(7)-(I>3):NEXT:DATA9361,9368,9375,3637,3641
30 DEFUSR=&H922E:SCREEN0:BLOAD"GRAPHOS.LTR",R:COLOR1,15:PRINT"GRAPHOS III  vr. 1.21a":PRINT"vr. 1.2   (c) 1987 Renato Degiovani":PRINT"vr. 1.21a (c) 1997 A&L Software"
40 PRINT:PRINT"   O sistema de disco permite grava‡µestamb‚m em cassete. Ao requerer uma ope-ra‡±o de I/O, o GRAPHOS indaga o perif‚rico alvo. Para evitar isto, pode-se dirigir a opera‡±o somente para o drive."
50 PRINT:PRINT"Deseja a pergunta:(D)isco (C)assete ?";:A$=INPUT$(1):PRINTA$:PRINT:PRINT:IFA$="N"THENPOKE&HAE64,&HA7:POKE&HAE65,&HC9
60 PRINT:PRINT"Se a impress±o da tela n±o ‚ normal, vocˆ pode mudar a rotina de impress±o, sanando o problema.":PRINT:PRINT"Deseja outra rotina de impress±o ?";:A$=INPUT$(1):PRINTA$:PRINT:PRINT
70 IFA$="S"THENP=&HC22A:POKEP,65:POKEP+5,8:POKEP+7,70:S=1:A$="CD38C23E0ACD38C23E1818E6":FORP=&HC246TO&HC251:POKEP,VAL("&H"+MID$(A$,S,2)):S=S+2:NEXT
80 X=USR(0):KEYON:COLOR15,1,1:NEW
