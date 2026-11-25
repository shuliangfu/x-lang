# tree-sitter-xlang — independent release plan（§6 10.6 residual · knife 11.23）

> **Status**: plan registered（knife **11.23**）；**CLOSE 11.28**＝**(1) HARD-STOP residual HOLD** — **still no user-named standalone URL**；**physical submodule／split not done**.  
> **Authority**: [`../HOST_CC_POLICY.md`](../HOST_CC_POLICY.md) §10.6.2.  
> Product chain already treats this tree as **仓外**（knife 11.21）.
>
> **11.28 CLOSE**：阻断＝无用户点名独立仓 URL；未自创 remote；未整表删 bindings；物理迁⏸。

## Why not migrate this knife

| Blocker | Detail |
|---------|--------|
| No separate remote | Package `repository`／go.mod still `github.com/shuliangfu/x-lang`；no `tree-sitter-xlang` standalone repo |
| No `.gitmodules` | Monorepo path `editors/tree-sitter-xlang/` is ordinary tracked tree |
| Cross-refs | README／NOTICE／LICENSE／CONTRIBUTING／`xlang.toml` comment／vim syntax note／zero-make gate stubs expect in-tree paths |
| Ban | Fake-green mass-delete bindings；CloudAgent；irreversible publish without user-named remote |

## Planned steps（future knife／user-approved）

1. Create standalone GitHub repo（user names URL；e.g. `shuliangfu/tree-sitter-xlang`）.
2. `git subtree split`（or filter-repo）history of `editors/tree-sitter-xlang/` → push to standalone.
3. In monorepo：add `.gitmodules` + `git submodule add <url> editors/tree-sitter-xlang`（or replace path with submodule checkout）.
4. Retarget metadata：`package.json`／`Cargo.toml` `repository`、`bindings/go/go.mod` module path、README install notes.
5. Update monorepo docs：root README／NOTICE／LICENSE map／CONTRIBUTING／`editors/HOST_CC_POLICY.md`；keep zero-make gate stub checks via submodule path.
6. Protect：product g05／`./xbuild` still **0×** tree-sitter compile inputs；no Soft Cap／nail／tip raises.

## Non-goals（this plan）

- Deleting bindings to “look migrated”
- Publishing npm／crates without user release approval
- Touching `compiler/**` product OBJ／g05 bodies

## Tools dry-run（knife **11.29**）

In-tree helper（**not** a physical migrate）:

```bash
bash editors/tree-sitter-xlang/scripts/prepare_independent_release.sh          # inventory
bash editors/tree-sitter-xlang/scripts/prepare_independent_release.sh --check  # stubs＋g05 0×＋refs
XLANG_TREE_SITTER_REMOTE=https://github.com/OWNER/tree-sitter-xlang \
  bash editors/tree-sitter-xlang/scripts/prepare_independent_release.sh --print-retarget
```

- Default／`--check`：dry-run only；EXIT0＝inventory＋gate stubs＋product g05 0× tree-sitter.
- `--print-retarget` without `XLANG_TREE_SITTER_REMOTE`：EXIT2 refuse（honest）.
- `--apply-submodule`：always EXIT2 refuse until user-named remote flow.
- **Does not** create a GitHub repo, submodule, or delete bindings.

