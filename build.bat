@echo off
rem Builds Commodore98.exe on Windows. Needs LLVM: winget install LLVM.LLVM
cd /d "%~dp0"
if not exist build mkdir build
for %%L in (kernel32 user32 gdi32 shell32) do llvm-dlltool -m i386:x86-64 -d win32\%%L.def -l build\%%L.lib || goto :fail
pushd win32
llvm-rc /FO ..\build\c98.res c98.rc || (popd & goto :fail)
popd
clang --target=x86_64-pc-windows-msvc -Os -ffreestanding -fno-builtin -fno-stack-protector -mno-stack-arg-probe -Isrc -c src\c98.c -o build\c98.obj || goto :fail
lld-link build\c98.obj build\c98.res build\kernel32.lib build\user32.lib build\gdi32.lib build\shell32.lib /subsystem:windows /entry:start /nodefaultlib /opt:ref /opt:icf /out:Commodore98.exe || goto :fail
echo Built Commodore98.exe
exit /b 0
:fail
echo Build failed. Is LLVM installed and on your PATH?
exit /b 1
