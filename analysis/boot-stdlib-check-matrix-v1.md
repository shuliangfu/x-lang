# BOOT-013 std/core 全模块 check 矩阵 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STBL-002`、`tests/run-stdlib-import.sh`

---

## 1. 阅读路径（约 5 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 打开 `tests/baseline/stdlib-check-matrix.tsv` |
| 2 | `./tests/run-stdlib-check-matrix-gate.sh` |
| 3 | 本地全量：`./tests/run-stdlib-check-matrix.sh` |

---

## 2. 模块矩阵

权威：`stdlib-check-matrix.tsv`（**11** core + **60** std = **71** 模块）。

对每个模块生成临时 `import <mod>; function main(): i32 { return 0; }` 并执行 `shux check -L .`。

| 层 | 数量 | 说明 |
|----|------|------|
| core | 11 | 无 OS 依赖 |
| std | 60 | 含 schema 等新建模块 |

**工具链**：优先 `compiler/shux-c`（跨平台 typeck）；无则 native `shux`；皆无则 gate **SKIP** runnable。

---

## 3. 与自举边界

- 本矩阵仅 **typeck**，不链接执行（避免全量 `.o` 链入耗时）。
- 编译器热路径依赖模块（io/fs/fmt）失败须 P0 修复。
- 扩展新模块：在 TSV 追加 `module` 行 + `std/xxx/mod.x`。

---

## 4. 报告格式（runnable）

```
shux: [SHUX_STDLIB_CHECK] status=ok core=11 std=58 fail=0 skip=0
```

| 字段 | 含义 |
|------|------|
| `core` / `std` | 各层 check 通过数 |
| `fail` | 失败模块数 |
| `skip` | 无 shux 时 1 |

门禁：`tests/run-stdlib-check-matrix-gate.sh`；便携：`tests/run-portable-suite.sh`。
