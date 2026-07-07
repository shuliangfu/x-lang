#!/usr/bin/env bash
# 为 Shux 核心 .x 源文件批量 prepend AGPL 标准文件头（已含 SPDX 则跳过）。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKER='SPDX-License-Identifier: AGPL-3.0-or-later'

read -r -d '' HEADER <<'EOF' || true
// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

EOF

added=0
skipped=0

while IFS= read -r -d '' file; do
  if grep -qF "$MARKER" "$file"; then
    skipped=$((skipped + 1))
    continue
  fi
  tmp="$(mktemp)"
  printf '%s\n' "$HEADER" > "$tmp"
  cat "$file" >> "$tmp"
  mv "$tmp" "$file"
  added=$((added + 1))
done < <(find "$ROOT/compiler/src" "$ROOT/core" "$ROOT/std" -name '*.x' -type f -print0)

echo "license header: added=$added skipped=$skipped"
