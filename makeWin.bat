@echo off
rem =============================================================================
rem Make para MSX usando PASMO e tendo como alvo um .BIN
rem (R) Cybernostra, Inc. 1972-2020
rem =============================================================================

rem ===== Variavies de setup do sistema
rem     SourceFile: Nome do programa principal, formato MSX-DOS
rem       DiskName: Nome da imagem de disco a ser gerada 
rem        COMname: Nome do executavel MSX
rem   MakeAutoexec: Cria ou nao cria autoexec.bat e autoexec.bas
rem        MakeDOS: Copia os arquivos do MSXDOS ou nao
rem       emulPath: Caminho e nome do executavel de seu emulador MSX
rem       emulArgs: Argumentos a serem passados para o emulador 
rem                 (-diska ja e incluido)
rem         Source: Diretorio que contem os fontes dos programas
rem          Tools: Diretorio que contem ferramentas necessarias para 
rem                 a compilacao e criacao dos discos
rem          Build: Diretorio de destino dos arquivos compilados e 
rem                 imagem de disco
set SourceFile=program
set DiskName=program.dsk
set COMname=program
set MakeAutoexec=true
set MakeDOS=true
set MakeBAD=true
set MakeASM=false
set MakeALF=false
set emulPath=C:\retro\msx\openmsx.exe
set emulArgs=-machine msx1_eu -ext Sharp_HB-3600 -script program.tcl -diskb diskb/
set Source=source
set Tools=bin
set Build=build
set Resources=resources

echo %date%-%time%-[definicoes]: Variaveis Globais Configuradas

rem ===== Variaveis de Trabalho
rem       compile: caminho do compilador a ser usado
rem      disktool: caminho da ferramenta de criacao de imagem de disco
rem          Tdos: caminho da ferramenta de conversao UNIX -> DOS
rem         Tunix: caminho da ferramenta de conversao DOS -> UNIX
rem  CopyToFloppy: Comando para criacao e adicao de arquivos a imagem
set compile=%Tools%\pasmo.exe
set python=python3
set disktool=%Tools%\DskTool.exe
set Tdos=%Tools%\unix2dos.exe
set Tunix=%Tools%\dos2unix.exe
set CopyToFloppy=%disktool% a %Build%\%DiskName%
set token=%python% %Tools%\msxbadig.py
set Grep=grep -v removed_line_number

echo %date%-%time%-[definicoes]: Variaveis Locais Configuradas

rem ===== Variaveis do Projeto
rem     BADaux: Lista de arquivos auxiliares BASIC a serem compilados
rem             e nao incorporados no PROGRAM.BAD
rem     ASMaux: Lista de arquivos auxiliares Assembly a serem compilados
rem             e nao incorporados no PROGRAM.BIN
rem     ALFaux: Lista de arquivos auxiliares de fontes a serem compilados
rem             e nao incorporados no PROGRAM.BIN
set BADaux=ataque base combate
set BADaux=
set ASMaux=
set ALFaux=

cls

echo %date%-%time%-[definicoes]: Variaveis de Projeto Configuradas

rem ===== Preparacao
rem Remove arquivo de erro caso exista antes da compilacao
if exist %Source%\error.txt del %Source%\error.txt

rem ===== Compilacao do programa BAS
echo %date%-%time% - make: Compiling BAS file
echo %token% %Source%\%SourceFile%.bad
%token% %Source%\%SourceFile%.bad > %Source%\error.txt
if [%MakeBAD%] == [true] (
	echo  %date%-%time%-[auxiliar]: Compilando BAD Auxiliares
	for %%i in (%BADaux%) do (
		echo %token% %Source%\%%i.bad
		%token% %Source%\%%i.bad | %Tools%\%Grep% >> %Source%\error.txt
	)
)
FOR /F "usebackq" %%A IN ('%Source%/error.txt') DO set e2=%%~zA

rem ===== Compilacao do programa ASM
echo %date%-%time% - make: Compiling ASM file
echo %compile% --msx --err %Source%\%SourceFile%.asm %Source%\%SourceFile%.bin
%compile% --msx --err %Source%\%SourceFile%.asm %Source%\%SourceFile%.bin >> %Source%\error.txt
if [%MakeASM%] == [true] (
	echo  %date%-%time%-[auxiliar]: Compilando ASM Auxiliares
	for %%i in (%ASMaux%) do (
		echo %compile% --msx --err %Source%\%%i %Source%\%%i.bin
		%compile% --msx --err %Source%\%%i.asm %Source%\%%i.bin >> %Source%\error.txt
	)
)

rem ===== Tratamento de erros
rem sem saida de erro, exclui o arquivo error.txt
FOR /F "usebackq" %%A IN ('%Source%/error.txt') DO set e1=%%~zA

set /a "e=%e1%+%e2%"
echo Errors file size: %e%

if %e% EQU 0 del %Source%\error.txt

rem Existe o arquivo de erro e saida <> 0 mostra no console
if exist %Source%\error.txt (
	echo %date%-%time% - make: Compiler error:
	type %Source%\error.txt
	goto :eof
)

rem Composicao do executavel e imagem de disco
echo %date%-%time% - make: Composing BIN file
copy %Source%\%SourceFile%.bin %Build%\%COMname%.bin > nul
copy %Source%\%SourceFile%.bin %Build%\%COMname%.asm > nul
copy %Source%\%SourceFile%.bas %Build%\%COMname%.bas > nul
copy %Source%\%SourceFile%.asc %Build%\%COMname%.asc > nul

if [%MakeBAD%] == [true] (
	echo  %date%-%time%-[auxiliar]: Composing Aux BAS
	for %%i in (%BADaux%) do (
		copy %Source%\%%i.bas %Build%\%%i.bas > nul
		copy %Source%\%%i.asc %Build%\%%i.asc > nul
	)
)

if [%MakeASM%] == [true] (
	echo  %date%-%time%-[auxiliar]: Composing Aux ASM
	for %%i in (%ASMaux%) do (
		copy %Source%\%%i.asm %Build%\%%i.asm > nul
		copy %Source%\%%i.bin %Build%\%%i.bin > nul
	)
)

rem Limpeza em caso de erro, fall back do emulador
echo %date%-%time% - make: Cleanup
del %Source%\%SourceFile%.bin > nul
del %Source%\%SourceFile%.bas > nul
del %Source%\%SourceFile%.asc > nul

if [%MakeBAD%] == [true] (
	echo  %date%-%time%-[auxiliar]: Cleam Aux BAS
	for %%i in (%BADaux%) do (
		del %Source%\%%i.bas > nul
		del %Source%\%%i.asc > nul
	)
)

if [%MakeASM%] == [true] (
	echo  %date%-%time%-[auxiliar]: Clean Aux ASM
	for %%i in (%ASMaux%) do (
		del %Source%\%%i.bin > nul
	)
)

if [%DiskName%] == [] goto :msx

rem Criacao da imagem de disco respeitando os parametros
echo %date%-%time% - make: Building virtual floppy 
if exist %Build%\%DiskName% del %Build%\%DiskName%

if [%MakeDOS%] == [true] %CopyToFloppy% %Tools%\msxdos.sys %Tools%\command.com > nul

if [%MakeAutoexec%] == [true] (
	echo basic autoexec.bas > %Build%\autoexec.bat
	%Tdos% %Build%\autoexec.bat
	echo 10 bload "%COMname%.bin",r > %Build%\autoexec.bas
	echo 20 bload "%COMname%.alf",s,-2560 >> %Build%\autoexec.bas
	echo 30 run "%COMname%.bas" >> %Build%/autoexec.bas
	%CopyToFloppy% %Build%\autoexec.bas %Build%\autoexec.bat > nul
)

%CopyToFloppy% %Build%\%COMname%.bin > nul
%CopyToFloppy% %Build%\%COMname%.bas > nul

if [%MakeBAD%] == [true] (
	echo  %date%-%time%-[auxiliar]: Copy Aux BAS
	for %%i in (%BADaux%) do (
		%CopyToFloppy% %Build%\%%i.bas > nul
		%CopyToFloppy% %Build%\%%i.asc > nul
	)
)

if [%MakeASM%] == [true] (
	echo  %date%-%time%-[auxiliar]: Copy Aux ASM
	for %%i in (%ASMaux%) do (
		%CopyToFloppy% %Build%\%%i.asm > nul
		%CopyToFloppy% %Build%\%%i.bin > nul
	)
)

if [%MakeALF%] == [true] (
	echo  %date%-%time%-[auxiliar]: Copy Aux ALF
	for %%i in (%ALFaux%) do (
		%CopyToFloppy% %Source%\%%i.alf %Build%\%%i.alf > nul
	)
)

for %%I in (%Resources%\*.*) do %CopyToFloppy% %%I > nul

rem ===== msx
rem Executa o emulador caso esteja configurado

:msx
if [%emulPath%]==[""] (
	echo echo %date%-%time% - make : No emulator Launching
) else (
	echo echo %date%-%time% -  make : Attempt to launch emulator
	if exist %emulPath% call %emulPath% %emulArgs% -diska %Build%/%DiskName%
	echo %emulPath% %emulArgs% -diska %Build%/%DiskName%
)
:eof

