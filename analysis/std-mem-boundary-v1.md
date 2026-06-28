# STD-018 std.mem 与 core.mem 职责边界 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`CORE-008`（core.mem 内建）、`std.heap`（C memcpy 热路径）、`std.io`（Buffer ABI）

---

## 1. 目标

消除 **core.mem** 与 **std.mem** 的职责重叠与**无重复拷贝路径**：  
- **core.mem**：无 OS、无堆、编译器可内建化的字节原语 + 对齐辅助  
- **std.mem**：OS 层 Buffer ABI + 经 **std.heap C 层** 的 copy/set/compare（不 import("core.mem")）

验收：`tests/run-std-mem-boundary-gate.sh` 绿。

---

## 2. 职责矩阵

| 能力 | `core.mem` | `std.mem` | 实现路径 |
|------|------------|-----------|----------|
| 字节拷贝（不重叠） | `mem_copy` | `copy` | core：`.sx` 循环 → `__builtin_memcpy`；std：`heap.copy` → `memcpy` |
| 字节填充 | `mem_set` / `mem_zero` | `set` | core：内建 `memset`；std：`heap_mem_set_c` |
| 字节比较 | `mem_compare` | `compare` | core：内建 `memcmp`；std：`heap_mem_compare_c` |
| 重叠拷贝 | `mem_move` | — | **仅 core** |
| 内存交换 | `mem_swap` | — | **仅 core** |
| 对齐查询/运算 | `align_of_*` / `align_up` | — | **仅 core** |
| IO Buffer ABI | — | `Buffer` + `register_buffer` | **仅 std**（`std.io.core`） |

**禁止**：`std.mem` `import("core.mem")` 并在同一模块再包一层 `mem_copy`（双路径漂移）。

---

## 3. 选用指南

| 场景 | 推荐 |
|------|------|
| 编译器自举 / freestanding / 仅 `import core.*` | `core.mem` |
| 用户程序 + std IO Buffer 预注册 | `std.mem` |
| `std.vec` append_slice 快路径 | `std.heap.copy_*_at`（非 std.mem 门面） |
| 需要 `mem_move` / 对齐辅助 | `core.mem` |

---

## 4. 烟测

| 脚本 | 覆盖 |
|------|------|
| `tests/mem/main.sx` | core.mem 全原语（`run-mem.sh`） |
| `tests/mem/std_mem_boundary.sx` | std.mem copy/set/compare |
| `tests/mem/buffer.sx` | Buffer + register_buffer |

---

## 5. Gate 与 report

```bash
./tests/run-std-mem-boundary-gate.sh
```

manifest：`tests/baseline/std-mem-boundary.tsv`

```
shux: [SHUX_STD_MEM_BOUNDARY] status=ok core_only=4 std_only=4 no_cross_import=1
```

---

## 6. 维护

新增 mem 类 API 时先判定层级：core 原语 vs std OS/堆门面；更新本 RFC + `std/mem/README.md` §边界。
