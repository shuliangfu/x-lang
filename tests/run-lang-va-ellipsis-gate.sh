#!/usr/bin/env bash
# Cap 10.7.1 language: parse `...` → is_variadic → host-C `, ...` on decl *and* def.
# slice5: parse + decl emit; slice6: definition emit must match.
# PLATFORM: SHARED — L2 probe; Ubuntu gold. Does not run xlang check.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
XLANG="${XLANG:-$ROOT/compiler/xlang}"
SRC="$ROOT/tests/sys/lang_va_ellipsis_smoke.x"
OUT_C="/tmp/xlang_lang_va_ellipsis_$$.c"
trap 'rm -f "$OUT_C"' EXIT

if [[ ! -x "$XLANG" ]]; then
  echo "xlang: [XLANG_LANG_VA_ELLIPSIS] status=fail run=0 obs=0 skip=1 reason=no_xlang" >&2
  exit 1
fi

# Emit host-C (not link) so we can grep prototypes and definitions.
if ! "$XLANG" -E "$SRC" >"$OUT_C" 2>/tmp/xlang_lang_va_ellipsis_err.$$; then
  echo "xlang: [XLANG_LANG_VA_ELLIPSIS] status=fail run=0 obs=0 skip=0 reason=emit" >&2
  tail -20 /tmp/xlang_lang_va_ellipsis_err.$$ >&2 || true
  rm -f /tmp/xlang_lang_va_ellipsis_err.$$
  exit 1
fi
rm -f /tmp/xlang_lang_va_ellipsis_err.$$

# Must see `, ...` at least twice ideally (extern/proto + definition), and at least
# one definition line: `lang_va_ellipsis_probe(... , ...)` not only `extern`.
if ! grep -E ',\s*\.\.\.' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_ELLIPSIS] status=fail run=0 obs=0 skip=0 reason=no_ellipsis" >&2
  grep -n 'lang_va_ellipsis\|ellipsis\|\.\.\.' "$OUT_C" | head -20 >&2 || true
  exit 1
fi

# Definition (non-extern) must carry `, ...` — slice6 residual vs decl-only emit.
def_lines="$(grep -E '^int32_t[[:space:]]+lang_va_ellipsis_probe\(' "$OUT_C" || true)"
if [[ -z "$def_lines" ]]; then
  echo "xlang: [XLANG_LANG_VA_ELLIPSIS] status=fail run=0 obs=0 skip=0 reason=no_def" >&2
  grep -n 'lang_va_ellipsis_probe' "$OUT_C" | head -20 >&2 || true
  exit 1
fi
if ! echo "$def_lines" | grep -E ',\s*\.\.\.' >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_ELLIPSIS] status=fail run=0 obs=0 skip=0 reason=no_ellipsis_def" >&2
  echo "$def_lines" >&2
  exit 1
fi

host="$(uname -s 2>/dev/null || echo unknown)/$(uname -m 2>/dev/null || echo unknown)"
echo "xlang: [XLANG_LANG_VA_ELLIPSIS] status=ok run=1 obs=0 skip=0 host=$host"
