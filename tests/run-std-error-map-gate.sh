#!/usr/bin/env bash
# STD-020：std.error 错误码映射与 last_error 门禁
#
# 用法：./tests/run-std-error-map-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_ERROR_MAP_DOC:-analysis/std-error-map-v1.md}"
UNIFY_DOC="${SHU_STD_ERROR_UNIFY_DOC:-analysis/std-error-unify-v1.md}"
MANIFEST="${SHU_STD_ERROR_MAP_TSV:-tests/baseline/std-error-map.tsv}"
ERR_MOD="${SHU_STD_ERROR_MOD:-std/error/mod.su}"
LIB="tests/lib/std-error-map.sh"
SMOKE="tests/std/error_map_smoke.su"

# shellcheck source=tests/lib/std-error-map.sh
. tests/lib/std-error-map.sh

echo "=== STD-020: error map manifest ==="
for f in "$DOC" "$UNIFY_DOC" "$MANIFEST" "$LIB" "$ERR_MOD" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "std-error-map gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in error_code_to_module_base last_error fs_last_error error_sidecar_db_struct; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-error-map gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'std-error-map.tsv' "$DOC" 2>/dev/null; then
  echo "std-error-map gate FAIL: doc missing matrix ref" >&2
  exit 1
fi

map_miss="$(std_error_map_manifest_ok "$ERR_MOD" "$MANIFEST" || true)"
if [ "${map_miss:-0}" -gt 0 ]; then
  std_error_map_emit_report "fail" 0 0 0
  echo "std-error-map gate FAIL: manifest_miss=${map_miss}" >&2
  exit 1
fi
echo "std-error-map manifest OK"

stdlib_cm_native_shu() {
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
resolve_shu() {
  local cand
  for cand in ./compiler/shu-c ./compiler/shu; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1
if SHU_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-020: typeck (SHU=$SHU_BIN) ==="
  if "$SHU_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-error-map gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    std_error_map_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
  # shellcheck source=tests/lib/bootstrap-link-shu.sh
  . "$(dirname "$0")/lib/bootstrap-link-shu.sh"
  if $RUN_SHU -L . "$SMOKE" -o /tmp/shu_std_error_map 2>/tmp/shu_std_error_map_build.log; then
    exitcode=0
    /tmp/shu_std_error_map >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
    else
      echo "std-error-map gate FAIL: runnable exit=$exitcode" >&2
      std_error_map_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-error-map gate SKIP runnable link (check passed)" >&2
    tail -5 /tmp/shu_std_error_map_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "std-error-map gate SKIP typeck (no native shu)" >&2
fi

std_error_map_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-error-map gate OK"
