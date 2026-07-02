#!/usr/bin/env -S deno run --allow-read
// @ts-nocheck

export {};

type FileReport = {
  file: string;
  externs: string[];
  suspiciousCalls: Array<{
    line: number;
    callee: string;
    text: string;
  }>;
};

const root = Deno.args[0] ?? "/home/shu/shux/std";

async function* walk(dir: string): AsyncGenerator<string> {
  for await (const entry of Deno.readDir(dir)) {
    const path = `${dir}/${entry.name}`;
    if (entry.isDirectory) {
      yield* walk(path);
      continue;
    }
    if (entry.isFile && path.endsWith(".sx")) {
      yield path;
    }
  }
}

function collectExternNames(text: string): Set<string> {
  const names = new Set<string>();
  const re = /^\s*extern function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(/gm;
  for (const match of text.matchAll(re)) {
    names.add(match[1]);
  }
  return names;
}

function stripLineComment(line: string): string {
  const idx = line.indexOf("//");
  return idx >= 0 ? line.slice(0, idx) : line;
}

function stripBlockComments(line: string, inBlockComment: boolean): {
  line: string;
  inBlockComment: boolean;
} {
  let out = "";
  let i = 0;
  let blocked = inBlockComment;
  while (i < line.length) {
    if (blocked) {
      const end = line.indexOf("*/", i);
      if (end < 0) {
        return { line: out, inBlockComment: true };
      }
      i = end + 2;
      blocked = false;
      continue;
    }
    const start = line.indexOf("/*", i);
    if (start < 0) {
      out += line.slice(i);
      break;
    }
    out += line.slice(i, start);
    i = start + 2;
    blocked = true;
  }
  return { line: out, inBlockComment: blocked };
}

function countChar(text: string, ch: string): number {
  let n = 0;
  for (const c of text) {
    if (c === ch) n++;
  }
  return n;
}

function findSuspiciousCalls(text: string, externs: Set<string>) {
  const results: FileReport["suspiciousCalls"] = [];
  if (externs.size === 0) return results;
  const callNames = [...externs].sort((a, b) => b.length - a.length);
  const lines = text.split("\n");
  let unsafeDepth = 0;
  let inBlockComment = false;
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const blockStripped = stripBlockComments(raw, inBlockComment);
    inBlockComment = blockStripped.inBlockComment;
    const line = stripLineComment(blockStripped.line);
    if (unsafeDepth > 0) {
      unsafeDepth += countChar(line, "{") - countChar(line, "}");
      if (unsafeDepth < 0) unsafeDepth = 0;
      continue;
    }
    const unsafeIdx = line.indexOf("unsafe");
    if (unsafeIdx >= 0) {
      const unsafeSlice = line.slice(unsafeIdx);
      const delta = countChar(unsafeSlice, "{") - countChar(unsafeSlice, "}");
      if (delta > 0) {
        unsafeDepth += delta;
      }
      continue;
    }
    if (!line.includes("(")) continue;
    if (/^\s*extern function\b/.test(line)) continue;
    for (const callee of callNames) {
      const callRe = new RegExp(`\\b${callee}\\s*\\(`);
      if (!callRe.test(line)) continue;
      results.push({
        line: i + 1,
        callee,
        text: raw.trim(),
      });
      break;
    }
  }
  return results;
}

const reports: FileReport[] = [];
for await (const file of walk(root)) {
  const text = await Deno.readTextFile(file);
  const externs = collectExternNames(text);
  const suspiciousCalls = findSuspiciousCalls(text, externs);
  if (suspiciousCalls.length === 0) continue;
  reports.push({
    file,
    externs: [...externs].sort(),
    suspiciousCalls,
  });
}

reports.sort((a, b) => a.file.localeCompare(b.file));

for (const report of reports) {
  console.log(`# ${report.file}`);
  console.log(`externs: ${report.externs.join(", ")}`);
  for (const call of report.suspiciousCalls) {
    console.log(`  L${call.line} ${call.callee}: ${call.text}`);
  }
  console.log("");
}

console.log(`TOTAL_FILES=${reports.length}`);
