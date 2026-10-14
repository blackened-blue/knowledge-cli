package main
import ("fmt";"os";"runtime/debug")
func main(){ v:="0.0.0"; if bi,ok:=debug.ReadBuildInfo();ok{v=bi.GoVersion}; if len(os.Args)>1&&os.Args[1]=="--version"{fmt.Println("knowledge 0.0.0 ("+v+")")} }
