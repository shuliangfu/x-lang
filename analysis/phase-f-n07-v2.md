# 阶段 F-NL-07 完成标准 v2（编译器 bootstrap nostdlib 首试）

> **NL-07 v2**：在 v1 track 之上，提供 **可选** `SHUX_BOOTSTRAP_NOSTDLIB=1` 全 bootstrap 链 nostdlib 路径 + 扩展 libc/libm 桩；**默认仍 -lc/-lm**，失败自动回退。

## v2 完成（✅ 链尾统一 + 桩扩展）

| 项 | 标准 | 产物 |
|----|------|------|
| NL-07 v2 文档 | 本文件 | `analysis/phase-f-n07-v2.md` |
| bootstrap 桩 | string/mem/stdio + libm(__builtin_*) + fenv 空实现 + getenv | `compiler/src/asm/bootstrap_nostdlib_stubs.c` |
| 构建开关 | `SHUX_BOOTSTRAP_NOSTDLIB=1` 尝试 nostdlib **全部 6 链** | `compiler/scripts/build_shux_asm.sh` NL-07 块 |
| 链尾 helper | `bootstrap_link_tail_crt0` / `bootstrap_link_tail_driver` | 去 `-lc/-lm`，保留 `${PIPELINE_LIBS}`（`-lpthread/-luring`） |
| v2 prep gate | manifest + 桩编译 | `tests/run-nolibc-n07-v2-prep-gate.sh` |

## 链入顺序（nostdlib 尝试）

```
crt0_x86_64.o + typeck_f64_bits.o + runtime_panic.o
+ freestanding_io_x86_64.o + bootstrap_nostdlib_stubs.o
+ build_asm/*.o（或 driver/experimental/strict 对象集）
→ cc -nostdlib -static -Wl,--gc-sections [+ -lpthread -luring]
```

**注意**：

- 编译器 bootstrap 入口仍为 **crt0_x86_64.s**（`main_entry`），非用户 freestanding 的 crt0_user。
- **pthread / io_uring** 仍链系统库；v2 仅去 `-lc/-lm`。
- 默认（未设 `SHUX_BOOTSTRAP_NOSTDLIB`）行为与 v1 相同：`-lc -lm`。

## `-lc` 基线变化

| 指标 | v1 | v2 |
|------|----|----|
| `lc_link_cmds`（build_shux_asm 非注释含 `-lc` 行） | 6 | **2**（仅 helper 回退 echo） |

## 复现

```bash
# v2 prep（任意平台）
SHUX_NOLIBC_N07_V2_FAIL=1 ./tests/run-nolibc-n07-v2-prep-gate.sh

# Linux x86_64 实际尝试 nostdlib 全链（需 build_asm/*.o 就绪）
cd compiler && SHUX_BOOTSTRAP_NOSTDLIB=1 ./scripts/build_shux_asm.sh
```

## 延后（NL-07 v3+）

- ~~Linux x86_64 烟测硬绿~~ → 见 `analysis/phase-f-n07-v3.md` ✅
- **NL-07 v4**：`build_shux_asm` driver/experimental/strict 全链 nostdlib 硬绿
- pthread / io_uring 去系统库（或自研 stub）
- 默认启用 nostdlib（`-lc` 基线降至 0）
- `getenv` 真实环境块（当前桩恒 NULL）
