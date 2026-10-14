// Probe for experiment E3 (session-start hooks). Throwaway; not part of the product.
// It appends one JSON line to a log file, prints one line to standard output and exits.
//
// Usage:  node probe.mjs [--label <text>] [--sleep <seconds>] [--exit <code>]
//   --label   a name for this hook setup, written to the log
//   --sleep   wait this many seconds before exiting (tests the 5-second budget)
//   --exit    exit with this code (tests whether a failing hook breaks the session)
// Log file: the value of KC_E3_LOG, or kc-e3.log in the system temp folder.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const args = process.argv.slice(2);
const opt = (name, fallback) => {
  const i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : fallback;
};
const label = opt('--label', 'unlabelled');
const sleepSeconds = Number(opt('--sleep', '0'));
const exitCode = Number(opt('--exit', '0'));
const started = Date.now();

const logFile = process.env.KC_E3_LOG || path.join(os.tmpdir(), 'kc-e3.log');
const interesting = Object.keys(process.env).filter((k) => /claude|kiro|qoder/i.test(k));

const record = {
  time: new Date(started).toISOString(),
  label,
  argv: process.argv,
  cwd: process.cwd(),
  platform: process.platform,
  release: os.release(),
  node: process.version,
  shellHint: process.env.ComSpec || process.env.SHELL || 'unknown',
  stdinIsTTY: Boolean(process.stdin.isTTY),
  pathEntries: (process.env.PATH || process.env.Path || '').split(path.delimiter).length,
  assistantEnvNames: interesting, // names only, never values
};

fs.appendFileSync(logFile, JSON.stringify(record) + '\n');
console.log('knowledge-e3-probe ok ' + label);

setTimeout(() => {
  fs.appendFileSync(logFile, JSON.stringify({ label, finishedAfterMs: Date.now() - started, exitCode }) + '\n');
  process.exit(exitCode);
}, Math.max(0, sleepSeconds) * 1000);
