#!/usr/bin/env bash
# Cap 10.7.1 language slice7–14: va_* → Cap (-E/host-cc) + product -backend c -o + default asm -o.
# slice7–10: Cap rewrite/arity/host-cc/preamble; slice11: invoke_cc Cap -I;
# slice12: asm Cap va_start/end/va_arg_i32; slice13: asm Cap va_arg_i64/ptr;
# slice14: typed turbofish va_arg<T>(ap).
# PLATFORM: SHARED — L2 probe; Ubuntu gold. Does not run xlang check.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
XLANG="${XLANG:-$ROOT/compiler/xlang}"
SRC="$ROOT/tests/sys/lang_va_cap_builtins_smoke.x"
OUT_C="/tmp/xlang_lang_va_cap_builtins_$$.c"
OUT_BIN="/tmp/xlang_lang_va_cap_builtins_$$"
OUT_PROD="/tmp/xlang_lang_va_cap_builtins_prod_$$"
trap 'rm -f "$OUT_C" "$OUT_BIN" "$OUT_PROD"' EXIT

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

# Call site must emit trailing variadic args (slice8 arity + slice13 i64/ptr).
if ! grep -E 'lang_va_cap_probe\([^)]*42' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_variadic_call" >&2
  grep -n 'lang_va_cap_probe' "$OUT_C" | head -20 >&2 || true
  exit 1
fi
# slice13–14: typed va_arg<T> / helpers must rewrite to Cap macros (not bare va_arg calls).
if ! grep -F 'int64_t)(xlang_va_arg(ap, int64_t)' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_va_arg_i64" >&2
  grep -n 'va_arg\|xlang_va_arg' "$OUT_C" | head -30 >&2 || true
  exit 1
fi
if ! grep -F 'uint8_t *)(xlang_va_arg(ap, uint8_t *)' "$OUT_C" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_va_arg_ptr" >&2
  grep -n 'va_arg\|xlang_va_arg' "$OUT_C" | head -30 >&2 || true
  exit 1
fi

# Cap 10.7.1 slice9: host-cc + run — Cap macros must be real (expect exit 42).
CC_BIN="${CC:-cc}"
if ! "$CC_BIN" -std=gnu11 -O0 -Wall -I"$ROOT/compiler/include" -o "$OUT_BIN" "$OUT_C" \
  2>/tmp/xlang_lang_va_cap_builtins_cc.$$; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=host_cc" >&2
  cat /tmp/xlang_lang_va_cap_builtins_cc.$$ >&2 || true
  rm -f /tmp/xlang_lang_va_cap_builtins_cc.$$
  exit 1
fi
rm -f /tmp/xlang_lang_va_cap_builtins_cc.$$
if [[ ! -x "$OUT_BIN" ]]; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_exe" >&2
  exit 1
fi
set +e
"$OUT_BIN"
rc=$?
set -e
if [[ "$rc" -ne 42 ]]; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=run_rc rc=$rc want=42" >&2
  exit 1
fi

# Cap 10.7.1 slice10: product -o preamble must fold Cap va header (N=224 slot).
if ! grep -F 'xlang_va_cap.h' "$ROOT/compiler/seeds/rt_preamble.from_x.c" >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=no_preamble_cap" >&2
  exit 1
fi

# Cap 10.7.1 slice11: product opt-in host-C -o must resolve Cap headers via invoke_cc -I.
# PC: C is opt-in (ALLOW_HOST_CC + -backend c); default asm Cap va remains residual.
rm -f "$OUT_PROD"
set +e
XLANG_ALLOW_HOST_CC=1 "$XLANG" build -backend c -o "$OUT_PROD" "$SRC" \
  >/tmp/xlang_lang_va_cap_builtins_prod.$$ 2>&1
prod_rc=$?
set -e
if [[ "$prod_rc" -ne 0 ]] || [[ ! -x "$OUT_PROD" ]]; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=product_c_o" >&2
  cat /tmp/xlang_lang_va_cap_builtins_prod.$$ >&2 || true
  rm -f /tmp/xlang_lang_va_cap_builtins_prod.$$
  exit 1
fi
rm -f /tmp/xlang_lang_va_cap_builtins_prod.$$
set +e
"$OUT_PROD"
prod_run=$?
set -e
if [[ "$prod_run" -ne 42 ]]; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=product_run_rc rc=$prod_run want=42" >&2
  exit 1
fi

# Cap 10.7.1 slice12–14: default product asm -o (no ALLOW_HOST_CC) must exit 42.
# slice14: no UNDEF for va_arg / va_arg_i64 / va_arg_ptr either.
OUT_ASM="/tmp/xlang_lang_va_cap_builtins_asm_$$"
trap 'rm -f "$OUT_C" "$OUT_BIN" "$OUT_PROD" "$OUT_ASM"' EXIT
rm -f "$OUT_ASM"
set +e
"$XLANG" -o "$OUT_ASM" "$SRC" >/tmp/xlang_lang_va_cap_builtins_asm.$$ 2>&1
asm_rc=$?
set -e
if [[ "$asm_rc" -ne 0 ]] || [[ ! -x "$OUT_ASM" ]]; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=product_asm_o" >&2
  cat /tmp/xlang_lang_va_cap_builtins_asm.$$ >&2 || true
  rm -f /tmp/xlang_lang_va_cap_builtins_asm.$$
  exit 1
fi
rm -f /tmp/xlang_lang_va_cap_builtins_asm.$$
if nm -u "$OUT_ASM" 2>/dev/null | grep -E 'U (va_start|va_end|va_arg_i32|va_arg_i64|va_arg_ptr|va_arg)$' >/dev/null 2>&1; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=asm_undef_va" >&2
  nm -u "$OUT_ASM" 2>/dev/null | grep -E 'va_' >&2 || true
  exit 1
fi
set +e
"$OUT_ASM"
asm_run=$?
set -e
if [[ "$asm_run" -ne 42 ]]; then
  echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=fail run=0 obs=0 skip=0 reason=asm_run_rc rc=$asm_run want=42" >&2
  exit 1
fi

host="$(uname -s 2>/dev/null || echo unknown)/$(uname -m 2>/dev/null || echo unknown)"
echo "xlang: [XLANG_LANG_VA_CAP_BUILTINS] status=ok run=1 obs=0 skip=0 host=$host"
