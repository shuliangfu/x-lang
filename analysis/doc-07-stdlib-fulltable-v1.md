# DOC-007 docs/07 标准库全表同步 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：STBL-002（`std/README.md`）、CORE-015（core 表）、DOC-006（Cookbook）

---

## 1. 目标

将 `docs/07-内置与标准库.md` 的 **std 模块表** 从「示例摘录」升级为与 `std/README.md`（STBL-002）**三档分类一致**的全表，供语言参考与 IDE 文档消费。

验收：DOC-007 gate 禁止过时 stub 措辞 + 43 个 `std.*` 锚点存在于 docs/07 与 README。

---

## 2. 文档结构（docs/07）

| 章节 | 对应 STBL-002 |
|------|---------------|
| `## std 已完善` | README §一（39 模块） |
| `## std 部分完善` | README §二（async/regex/simd/process 扩展） |
| `## std 预研 / 占位` | README §三（db/elf） |
| `## 治理与 Cookbook` | README §四 + DOC-006 |

core 表（11 模块）保持 CORE-014 现状，由 CORE-015 gate 独立校验。

---

## 3. 禁止措辞（gate 扫描 docs/07）

| 过时表述 | 原因 |
|----------|------|
| `std 模块（示例）` | DOC-007 后须全表 |
| `std.vector` | 统一为 `std.vec` |
| `heap`、`std.error` 等` | 含糊「等」列举 |

---

## 4. 必需锚点（STBL-002 联动）

| 锚点 | 证明 |
|------|------|
| `scheduler.c` | async 实装 |
| `spawn_simple` | process 子进程 |
| `resolve_ex` | DNS（STD-029） |
| `env_iter` | 环境遍历（STD-025） |
| `panic_hook_collect` | runtime（STD-028） |
| `run-stbl-readme-sync-gate` | STBL-002 联动 |
| `run-doc-cookbook-expand-gate` | DOC-006 联动 |
| `NEXT.md` | Phase 2 路线图 |

---

## 5. Gate 与 report

- 门禁：`tests/run-doc-07-stdlib-fulltable-gate.sh`
- manifest：`tests/baseline/doc-07-stdlib-fulltable.tsv`
- 便携回归：`tests/run-portable-suite.sh`

```
shux: [SHUX_DOC07] status=ok forbidden=0 readme_miss=0 doc_miss=0
```

---

## 6. 维护

`std/README.md` §一↔§三 分类变更时，同步更新 docs/07 对应表与 manifest `anchor_*` 行。
