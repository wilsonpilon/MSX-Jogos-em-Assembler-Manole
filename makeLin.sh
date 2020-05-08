#!/bin/bash
# =============================================================================
# Make para MSX usando PASMO e tendo como alvo um .BIN
# (R) Cybernostra, Inc. 1972-2020
# =============================================================================

# ===== Variavies de setup do sistema
#     SourceFile: Nome do programa principal, formato MSX-DOS
#       DiskName: Nome da imagem de disco a ser gerada 
#        COMname: Nome do executavel MSX
#   MakeAutoexec: Cria ou nao cria autoexec.bat e autoexec.bas
#        MakeDOS: Copia os arquivos do MSXDOS ou nao
#       emulPath: Caminho e nome do executavel de seu emulador MSX
#       emulArgs: Argumentos a serem passados para o emulador 
#                 (-diska ja e incluido)
#         Source: Diretorio que contem os fontes dos programas
#          Tools: Diretorio que contem ferramentas necessarias para 
#                 a compilacao e criacao dos discos
#          Build: Diretorio de destino dos arquivos compilados e 
#                 imagem de disco
export SourceFile="program"
export DiskName="program.dsk"
export DiskNameB="diskb.dsk"
export COMname="program"
export MakeAutoexec=true
export MakeDOS=false
export MakeBAD=true
export MakeASM=true
export MakeALF=false
export Source="source"
export Tools="bin"
export Build="build"
#export emulPath="/usr/local/bin/openmsx"
#export emulArgs="-machine msx1_eu -ext Sharp_HB-3600 -script program.tcl -diskb diskb/"
export emulPath="/usr/local/bin/fmsx"
export emulArgs="-home /usr/local/bin -msx1 -diskb $Build/$DiskNameB"

echo $(date)-[definicoes]: Variaveis Globais Configuradas

# ===== Variaveis de Trabalho
#       compile: caminho do compilador a ser usado
#      disktool: caminho da ferramenta de criacao de imagem de disco
#          Tdos: caminho da ferramenta de conversao UNIX -> DOS
#         Tunix: caminho da ferramenta de conversao DOS -> UNIX
#  CopyToFloppy: Comando para criacao e adicao de arquivos a imagem
export compile="$Tools/pasmo"
export disktool="$Tools/wrdsk"
export Tdos="$Tools/unix2dos"
export Tunix="$Tools/dos2unix"
export CopyToFloppy="$disktool $Build/$DiskName"
export CopyToFloppyB="$disktool $Build/$DiskNameB"
export token="$Tools/msxbadig.py"
export Grep="grep -v removed_line_number"

echo $(date)-[definicoes]: Variaveis Locais Configuradas
# ===== Variaveis do Projeto
#     BADaux: Lista de arquivos auxiliares BASIC a serem compilados
#             e nao incorporados no PROGRAM.BAD
#     ASMaux: Lista de arquivos auxiliares Assembly a serem compilados
#             e nao incorporados no PROGRAM.BIN
#     ALFaux: Lista de arquivos auxiliares de fontes a serem compilados
#             e nao incorporados no PROGRAM.BIN
export BADaux="ataque base combate"
export ASMaux="teste abc"
export ALFaux=

clear

echo $(date)-[definicoes]: Variaveis de Projeto Configuradas

# ===== runemulator
# Executa o emulador caso esteja configurado
function runemulator {
    if [ $emulPath = "" ] 
	then
        echo $(date) - make : No emulator Launching
    else
        echo $(date) -  make : Attempt to launch emulator
	    if [ -f $emulPath ] 
		then
            $emulPath $emulArgs -diska $Build/$DiskName
        fi
    fi
}

# ===== Preparacao
# Remove arquivo de erro caso exista antes da compilacao
if [ -f $Source/error.txt ] 
then
    rm $Source/error.txt
fi

# ===== Compilacao do programa BAS
echo $(date) - make: Compiling BAS file
$token $Source/$SourceFile.bad > $Source/error.txt
if $MakeBAD
then
	echo  $(date)-[auxiliar]: Compilando BAD Auxiliares
	echo $BADaux
	for i in $BADaux
	do 
		echo $token $Source/$i.bad
		$token $Source/$i.bad | $Grep >> $Source/error.txt
	done
fi
e2=$(stat -c%s $Source/error.txt)


# ===== Compilacao do programa ASM
echo $(date) - make: Compiling ASM file
$compile --msx --err $Source/$SourceFile.asm $Source/$SourceFile.bin >> $Source/error.txt
if $MakeASM
then
	echo  $(date)-[auxiliar]: Compilando ASM Auxiliares
	echo $ASMaux
	for i in $ASMaux
	do 
		echo $compile --msx --err $Source/$i.asm $Source/$i.bin
		$compile --msx --err $Source/$i.asm $Source/$i.bin >> $Source/error.txt
	done
fi

# ===== Tratamento de erros
# sem saida de erro, exclui o arquivo error.txt
e1=$?
e=$(($e1 + $e2))

if [ $e -eq 0 ]
then
   rm $Source/error.txt
fi

# Existe o arquivo de erro e saida <> 0 mostra no console
if [ -f $Source/error.txt ] 
then
	echo $(date) - make: Compiler error:
	cat $Source/error.txt
##### Composicao do executavel e imagem de disco
else
	cp $Source/$SourceFile.bas $Build/$COMname.bas
	cp $Source/$SourceFile.asc $Build/$COMname.asc

	if $MakeBAD
	then
		echo  $(date)-[auxiliar]: Copiando BAD Auxiliares
		echo $BADaux
		for i in $BADaux
		do 
			cp $Source/$i.asc $Build/$i.asc
			cp $Source/$i.bas $Build/$i.bas
		done
	fi

	if $MakeASM
	then
		echo  $(date)-[auxiliar]: Copiando ASM Auxiliares
		echo $ASMaux
		for i in $ASMaux
		do 
			cp $Source/$i.asm $Build/$i.asm
			cp $Source/$i.bin $Build/$i.bin
		done
	fi


	# Limpeza em caso de erro, fall back do emulador
	echo $(date) - make: Cleanup
	rm $Source/$SourceFile.bin
	rm $Source/$SourceFile.bas
	rm $Source/$SourceFile.asc

	if $MakeBAD
	then
		echo  $(date)-[auxiliar]: Limpando BAD Compilados
		echo $BADaux
		for i in $BADaux
		do 
			rm $Source/$i.asc
			rm $Source/$i.bas
		done
	fi

	if $MakeASM
	then
		echo  $(date)-[auxiliar]: Limpando ASM Compilados
		echo $ASMaux
		for i in $ASMaux
		do 
			rm $Source/$i.bin
		done
	fi

	if [ $DiskName == "" ] 
	then
        runemulator
    fi

	# Criacao da imagem de disco respeitando os parametros
	echo $(date) - make: Building virtual floppy 
	if [ -f $Build/$DiskName ] 
	then
        rm $Build/$DiskName
    fi
	if $MakeDOS
	then
		$CopyToFloppy $Tools/msxdos.sys $Tools/command.com $Source/*.asm
		echo -e "basic autoexec.bas" > $Build/autoexec.bat
		$Tdos $Build/autoexec.bat
	fi
	$CopyToFloppy $Source/*.asm > /dev/null
	$CopyToFloppy $Source/*.bad > /dev/null
	if $MakeAutoexec
	then
		echo -e "10 bload \"$COMname.bin\",r\r\n" > $Build/autoexec.bas
		echo -e "20 bload \"$COMname.alf\",s,-&HA00\r\n" >> $Build/autoexec.bas
		echo -e "30 run \"$COMname.bas\"\r\n" >> $Build/autoexec.bas
		$CopyToFloppy $Build/autoexec.bas > /dev/null
		$CopyToFloppy $Build/autoexec.bat > /dev/null
	fi
	$CopyToFloppy $Build/$COMname.bin > /dev/null
	$CopyToFloppy $Build/$COMname.bas > /dev/null


	if $MakeBAD
	then
		echo  $(date)-[auxiliar]: Copiando BAD Auxiliares
		echo $BADaux
		for i in $BADaux
		do 
			$CopyToFloppy $Build/$i.asc > /dev/null
			$CopyToFloppy $Build/$i.bas > /dev/null
		done
	fi

	if $MakeASM
	then
		echo  $(date)-[auxiliar]: Copiando ASM Auxiliares
		echo $ASMaux
		for i in $ASMaux
		do 
			$CopyToFloppy $Build/$i.asm > /dev/null
			$CopyToFloppy $Build/$i.bin > /dev/null
		done
	fi

	# Copia arquivos que estao em resources para o disco
	echo  $(date)-[disco A]: Copiando Recursos
	for f in $(ls resources/*) 
	do 
        $CopyToFloppy $f > /dev/null
    done

	# Prepara disco B
	echo  $(date)-[disco B]: Copiando Programas
	rm $Build/$DiskNameB
	for f in $(ls diskb/*) 
	do 
        $CopyToFloppyB $f /dev/null
    done

	# Executa o emulador
	runemulator
fi
