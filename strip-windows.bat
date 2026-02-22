@echo off
setlocal EnableDelayedExpansion

set toPublicize=Assembly-CSharp.dll assembly_valheim.dll assembly_utils.dll assembly_postprocessing.dll assembly_sunshafts.dll com.rlabrecque.steamworks.net.dll assembly_simplemeshcombine.dll assembly_lux.dll assembly_guiutils.dll assembly_googleanalytics.dll
set toIgnore=Mono.Security.dll mscorlib.dll

set exePath=%1
echo exePath: %exePath%

REM Remove quotes
set exePath=%exePath:"=%

set managedPath=%exePath:.exe=_Data\Managed%
echo managedPath: %managedPath%

set scriptDir=%~dp0
set outPath=%scriptDir%package\lib

if not exist "%outPath%" mkdir "%outPath%"

REM -----------------------------
REM Runtime selection for NStrip
REM -----------------------------
where mono >nul 2>nul
if %errorlevel%==0 (
    set RUNTIME=mono
) else (
    where wine >nul 2>nul
    if %errorlevel%==0 (
        set RUNTIME=wine
    ) else (
        echo Error: Neither mono nor wine found in PATH.
        pause
        exit /b 1
    )
)

echo Using runtime: %RUNTIME%

REM Ask whether to keep Unity DLLs
set /p keepUnity=Keep Unity DLLs? (y/n): 

REM Strip all assemblies, but keep them private.
call :run_nstrip "%managedPath%" -o "%outPath%"

REM Strip and publicize assemblies
for %%a in (%toPublicize%) do (
    echo a: %%a
    call :run_nstrip "%managedPath%\%%a" -o "%outPath%\%%a" -cg -p --cg-exclude-events
)

REM Removing unused packages
for %%a in (%toIgnore%) do (
    echo a: %%a
    del /f "%outPath%\%%a" >nul 2>nul
)

REM Conditionally remove Unity DLLs
if /I "%keepUnity%"=="y" (
    echo Keeping Unity DLLs.
) else (
    echo Removing Unity DLLs.
    del /f "%outPath%\Unity*.dll" >nul 2>nul
)

REM Always remove System DLLs
del /f "%outPath%\System*.dll" >nul 2>nul

echo.
pause
exit /b 0


:run_nstrip
%RUNTIME% "%scriptDir%tools\NStrip.exe" %*
exit /b 0