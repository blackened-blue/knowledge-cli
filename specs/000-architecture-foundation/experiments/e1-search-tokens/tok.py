import json,re,unicodedata,sys
c=json.load(open('corpus.json',encoding='utf8'))
sp=re.compile(r"[\s.,;:!?\u3002\uff0c\u3001\uff1b\uff1a\uff01\uff1f()]+")
def bigram(s):
    out=[]
    for run in [r for r in sp.split(unicodedata.normalize('NFC',s).lower()) if r]:
        cs=list(run)
        if len(cs)==1: out.append(cs[0])
        else: out.extend(cs[i]+cs[i+1] for i in range(len(cs)-1))
    return out
json.dump({k:[bigram(s) for s in v] for k,v in c.items()},open('py-tokens.json','w'),ensure_ascii=False,separators=(',',':'))
