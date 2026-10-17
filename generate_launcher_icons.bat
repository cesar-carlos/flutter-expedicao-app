@echo off
cd /d "%~dp0"

echo ==============================================
echo    Flutter Launcher Icons Generator
echo    Data7 - EXP Application
echo ==============================================
echo.

echo [1/3] Instalando dependencias...
flutter pub get
if errorlevel 1 (
    echo ERRO: Falha ao instalar dependencias
    pause
    exit /b 1
)

echo [2/3] Gerando icones do launcher...
dart run flutter_launcher_icons
if errorlevel 1 (
    echo Tentando comando alternativo...
    flutter packages pub run flutter_launcher_icons:main
    if errorlevel 1 (
        echo ERRO: Falha ao gerar icones
        pause
        exit /b 1
    )
)

echo [3/3] Verificando arquivos gerados...
echo.
echo Icones Android:
if exist "android\app\src\main\res\mipmap-hdpi\launcher_icon.png" (
    echo   Android icons gerados com sucesso
) else (
    echo   Android icons nao encontrados
    pause
    exit /b 1
)

echo.
echo ==============================================
echo    Processo concluido!
echo ==============================================
echo.
echo Proximo passo: Execute 'flutter run' para testar
echo.
pause
