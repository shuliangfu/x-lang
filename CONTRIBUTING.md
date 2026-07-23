# Contributing to Xlang

Thank you for considering a contribution.

## Layered licenses

Xlang uses **layered licensing** (see root [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE)):

| Area | License |
|------|---------|
| `compiler/`, `tools/`, root build scripts | **AGPL-3.0-or-later** |
| `core/`, `std/` | **Apache-2.0** |
| `examples/`, `tests/` (outside `compiler/`) | **Apache-2.0** |
| `editors/vscode/` | **Apache-2.0** |
| `editors/tree-sitter-xlang/`, `editors/vim/` | **Apache-2.0** |

By submitting a contribution (pull request, patch, or other submission), you
agree that:

1. You have the right to submit the contribution under the license that applies
   to the files you touch (table above).
2. You license your contribution to the project under **that same license**
   (and, for AGPL-covered paths, under AGPL-3.0-or-later as published in
   `LICENSE.AGPL-3.0`).
3. You grant the copyright holder permission to **relicense your contribution
   within the same layer** for project needs (for example, offering commercial
   AGPL exemptions for Layer A code you contributed, or routine SPDX/header
   maintenance). This does **not** move Layer B (Apache) code under AGPL, or
   the reverse, without an explicit dual grant in the contribution.

If you cannot offer these terms, do not submit the change; open an issue instead.

## Certificate of Origin (DCO-style)

Each commit should include:

```text
Signed-off-by: Your Name <your@email.example>
```

Use `git commit -s`. This certifies that the contribution is made under the
Developer Certificate of Origin (https://developercertificate.org/).

## Source headers

- New or substantially edited **product `.x`** files should carry the SPDX
  header for their layer (templates in `NOTICE`).
- Do **not** copy AGPL headers into `core/` or `std/`, or Apache headers into
  `compiler/` product sources.
- Helper: `tools/add_x_license_header.sh`

## Engineering rules

Follow [`AGENTS.md`](AGENTS.md): root-cause fixes, no dual authority, platform
boundaries, Ubuntu gold for product claims, true cold L4 when claiming
self-host/release green.

## Contact

- License / commercial (compiler AGPL exemption): admin@shuliangfu.com
- Project: https://github.com/shuliangfu/xlang
