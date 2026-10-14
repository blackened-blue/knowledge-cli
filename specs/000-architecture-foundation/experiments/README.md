# Experiments for the Architecture Foundation

These are the throwaway scripts behind experiments E1 to E8 in `../research.md`, plus the probe and checklist for experiment E3. They exist so the project owner can clone this repository and run the experiments on Linux and Windows (tasks T032 and T034).

## Rules

- **Throwaway.** The scripts are not part of the product and must never reach the main line of the product repository (spec 000, FR-017). They live on the `speckit` branch only.
- **English only.** Test text in Thai and Chinese is stored as `\uXXXX` escapes (the JSON files and the source files hold plain ASCII), so the scripts still test those languages at run time.
- **Nothing here is generated output.** Repositories, indexes and binaries that the scripts create are not stored. Run the steps below to create them in a scratch folder outside this repository.

## What you need

| Tool | Used by | Version tried |
|---|---|---|
| Git | all | 2.53 |
| Node.js | E1, E2, E4 | 26.7 |
| Python 3 | E1, E2, E8 | 3.14 |
| Go | E1, E2, E4, E5 (the Go parts) | 1.26 |
| .NET SDK | E4 (optional) | 10.0 |
| A POSIX shell | E6, E7 (on Windows use Git Bash) | bash |

## The experiments

| Folder | Experiment | Decision it supports | Run it |
|---|---|---|---|
| `e1-search-tokens/` | E1: bigram search for Thai, Chinese and English | D-003 | See E1 below |
| `e2-index-and-sync/` | E2: index build, incremental update, query time | D-004 | See E2 below |
| `e3-hooks/` | E3: session-start hooks on Windows | D-008, D-014 | `e3-hooks/E3-checklist.md` |
| `e4-distribution/` | E4: size and start time of a hello program per system | D-002 | See E4 below |
| `e5-integrity/` | E5: checksum rejects altered files | D-005 | See E5 below |
| `e6-unreviewed-pages/` | E6: unreviewed pages with plain Git | D-009 | `bash run-e6.sh` then `bash run-e6b.sh` |
| `e7-paths/` | E7: case and Unicode path collisions | D-006 | `bash run.sh` |
| `e8-secret-scan/` | E8: ten secret rules | D-007 | `python3 scan.py <folder> [<folder> ...]` |

Run every command in a copy or scratch folder, not inside this repository. Scripts E6 and E7 create folders next to themselves, so copy the folder first (for example `cp -R e7-paths /tmp/e7 && cd /tmp/e7 && bash run.sh`).

### E1: search tokens

```text
cp -R e1-search-tokens /tmp/e1 && cd /tmp/e1
node e1.mjs                      # recall, precision, determinism for three tokenizers (writes node-tokens.json)
python3 tok.py                   # writes py-tokens.json
(cd gotok && go build -o ../gotok.bin .) && ./gotok.bin   # writes go-tokens.json
python3 compare-tokens.py        # prints IDENTICAL when the three languages agree
node e1b.mjs                     # false positives of "all bigrams present" versus "adjacent bigrams"
```

To close the gap noted in D-002, add composed and decomposed Unicode forms of the same word to `corpus.json` before running (task T028). Expected on macOS: the bigram tokenizer has recall 1 and precision 1 for all three languages; whitespace splitting fails for Thai and Chinese.

### E2: index and sync

```text
cp -R . /tmp/exp && cd /tmp/exp/e2-index-and-sync     # run from this folder; gen.py reads ../e1-search-tokens/corpus.json
python3 gen.py                             # five bare repositories w0.git .. w4.git, 5,000 pages each, about 360 MB
git clone w0.git c0
node idx/idx.mjs c0/wiki/pages             # prints one JSON line: pages, fullBuildMs, incremental70Ms, queryMs, terms, rssMB
python3 idx/idx.py c0/wiki/pages
(cd idx/go && go build -o ../idx-go . ) && ./idx/idx-go c0/wiki/pages
```

`idx2.mjs` differs from `idx.mjs` in one place only: its word pattern also keeps combining marks (`\p{M}`) inside a word, which Thai text needs. Which of the two produced each number in D-004 was not recorded; run both and compare.

The fetch timings in D-004 (five wikis one after another and in parallel, with a change of 50 new and 20 edited pages) were taken with ad-hoc `git fetch` commands and are **not saved as a script**. To repeat them: clone the five repositories, push a commit with 50 new and 20 edited pages to each bare repository, then time `git fetch` for the five clones in sequence and with `&` in parallel. Also time `git ls-remote` against a real remote for the latency figure.

The 5-second budget must be re-measured with Node start-up included (task T008).

### E4: distribution

```text
# Go: one executable per system
cd e4-distribution/hello-go && go mod init hello 2>/dev/null
GOOS=linux GOARCH=amd64 go build -o hello-linux-amd64 .
GOOS=windows GOARCH=amd64 go build -o hello-windows-amd64.exe .
GOOS=darwin GOARCH=arm64 go build -o hello-darwin-arm64 .
ls -l hello-*                               # record the sizes
time ./hello-linux-amd64 --version          # on a Linux machine; use the matching file on each system

# .NET self-contained single file (optional)
cd ../hello-dotnet && dotnet publish -c Release -r linux-x64 --self-contained -p:PublishSingleFile=true -o out-linux-x64

# Node: start time of the script on the target system
time node ../hello-node/hello.js --version
```

Record the size of each file and the time of `--version` on each system, including the first run (Windows may show a SmartScreen warning for unsigned files). Since D-002 now uses Node.js, the Node start time is the figure that matters most.

### E5: integrity check

```text
cd e5-integrity
go build -o verify .
bash make-fixtures.sh                       # creates pkg.bin, pkg.bin.sha256, tampered.bin, trunc.bin
./verify pkg.bin pkg.bin.sha256             # expect: OK
./verify tampered.bin pkg.bin.sha256        # expect: REJECT, exit code 1
./verify trunc.bin pkg.bin.sha256           # expect: REJECT, exit code 1
```

Task T027 repeats this in Node. The new decision (D-036) relies on the package manager's own integrity check and on provenance, which experiment E9 tests.

## Reporting results

Add one row per run to the table below (in your own copy of this file), then give the rows to the assistant so the numbers are recorded in `../research.md` under the decision named in the table above.

| Experiment | System and version | Machine | Date | Result (numbers or pass/fail) | Notes |
|---|---|---|---|---|---|
| | | | | | |

## What has and has not been checked

- The E1 scripts were re-run after they were converted to ASCII: the Node, Python and Go token files are byte-identical to the originals, and `compare-tokens.py` prints IDENTICAL.
- The E2 index scripts gave the same page and term counts as the originals on a 60-page sample. The E8 script flagged 50 of 50 seeded secrets on a sample. The shell scripts pass a syntax check.
- E5 was re-run from this folder with `make-fixtures.sh`: the intact file gave OK, and the file with a flipped bit and the shortened file were both rejected with exit code 1.
- The E3 probe was run once on macOS (exit code, sleep and log line behave as described). The E3 checklist itself has never been run on Windows.
- The E4 programs were not re-run after copying.
