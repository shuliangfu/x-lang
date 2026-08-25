# STD-052：std.backtrace 符号化 v1

> 更新时间：2026-08-26（honesty soft→硬绿）· 原稿 2026-06-17  
> 状态：**定版（v1）+ gate honesty**  
> 关联：TOOL-005（调试符号）、SAFE-007（崩溃证据）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 + §5 Gate |
| 2 | `tests/baseline/std-backtrace-symbolicate-vectors.tsv` |
| 3 | `./tests/run-std-backtrace-symbolicate-gate.sh` |
| 4 | 烟测：`symbolicate_gold.c`、`symbolicate_known.x` |

---

## 2. API

| API | 说明 |
|-----|------|
| `capture(buf, max_frames)` | 写入返回地址，每帧 `sizeof(void*)` 字节 |
| `symbolicate(buf, len, out_ptrs, out_names, max)` | `len` 为帧数；`out_names` 布局 `max × SYM_NAME_LEN`（128） |
| `SYM_NAME_LEN` | 128 |

**实现**：`dladdr`（Unix/macOS）；Windows `DbgHelp` `SymFromAddr`。未解析时回退 `0x…` 十六进制，不计入成功帧数。

**金样锚点**：`backtrace_gold_anchor_c`（runtime seed），烟测期望符号名含 `gold_anchor`。

C 烟测入口 `backtrace_symbolicate_smoke_c` 位于 `compiler/seeds/runtime_backtrace_platform.from_x.c`（非 `std/backtrace/backtrace.x`）。

---

## 3. 已知帧金样

| ID | 类型 | 期望 |
|----|------|------|
| `gold_anchor_direct` | C 烟测 | `symbolicate` 解析锚点地址，名含 `gold_anchor` |
| `capture_symbolicate` | C / `.x` | `capture` 后写入至少 1 个 name 槽（具名 **或** hex 回退；具名需产品 ld `--export-dynamic`） |

编译烟测二进制建议 `-g`；Linux 另加 `-rdynamic -ldl`。

---

## 4. 平台

| 平台 | capture | symbolicate |
|------|---------|-------------|
| Linux (glibc) | execinfo | dladdr |
| macOS | execinfo | dladdr |
| Windows | CaptureStackBackTrace | DbgHelp |
| 其他 | 0 | 回退十六进制 |

---

## 5. Gate

```bash
./tests/run-std-backtrace-symbolicate-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期暂停闸门，2026-08-05）；CHK 红不硬失败。
- `symbolicate_known.x` **exit 0 硬失败**（有 native xlang 时 **无 soft SKIP**）；接受具名 **或** hex 名槽（裸 `ld` 缺 `--export-dynamic` 时 Linux 常走 hex）。
- C gold（`symbolicate_gold.c`）在 execinfo 宿主上硬失败；Alpine/musl 无 execinfo 时仅跳过 C gold；C gold 仍要求 `gold_anchor` **具名**。
- C gold 链入 `runtime_process_argv.o`＋`runtime_link_abi_user_env.o`（backtrace／crash-evidence 依赖；化石 symbol_miss 曾掩盖 UNDEF）。
- TSV `symbol_smoke_c` 路径对齐 seed（化石曾指 `backtrace.x`）。
- 产品残债（**非软**）：asm 裸 `ld` 链 backtrace 时未传 `--export-dynamic`（cc 路径的 `-rdynamic` 对裸 ld 无效）。

期望报告：

```
xlang: [XLANG_STD_BACKTRACE_SYM] status=ok check=? c_gold=1 x=1 skip=0 host=…
```

- `check=` 观测（Darwin 常 0／Ubuntu 常 1，均不挡硬绿）。
- 硬绿信号 = `x=1` + `c_gold=1`（execinfo 宿主）+ `skip=0`。

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | symbolicate 实装 + gold_anchor 金样 |
| honesty | 2026-08-26 | soft→硬绿：prefer asm；`## 5. Gate`；smoke_c→seed；check 观测；format_hex 按字节；.x 烟测接受 hex 名槽 |
