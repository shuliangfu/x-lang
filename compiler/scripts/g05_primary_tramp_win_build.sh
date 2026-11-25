#!/usr/bin/env bash
# g05_primary_tramp_win_build.sh OUT.o
# tip_l4 Win DIG: build pthin_expr_primary_tramp via xlang_bi split + stubs.
# Full tramp / multi-export TUs hit bi CG002 (59-fn / label match). Proven
# split: calls + faces + export groups + one-fns; five faces SEGV/CG002 even
# alone → pthin_expr_primary_tramp_win_stubs.x. Localize bi Lxml_* then ld -r.
# Gate: all g05_primary_tramp_pure symbols T, tramp-face U = 0 (no false green).
# cwd: compiler/. PLATFORM: WINDOWS.
set -euo pipefail
out="${1:-}"
if [ -z "$out" ]; then
  echo "g05_primary_tramp_win_build: need <out.o>" >&2
  exit 2
fi
if [ ! -f src/asm/pthin_expr_primary_tramp.x ]; then
  echo "g05_primary_tramp_win_build: missing tramp.x" >&2
  exit 1
fi
if [ ! -f src/asm/pthin_expr_primary_tramp_win_stubs.x ]; then
  echo "g05_primary_tramp_win_build: missing win stubs" >&2
  exit 1
fi
_xl=""
for c in ./xlang_bi.exe ./xlang_bi; do
  if [ -x "$c" ]; then _xl="$c"; break; fi
done
if [ -z "$_xl" ]; then
  echo "g05_primary_tramp_win_build: no xlang_bi" >&2
  exit 1
fi
_tmpdir="${TMPDIR:-/tmp}"
# MSYS mktemp rejects XXXXXX.ext — create then suffix.
_workdir="$(mktemp -d "${_tmpdir}/tramp_win.XXXXXX")"
cleanup() { rm -rf "$_workdir"; }
trap cleanup EXIT

_winonly="${_workdir}/winonly.x"
_parts_dir="${_workdir}/parts"
mkdir -p "$_parts_dir"

# 1) windows-cfg-only view (same filter as g05_p9a_win_bridge_build).
python3 - "$_winonly" <<'PY'
import re, sys
src = open("src/asm/pthin_expr_primary_tramp.x", encoding="utf-8").read().splitlines(True)
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
    # Skip attribute lines (#[no_mangle], #[cfg(...)] already consumed).
    while i < n and lines[i].lstrip().startswith("#["):
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

# 2) Split winonly into proven TUs; drop stubbed faces (provided by stubs.x).
python3 - "$_winonly" "$_parts_dir" <<'PY'
import re, sys, os
lines = open(sys.argv[1], encoding="utf-8").read().splitlines(True)
parts_dir = sys.argv[2]

# Locate function ranges: (start, end, name, is_export)
ranges = []
i = 0
while i < len(lines):
    if re.match(r'^\s*(export\s+)?function\s+', lines[i]):
        m = re.search(r'function\s+(\w+)', lines[i])
        name = m.group(1)
        is_export = bool(re.match(r'^\s*export\s+function\s+', lines[i]))
        j = i
        while j < len(lines) and j < i + 8:
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
                        ranges.append((s, k, name, is_export))
                        i = k - 1
                        break
                break
            if ";" in lines[j] and j > i:
                break
            j += 1
    i += 1

# preamble: everything before first function
first_fn = min(r[0] for r in ranges) if ranges else len(lines)
preamble = lines[:first_fn]

# Turn bodies of kept exports into externs when building a sibling TU.
STUBBED = {
    "parser_asm_empty_ident_braces_prefer_block_ptr_c",
    "parser_asm_string_lit_append_byte_ptr_c",
    "parser_asm_struct_lit_append_field_src_c",
    "parser_asm_struct_lit_append_shorthand_src_c",
    "parser_asm_struct_lit_parse_field_value_c",
}
# helpers always defined in calls / set TUs
CALLS = {
    "pthin_primary_call_parse_expr",
    "pthin_primary_call_finish",
    "pthin_primary_call_match",
    "pthin_primary_call_lex_next",
    "pthin_primary_call_type_ref",
    "pthin_primary_call_skip_angle",
    "pthin_primary_call_simd",
    "pthin_primary_write_back",
}
FACES = {"pthin_primary_face_primary", "pthin_primary_face_struct"}
SET_FINISH = {"pthin_primary_set_finish_zeros"}
# skip helpers that only serve stubbed faces
SKIP_HELPERS = {"pthin_primary_set_init_overflow", "pthin_primary_set_copy_name"}

EXP1 = {
    "parser_parse_match_ptr_into_c",
    "parser_parse_at_simd_builtin_ptr_into_c",
    "parser_asm_lbrace_looks_like_block_ptr_c",
}
EXP3 = {
    "parser_asm_parse_anonymous_struct_lit_ptr_c",
    "parser_asm_parse_type_ref_ptr_into_c",
    "parser_asm_skip_angle_count_ptr_into_c",
}
EXP4 = {
    "parser_asm_ident_pre_dispatch_ptr_c",
    "parser_asm_append_type_inst_mangle_c",
    "parser_asm_parse_primary_into_slice_c",
}
ONES = {
    "labi_pthin_expr_primary_slice_marker",
    "parser_asm_finish_struct_lit_from_type_ident_into_c",
    "parser_asm_parse_anonymous_struct_lit_c",
    "parser_asm_parse_struct_lit_fields_ptr_c",
    "parser_asm_string_lit_decode_span_ptr_c",
    "parser_parse_expr_ptr_into_c",
    "parser_finish_struct_lit_ptr_into_c",
    "pthin_expr_primary_tramp_w1539_anchor",
}

def sig_line(block_lines):
    for ln in block_lines:
        m = re.match(r'^\s*(export\s+)?function\s+(.+;)\s*$', ln)
        if m and ";" in ln:
            return "extern function " + m.group(2) + "\n"
        m = re.match(r'^\s*(export\s+)?function\s+(.+)$', ln)
        if m:
            # multi-line sig — rare; fall through
            pass
    # rebuild from first function line through ')' before '{'
    buf = []
    started = False
    for ln in block_lines:
        if re.match(r'^\s*(export\s+)?function\s+', ln):
            started = True
        if not started:
            continue
        buf.append(ln.rstrip("\n"))
        if "{" in ln:
            sig = " ".join(buf)
            sig = re.sub(r'\s*\{.*', '', sig)
            sig = re.sub(r'^\s*export\s+', '', sig)
            return "extern " + sig.strip() + ";\n"
    return None

def collect(names):
    return [r for r in ranges if r[2] in names]

def write_tu(path, keep_names, extra_extern_names=None):
    keep = collect(keep_names)
    # externs for all other non-stubbed functions this TU may call
    extern_names = set()
    if extra_extern_names:
        extern_names |= set(extra_extern_names)
    # default: calls + faces available as extern when not in keep
    for n in CALLS | FACES | SET_FINISH | EXP1 | EXP3 | EXP4 | ONES:
        if n not in keep_names:
            extern_names.add(n)
    for n in STUBBED | SKIP_HELPERS:
        extern_names.discard(n)
    body = []
    seen_ext = set()
    for r in ranges:
        if r[2] in extern_names and r[2] not in seen_ext:
            sl = sig_line(lines[r[0]:r[1]])
            if sl:
                body.append(sl)
                seen_ext.add(r[2])
    for r in keep:
        body.extend(lines[r[0]:r[1]])
        if not body[-1].endswith("\n"):
            body.append("\n")
        body.append("\n")
    with open(path, "w", encoding="utf-8") as f:
        f.write("".join(preamble))
        if not "".join(preamble).endswith("\n"):
            f.write("\n")
        f.write("".join(body))

write_tu(os.path.join(parts_dir, "calls.x"), CALLS, extra_extern_names=set())
write_tu(os.path.join(parts_dir, "faces.x"), FACES)
write_tu(os.path.join(parts_dir, "exp1.x"), EXP1)
write_tu(os.path.join(parts_dir, "exp3.x"), EXP3)
write_tu(os.path.join(parts_dir, "exp4.x"), EXP4)
write_tu(os.path.join(parts_dir, "set_finish.x"), SET_FINISH)
for n in sorted(ONES):
    write_tu(os.path.join(parts_dir, f"one_{n}.x"), {n})
print("parts", len(os.listdir(parts_dir)))
PY

bi_one() {
  local src="$1" obj="$2"
  rm -f "$obj"
  if ! "$_xl" -backend asm -c "$src" -o "$obj" >/dev/null 2>&1 || [ ! -s "$obj" ]; then
    echo "g05_primary_tramp_win_build: bi failed $(basename "$src")" >&2
    return 1
  fi
  # localize bi per-TU Lxml_* so ld -r can merge
  local sym
  while read -r _ _ sym; do
    case "$sym" in
      Lxml_*) objcopy -L "$sym" "$obj" 2>/dev/null || true ;;
    esac
  done < <(nm "$obj" 2>/dev/null | grep ' [Tt] Lxml_' || true)
  return 0
}

OBJS=()
for base in calls faces exp1 exp3 exp4 set_finish; do
  bi_one "${_parts_dir}/${base}.x" "${_parts_dir}/${base}.o"
  OBJS+=("${_parts_dir}/${base}.o")
done
for f in "${_parts_dir}"/one_*.x; do
  bi_one "$f" "${f%.x}.o"
  OBJS+=("${f%.x}.o")
done
bi_one src/asm/pthin_expr_primary_tramp_win_stubs.x "${_parts_dir}/stubs.o"
OBJS+=("${_parts_dir}/stubs.o")

rm -f "$out"
if ! ld -r -o "$out" "${OBJS[@]}" 2>/dev/null || [ ! -s "$out" ]; then
  echo "g05_primary_tramp_win_build: ld -r merge failed" >&2
  rm -f "$out"
  exit 1
fi

# Gate: required T symbols (same list as g05_primary_tramp_pure).
miss=0
for s in labi_pthin_expr_primary_slice_marker \
  parser_asm_append_type_inst_mangle_c \
  parser_asm_struct_lit_append_field_src_c \
  parser_asm_struct_lit_append_shorthand_src_c \
  parser_asm_struct_lit_parse_field_value_c \
  parser_asm_parse_anonymous_struct_lit_c \
  parser_asm_finish_struct_lit_from_type_ident_into_c \
  parser_parse_expr_ptr_into_c \
  parser_finish_struct_lit_ptr_into_c \
  parser_asm_lbrace_looks_like_block_ptr_c \
  parser_asm_empty_ident_braces_prefer_block_ptr_c \
  parser_asm_parse_struct_lit_fields_ptr_c \
  parser_asm_string_lit_decode_span_ptr_c \
  parser_asm_string_lit_append_byte_ptr_c \
  parser_parse_match_ptr_into_c \
  parser_parse_at_simd_builtin_ptr_into_c \
  parser_asm_parse_anonymous_struct_lit_ptr_c \
  parser_asm_parse_type_ref_ptr_into_c \
  parser_asm_skip_angle_count_ptr_into_c \
  parser_asm_ident_pre_dispatch_ptr_c \
  parser_asm_parse_primary_into_slice_c \
  pthin_expr_primary_tramp_w1539_anchor; do
  if ! nm "$out" | grep -E " T [_]?${s}\$" >/dev/null; then
    echo "g05_primary_tramp_win_build: missing T $s" >&2
    miss=1
  fi
done
# Anti-false-green: tramp faces must not remain U in the merged object.
u=0
for s in parser_asm_empty_ident_braces_prefer_block_ptr_c \
  parser_asm_string_lit_append_byte_ptr_c \
  parser_asm_struct_lit_append_field_src_c \
  parser_asm_struct_lit_append_shorthand_src_c \
  parser_asm_struct_lit_parse_field_value_c \
  parser_finish_struct_lit_ptr_into_c \
  parser_parse_expr_ptr_into_c \
  parser_asm_parse_anonymous_struct_lit_ptr_c \
  parser_asm_parse_struct_lit_fields_ptr_c \
  parser_asm_string_lit_decode_span_ptr_c \
  parser_asm_parse_primary_into_slice_c \
  parser_asm_lbrace_looks_like_block_ptr_c \
  parser_asm_ident_pre_dispatch_ptr_c \
  parser_asm_parse_type_ref_ptr_into_c \
  parser_parse_match_ptr_into_c \
  labi_pthin_expr_primary_slice_marker \
  pthin_expr_primary_tramp_w1539_anchor; do
  if nm "$out" | grep -E " U [_]?${s}\$" >/dev/null; then
    echo "g05_primary_tramp_win_build: U face $s (false-green hole)" >&2
    u=1
  fi
done
if [ "$miss" = 1 ] || [ "$u" = 1 ]; then
  rm -f "$out"
  exit 1
fi
echo "g05_ensure: P4 primary trampoline via $_xl split+stubs ld -r (Win bi; tip tramp DIG)" >&2
exit 0
