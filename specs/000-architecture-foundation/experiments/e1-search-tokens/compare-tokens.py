# Compare the bigram tokens produced by Node, Python and Go for the same corpus.
# Run e1.mjs, tok.py and gotok first (see the README). Prints IDENTICAL or the first difference.
import json, sys
a = json.load(open('node-tokens.json', encoding='utf8'))
b = json.load(open('py-tokens.json', encoding='utf8'))
c = json.load(open('go-tokens.json', encoding='utf8'))
same = a == b == c
print('IDENTICAL' if same else 'DIFFERENT')
if not same:
    for lang in a:
        for i, (x, y, z) in enumerate(zip(a[lang], b[lang], c[lang])):
            if not (x == y == z):
                print('first difference:', lang, i)
                sys.exit(1)
