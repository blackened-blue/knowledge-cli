package main
import ("fmt";"os";"path/filepath";"sort";"strings";"time";"unicode";"runtime")
func isCJK(r rune) bool { return (r>=0x0E00&&r<=0x0E7F)||(r>=0x4E00&&r<=0x9FFF) }
func tokens(t string) []string { out:=[]string{}; var run []rune; flush:=func(){ if len(run)==0{return}; c:=false; for _,r:=range run{ if isCJK(r){c=true;break} }; if c { if len(run)==1{out=append(out,string(run))}else{for i:=0;i<len(run)-1;i++{out=append(out,string(run[i:i+2]))}} } else {out=append(out,string(run))}; run=run[:0] }
 for _,r:=range strings.ToLower(t){ if unicode.IsLetter(r)||unicode.IsNumber(r)||unicode.IsMark(r){run=append(run,r)}else{flush()} }; flush(); return out }
var index=map[string]map[string][]int32{}; var docTerms=map[string]map[string]struct{}{}
func add(id,t string){ ts:=tokens(t); set:=map[string]struct{}{}; for p,x:=range ts{ set[x]=struct{}{}; m:=index[x]; if m==nil{m=map[string][]int32{};index[x]=m}; m[id]=append(m[id],int32(p)) }; docTerms[id]=set }
func remove(id string){ for x:=range docTerms[id]{ if m:=index[x];m!=nil{delete(m,id); if len(m)==0{delete(index,x)}} }; delete(docTerms,id) }
func search(q string) int { qt:=tokens(q); first:=index[qt[0]]; n:=0; for id,ps:=range first{ ok:=true; for k:=1;k<len(qt)&&ok;k++{ pk:=index[qt[k]][id]; found:=false; for _,p:=range ps{ for _,x:=range pk{ if x==p+int32(k){found=true;break}}; if found{break}}; ok=found }; if ok{n++} }; return n }
func main(){ d:=os.Args[1]; ents,_:=os.ReadDir(d); var files []string; for _,e:=range ents{ if strings.HasSuffix(e.Name(),".md"){files=append(files,e.Name())}}; sort.Strings(files)
 rd:=func(f string) string { b,_:=os.ReadFile(filepath.Join(d,f)); return string(b) }
 t:=time.Now(); for _,f:=range files{add(f,rd(f))}; full:=time.Since(t)
 t=time.Now(); for _,f:=range files[:70]{remove(f);add(f,rd(f))}; inc:=time.Since(t)
 qs:=[]string{"\u77e5\u8bc6\u5e93","\u56e2\u961f\u77e5\u8bc6","knowledge base","\u0e01\u0e32\u0e23\u0e04\u0e49\u0e19\u0e2b\u0e32"}; t=time.Now(); for r:=0;r<200;r++{search(qs[r%4])}; q:=float64(time.Since(t).Microseconds())/200/1000
 var m runtime.MemStats; runtime.ReadMemStats(&m)
 fmt.Printf("{\"lang\":\"go\",\"pages\":%d,\"fullBuildMs\":%d,\"incremental70Ms\":%d,\"queryMs\":%.2f,\"terms\":%d,\"heapMB\":%d}\n",len(files),full.Milliseconds(),inc.Milliseconds(),q,len(index),m.Sys/1e6) }
