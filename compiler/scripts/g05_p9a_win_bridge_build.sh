#!/usr/bin/env bash
# g05_p9a_win_bridge_build.sh OUT.o
# tip_l4 Win DIG: build parser_asm_lex_step_bridge via xlang_bi.
# 1) windows-cfg-only view of parser_asm_lex_step_bridge.x
# 2) drop wrap_buf (bi CG002 on that face)
# 3) bi-compile nowrap + wrap stub (paths end in .o — bi keys -c off suffix)
# 4) ld -r merge → OUT
# cwd: compiler/. PLATFORM: WINDOWS.
set -euo pipefail
out="${1:-}"
if [ -z "$out" ]; then
  echo "g05_p9a_win_bridge_build: need <out.o>" >&2
  exit 2
fi
if [ ! -f src/asm/parser_asm_lex_step_bridge.x ]; then
  echo "g05_p9a_win_bridge_build: missing src/asm/parser_asm_lex_step_bridge.x" >&2
  exit 1
fi
if [ ! -f src/asm/parser_asm_lex_wrap_buf_win_stub.x ]; then
  echo "g05_p9a_win_bridge_build: missing wrap stub" >&2
  exit 1
fi
_xl=""
for c in ./xlang_bi.exe ./xlang_bi; do
  if [ -x "$c" ]; then _xl="$c"; break; fi
done
if [ -z "$_xl" ]; then
  echo "g05_p9a_win_bridge_build: no xlang_bi" >&2
  exit 1
fi
_tmpdir="${TMPDIR:-/tmp}"
# MSYS mktemp rejects XXXXXX.ext — create then suffix.
_winonly="$(mktemp "${_tmpdir}/p9a_winonly.XXXXXX")"
_nowrap="$(mktemp "${_tmpdir}/p9a_nowrap.XXXXXX")"
_oa="$(mktemp "${_tmpdir}/p9a_a.XXXXXX")"
_ob="$(mktemp "${_tmpdir}/p9a_b.XXXXXX")"
mv -f "$_winonly" "${_winonly}.x"
_winonly="${_winonly}.x"
mv -f "$_nowrap" "${_nowrap}.x"
_nowrap="${_nowrap}.x"
mv -f "$_oa" "${_oa}.o"
_oa="${_oa}.o"
mv -f "$_ob" "${_ob}.o"
_ob="${_ob}.o"
cleanup() { rm -f "$_winonly" "$_nowrap" "$_oa" "$_ob"; }
trap cleanup EXIT

python3 - "$_winonly" <<'PY'
import re, sys
src = open("src/asm/parser_asm_lex_step_bridge.x", encoding="utf-8").read().splitlines(True)
out = []
i = 0
cfg_re = re.compile(r'^\s*#\[cfg\(target_os\s*=\s*"(linux|macos|freebsd|windows)"\)\]\s*$')

def skip_doc_and_item(i, lines):
    n = len(lines)
    while i < n and lines[i].strip() == "":
        i += 1
    if i < n and lines[i].lstrip().startswith("/**"):
        while i < n and "*/" not in lines[i]:
            i += 1
        if i < n:
            i += 1
        while i < n and lines[i].strip() == "":
            i += 1
    if i >= n:
        return i
    if re.match(r'^\s*extern\s+function\s+', lines[i]) or re.match(r'^\s*export\s+extern\s+', lines[i]):
        while i < n:
            line = lines[i]
            i += 1
            if ";" in line:
                break
        return i
    if re.match(r'^\s*(export\s+)?function\s+', lines[i]):
        depth = 0
        started = False
        while i < n:
            for ch in lines[i]:
                if ch == "{":
                    depth += 1
                    started = True
                elif ch == "}":
                    depth -= 1
            i += 1
            if started and depth <= 0:
                break
        return i
    return i + 1

while i < len(src):
    m = cfg_re.match(src[i])
    if m:
        osname = m.group(1)
        i += 1
        if osname != "windows":
            i = skip_doc_and_item(i, src)
        continue
    out.append(src[i])
    i += 1
open(sys.argv[1], "w", encoding="utf-8").write("".join(out))
PY

python3 - "$_winonly" "$_nowrap" <<'PY'
import re, sys
lines = open(sys.argv[1], encoding="utf-8").read().splitlines(True)
# drop wrap_buf function (+ doc / no_mangle)
ranges = []
i = 0
while i < len(lines):
    if re.match(r'^(export\s+)?function\s+', lines[i]):
        j = i
        while j < len(lines) and j < i + 5:
            if "{" in lines[j]:
                depth = 0
                started = False
                k = j
                while k < len(lines):
                    for ch in lines[k]:
                        if ch == "{":
                            depth += 1
                            started = True
                        elif ch == "}":
                            depth -= 1
                    k += 1
                    if started and depth <= 0:
                        s = i
                        t = i - 1
                        while t >= 0 and lines[t].strip() == "":
                            t -= 1
                        if t >= 0 and "*/" in lines[t]:
                            while t >= 0 and "/**" not in lines[t]:
                                t -= 1
                            if t >= 0:
                                s = t
                        if s > 0 and "no_mangle" in lines[s - 1]:
                            s -= 1
                        name = re.search(r"function\s+(\w+)", lines[i]).group(1)
                        ranges.append((s, k, name))
                        i = k - 1
                        break
                break
            if ";" in lines[j]:
                break
            j += 1
    i += 1
wrap = [r for r in ranges if r[2] == "parser_asm_lex_wrap_buf_c"]
if not wrap:
    open(sys.argv[2], "w", encoding="utf-8").write("".join(lines))
else:
    ws, we, _ = wrap[0]
    out = []
    i = 0
    while i < len(lines):
        if i == ws:
            i = we
            continue
        out.append(lines[i])
        i += 1
    open(sys.argv[2], "w", encoding="utf-8").write("".join(out))
PY

rm -f "$_oa" "$_ob" "$out"
if ! "$_xl" -backend asm -c "$_nowrap" -o "$_oa" >/dev/null 2>&1 || [ ! -s "$_oa" ]; then
  echo "g05_p9a_win_bridge_build: bi nowrap failed" >&2
  exit 1
fi
if ! "$_xl" -backend asm -c src/asm/parser_asm_lex_wrap_buf_win_stub.x -o "$_ob" >/dev/null 2>&1 || [ ! -s "$_ob" ]; then
  echo "g05_p9a_win_bridge_build: bi wrap stub failed" >&2
  exit 1
fi
if ! ld -r -o "$out" "$_oa" "$_ob" 2>/dev/null || [ ! -s "$out" ]; then
  echo "g05_p9a_win_bridge_build: ld -r merge failed" >&2
  rm -f "$out"
  exit 1
fi
echo "g05_ensure: P9a bridge via $_xl nowrap+wrap_stub ld -r (Win bi; tip P9a DIG)" >&2
exit 0
