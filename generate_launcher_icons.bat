@echo off
echo ==============================================
echo    Flutter Launcher Icons Generator
echo    Data7 - EXP Application
echo ==============================================
echo.

echo [1/4] Navegando para o diretorio do projeto...
cd /d "d:\Developer\Data7\Expedicao\Flutter\app\exp"

echo [2/4] Instalando dependencias...
flutter pub get
if errorlevel 1 (
    echo ERRO: Falha ao instalar dependencias
    pause
    exit /b 1
)

echo [3/4] Gerando icones do launcher...
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

echo [4/4] Verificando arquivos gerados...
echo.
echo Icones Android:
if exist "android\app\src\main\res\mipmap-hdpi\launcher_icon.png" (
    echo   ✓ Android icons gerados com sucesso
) else (
    echo   ✗ Android icons nao encontrados
)

echo.
echo Icones iOS:
if exist "ios\Runner\Assets.xcassets\AppIcon.appiconset" (
    echo   ✓ iOS icons gerados com sucesso
) else (
    echo   ✗ iOS icons nao encontrados
)

echo.
echo Icones Web:
if exist "web\icons\Icon-192.png" (
    echo   ✓ Web icons gerados com sucesso
) else (
    echo   ✗ Web icons nao encontrados
)

echo.
echo ==============================================
echo    Processo concluido!
echo ==============================================
echo.
echo Proximo passo: Execute 'flutter run' para testar
echo.
pause
