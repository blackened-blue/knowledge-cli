import fs from 'node:fs';
const corpus = JSON.parse(fs.readFileSync('corpus.json','utf8'));
const queries = JSON.parse(fs.readFileSync('queries.json','utf8'));
const wsTok = s => s.toLowerCase().split(/[\s.,;:!?\u3002\uff0c\u3001\uff1b\uff1a\uff01\uff1f()]+/u).filter(Boolean);
const segTok = (s,loc) => [...new Intl.Segmenter(loc,{granularity:'word'}).segment(s.toLowerCase())].filter(x=>x.isWordLike).map(x=>x.segment);
const bigram = s => { const out=[]; for (const run of s.normalize('NFC').toLowerCase().split(/[\s.,;:!?\u3002\uff0c\u3001\uff1b\uff1a\uff01\uff1f()]+/u).filter(Boolean)) { const cs=[...run]; if (cs.length===1) out.push(cs[0]); else for (let i=0;i<cs.length-1;i++) out.push(cs[i]+cs[i+1]); } return out; };
const tokenizers = { whitespace:(s,l)=>wsTok(s), 'icu-segmenter':(s,l)=>segTok(s,l), 'char-bigram':(s,l)=>bigram(s) };
function search(tok, docs, q, loc){ const qt=[...new Set(tok(q,loc))]; if(!qt.length) return []; return docs.map((d,i)=>[i,new Set(tok(d,loc))]).filter(([i,set])=>qt.every(t=>set.has(t))).map(([i])=>i); }
const res={};
for (const [name,tok] of Object.entries(tokenizers)) {
  for (const loc of ['th','zh','en']) {
    const docs=corpus[loc]; let tp=0,fp=0,fn=0,det=true,found=0,total=0;
    for (const [q] of queries[loc]) {
      const truth = docs.map((d,i)=>[i,d.toLowerCase().includes(q.toLowerCase())]).filter(x=>x[1]).map(x=>x[0]);
      const first = JSON.stringify(search(tok,docs,q,loc));
      for (let r=0;r<100;r++) if (JSON.stringify(search(tok,docs,q,loc))!==first) det=false;
      const got = JSON.parse(first);
      const t=new Set(truth); const g=new Set(got);
      tp+=[...g].filter(x=>t.has(x)).length; fp+=[...g].filter(x=>!t.has(x)).length; fn+=[...t].filter(x=>!g.has(x)).length;
    }
    res[`${name}/${loc}`]={recall:+(tp/(tp+fn)).toFixed(3),precision:tp+fp?+(tp/(tp+fp)).toFixed(3):0,falsePositives:fp,missed:fn,deterministic100:det};
  }
}
console.table(res);
// dump bigram tokens for cross-language check
const dump={}; for (const loc of ['th','zh','en']) dump[loc]=corpus[loc].map(bigram);
fs.writeFileSync('node-tokens.json',JSON.stringify(dump));
