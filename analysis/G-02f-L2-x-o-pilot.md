# G-02f L2 试点：产品链 `.x` 编出的 `.o`（G-02f-256 → f-257）

## 1. 目标

今日 G05 热路径几乎全部是：

```text
seeds/*.from_x.c  →  cc -c  →  *.o  →  link shux
```

即便 `.x` 已是 L1 逻辑源，**运行时仍是手写/生成的 seed C**。L2 终局要把至少部分 G05 objs 改成：

```text
src/**/*.x  →  工具链  →  *.o  →  link shux
```

**f-256**：最窄 1:1 路径（sizes）。  
**f-257**：表驱动 + 第二路径（target_cpu pure flags 混合）。

## 2. 当前 L2 TUs

| # | 源 | 产物 | 路径 | 步 |
|---|----|------|------|----|
| 1 | `src/lsp/lsp_diag_pipeline_sizes.x` | `sizes_nostub.o` | 1:1 `.x→-E→cc` | f-256 |
| 2 | `src/driver/target_cpu_flags.x` | 并入 `target_cpu.o` | hybrid：flags.o + seed-rest（`-DSHUX_L2_TARGET_CPU_FLAGS_FROM_X`）`cc -r` | f-257 |

- **默认路径**：仍整 seed `cc`（冷启动/回滚安全）
- **优先路径**：`SHUX_G05_PREFER_X_O=1`（显式 opt-in）

### 2.1 target_cpu hybrid 细节

| 层 | 内容 |
|----|------|
| **flags.x** | `driver_set/get_pending_target_cpu_features`、`tcp_tolower`、`tcp_eq5`、`tcp_eq6` |
| **seed-rest** | resolve / simd / print / detect_* / `tcp_eq_at` / parse_named / flags_has_token… |
| **seed 宏** | `SHUX_L2_TARGET_CPU_FLAGS_FROM_X` 省略 flags 符号，改为 `extern` |
| **失败** | 回退整文件 `seeds/target_cpu_pure.from_x.c` |

> 全量 `target_cpu_pure.x` 的 `-E` 仍会挂起/超时，故 **禁止** 整 TU 优先；仅切 pure flags 子集。

## 3. 实现路径（当前机可绿）

asm 后端对纯常量 TU 仍可能 `asm_codegen_elf_o` 失败。**过渡路径**（仍算 L2 语义主权）：

```text
shux -backend c -E foo.x  →  tmp.c  →  cc -c  →  foo.o
```

- **输入**：仓库内 `.x`（非 committed seed 作为逻辑源）
- **中间**：临时 C（不入库）
- **失败**：回退 seed `cc`（默认与今日相同）

## 4. 开关与脚本

| 环境变量 | 默认 | 行为 |
|----------|------|------|
| `SHUX_G05_PREFER_X_O` | 未设/0 | 仅 seed（与 f-255 前一致） |
| `SHUX_G05_PREFER_X_O=1` | — | 表内 TU 优先 `.x`；hybrid 失败则整 seed |

入口：`compiler/scripts/g05_ensure_relink_prereqs.sh`  
助手：`g05_try_x_to_o` · `g05_ensure_l2_or_seed`（1:1 表项）

## 5. 验收

### 5.1 默认（必须双绿）

```bash
cd compiler && G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
# + STRICT + noinc + rv42 + lang-unsafe（macOS + Ubuntu）
```

### 5.2 优先路径（本机 smoke）

```bash
cd compiler
rm -f src/lsp/lsp_diag_pipeline_sizes_nostub.o src/driver/target_cpu.o
SHUX_G05_PREFER_X_O=1 sh scripts/g05_ensure_relink_prereqs.sh
# 日志应含：
#   sizes_nostub.o ← ...sizes.x (G-02f-257 L2 prefer .x: sizes_nostub)
#   target_cpu.o ← ...target_cpu_flags.x + seed-rest (G-02f-257 L2 hybrid flags)
nm src/lsp/lsp_diag_pipeline_sizes_nostub.o | grep sizeof
nm src/driver/target_cpu.o | grep 'T _tcp_tolower\|T _shu_target_cpu_detect'
G05_SYNC_ASM=1 SHUX_G05_PREFER_X_O=1 sh scripts/g05_prepare_and_relink.sh
./shux -backend c build -o /tmp/rv42 /tmp/rv42.x && /tmp/rv42  # exit 42
```

macOS arm64 默认 asm 可能 `code_len=0`（已知限制）；C 后端 smoke 即可。

## 6. 扩展顺序（后续 f-步）

1. ~~**L2-2 扩表**~~ ✅ f-257 表驱动 + flags hybrid  
2. **L2-4 第 3 TU**：再选「纯 helper、符号面小」者（或更多 flags：`append_feat_name` 等，须确认 `-E` 不挂）  
3. **L2**：`diag` 表数据+va_list 边界清晰后再试  
4. **asm 直出 .o**：修 CG002 后去掉 `-E` 中间步  
5. 评估是否默认 `PREFER_X_O`（避免冷启动鸡生蛋）

## 7. 非目标（本步不做）

- 不默认打开 `PREFER_X_O`（避免冷启动鸡生蛋）
- 不删 seed 文件
- 不一次改多个 mega
- 不要求 gen1/gen2 黄金哈希本步变化
- 不整文件 `-E` `target_cpu_pure.x`（仍 hang）

## 8. 回滚

```bash
unset SHUX_G05_PREFER_X_O
rm -f src/lsp/lsp_diag_pipeline_sizes_nostub.o src/driver/target_cpu.o
sh scripts/g05_ensure_relink_prereqs.sh   # 仅 seed
```
