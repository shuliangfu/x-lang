#!/usr/bin/env bash
# PLATFORM: WINDOWS leftover-PE hybrid — thin→rest return-helper redirect.
# Wrapper picks host Python (MSYS often has Store stub `python3` → exit 49).
set -euo pipefail
o="${1:?usage: win_pe_pabi_redirect_return_helpers.sh <merged.o|exe>}"
here="$(cd "$(dirname "$0")" && pwd)"
py=""
for c in \
  "/c/Program Files/Python312/python.exe" \
  "/c/Program Files/Python311/python.exe" \
  python \
  python3; do
  if command -v "$c" >/dev/null 2>&1 || [ -x "$c" ]; then
    if "$c" -c "import sys; sys.exit(0)" >/dev/null 2>&1; then
      py="$c"
      break
    fi
  fi
done
if [ -z "$py" ]; then
  echo "win_pe_pabi_redirect: no working python" >&2
  exit 1
fi
exec "$py" "$here/win_pe_pabi_redirect_return_helpers.py" "$o"
