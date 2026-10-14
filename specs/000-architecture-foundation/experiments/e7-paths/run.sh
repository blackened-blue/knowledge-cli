#!/bin/bash
cd "$(dirname "$0")"
G="git -c user.name=t -c user.email=t@t"
echo "filesystem case-insensitive? $(mkdir -p fs && cd fs && touch Probe && [ -e probe ] && echo yes || echo no)"
git init -q --bare -b trunk src.git
git init -q work && cd work
b1=$(echo one | git hash-object -w --stdin); b2=$(echo two | git hash-object -w --stdin)
# register two paths that differ only in letter case, and a composed/decomposed accent pair
git update-index --add --cacheinfo 100644,$b1,wiki/pages/Alpha.md
git update-index --add --cacheinfo 100644,$b2,wiki/pages/alpha.md
git update-index --add --cacheinfo 100644,$b1,$'wiki/pages/caf\xc3\xa9.md'
git update-index --add --cacheinfo 100644,$b2,$'wiki/pages/cafe\xcc\x81.md'
git update-index --add --cacheinfo 100644,$b1,wiki/pages/CON.md
tree=$(git write-tree); c=$(echo m | $G commit-tree $tree); git update-ref refs/heads/trunk $c; git push -q ../src.git trunk
cd .. && git clone -q src.git out 2>&1 | head -3
echo "files on disk after checkout:"; ls out/wiki/pages | cat
echo "tracked paths in the repository:"; git --git-dir=src.git ls-tree -r --name-only trunk | cat
echo "paths colliding after lower-case + NFC normalisation:"
python3 - <<'PY'
import subprocess,unicodedata,collections
names=subprocess.run(['git','--git-dir=src.git','ls-tree','-r','--name-only','-z','trunk'],capture_output=True).stdout.decode('utf8').split('\0')
d=collections.defaultdict(list)
for n in filter(None,names): d[unicodedata.normalize('NFC',n).casefold()].append(n)
for k,v in d.items():
    if len(v)>1: print('  COLLISION:',[unicodedata.normalize('NFC',x) for x in v],'raw bytes differ:',len(set(x.encode() for x in v))==len(v))
reserved={'con','prn','aux','nul'}|{f'com{i}' for i in range(1,10)}|{f'lpt{i}' for i in range(1,10)}
for n in filter(None,names):
    stem=n.rsplit('/',1)[-1].split('.')[0].casefold()
    if stem in reserved: print('  RESERVED NAME on Windows:',n)
PY
