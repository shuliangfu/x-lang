# History rewrite · 2026-07-31 · strip cursoragent co-author

## Why

GitHub **Contributors** listed [cursoragent](https://github.com/cursoragent) because **645** commits carried the trailer:

```
Co-authored-by: Cursor <cursoragent@cursor.com>
```

Author/committer remained `Shuliangfu <admin@shuliangfu.com>`; GitHub still attributes co-authors as contributors.

## What we did

- Tool: `git filter-repo --message-callback` (strip that trailer only; trees unchanged)
- Force-pushed all branches + tags to `origin`
- Local trailer count after rewrite: **0**

## Important pin / tip SHA remap (content-identical commits)

| Role | Old (prefix) | New (prefix) |
|------|--------------|--------------|
| Product L4 pin | `53fd80927` | `9bb7a757c` |
| tip L4 safety net | `f8be401e9` | `ec773fe95` |
| tip dual L4 candidate | `81285129e` | `eef4d7743` |
| pre-rewrite self-hosting HEAD | `ea367f842` | `ce34f482e` |

Full map: `.git/filter-repo/commit-map` (local after rewrite) or regenerate with the same tool.

## For other clones

```bash
git fetch origin
git checkout self-hosting
git reset --hard origin/self-hosting
# or re-clone
```

Do **not** merge pre-rewrite local commits into the rewritten remote without a careful rebase onto the new history.

## Prevention

Disable Cursor auto “Co-authored-by: Cursor …” in commit settings so new commits do not reintroduce the trailer.
