import fs from 'node:fs'; import path from 'node:path';
const dir=process.argv[2]; const isCJK=c=>{const x=c.codePointAt(0);return (x>=0x0E00&&x<=0x0E7F)||(x>=0x4E00&&x<=0x9FFF)};
function tokens(text){const out=[];for(const run of text.normalize('NFC').toLowerCase().match(/[\p{L}\p{N}\p{M}]+/gu)||[]){const cs=[...run]; if(cs.some(isCJK)){ if(cs.length===1)out.push(cs[0]); else for(let i=0;i<cs.length-1;i++)out.push(cs[i]+cs[i+1]); } else out.push(run);} return out;}
const index=new Map(); const docTerms=new Map();
function add(id,text){const ts=tokens(text);docTerms.set(id,new Set(ts));ts.forEach((t,p)=>{let m=index.get(t);if(!m){m=new Map();index.set(t,m);}let a=m.get(id);if(!a){a=[];m.set(id,a);}a.push(p);});}
function remove(id){const ts=docTerms.get(id);if(!ts)return;for(const t of ts){const m=index.get(t);if(m){m.delete(id);if(!m.size)index.delete(t);}}docTerms.delete(id);}
const files=fs.readdirSync(dir).filter(f=>f.endsWith('.md'));
let t0=performance.now(); files.forEach((f,i)=>add(f,fs.readFileSync(path.join(dir,f),'utf8'))); const full=performance.now()-t0;
t0=performance.now(); for(const f of files.slice(0,70)){remove(f);add(f,fs.readFileSync(path.join(dir,f),'utf8'));} const inc=performance.now()-t0;
function search(q){const qt=tokens(q);const first=index.get(qt[0]);if(!first)return[];const res=[];for(const [id,ps] of first){let ok=true;for(let k=1;k<qt.length&&ok;k++){const m=index.get(qt[k]);const pk=m&&m.get(id);ok=!!pk&&ps.some(p=>pk.includes(p+k));}if(ok)res.push(id);}return res;}
t0=performance.now(); let hits=0; for(let r=0;r<200;r++)hits+=search(['\u77e5\u8bc6\u5e93','\u56e2\u961f\u77e5\u8bc6','knowledge base','\u0e01\u0e32\u0e23\u0e04\u0e49\u0e19\u0e2b\u0e32'][r%4]).length; const q=(performance.now()-t0)/200;
console.log(JSON.stringify({lang:'node',pages:files.length,fullBuildMs:Math.round(full),incremental70Ms:Math.round(inc),queryMs:+q.toFixed(2),terms:index.size,rssMB:Math.round(process.memoryUsage().rss/1e6)}));
