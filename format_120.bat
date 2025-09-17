@echo off
echo Formatando codigo Dart com 120 colunas...
dart format --line-length=120 lib/
dart format --line-length=120 test/
echo Formatacao concluida!
pause
