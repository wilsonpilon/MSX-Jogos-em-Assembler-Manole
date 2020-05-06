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
export COMname="program"
export MakeAutoexec=true
export MakeDOS=false
export emulPath="/usr/local/bin/openmsx"
export emulArgs="-machine msx1_eu -ext Sharp_HB-3600 -script program.tcl -diskb diskb/"
export Source="source"
export Tools="bin"
export Build="build"

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
export token="$Tools/msxbadig.py"

echo $(date)-[definicoes]: Variaveis Locais Configuradas

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
e2=$(stat -c%s $Source/error.txt)

# ===== Compilacao do programa ASM
echo $(date) - make: Compiling ASM file
$compile --msx --err $Source/$SourceFile.asm $Source/$SourceFile.bin >> $Source/error.txt

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
	echo $(date) - make: Composing BIN file
	cp $Source/$SourceFile.bin $Build/$COMname.bin
	cp $Source/$SourceFile.bas $Build/$COMname.bas
	cp $Source/$SourceFile.asc $Build/$COMname.asc

	# Limpeza em caso de erro, fall back do emulador
	echo $(date) - make: Cleanup
	rm $Source/$SourceFile.bin
	rm $Source/$SourceFile.bas
	rm $Source/$SourceFile.asc
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
	$CopyToFloppy $Source/*.asm
	$CopyToFloppy $Source/*.bad
	if $MakeAutoexec
	then
		echo -e "10 bload \"$COMname.bin\",r\r\n" > $Build/autoexec.bas
		echo -e "20 bload \"$COMname.alf\",s,-&HA00\r\n" >> $Build/autoexec.bas
		echo -e "30 run \"$COMname.bas\"\r\n" >> $Build/autoexec.bas
		$CopyToFloppy $Build/autoexec.bas
		$CopyToFloppy $Build/autoexec.bat
	fi
	$CopyToFloppy $Build/$COMname.bin
	$CopyToFloppy $Build/$COMname.bas

	# Copia arquivos que estao em resources para o disco
	for f in $(ls resources/*) 
	do 
        $CopyToFloppy $f
    done

	# Executa o emulador
	runemulator
fi
