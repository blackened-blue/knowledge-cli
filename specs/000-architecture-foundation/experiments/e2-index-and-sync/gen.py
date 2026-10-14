import random,subprocess,json
random.seed(7)
c=json.load(open('../e1-search-tokens/corpus.json',encoding='utf8'))
en=" ".join(c['en']).replace('.','').lower().split()
th=[w for s in c['th'] for w in s.split()]
zh=list("\u56e2\u961f\u77e5\u8bc6\u5e93\u5e2e\u52a9\u65b0\u6210\u5458\u5feb\u901f\u4e86\u89e3\u9879\u76ee\u80cc\u666f\u6bcf\u4efd\u6587\u6863\u90fd\u5fc5\u987b\u6ce8\u660e\u6765\u6e90\u641c\u7d22\u9700\u8981\u5206\u8bcd")
def page(i):
    parts=[f"# Page {i}\n\n"]
    for _ in range(14):
        k=random.random()
        if k<0.6: parts.append(" ".join(random.choice(en) for _ in range(random.randint(12,22)))+".\n\n")
        elif k<0.85: parts.append("".join(random.choice(th) for _ in range(random.randint(4,8)))+"\n\n")
        else: parts.append("".join(random.choice(zh) for _ in range(random.randint(10,24)))+"\u3002\n\n")
    return "".join(parts)
def blob(path,data): return f"M 100644 inline {path}\ndata {len(data)}\n".encode()+data+b"\n"
def write_repo(name,n):
    subprocess.run(['git','init','-q','--bare','-b','main',f'{name}.git'],check=True)
    msg=b"init"
    chunks=[b"commit refs/heads/main\ncommitter T <t@t> 1700000000 +0000\ndata %d\n"%len(msg)+msg+b"\n"]
    chunks.append(blob("knowledge.yaml",b"name: t\nformat_version: 1\n"))
    for i in range(n): chunks.append(blob(f"wiki/pages/page-{i:05d}.md",page(i).encode()))
    subprocess.run(['git','fast-import','--quiet'],cwd=f'{name}.git',input=b"".join(chunks),check=True)
for k in range(5): write_repo(f'w{k}',5000)
