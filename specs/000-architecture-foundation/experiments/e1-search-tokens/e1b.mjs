import fs from 'node:fs';
const corpus = JSON.parse(fs.readFileSync('corpus.json','utf8'));
const seg = new Intl.Segmenter('th',{granularity:'word'});
const words=[...new Set(corpus.th.flatMap(s=>[...seg.segment(s)].filter(x=>x.isWordLike).map(x=>x.segment)))];
let seed=42; const rnd=()=> (seed=(seed*1664525+1013904223)>>>0)/2**32;
const pages=Array.from({length:5000},()=>Array.from({length:40},()=>words[Math.floor(rnd()*words.length)]).join(''));
const bigrams=s=>{const cs=[...s];const o=[];for(let i=0;i<cs.length-1;i++)o.push(cs[i]+cs[i+1]);return o;};
const idx=pages.map(p=>({set:new Set(bigrams(p)),seq:bigrams(p).join('|')}));
const qs=words.filter(w=>[...w].length>=2).slice(0,60);
let fpAnd=0,fpPhrase=0,tp=0,fn=0;
for(const q of qs){const qb=bigrams(q);const qseq=qb.join('|');
 pages.forEach((p,i)=>{const truth=p.includes(q);const and=qb.every(b=>idx[i].set.has(b));const phr=(' |'+idx[i].seq+'|').includes('|'+qseq+'|');
  if(truth&&and)tp++; if(!truth&&and)fpAnd++; if(!truth&&phr)fpPhrase++; if(truth&&!phr)fn++;});}
console.log({pages:pages.length,queries:qs.length,truePositives:tp,falsePositivesAndOnly:fpAnd,falsePositivesWithAdjacency:fpPhrase,missedWithAdjacency:fn,icu:process.versions.icu});
