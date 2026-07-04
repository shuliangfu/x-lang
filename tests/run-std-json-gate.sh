#!/usr/bin/env bash
# STD-008：std.json 零拷贝 manifest 门禁
#
# 1) std-json-zc-v1.md + manifest
# 2) parse_string_view + json_parse_string_view_c
# 3) native shux：main + zc_parse_string_view 烟测
#
# 用法：./tests/run-std-json-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_JSON_DOC:-analysis/std-json-zc-v1.md}"
MANIFEST="${SHUX_STD_JSON_MANIFEST:-tests/baseline/std-json-manifest.tsv}"
MOD_X="${SHUX_STD_JSON_MOD:-std/json/mod.x}"
JSON_X="${SHUX_STD_JSON_X:-std/json/json.x}"
MIN_APIS=10

# shellcheck source=tests/lib/std-json.sh
. tests/lib/std-json.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== STD-008: std.json zero-copy manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$JSON_X"; do
  if [ ! -f "$f" ]; then
    echo "std-json gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
API_N=0
echo "=== STD-008: API surface ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-json FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_json_has_api "$MOD_X" "$anchor"; then
        echo "std-json FAIL: missing API ${anchor} in $MOD_X" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-json FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-json FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ "$anchor" = "std/json/json.x" ] || [ "$anchor" = "std/json/json.c" ]; then
        if ! std_json_has_c_impl "$JSON_X" "json_parse_string_view_c"; then
          echo "std-json FAIL: missing json_parse_string_view_c in $JSON_X" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
    script|hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-json FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-json FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-json FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-json FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-json FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-json gate FAIL: apis=${API_N} < min ${MIN_APIS}" >&2
  exit 1
fi

for kw in zero copy parse_string_view large object runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "std-json gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "std-json gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-json manifest OK (apis=${API_N})"

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHUX_BIN" ] && native_shu "$SHUX_BIN"; then
  echo "=== STD-008: std.json smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || SHUX_LEGACY_C_FRONTEND=1 make -C compiler shux-c 2>/dev/null || true
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/json/json.o
  FAIL=0
  for smoke in tests/json/main.x tests/json/zc_parse_string_view.x; do
    tag="$(basename "$smoke" .x)"
    if std_json_run_smoke "$SHUX_BIN" "$smoke" "$tag"; then
      echo "std-json smoke OK $tag"
    else
      FAIL=$((FAIL + 1))
    fi
  done
  if [ "$FAIL" -gt 0 ]; then
    echo "std-json gate FAIL: smoke=${FAIL}" >&2
    exit 1
  fi
else
  echo "std-json gate SKIP smoke (no native shux)" >&2
fi

echo "std-json gate OK"
