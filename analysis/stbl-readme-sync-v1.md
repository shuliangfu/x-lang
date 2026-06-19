# STBL-002 std/README 与实现同步 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2、`BOOT-013` check 矩阵

---

## 1. 目标

消除 `std/README.md` 与源码/测试的**文档漂移**（如 process 无 spawn、async 仅占位、http/tar 无测试）。

验收：**runnable** gate 禁止过时措辞 + 要求关键锚点存在。

---

## 2. 禁止措辞（gate 扫描）

| 过时表述 | 原因 |
|----------|------|
| `spawn/exec/管道为 P3` | `std/process/mod.sx` 已实现 spawn/exec |
| `std.async` 仅占位 | `scheduler.c` + 1M gate 已交付 |
| `无 run-http.sh` | 已纳入 run-all |
| `无 run-tar.sh` | 已纳入 run-all |

---

## 3. 必需锚点

| 锚点 | 证明 |
|------|------|
| `scheduler.c` | async 实装 |
| `spawn_simple` | process 子进程 |
| `run-http.sh` | http 烟测 |
| `run-tar.sh` | tar 烟测 |
| `STD-010` / `std.db` | db 预研状态 |
| `NEXT.md` | Phase 2 路线图 |
| `run-stdlib-check-matrix` | BOOT-013 联动 |

---

## 4. Gate 与 report

- 门禁：`tests/run-stbl-readme-sync-gate.sh`
- manifest：`tests/baseline/stbl-readme-sync.tsv`
- 便携回归：`tests/run-portable-suite.sh`

```
shux: [SHUX_STBL_README] status=ok forbidden=0 anchors=7
```

---

## 5. 维护

README 分类变更（§一↔§二↔§三）时同步更新 manifest `tier_*` 行与 gate 锚点。
