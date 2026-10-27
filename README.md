# Commodore 98 Workbench

What would Commodore have shipped in 1998 if it had survived? This is a tiny what-if
desktop for Windows: a C64-style boot, a late-90s windowed GUI, a working
Commodore-style BASIC and a game maker, all in one **~80 KB .exe** with no emulator,
no VM and no runtime.

![Commodore 98 desktop](docs/desktop.png)

## Features

- **Boot sequence:** blue C64 screen that types `LOAD"WORKBENCH",8,1` and loads the desktop
- **Desktop that fits your monitor:** the window resizes and maximizes, and the workspace grows
  with it (auto scale, or pick 1x to 4x). Menu bar with clock, context menus, draggable and
  resizable windows
- **Your own files:** New Note and New Folder from the right-click menu, rename (F2), Trash with
  Empty Trash and Delete Permanently. Notes save as you type, as real files in the `desktop`
  folder next to the exe
- **Drag and drop:** put icons anywhere on the desktop or in folders and they stay there. Drop
  icons onto folders or the Trash to move them, or drag them between folder windows
- **Settings:** screen scale, small or large icons, five colour themes, backdrop style,
  boot screen, BASIC screen size. Saved to `settings.ini`
- **BASIC 7.0:** C64 flavour with a toolbar (Run, Stop, Clear, Reset, Edit): `PRINT`, `INPUT`,
  `IF..THEN`, `GOTO`, `GOSUB`, `FOR..NEXT`, string functions, `POKE 53280/53281/646` colours,
  `SYS 64738`, and the PETSCII diagonals, so `10 PRINT CHR$(205.5+RND(1));:GOTO 10` works
- **Game Maker:** a code editor with New, Open, Save, Run and a built-in reference. BASIC gets
  game commands: `GET` (keys without waiting, arrow keys included), `LOCATE`, `COLOR`, `SLEEP`,
  `DIM` arrays, `SCRN`, `PEEK`/`POKE` screen memory, `ON..GOTO`. Includes DODGE, a complete game
- **Program library:** `cassettes/` and `floppies/` folders next to the exe

![Game Maker running DODGE](docs/gamemaker.png)

![Game Maker editor with the DODGE example](docs/editor.png)

![BASIC listing the floppies folder](docs/basic.png)

## Download

Grab `Commodore98.zip` from the [Releases](../../releases) page, unzip it anywhere and run
`Commodore98.exe`. Windows SmartScreen may warn about an unsigned app the first time:
choose **More info → Run anyway**.

## Using the program library

| Command | What it does |
|---|---|
| `LOAD"$",8` or `DIR` | List the `floppies` folder, numbered |
| `LOAD` | List the `cassettes` folder ("PRESS PLAY ON TAPE") |
| `RUN 1` | Start entry 1 of the list you just showed |
| `LOAD"GUESS"` | Load a program by name without running it |
| `SAVE"MYGAME"` | Save the program you typed to `floppies/MYGAME.BAS` |

Game Maker's **Save** writes to `floppies/` too, so anything you make shows up in the list.

`.bas` files are plain text BASIC programs (one numbered line per line) and run inside
Commodore 98.

### Playing real C64 games

Real C64 files (`.prg`, `.d64`, `.t64`, `.tap`, `.crt`, `.g64`, `.d71`, `.d81`) are 6502
machine code, so they need an emulator. Commodore 98 drives [VICE](https://vice-emu.sourceforge.io/)
for you:

1. Download VICE for Windows (64-bit) and unzip it into the `emulator` folder next to
   `Commodore98.exe` (Commodore 98 creates the folder on first run).
2. Put games in `floppies/` or `cassettes/`.
3. In BASIC, `LOAD"$",8` and then `RUN 3`: the game boots in VICE with `-autostart`.

Commodore 98 finds `x64sc.exe` in `emulator/`, `emulator/bin/` or one folder deeper (the way
the VICE zip unpacks). Without VICE it falls back to whatever app Windows associates with the
file type, and otherwise explains what to install.

Type `HELP` inside BASIC for the full command list. `ESC` is RUN/STOP.

## Building

The app is one C file (`src/c98.c`) that talks to Win32 directly. It uses no Windows SDK
headers and no C runtime, which is why it is so small.

**From Linux or macOS** (cross-compiles with LLVM):

```sh
sudo apt install clang lld llvm     # or: brew install llvm lld
./build.sh
```

**From Windows** (install LLVM with `winget install LLVM.LLVM`):

```bat
build.bat
```

Either way you get `Commodore98.exe` in the repo folder, next to the `cassettes` and
`floppies` folders, ready to run.

Every push to `main` is built by GitHub Actions. Pushing a tag such as `v1.0` also
publishes `Commodore98.zip` as a release.

### Test harness

`./build.sh test` builds the same code for your own OS as `build/c98test`, a headless
version that reads scripted input on stdin and can save screenshots. One command per line:

```
w 60            run 60 frames (16 ms each)
t RUN           type text        e   press Return      k 27   send a key code
c 300 200       click            D 48 120   double-click      R x y   right-click
K 0..9          special keys (0 left 1 right 2 up 3 down 4 home 5 end 6 pgup 7 pgdn 8 del 9 F2)
z 2560 1440     resize the "window" (client pixels)       W 1   mouse wheel
p / r x y       mouse down / up (with m x y to move in between, for dragging)
s shot.ppm      save a screenshot
```

```sh
printf 'w 250\nt PRINT 2+2\ne\nw 2\ns shot.ppm\n' | ./build/c98test
```

## Project layout

```
src/c98.c          the whole app: graphics, GUI, BASIC, editor, Win32 layer, test harness
src/font16.h       8x16 bitmap font
win32/             import-library definitions, icon and resource script
cassettes/         sample programs listed by LOAD
floppies/          sample programs listed by LOAD"$",8 (DODGE, GUESS, MAZE)
emulator/          (created on first run) unzip VICE here to play real C64 games
docs/              screenshots and the readme that ships inside the release zip
```

## Credits and license

Code released under the [MIT License](LICENSE).

The font is extracted from the X11 `koi8x16b` bitmap font (Misc Fixed Bold, from
font-misc-cyrillic), whose license says it "may be distributed and modified without
restrictions."

This is a fan-made project. It is not affiliated with or endorsed by any owner of the
Commodore name or trademarks, and it contains no Commodore ROM code.
