import sys,os,re,time,unicodedata,resource
d=sys.argv[1]
def cjk(c):
    x=ord(c); return 0x0E00<=x<=0x0E7F or 0x4E00<=x<=0x9FFF
rx=re.compile(r'[^\W_]+',re.UNICODE)
def tokens(t):
    out=[]
    for run in rx.findall(unicodedata.normalize('NFC',t).lower()):
        if any(cjk(c) for c in run):
            out.extend([run] if len(run)==1 else [run[i:i+2] for i in range(len(run)-1)])
        else: out.append(run)
    return out
index={}; docterms={}
def add(i,t):
    ts=tokens(t); docterms[i]=set(ts)
    for p,x in enumerate(ts): index.setdefault(x,{}).setdefault(i,[]).append(p)
def remove(i):
    for x in docterms.pop(i,()):
        m=index.get(x)
        if m is not None:
            m.pop(i,None)
            if not m: del index[x]
files=sorted(f for f in os.listdir(d) if f.endswith('.md'))
rd=lambda f: open(os.path.join(d,f),encoding='utf8').read()
t=time.perf_counter(); [add(f,rd(f)) for f in files]; full=time.perf_counter()-t
t=time.perf_counter()
for f in files[:70]: remove(f); add(f,rd(f))
inc=time.perf_counter()-t
def search(q):
    qt=tokens(q); first=index.get(qt[0])
    if not first: return []
    res=[]
    for i,ps in first.items():
        ok=True
        for k in range(1,len(qt)):
            pk=index.get(qt[k],{}).get(i)
            if not pk or not any((p+k) in pk for p in ps): ok=False;break
        if ok: res.append(i)
    return res
t=time.perf_counter()
for r in range(200): search(['\u77e5\u8bc6\u5e93','\u56e2\u961f\u77e5\u8bc6','knowledge base','\u0e01\u0e32\u0e23\u0e04\u0e49\u0e19\u0e2b\u0e32'][r%4])
q=(time.perf_counter()-t)/200*1000
import json; print(json.dumps({'lang':'python','pages':len(files),'fullBuildMs':round(full*1000),'incremental70Ms':round(inc*1000),'queryMs':round(q,2),'terms':len(index),'rssMB':round(resource.getrusage(resource.RUSAGE_SELF).ru_maxrss/1e6)}))
