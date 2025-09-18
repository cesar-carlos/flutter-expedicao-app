@echo off
echo Verificando imports relativos no projeto...
echo.

echo === Buscando imports relativos ===
findstr /R /S /N "^import '\.\." lib\*.dart
if %ERRORLEVEL% EQU 0 (
    echo.
    echo *** ATENÇÃO: Encontrados imports relativos! ***
    echo Execute o comando abaixo para corrigir manualmente:
    echo dart fix --apply
    echo.
) else (
    echo ✓ Nenhum import relativo encontrado!
)

echo.
echo === Buscando imports com ./ ===
findstr /R /S /N "^import '\." lib\*.dart
if %ERRORLEVEL% EQU 0 (
    echo.
    echo *** ATENÇÃO: Encontrados imports relativos com ./ ***
    echo Corrija manualmente substituindo por package:exp/
    echo.
) else (
    echo ✓ Nenhum import relativo com ./ encontrado!
)

echo.
echo === Executando análise do projeto ===
dart analyze --fatal-infos
if %ERRORLEVEL% EQU 0 (
    echo ✓ Análise passou sem problemas de imports!
) else (
    echo *** Existem problemas na análise - verifique os imports ***
)

echo.
echo Verificação de imports concluída!
pause
