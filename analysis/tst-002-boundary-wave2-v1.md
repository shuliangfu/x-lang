# TST-002 P0 边界测试波次 2 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`TST-001`、`STD-013`/`STD-014`、`tests/run-heap.sh` / `run-vec.sh` / `run-map.sh` / `run-process.sh`

---

## 1. 目标

| ID | 交付 |
|----|------|
| TST-002 | **heap / vec / map / process** 四模块边界烟测波次 2 |
| 验收 | 每模块 **≥8** `// case N`；`run-tst-002-boundary-gate.sh` 全绿 |

---

## 2. 用例矩阵

| 模块 | 文件 | case 数 | 覆盖要点 |
|------|------|---------|----------|
| `std.heap` | `tests/heap/boundary.x` | 8 | alloc/free、zero、realloc、Arena64 |
| `std.vec` | `tests/vec/boundary.x` | 9 | push/pop、append_slice、clear/truncate |
| `std.map` | `tests/map/boundary.x` | 8 | Map_u64/Map_str insert/get/remove |
| `std.process` | `tests/process/boundary.x` | 9 | pid、pipe、getcwd、getenv |

与波次 1（`TST-001`）互补：波次 1 覆盖 IO 路径；波次 2 覆盖容器与进程基础 API。

---

## 3. 门禁

```bash
./tests/run-tst-002-boundary-gate.sh
```

manifest：`tests/baseline/tst-002-boundary-wave2.tsv`

---

## 4. 与 run-all 关系

功能烟测仍由 `run-heap.sh` 等承担；本 gate 专注**边界向量**计数与链接。`run-portable-suite.sh` 挂入门禁。
