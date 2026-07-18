#!/usr/bin/env bash
# Prepend layered SPDX headers to product .x sources (skip if any SPDX present).
#   compiler/src  → AGPL-3.0-or-later
#   core, std     → Apache-2.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

HEADER_AGPL='// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
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
// Full text: LICENSE.AGPL-3.0
'

HEADER_APACHE='// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0
'

added=0
skipped=0

prepend_tree() {
  local dir="$1"
  local header="$2"
  while IFS= read -r -d '' file; do
    if grep -qF 'SPDX-License-Identifier:' "$file"; then
      skipped=$((skipped + 1))
      continue
    fi
    tmp="$(mktemp)"
    printf '%s\n' "$header" > "$tmp"
    cat "$file" >> "$tmp"
    mv "$tmp" "$file"
    added=$((added + 1))
  done < <(find "$dir" -name '*.x' -type f -print0 2>/dev/null)
}

prepend_tree "$ROOT/compiler/src" "$HEADER_AGPL"
prepend_tree "$ROOT/core" "$HEADER_APACHE"
prepend_tree "$ROOT/std" "$HEADER_APACHE"

echo "license header: added=$added skipped=$skipped (layered AGPL/Apache)"
