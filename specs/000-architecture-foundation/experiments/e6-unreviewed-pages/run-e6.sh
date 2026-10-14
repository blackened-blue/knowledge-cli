#!/bin/bash
# E6: unreviewed pages with plain Git. Throwaway simulation. Touches only the directory it lives in.
# Branch names: "trunk" is the reviewed branch, "review" holds reviewed plus unreviewed pages.
cd "$(dirname "$0")" || exit 9
rm -rf wiki.git admin a b rev
G="git -c user.name=t -c user.email=t@t"

git init -q --bare -b trunk wiki.git
$G clone -q wiki.git admin 2>/dev/null
( cd admin && git checkout -q -b trunk \
  && printf 'name: t\nformat_version: 1\n' > knowledge.yaml \
  && mkdir -p wiki/pages && echo "# base" > wiki/pages/base.md \
  && git add -A && $G commit -q -m init \
  && git push -q origin trunk && git push -q origin trunk:review )
for u in a b; do $G clone -q wiki.git $u 2>/dev/null; ( cd $u && git checkout -q -B review origin/review ); done

share() { # share <member dir> <page path> <content>
  local d=$1 path=$2 content=$3
  ( cd "$d" || exit 9
    git fetch -q origin; git checkout -q review
    $G merge -q --no-edit origin/trunk >/dev/null 2>&1
    $G merge -q --no-edit origin/review >/dev/null 2>&1
    if git cat-file -e "origin/review:$path" 2>/dev/null; then echo "HOLD: $path already exists on the unreviewed branch"; exit 2; fi
    mkdir -p "$(dirname "$path")"; printf '%s\n' "$content" > "$path"; git add "$path"; $G commit -q -m "share $path"
    for try in 1 2 3; do
      if git push -q origin review 2>/dev/null; then echo "PUSHED $path (try $try)"; exit 0; fi
      git fetch -q origin; $G merge -q --no-edit origin/review >/dev/null 2>&1
    done
    echo FAILED; exit 1 )
}

echo "1) A shares a new page:";                       share a wiki/pages/p1.md "# p1 by A"
echo "2) B has a stale view, A pushes again, then B pushes a different page:"
( cd b && git fetch -q origin )
share a wiki/pages/p2.md "# p2 by A"
( cd b && git checkout -q review )
share b wiki/pages/p3.md "# p3 by B"
echo "3) B shares the same path as A's unreviewed page p1:"; share b wiki/pages/p1.md "# p1 by B"; echo "   exit=$?"
echo "4) pages on review but not on trunk:";         git --git-dir=wiki.git diff --name-status trunk review

echo "5) reviewer promotes with a SQUASH merge, then members keep working:"
$G clone -q wiki.git rev 2>/dev/null
( cd rev && git checkout -q trunk && $G merge -q --squash origin/review && $G commit -q -m "promote (squash)" && git push -q origin trunk )
echo "   files whose content differs between trunk and review: $(git --git-dir=wiki.git diff --name-only trunk review | wc -l | tr -d ' ')"
( cd a && git fetch -q origin && git checkout -q review && $G merge -q --ff-only origin/review \
  && echo "# p1 by A edited after promotion" > wiki/pages/p1.md && git add -A && $G commit -q -m edit \
  && git push -q origin review && echo "   A pushed an edit to an unreviewed page" )
( cd b && git fetch -q origin && git checkout -q review
  echo "   B merges trunk, then review:"
  $G merge --no-edit origin/trunk 2>&1 | tail -1
  $G merge --no-edit origin/review 2>&1 | tail -1
  echo "   conflicted files: $(git diff --name-only --diff-filter=U | wc -l | tr -d ' ')" )

echo "6) Same idea with a MERGE-COMMIT promotion (no squash), on a fresh copy:"
rm -rf wiki2.git a2 b2 rev2
git clone -q --bare wiki.git wiki2.git
$G clone -q wiki2.git rev2 2>/dev/null
( cd rev2 && git checkout -q trunk && git reset -q --hard origin/review~0 >/dev/null 2>&1; git checkout -q -B trunk origin/trunk )
echo "   (script ends here; extend with the merge-commit steps if step 5 shows conflicts)"
