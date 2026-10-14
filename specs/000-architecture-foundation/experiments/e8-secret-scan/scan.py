import re,random,glob,json,os
random.seed(3)
R=[('aws-access-key',r'\b(AKIA|ASIA)[0-9A-Z]{16}\b'),
('aws-secret',r'(?i)aws_?secret_?(access_?)?key["\']?\s*[:=]\s*["\']?[A-Za-z0-9/+=]{40}'),
('github-token',r'\b(gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{50,})\b'),
('slack-token',r'\bxox[abprs]-[A-Za-z0-9-]{10,}\b'),
('private-key',r'-----BEGIN (?:RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY'),
('jwt',r'\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b'),
('google-api-key',r'(?<![0-9A-Za-z_-])AIza[0-9A-Za-z_-]{35}(?![0-9A-Za-z_-])'),
('stripe-key',r'\b[sr]k_live_[0-9A-Za-z]{20,}\b'),
('llm-api-key',r'\bsk-(?:ant-)?[A-Za-z0-9_-]{32,}\b'),
('generic-assignment',r'(?i)\b(password|passwd|pwd|secret|token|api[_-]?key)\b["\']?\s*[:=]\s*["\']?(?!\$\{|<|\{\{|%|x{4,}|\*{4,}|your|example|changeme|placeholder)[^\s"\'`,;]{8,}')]
C=[(n,re.compile(p)) for n,p in R]
def scan(text): return sorted({n for n,rx in C if rx.search(text)})
al='ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; an=al+al.lower()
def rnd(a,n): return ''.join(random.choice(a) for _ in range(n))
gen={'aws-access-key':lambda:'AKIA'+rnd(al,16),
'github-token':lambda:'ghp_'+rnd(an,36),
'slack-token':lambda:'xoxb-'+rnd('0123456789',11)+'-'+rnd(an,24),
'private-key':lambda:'-----BEGIN RSA PRIVATE KEY-----\n'+rnd(an,64)+'\n-----END RSA PRIVATE KEY-----',
'jwt':lambda:'eyJ'+rnd(an,20)+'.eyJ'+rnd(an,30)+'.'+rnd(an,30),
'google-api-key':lambda:'AIza'+rnd(an+'_-',35),
'stripe-key':lambda:'sk_live_'+rnd(an,24),
'llm-api-key':lambda:'sk-ant-'+rnd(an+'_-',40),
'password-assign':lambda:'password = '+rnd(an,12)+'!',
'token-assign':lambda:'api_key: "'+rnd(an,28)+'"'}
ctx=['Deploy notes:\n{}\nDone.','```yaml\nconfig: {}\n```','The value is {} and must not be shared.','# Setup\n\nexport VALUE={}\n']
seeded=[];miss=[]
for k,g in gen.items():
    for _ in range(5):
        s=g(); t=random.choice(ctx).format(s); seeded.append((k,t))
hit=0
for k,t in seeded:
    found=scan(t)
    if found: hit+=1
    else: miss.append(k)
print('seeded',len(seeded),'flagged',hit,'missed',miss)
# benign corpus (real markdown from local docs, read-only)
import sys
roots=sys.argv[1:]  # folders that hold markdown files to scan (read only)
assert roots, 'usage: python3 scan.py <folder> [<folder> ...]'
files=[f for r in roots for f in glob.glob(r+'/**/*.md',recursive=True)]
flag=[];
for f in files:
    try: t=open(f,encoding='utf8').read()
    except Exception: continue
    for i,line in enumerate(t.split('\n')):
        rules=scan(line)
        if rules: flag.append((os.path.basename(f),i+1,rules,line.strip()[:90]))
print('benign files',len(files),'flagged lines',len(flag),'files with a flag',len({x[0] for x in flag}))
from collections import Counter
print(Counter(r for x in flag for r in x[2]))
for x in flag[:12]: print(' ',x)
