# G-02f L2 试点：产品链 `.x` 编出的 `.o`（G-02f-256）

## 1. 目标

今日 G05 热路径几乎全部是：

```text
seeds/*.from_x.c  →  cc -c  →  *.o  →  link shux
```

即便 `.x` 已是 L1 逻辑源，**运行时仍是手写/生成的 seed C**。L2 终局要把至少部分 G05 objs 改成：

```text
src/**/*.x  →  工具链  →  *.o  →  link shux
```

本试点（**L2-1 设计 + L2-2 实现切片**）先打通**一条最窄路径**，不破坏默认双绿。

## 2. 试点 TU

| 项 | 选择 | 原因 |
|----|------|------|
| 源 | `compiler/src/lsp/lsp_diag_pipeline_sizes.x` | 三枚 `sizeof_*` 常量；无 OS/IO；已 G-02f-1 逻辑闭合 |
| 产物 | `src/lsp/lsp_diag_pipeline_sizes_nostub.o` | 已在 G05 清单 |
| 默认路径 | 仍 `seeds/lsp_diag_pipeline_sizes.from_x.c` + `cc` | 冷启动/回滚安全 |
| 优先路径 | `SHUX_G05_PREFER_X_O=1` | 显式 opt-in |

## 3. 实现路径（当前机可绿）

asm 后端对纯常量 TU 仍可能 `asm_codegen_elf_o` 失败。**过渡路径**（仍算 L2 语义主权）：

```text
shux -backend c -E sizes.x  →  tmp.c  →  cc -c  →  sizes_nostub.o
```

- **输入**：仓库内 `.x`（非 committed seed 作为逻辑源）
- **中间**：临时 C（不入库）
- **失败**：回退 seed `cc`（默认与今日相同）

后续可换：`shux -backend asm -o foo.o` 一旦稳定。

## 4. 开关与脚本

| 环境变量 | 默认 | 行为 |
|----------|------|------|
| `SHUX_G05_PREFER_X_O` | 未设/0 | 仅 seed（与 f-255 前一致） |
| `SHUX_G05_PREFER_X_O=1` | — | sizes 优先 `.x→-E→cc`；失败 stderr 提示后 seed |

入口：`compiler/scripts/g05_ensure_relink_prereqs.sh`  
助手：`g05_try_x_to_o <src.x> <out.o> [extra cflags...]`

## 5. 验收

### 5.1 默认（必须双绿）

```bash
cd compiler && G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
# + STRICT + noinc + rv42 + lang-unsafe（macOS + Ubuntu）
```

### 5.2 优先路径（本机 smoke）

```bash
cd compiler
rm -f src/lsp/lsp_diag_pipeline_sizes_nostub.o
SHUX_G05_PREFER_X_O=1 sh scripts/g05_ensure_relink_prereqs.sh
# 日志应含：sizes_nostub.o ← ...sizes.x (G-02f-256 L2 prefer .x)
nm src/lsp/lsp_diag_pipeline_sizes_nostub.o | grep sizeof
G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
```

## 6. 扩展顺序（后续 f-步）

1. **L2-2 扩表**：第二 TU 选「纯 helper、符号面小」者（如更多 sizes / pure flags）
2. **L2-3**：`target_cpu` pure 子集（detect 仍 🔒 seed）
3. **L2-4**：`diag` 表数据+va_list 边界清晰后再试
4. **asm 直出 .o**：修 CG002 后去掉 `-E` 中间步

## 7. 非目标（本步不做）

- 不默认打开 `PREFER_X_O`（避免冷启动鸡生蛋）
- 不删 seed 文件
- 不一次改多个 mega
- 不要求 gen1/gen2 黄金哈希本步变化

## 8. 回滚

```bash
unset SHUX_G05_PREFER_X_O
rm -f src/lsp/lsp_diag_pipeline_sizes_nostub.o
sh scripts/g05_ensure_relink_prereqs.sh   # 仅 seed
```
