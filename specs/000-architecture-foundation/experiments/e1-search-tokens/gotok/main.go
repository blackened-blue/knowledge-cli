package main
import ("encoding/json";"os";"regexp";"strings")
var sp=regexp.MustCompile(`[\s.,;:!?\x{3002}\x{ff0c}\x{3001}\x{ff1b}\x{ff1a}\x{ff01}\x{ff1f}()]+`)
func bigram(s string) []string { out:=[]string{}; for _,run:=range sp.Split(strings.ToLower(s),-1){ if run==""{continue}; cs:=[]rune(run); if len(cs)==1{out=append(out,string(cs))}else{for i:=0;i<len(cs)-1;i++{out=append(out,string(cs[i:i+2]))}}}; return out }
func main(){ b,_:=os.ReadFile("corpus.json"); var c map[string][]string; json.Unmarshal(b,&c); o:=map[string][][]string{}; for k,v:=range c{ for _,s:=range v{o[k]=append(o[k],bigram(s))}}; f,_:=os.Create("go-tokens.json"); e:=json.NewEncoder(f); e.SetEscapeHTML(false); e.Encode(o)}
