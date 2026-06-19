# CORE-008 core.mem 热路径编译器内建化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2 §2.1、`core/mem/mod.sx`、`compiler/src/codegen/codegen.c`

---

## 1. 目标

`core.mem` 四条热路径原语在**跨模块 import 调用**时，C 后端应生成单条 `__builtin_*` 调用（或等价内联），避免逐字节 `.sx` 循环进入用户代码路径。

| API | C 符号 | intrinsic |
|-----|--------|-----------|
| `mem_copy` | `core_mem_mem_copy` | `__builtin_memcpy` |
| `mem_set` | `core_mem_mem_set` | `__builtin_memset` |
| `mem_move` | `core_mem_mem_move` | `__builtin_memmove` |
| `mem_compare` | `core_mem_mem_compare` | `__builtin_memcmp` |

`core/mem/mod.sx` 函数体仍保留 `.sx` 循环实现（避免与部分平台系统头 `memcpy` 宏冲突；模块自编译路径可接受）。

---

## 2. 实现位置

- **映射表**：`compiler/src/codegen/codegen.c` → `builtin_intrinsic_name()`
- **调用点**：`codegen` CALL 跨模块路径经 `builtin_intrinsic_name(full_name)` 输出

自举 `.sx` codegen 路径尚未镜像该表；当前验收以 C 前端 `shux-c -E` 为准（与 Phase 1 其他 emit gate 一致）。

---

## 3. 验收

### 3.1 manifest（全平台）

- RFC、manifest TSV、gate 脚本、`codegen.c` 四条映射字符串存在
- 烟测源 `tests/core-mem/intrinsic_emit.sx` 存在

### 3.2 runnable（本机可执行 shux-c 时）

**注意**：有 `import` 时 `-E` 仅内联依赖模块，**不输出入口 `main` 体**（与 `tests/mem/main.sx` 实测一致），不能用于验跨模块 CALL intrinsic。须用 `-o` 编译路径 + `SHUX_DEBUG_C=1` 落盘生成 C：

```bash
SHUX_DEBUG_C=1 ./compiler/shux-c -L . tests/mem/main.sx -o /tmp/shux_mem_probe
grep __builtin_mem /tmp/shux_debug.c
```

（链接失败可忽略，只要 `/tmp/shux_debug.c` 已写出。）

生成 C 的 `main` 中须同时包含：

- `__builtin_memcpy`
- `__builtin_memset`
- `__builtin_memmove`
- `__builtin_memcmp`

报告前缀：

```
shux: [SHUX_CORE_MEM_INTRINSIC] status=ok emit=4/4
```

---

## 4. Gate 与 CI

- manifest：`tests/baseline/core-mem-intrinsic.tsv`
- 库：`tests/lib/core-mem-intrinsic.sh`
- 门禁：`tests/run-core-mem-intrinsic-gate.sh`
- 行为回归：`tests/run-mem.sh`（语义）
- 便携回归：`tests/run-portable-suite.sh`

---

## 5. 维护

新增 `core.mem` 热路径 API 时：

1. 在 `builtin_intrinsic_name` 登记 C 符号 → intrinsic
2. 更新 manifest `mapping_*` 行与 `intrinsic_emit.sx`
3. 更新 `core/mem/mod.sx` 模块头注释
