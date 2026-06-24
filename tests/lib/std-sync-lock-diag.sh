#!/usr/bin/env bash
# std-sync-lock-diag.sh — STD-111 manifest 与烟测辅助（F-sync-lock-diag v2：逻辑在 sync.sx）

STD_SYNC_LOCK_DIAG_PREFIX="${SHUX_STD111_SYNC_LOCK_DIAG_PREFIX:-shux: [SHUX_STD111_SYNC_LOCK_DIAG]}"

# 校验 manifest 中 api/symbol/file；symbol 可在 sync.sx 或 tls glue。
std_sync_lock_diag_symbols_ok() {
  local mod_sx="$1"
  local sync_diag_sx="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-sync-lock-diag FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/sync/sync.c|std/sync/sync_lock_diag_glue.c|std/sync/sync.sx) path="$sync_diag_sx" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sync-lock-diag FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-sync-lock-diag FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_sync_lock_diag_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-lock_diag}"
  local exe="/tmp/shux_std_sync_lock_diag_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-sync-lock-diag FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-sync-lock-diag FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：lock_diag_smoke_ok.c + sync.o（需 shux-c 产出 sync.o）。
std_sync_lock_diag_run_c_smoke() {
  local sync_tls_glue="$1"
  local src="tests/sync/lock_diag_smoke_ok.c"
  local out="/tmp/shux_std_sync_lock_diag_c_$$"
  local sync_o="std/sync/sync.o"
  local rt_os="compiler/runtime_sync_os.o"
  local rt_tls="compiler/runtime_sync_lock_diag_tls.o"
  if [ ! -f "$sync_o" ]; then
    # shellcheck source=tests/lib/build-std-c-o.sh
    . tests/lib/build-std-c-o.sh
    ensure_std_c_o ../std/sync/sync.o 2>/dev/null || true
  fi
  ensure_runtime_sync_os_o 2>/dev/null || true
  ensure_runtime_sync_lock_diag_tls_o 2>/dev/null || true
  if [ ! -f "$sync_o" ] || [ ! -f "$rt_os" ] || [ ! -f "$rt_tls" ]; then
    echo "std-sync-lock-diag FAIL: missing sync.o or runtime sync .o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sync_o" "$rt_os" "$rt_tls" -lpthread 2>/dev/null; then
    if ! cc -std=c11 -O1 -o "$out" "$src" "$sync_o" "$rt_os" "$rt_tls" 2>/dev/null; then
      echo "std-sync-lock-diag FAIL: compile C smoke" >&2
      return 1
    fi
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sync-lock-diag FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

std_sync_lock_diag_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_SYNC_LOCK_DIAG_PREFIX} status=${status} c=${c_ok} sx=${su_ok} skip=${skip}"
}
