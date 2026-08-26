# STD-012 标准库示例工程体系 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`DOC-001`（Cookbook）、`STD-001/002/004`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读 `examples/hello.x`，确认工具链可用 |
| 2 | 浏览 `examples/cookbook/`（DOC-001 12 食谱） |
| 3 | 打开 `tests/baseline/std-examples-catalog.tsv` 按 category 选示例 |
| 4 | `./tests/run-std-examples.sh` 打印全量索引 |
| 5 | `./tests/run-std-examples-gate.sh` 验证目录完整 |

---

## 2. 目录布局

```
examples/
  hello.x              # 入门
  cookbook/             # DOC-001 食谱（IO/NET/ZC/ASYNC）
tests/
  <module>/main.x      # 标准库领域烟测（编入 catalog）
tests/baseline/
  std-examples-catalog.tsv   # 全量目录（35+）
  std-examples-manifest.tsv  # 门禁 manifest
```

---

## 3. Cookbook 子集（DOC-001）

| 前缀 | 数量 | 路径 |
|------|------|------|
| `ex_cb_*` | 12 | `examples/cookbook/*.x` |
| 门禁 | — | `tests/run-doc-stdlib-cookbook-gate.sh` |

Cookbook 是示例体系的**教程层**；全量 catalog 还收录 `tests/*/main.x` 等**回归层**示例。

---

## 4. 全量目录（std-examples-catalog.tsv）

| tier | 含义 | 数量（v1） |
|------|------|------------|
| `core` | 入门 | 1（`ex_hello`） |
| `cookbook` | 教程食谱 | 12 |
| `stdlib` | 模块烟测 / smoke | 22+ |

**合计 ≥ 35**，满足验收「30+ 可运行（runnable）示例」。

索引示例（节选）：

| id | category | path |
|----|----------|------|
| `ex_hello` | hello | `examples/hello.x` |
| `ex_cb_io_batch` | io | `examples/cookbook/io_batch_rw.x` |
| `ex_io_batch_smoke` | io | `tests/io/batch_rw_smoke.x` |
| `ex_net_main` | net | `tests/net/main.x` |
| `ex_cb_zc_arena` | zc | `examples/cookbook/zc_arena_concat.x` |
| `ex_cb_async_import` | async | `examples/cookbook/async_mod_import.x` |

完整列表见 catalog TSV 或 `./tests/run-std-examples.sh`。

---

## 5. Gate

假权威诚实（2026-08-26）：闸优先 `xlang_asm`，钉 `XLANG_LINK_XLANG`；`xlang check` 仅观测（check 闸门 2026-08-05 暂停）；`examples/hello.x` + `examples/cookbook/io_batch_rw.x` 可运行 exit0 硬失败；无 native 编译器 **FAIL**（禁 soft SKIP→OK）；报告 `check=`／`x=`／`skip=`。产品面 asm 本绿；旧闸仅 prefer `xlang-c` + cookbook/core 硬 typeck＝portable 假红。

```bash
# manifest + 路径 + catalog≥30 + hello/io runnable hard
./tests/run-std-examples-gate.sh

# 打印 Markdown 索引表
./tests/run-std-examples.sh

# 单示例 check（观测；非门禁硬绿）
./compiler/xlang_asm check -L . examples/hello.x
```

| 脚本 | 角色 |
|------|------|
| `tests/lib/std-examples.sh` | `std_ex_validate_paths` / `std_ex_check_example` / `std_ex_run_x_smoke` / `std_ex_emit_report` |
| `tests/run-std-examples-gate.sh` | manifest + catalog 路径 + check 观测 + hello/io runnable hard |
| `tests/run-doc-stdlib-cookbook-gate.sh` | Cookbook 子集（DOC-001） |

新增示例流程：

1. 添加 `.x` 到 `examples/` 或确认 `tests/` 烟测稳定  
2. 在 `std-examples-catalog.tsv` 增加一行  
3. 在本文 §4 或 category 小节补一句说明  
4. 跑 `run-std-examples-gate.sh`

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/archive/std/std-examples-v1.md` |
| catalog | `tests/baseline/std-examples-catalog.tsv` |
| manifest | `tests/baseline/std-examples-manifest.tsv` |
| 库 | `tests/lib/std-examples.sh` |
| runner | `tests/run-std-examples.sh` |
| 门禁 | `tests/run-std-examples-gate.sh` |
| Cookbook | `analysis/archive/doc/doc-stdlib-cookbook-v1.md`（若仍顶层则拒复活） |
| Cookbook manifest | `tests/baseline/doc-stdlib-cookbook.tsv` |

**STD-012 状态：定版 ✅**（Gate honesty 2026-08-26）
