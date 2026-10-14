#!/bin/bash
# Creates the files for experiment E5 in the current folder:
#   pkg.bin            a copy of any binary file (here: the verify program itself)
#   pkg.bin.sha256     its SHA-256
#   tampered.bin       the same file with one bit flipped at a random position
#   trunc.bin          the same file shortened by one byte
# Needs: bash, python3, and shasum or sha256sum. On Windows run it in Git Bash.
set -e
SRC="${1:-./verify}"
[ -f "$SRC" ] || SRC="./verify.exe"
[ -f "$SRC" ] || { echo "build verify first (go build -o verify .)"; exit 2; }
cp "$SRC" pkg.bin
if command -v shasum >/dev/null 2>&1; then shasum -a 256 pkg.bin | cut -d' ' -f1 > pkg.bin.sha256
else sha256sum pkg.bin | cut -d' ' -f1 > pkg.bin.sha256; fi
python3 - <<'PY'
import random
b = bytearray(open('pkg.bin', 'rb').read())
i = random.randrange(len(b))
b[i] ^= 1 << random.randrange(8)
open('tampered.bin', 'wb').write(b)
open('trunc.bin', 'wb').write(open('pkg.bin', 'rb').read()[:-1])
print('flipped one bit at byte', i, 'of', len(b))
PY
ls -l pkg.bin tampered.bin trunc.bin
