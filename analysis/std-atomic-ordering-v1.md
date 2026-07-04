# STD-046：std.atomic 序语义与 fence API v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：LANG 内存模型（C11 子集）、`compiler/src/asm/runtime_atomic_glue.c`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-atomic-ordering.tsv` |
| 3 | `./tests/run-std-atomic-ordering-gate.sh` |
| 4 | 烟测：`tests/atomic/ordering_fence.x` |

---

## 2. LANG 内存模型对齐（v1）

Shux **v1 原子语义**与 **C11 / LLVM `__ATOMIC_*`** 一致：

| 层级 | 约定 |
|------|------|
| 语言 | 普通 load/store **非原子**；跨线程共享须 `std.atomic` 或 `std.sync` |
| 编译器 | codegen 对 `extern` 原子 C 符号委托平台 `__atomic_*` / C11 `<stdatomic.h>` |
| 标准库 v1 | 全部 `load_*` / `store_*` / `fetch_*` / `compare_exchange_*` 使用 **`memory_order_seq_cst`** |

与 Rust `Ordering::SeqCst`、C++ `memory_order_seq_cst` 同级：**全序**、无数据竞争时行为可预测。

---

## 3. Ordering 常量（STD-046）

`std/atomic/mod.x` 导出与 C11 数值对齐的常量（供文档与未来 `*_order` API）：

| 常量 | 值 | 含义 |
|------|-----|------|
| `ORDER_RELAXED` | 0 | 无同步，仅原子性 |
| `ORDER_ACQUIRE` | 1 | 读侧获取 |
| `ORDER_RELEASE` | 2 | 写侧释放 |
| `ORDER_ACQ_REL` | 3 | 读改写 |
| `ORDER_SEQ_CST` | 4 | 顺序一致（**v1 默认**） |

**v1 范围**：现有 API 固定 `ORDER_SEQ_CST`；带 `order` 参数的重载列入后续 STD。

---

## 4. Fence API

| API | C 符号 | 语义 |
|-----|--------|------|
| `fence_seq_cst()` | `atomic_fence_seq_cst_c` | 全序栅栏 |
| `fence_acquire()` | `atomic_fence_acquire_c` | 获取栅栏 |
| `fence_release()` | `atomic_fence_release_c` | 释放栅栏 |

典型用法（发布-订阅，配合未来 relaxed load/store）：

```
// writer
store_i32(&data, 42);
fence_release();
store_i32(&ready, 1);

// reader
while (load_i32(&ready) == 0) { }
fence_acquire();
let v = load_i32(&data);
```

v1 烟测验证 fence 可链接、常量与文档一致；`tests/atomic/main.x` 回归既有原子算子。

---

## 5. 门禁

```bash
./tests/run-std-atomic-ordering-gate.sh
```

```
shux: [SHUX_STD_ATOMIC_ORDERING] status=ok fence=1 main=1 skip=0
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-18 | Ordering 常量 + fence API + LANG 对齐文档 |
