#!/bin/sh
# Builds Commodore98.exe from Linux or macOS by cross-compiling with LLVM.
# Needs: clang, lld (lld-link), llvm (llvm-dlltool, llvm-rc).
#   Ubuntu/Debian: sudo apt install clang lld llvm
#   macOS:         brew install llvm lld
#
#   ./build.sh        build Commodore98.exe in this folder
#   ./build.sh test   build build/c98test, a headless test harness for this OS
set -e
cd "$(dirname "$0")"
mkdir -p build

find_tool() {
    for t in "$@"; do
        if command -v "$t" >/dev/null 2>&1; then echo "$t"; return; fi
        for v in 20 19 18 17 16 15; do
            if command -v "$t-$v" >/dev/null 2>&1; then echo "$t-$v"; return; fi
        done
    done
    echo "missing tool: $1" >&2; exit 1
}

if [ "$1" = "test" ]; then
    ${CC:-cc} -O1 -Isrc -o build/c98test src/c98.c
    echo "Built build/c98test (reads commands on stdin, see README)"
    exit 0
fi

CLANG=$(find_tool clang)
LLD=$(find_tool lld-link)
DLLTOOL=$(find_tool llvm-dlltool)
RC=$(find_tool llvm-rc)

for lib in kernel32 user32 gdi32 shell32; do
    "$DLLTOOL" -m i386:x86-64 -d "win32/$lib.def" -l "build/$lib.lib"
done
(cd win32 && "$RC" /FO ../build/c98.res c98.rc)
"$CLANG" --target=x86_64-pc-windows-msvc -Os -ffreestanding -fno-builtin \
    -fno-stack-protector -mno-stack-arg-probe -Isrc -c src/c98.c -o build/c98.obj
"$LLD" build/c98.obj build/c98.res build/kernel32.lib build/user32.lib build/gdi32.lib build/shell32.lib \
    /subsystem:windows /entry:start /nodefaultlib /opt:ref /opt:icf /out:Commodore98.exe
echo "Built Commodore98.exe ($(wc -c < Commodore98.exe) bytes)"
