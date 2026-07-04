# SysV f32 xmm 实/形参 ABI

> **状态**：**默认开启**（`shux_asm` x86_64 SysV）；显式 **`SHUX_ABI_F32_XMM=0`** 回落 legacy（f64 widen + `cvtsd2ss`）。  
> **平台**：仅 **Linux x86_64 SysV** asm 后端；arm64/riscv64 未实现。

---

## 1. 动机

legacy 路径为在现有 gp-only CALL 桩上传递 f32，caller 发 **64-bit f64 立即数/寄存器**，callee `param_home` 再 **cvtsd2ss** 落 32-bit 栈槽。问题：

- 多一次转换，hot path 有额外指令；
- mixed 调用（如 `vec3f_soa_push(v, x, y, z)`：`*T` + 3×f32）无法利用 SysV **xmm0–xmm7** 传 f32；
- disasm 门禁难以保证无 `cvtsd2ss` 残留。

**xmm ABI** 与 SysV AMD64 一致：整型/指针仍走 rdi/rsi/…；**f32 实参按顺序占用 xmm0–xmm7**（与 gp 参数独立计数），callee 形参 homing 用 **movd xmmK → 32-bit home 槽**。

---

## 2. 开关

### 2.1 编译用户程序

| `SHUX_ABI_F32_XMM` | 行为 |
|-------------------|------|
| **unset**（默认） | **xmm ABI** |
| `1` | xmm ABI（与默认相同） |
| `0` | legacy：gp + f64 widen + callee `cvtsd2ss` |

**CLI**（与 `SHUX_ABI_F32_XMM=0` 等价，无需记环境变量）：

| 开关 | 行为 |
|------|------|
| `-legacy-f32-abi` | legacy f64 widen + `cvtsd2ss` |

```bash
# 默认 xmm（无需 export）
SHUX=./compiler/shux_asm ./compiler/shux_asm -backend asm -L . app.x -o app

# 显式 legacy 回归（环境变量或 CLI）
SHUX_ABI_F32_XMM=0 SHUX=./compiler/shux_asm ./compiler/shux_asm -backend asm -L . app.x -o app
SHUX=./compiler/shux_asm ./compiler/shux_asm -backend asm -L . -legacy-f32-abi app.x -o app
```

`pipeline_asm_abi_f32_xmm_enabled_c()`（`compiler/src/asm/pipeline_abi_f32_xmm.c`）读 `getenv("SHUX_ABI_F32_XMM")`：**仅 `"0"` 关闭**。

### 2.2 构建 `shux_asm`（链接 dispatch TU）

工具链须链入 xmm dispatch 对象（experimental / strict_glue 脚本已默认包含）：

| 对象 | 作用 |
|------|------|
| `src/asm/pipeline_abi_f32_xmm.o` | ABI 开关 |
| `src/asm/backend_call_dispatch.o` | CALL 侧 gp/xmm 分轨 |
| `src/asm/backend_enc_dispatch.c` | `movd` 等编码 |
| `pipeline_glue.c`（在 `pipeline_x.o` 内） | callee xmm homing、f32 load、struct layout |

重建示例（Linux Docker / amd64）：

```bash
cd compiler
make pipeline_x.o PIPELINE_X_FORCE_COMPILE=1   # pipeline_glue 变更后
cc -c -o src/asm/pipeline_abi_f32_xmm.o src/asm/pipeline_abi_f32_xmm.c   # 开关变更后
./scripts/relink_shux_asm_experimental_bootstrap.sh && cp shux_asm.experimental shux_asm
```

**勿**在已链 `pipeline_x.o`（含 glue）的 experimental 链上再单独链 `pipeline_abi_f32_xmm.o`（duplicate symbol）。

---

## 3. 语义摘要

| 角色 | legacy（`SHUX_ABI_F32_XMM=0`） | xmm ABI（**默认**） |
|------|-------------------------------|---------------------|
| f32 CALL 实参 | movabs f64 → gp；callee cvtsd2ss | movd / xmm 寄存器；**无 cvtsd2ss** |
| f32 形参 home | gp 槽 8B + cvtsd2ss | xmm0–7 movd → **4B** home 槽 |
| mixed `*T` + f32 | 全 gp；f32 仍 widen | `*T`→gp，f32→xmm |
| f32 字面量 field/let | imm32（与 ABI 无关） | 同左 |
| AoS f32 struct 布局 | 须 **align=4**（`glue_type_align_simple`） | 同左；字段 0/4/8 |

---

## 4. 验收门禁

统一脚本（推荐）：

```bash
SHUX=./compiler/shux_asm ./tests/run-f32-xmm-gates.sh
```

legacy 回归（**仅 CLI 烟测**，不再全量 dod-s2 legacy）：

```bash
SHUX=./compiler/shux_asm ./tests/run-f32-xmm-gates.sh
# 内含 run-abi-f32-xmm-gate.sh：-legacy-f32-abi exit=6 + disasm cvtsd2ss
```

| 脚本 | 覆盖 |
|------|------|
| `tests/run-f32-xmm-gates.sh` | abi 烟测 + dod-s2 vec3f push（**默认 xmm**）+ **CLI legacy** |
| `tests/run-abi-f32-xmm-gate.sh` | 纯 f32 / mixed / 字段回读；disasm **movd**、**禁 cvtsd2ss**；**`-legacy-f32-abi`** |
| `tests/run-dod-s2-gate.sh` | `import("std.vec")` **`vec3f_soa_push`**；xmm 时 push disasm 同上 |

烟测源码：`tests/abi/f32_*.x`。

**P5 / Docker / GHA**：`run-f32-xmm-gates.sh` 统一覆盖 xmm + CLI legacy；**不再**单独跑 `SHUX_ABI_F32_XMM=0` 全量 dod-s2。

---

## 5. Release 默认与 legacy 弃用时间表

| 阶段 | 目标日期 | 行为 |
|------|----------|------|
| **当前** | 2026 Q2 | release **`shux_asm -backend asm -O2`**；**f32 xmm ABI 默认 ON** |
| **警告期** | 2026 Q4 | 文档与 `--help` 标明 legacy 仅 `-legacy-f32-abi` / `SHUX_ABI_F32_XMM=0`；CI 仅 CLI 烟测 |
| **移除计划** | 2027 Q1 | 删除 legacy f64 widen + `cvtsd2ss` 路径（breaking） |

**Release 推荐命令**：

```bash
shux_asm -backend asm -O2 -L . app.x -o app
```

用户程序默认 **-O2**（未写 `-O` 时 `opt_level_buf` 为 `'2'`）；f32 实/形参默认 xmm，无需 export 环境变量。

---

## 6. 相关源码索引

| 文件 | 说明 |
|------|------|
| `compiler/src/asm/pipeline_abi_f32_xmm.c` | 环境变量开关（默认 ON） |
| `compiler/src/asm/backend_call_dispatch.c` | `glue_emit_call_args_elf_sysv_f32_xmm_c` |
| `compiler/pipeline_glue.c` | param_home xmm、field layout、f32 addss 链 |
| `compiler/ast_pool.c` | emit 前 `set_arena`、struct slot 尺寸 |
| `compiler/src/runtime.c` | `-legacy-f32-abi` → `setenv`；`driver_print_usage_c` |

---

## 7. 后续

- macOS x86_64 / arm64 SysV 变体如需对齐，单独开项；
- `shux-c` / 非 asm 后端不受本开关影响；
- 2027 Q1 按计划移除 legacy widen 路径。
