#!/usr/bin/env bash
# Cap 10.7.1 language slice7: va_start/arg/end → Cap xlang_va_* + header include.
# PLATFORM: SHARED — L2 -E probe; Ubuntu gold. Does not run xlang check.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
XLANG="${XLANG:-$ROOT/compiler/xlang}"
SRC="$ROOT/tests/sys/lang_va_cap_builtins_smoke.x"
OUT_C="/tmp/xlang_lang_va_cap_builtins_$$.c"
trap 'rm -f "$OUT_C"' EXIT

if [[ ! -x "$XLANG" ]]; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=1 reason=no_xlang" >&2
  exit 1
fi

if ! "$XLANG" -E "$SRC" >"$OUT_C" 2>/tmp/xlang_lang_va_cap_builtins_err.$$; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=emit" >&2
  tail -40 /tmp/xlang_lang_va_cap_builtins_err.$$ >&2 || true
  rm -f /tmp/xlang_lang_va_cap_builtins_err.$$
  exit 1
fi
rm -f /tmp/xlang_lang_va_cap_builtins_err.$$

# Cap header must appear in -E prologue.
if ! grep -F '#include <xlang_va_cap.h>' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_cap_header" >&2
  head -40 "$OUT_C" >&2 || true
  exit 1
fi

# VaList local → xlang_va_list spelling.
if ! grep -E 'xlang_va_list[[:space:]]+ap' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_valist" >&2
  grep -n 'ap\|VaList\|va_list' "$OUT_C" | head -30 >&2 || true
  exit 1
fi

# Builtin rewrites (must not leave bare va_start( as a C call to undeclared fn).
if ! grep -F 'xlang_va_start(' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_va_start" >&2
  grep -n 'va_start\|xlang_va_' "$OUT_C" | head -30 >&2 || true
  exit 1
fi
if ! grep -F 'xlang_va_arg(' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_va_arg" >&2
  grep -n 'va_arg\|xlang_va_' "$OUT_C" | head -30 >&2 || true
  exit 1
fi
if ! grep -F 'xlang_va_end(' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_va_end" >&2
  grep -n 'va_end\|xlang_va_' "$OUT_C" | head -30 >&2 || true
  exit 1
fi

host="$(uname -s 2>/dev/null || echo unknown)/$(uname -m 2>/dev/null || echo unknown)"
echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=ok run=1 obs=0 skip=0 host=$host"
