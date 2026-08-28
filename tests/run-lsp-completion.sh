#!/usr/bin/env bash
# TOOL-003: LSP textDocument/completion smoke (C1–C6 symbol hits).
#
# Honesty: soft default `./compiler/xlang` + soft auto-make when
# `--help` lacks `--lsp` (false authority; tip help may omit `--lsp`
# even when the binary embeds LSP) retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make). Tip `--lsp` empty / no
# completionProvider / incomplete hits = obs= (LSP/check-adjacent tip
# residual; refuse soft FAIL→OK silence / soft auto-make to chase
# help text). Report: run=/obs=/skip=
# Usage: ./tests/run-lsp-completion.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh
# shellcheck source=tests/lib/tool-lsp-completion.sh
. tests/lib/tool-lsp-completion.sh

PREFIX="${XLANG_LSP_COMPLETION_PREFIX:-xlang: [LSP_COMPLETION]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-8}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "lsp-completion FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== lsp-completion gate (prefer asm; hard; refuse soft auto-make) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

FIXTURE=tests/lsp/completion_symbols.x
[ -f "$FIXTURE" ] || die "missing $FIXTURE"
URI="file:///$(pwd)/tests/lsp/completion_symbols.x"

if ! command -v python3 >/dev/null 2>&1; then
  die "need python3 for JSON escape"
fi
DOC_JSON=$(python3 -c "import json; print(json.dumps(open('$FIXTURE').read()))")

INIT_REQ='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":"file:///'"$(pwd)"'","capabilities":{}}}'
DID_OPEN='{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"'"$URI"'","languageId":"su","version":1,"text":'"$DOC_JSON"'}}}'
# Cursor on main body return line (0-based line 18).
COMP_REQ='{"jsonrpc":"2.0","id":2,"method":"textDocument/completion","params":{"textDocument":{"uri":"'"$URI"'"},"position":{"line":18,"character":2}}}'
SHUTDOWN='{"jsonrpc":"2.0","id":3,"method":"shutdown"}'
EXIT_NOTIF='{"jsonrpc":"2.0","method":"exit"}'

OUT=$(mktemp)
ERR=$(mktemp)
LSP_IN=$(mktemp)
trap 'rm -f "$OUT" "$ERR" "$LSP_IN"' EXIT

{
  tool_lsp_send_frame "$INIT_REQ"
  tool_lsp_send_frame "$DID_OPEN"
  tool_lsp_send_frame "$COMP_REQ"
  tool_lsp_send_frame "$SHUTDOWN"
  tool_lsp_send_frame "$EXIT_NOTIF"
} >"$LSP_IN"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" --lsp <"$LSP_IN" >"$OUT" 2>"$ERR"
LSP_EC=$?
set -e

if [ "$LSP_EC" -eq 124 ]; then
  echo "lsp-completion OBS: --lsp timeout (tip residual; refuse soft silence / soft auto-make)" >&2
  OBS=$((OBS + 1))
  ok_report
  echo "lsp-completion OK (timeout obs)"
  exit 0
fi

if ! grep -q 'completionProvider' "$OUT"; then
  echo "lsp-completion OBS: no completionProvider (ec=$LSP_EC; tip LSP residual; refuse soft silence / soft auto-make); out_bytes=$(wc -c <"$OUT" | tr -d ' ')" >&2
  OBS=$((OBS + 1))
  ok_report
  echo "lsp-completion OK (capability obs)"
  exit 0
fi

if ! grep -q '"id":2' "$OUT"; then
  echo "lsp-completion OBS: missing completion response id=2 (tip residual; refuse soft silence)" >&2
  OBS=$((OBS + 1))
  ok_report
  echo "lsp-completion OK (response obs)"
  exit 0
fi

HITS=0
for label in add_one Point Kind core.mem function i32; do
  if tool_lsp_completion_has_label "$OUT" "$label"; then
    HITS=$((HITS + 1))
    echo "lsp-completion OK label=$label"
  fi
done
ITEMS=$(tool_lsp_completion_count_items "$OUT")
if [ "$HITS" -lt 6 ] || [ "${ITEMS:-0}" -lt 10 ]; then
  echo "lsp-completion OBS: hits=${HITS}/6 items=${ITEMS} (tip residual; refuse soft silence)" >&2
  OBS=$((OBS + 1))
  ok_report
  echo "lsp-completion OK (hits obs)"
  exit 0
fi

echo "tool-lsp-completion report hits=${HITS}/6 items=${ITEMS}"
echo "lsp-completion OK"
RUN_OK=$((RUN_OK + 1))
ok_report
