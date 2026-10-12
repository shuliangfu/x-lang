#!/usr/bin/env bash
# check_default_no_host_cc.sh — 7.1 evidence gate (w1543).
#
# Claim under test: the default user path (`xlang file.x -o out`, asm backend)
# never runs a host C compiler (cc / gcc / clang / c++ ...), on any host.
#
# How each host proves it:
#   Linux   strace -f records every execve (including failed PATH probes) for
#           each compile; any compiler basename is a violation.
#   Darwin  each compile runs under sandbox-exec with exec of cc/gcc/clang
#           denied; results (rc, output present, output bytes) must match an
#           unsandboxed run, and the unified log must show no exec denial.
#   Windows builds a toolchain copy with every compiler driver removed (ld,
#           crt and libs stay; lib is a junction), puts only that on PATH, and
#           requires the same results and identical .exe bytes as a normal run.
#
# Usage: bash compiler/scripts/check_default_no_host_cc.sh [path/to/xlang]
# Env:   CHECK_NOCC_IMPORT_N   how many import-using tests to add (default 40)
#        CHECK_NOCC_WORK       scratch dir (default under TMPDIR)
# Last line is "check_default_no_host_cc OK ..." (exit 0) or "... FAIL ..." (exit 1).
set -u
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../.." && pwd)
cd "$repo" || exit 1
os=$(uname -s)
case "$os" in MINGW*|MSYS*|CYGWIN*|Windows_NT) plat=win; exe=.exe ;; Darwin) plat=darwin; exe= ;; *) plat=linux; exe= ;; esac
X=${1:-compiler/xlang_asm$exe}
[ -x "$X" ] || { echo "check_default_no_host_cc FAIL no compiler at $X"; exit 1; }
W=${CHECK_NOCC_WORK:-${TMPDIR:-/tmp}/check_nocc_$$}
[ "$plat" = win ] && W=$(cygpath -u "$W")   # PATH entries must not carry a drive colon
rm -rf "$W"; mkdir -p "$W/a" "$W/b"
T() { local secs=$1; shift; if command -v timeout >/dev/null 2>&1; then timeout "$secs" "$@"; else perl -e 'alarm shift; exec @ARGV' "$secs" "$@"; fi; }
fail() { echo "check_default_no_host_cc FAIL plat=$plat $*"; exit 1; }

must="tests/return-value/main.x tests/option/main.x tests/stdlib-import/main.x examples/hello.x tests/float/f32_f64.x tests/io/read_ptr_view_smoke.x"
for f in $must; do [ -f "$f" ] || fail "missing corpus file $f"; done
imp=$(grep -rlF 'import("' tests 2>/dev/null | grep '\.x$' | sort | head -"${CHECK_NOCC_IMPORT_N:-40}")
corpus="$must $imp"
tag() { echo "$1" | tr '/.' '__'; }
ccre='^(cc|c89|c99|gcc|g\+\+|c\+\+|clang|clang\+\+|cpp|tcc|cc1|cc1plus|cl|[A-Za-z0-9_.-]*-(gcc|g\+\+|cc|clang|clang\+\+))(-[0-9.]+)?(\.exe)?$'
n=0; bad=

# One compile. $1 side dir, $2 file, rest = wrapper prefix.
build() { local d=$1 f=$2 o; shift 2; o="$d/$(tag "$f")$exe"; rm -f "$o"
  "$@" "$X" "$f" -o "$o" > "$d/$(tag "$f").log" 2>&1; echo $? > "$d/$(tag "$f").rc"; }
same() { local f=$1 t ra rb; t=$(tag "$f")
  ra=$(cat "$W/a/$t.rc"); rb=$(cat "$W/b/$t.rc")
  [ "$ra" = "$rb" ] || { bad="$bad $f:rc$ra/$rb"; return; }
  if [ -f "$W/a/$t$exe" ] || [ -f "$W/b/$t$exe" ]; then
    cmp -s "$W/a/$t$exe" "$W/b/$t$exe" || bad="$bad $f:bytes"
  fi; }
mustok() { local f t; for f in $must; do t=$(tag "$f"); [ "$(cat "$W/b/$t.rc")" = 0 ] && [ -f "$W/b/$t$exe" ] || bad="$bad $f:nobuild"; done; }

case $plat in
linux)
  command -v strace >/dev/null 2>&1 || fail "strace not installed (needed to record execve)"
  for f in $corpus; do n=$((n+1)); t=$(tag "$f")
    build "$W/b" "$f" T 120 strace -f -qq -e trace=execve -o "$W/b/$t.tr"
    hit=$(grep -oE 'execve\("[^"]+"' "$W/b/$t.tr" | sed 's/^execve("//; s/"$//' | while read -r p; do b=${p##*/}; echo "$b" | grep -qE "$ccre" && echo "$b"; done | sort -u | tr '\n' ',')
    [ -s "$W/b/$t.tr" ] || bad="$bad $f:notrace"
    [ -n "$hit" ] && bad="$bad $f:exec=$hit"
  done
  mustok ;;
darwin)
  command -v sandbox-exec >/dev/null 2>&1 || fail "sandbox-exec not available"
  sb="$W/nocc.sb"
  cat > "$sb" <<'SB'
(version 1)
(allow default)
(deny process-exec
  (regex #"/(cc|c89|c99|gcc|g\+\+|c\+\+|clang|clang\+\+|cpp|cc1|cc1plus)(-[0-9.]+)?$")
  (regex #"/[A-Za-z0-9_.-]*-(gcc|g\+\+|clang|clang\+\+)(-[0-9.]+)?$"))
SB
  t0=$(date '+%Y-%m-%d %H:%M:%S')
  for f in $corpus; do n=$((n+1))
    build "$W/a" "$f" T 120
    build "$W/b" "$f" T 120 sandbox-exec -f "$sb"
    same "$f"
  done
  mustok
  if command -v log >/dev/null 2>&1; then
    dn=$(T 120 log show --style syslog --start "$t0" --predicate 'eventMessage CONTAINS "deny(1) process-exec"' 2>/dev/null | grep -c 'xlang' || true)
    [ "${dn:-0}" = 0 ] || bad="$bad sandbox_denials=$dn"
  fi ;;
win)
  ld=$(command -v ld 2>/dev/null) || fail "ld not on PATH"
  root=$(cd "$(dirname "$ld")/.." && pwd)
  [ -d "$root/lib" ] || fail "no lib dir next to $ld"
  dk="$W/dk"; mkdir -p "$dk/bin"
  for p in "$root"/bin/*; do b=${p##*/}; echo "$b" | grep -qE "$ccre" && continue; cp -p "$p" "$dk/bin/" 2>/dev/null; done
  wlib=$(cygpath -w "$dk/lib"); wroot=$(cygpath -w "$root/lib")
  printf 'mklink /J "%s" "%s"\r\n' "$wlib" "$wroot" > "$W/mk.bat"
  printf 'rmdir "%s"\r\n' "$wlib" > "$W/rm.bat"
  # Always drop the junction (never its target), also on FAIL exits.
  trap '[ -e "$dk/lib" ] && cmd //c "$(cygpath -w "$W/rm.bat")" > /dev/null 2>&1' EXIT
  cmd //c "$(cygpath -w "$W/mk.bat")" > /dev/null 2>&1
  [ -f "$dk/lib/crt2.o" ] || fail "could not create lib junction at $wlib"
  [ -e "$dk/bin/timeout.exe" ] || fail "no timeout.exe in stripped toolchain copy"
  NOCC="$dk/bin:/c/WINDOWS/system32:/c/WINDOWS"
  left=$(PATH="$NOCC" command -v gcc cc clang c++ g++ 2>/dev/null | wc -l | tr -d ' ')
  [ "$left" = 0 ] || fail "compiler still reachable on stripped PATH"
  for f in $corpus; do n=$((n+1))
    build "$W/a" "$f" T 120
    ( PATH="$NOCC"; build "$W/b" "$f" timeout 120 )
    same "$f"
  done
  mustok
  cmd //c "$(cygpath -w "$W/rm.bat")" > /dev/null 2>&1 ;;
esac

[ -z "$bad" ] || fail "n=$n bad:$bad (logs in $W)"
[ "$plat" = win ] && [ ! -e "$W/dk/lib" ] && rm -rf "$W"
[ "$plat" != win ] && rm -rf "$W"
echo "check_default_no_host_cc OK plat=$plat n=$n"
