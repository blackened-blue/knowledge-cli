#!/bin/bash
# E6b: a real push race, and squash promotion when the reviewer edits a page. Throwaway simulation.
cd "$(dirname "$0")" || exit 9
rm -rf w.git adm a b rv
G="git -c user.name=t -c user.email=t@t"

git init -q --bare -b trunk w.git
$G clone -q w.git adm 2>/dev/null
( cd adm && git checkout -q -b trunk && printf 'name: t\nformat_version: 1\n' > knowledge.yaml \
  && mkdir -p wiki/pages && echo "# base" > wiki/pages/base.md \
  && git add -A && $G commit -q -m init && git push -q origin trunk && git push -q origin trunk:review )
for u in a b; do $G clone -q w.git $u 2>/dev/null; ( cd $u && git checkout -q -B review origin/review ); done

echo "R1) A real race: both members commit a different new page without fetching first"
( cd a && echo "# pa" > wiki/pages/pa.md && git add -A && $G commit -q -m pa )
( cd b && echo "# pb" > wiki/pages/pb.md && git add -A && $G commit -q -m pb )
( cd a && git push -q origin review && echo "   A pushed" )
( cd b && if git push -q origin review 2>/dev/null; then echo "   B pushed without a problem"; else echo "   B push rejected (non-fast-forward), as expected"; fi
  git fetch -q origin && $G merge -q --no-edit origin/review && git push -q origin review && echo "   B fetched, merged and pushed on retry" )
echo "   pages on review now: $(git --git-dir=w.git ls-tree -r --name-only review | grep -c 'wiki/pages/p')"

echo "R2) SQUASH promotion where the reviewer fixes the page while promoting"
( cd a && git fetch -q origin && $G merge -q --ff-only origin/review && printf '# p4\nline one\nline two\n' > wiki/pages/p4.md && git add -A && $G commit -q -m p4 && git push -q origin review )
$G clone -q w.git rv 2>/dev/null
( cd rv && git checkout -q trunk && $G merge -q --squash origin/review && printf '# p4\nline one fixed by reviewer\nline two\n' > wiki/pages/p4.md && git add -A && $G commit -q -m "promote (squash) with a fix" && git push -q origin trunk )
( cd a && printf '# p4\nline one\nline two\nline three by author\n' > wiki/pages/p4.md && git add -A && $G commit -q -m "author edit" && git push -q origin review && echo "   author edited p4 after promotion" )
( cd b && git fetch -q origin && git checkout -q review && $G merge -q --ff-only origin/review 2>/dev/null
  $G merge --no-edit origin/trunk >/dev/null 2>&1
  echo "   member merges trunk into review: conflicted files = $(git diff --name-only --diff-filter=U | wc -l | tr -d ' ')"
  git merge --abort 2>/dev/null )

echo "R3) MERGE-COMMIT promotion where the reviewer's fix is a commit on review itself"
rm -rf w2.git a2 b2 rv2
git init -q --bare -b trunk w2.git
$G clone -q w2.git adm2 2>/dev/null
( cd adm2 && git checkout -q -b trunk && printf 'name: t\nformat_version: 1\n' > knowledge.yaml && mkdir -p wiki/pages && echo "# base" > wiki/pages/base.md \
  && git add -A && $G commit -q -m init && git push -q origin trunk && git push -q origin trunk:review )
for u in a2 b2; do $G clone -q w2.git $u 2>/dev/null; ( cd $u && git checkout -q -B review origin/review ); done
( cd a2 && printf '# p4\nline one\nline two\n' > wiki/pages/p4.md && git add -A && $G commit -q -m p4 && git push -q origin review )
$G clone -q w2.git rv2 2>/dev/null
( cd rv2 && git checkout -q review && printf '# p4\nline one fixed by reviewer\nline two\n' > wiki/pages/p4.md && git add -A && $G commit -q -m "reviewer fix" && git push -q origin review \
  && git checkout -q trunk && $G merge -q --no-ff --no-edit origin/review && git push -q origin trunk && echo "   promoted with a merge commit" )
( cd a2 && git fetch -q origin && git checkout -q review && $G merge -q --no-edit origin/review && printf '# p4\nline one fixed by reviewer\nline two\nline three by author\n' > wiki/pages/p4.md && git add -A && $G commit -q -m "author edit" && git push -q origin review && echo "   author edited p4 after promotion" )
( cd b2 && git fetch -q origin && git checkout -q review && $G merge -q --no-edit origin/review >/dev/null 2>&1
  $G merge --no-edit origin/trunk >/dev/null 2>&1
  echo "   member merges trunk into review: conflicted files = $(git diff --name-only --diff-filter=U | wc -l | tr -d ' ')"
  git merge --abort 2>/dev/null )
