package main
import ("crypto/sha256";"encoding/hex";"fmt";"os";"strings")
func main(){ b,_:=os.ReadFile(os.Args[1]); want,_:=os.ReadFile(os.Args[2]); h:=sha256.Sum256(b); got:=hex.EncodeToString(h[:]); if got!=strings.TrimSpace(string(want)){fmt.Println("REJECT: checksum mismatch, nothing installed"); os.Exit(1)}; fmt.Println("OK")}
