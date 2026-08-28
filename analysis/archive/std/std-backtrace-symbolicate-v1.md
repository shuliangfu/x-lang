# STD-052：std.backtrace 符号化 v1

> 更新时间：2026-08-28（honesty residual XLANG fallthrough／auto-make →硬绿）· 原稿 2026-06-17  
> 状态：**定版（v1.2）** · Gate honesty residual XLANG fallthrough／auto-make →硬绿  
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

Honesty residual（2026-08-28）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- 显式坏 `XLANG`／缺 native **硬 die**（拒 XLANG fallthrough／soft auto-make／prefer-c／soft SKIP→OK／soft `ensure_std_c_o` 重建／`ensure_runtime_backtrace_platform_o`／extra CLI `.o`／C gold auto-make）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `symbolicate_known.x` 产品 `-o` **exit 0 硬失败**（硬绿信号＝`run=`；接受具名 **或** hex 名槽）
- Host-C archaeology **仅观测**（现成 `std/backtrace/backtrace.o`＋`compiler/runtime_backtrace_platform.o` only；拒 ensure／auto-make 重建；不传 extra CLI `.o`；C gold 文件存在仍 TSV 必有，compile/run 非绿）
- 报告行：`run=`／`obs=`／`skip=`（退役 `check=`／`c_gold=`／`x=` 当硬绿）
- 禁顶层 DOC 复活（live = `analysis/archive/std/`）
- 保留 `## 5. Gate`
- 关键词：STD-052／gold_anchor／SYM_NAME_LEN／dladdr
- 产品残债（**非软**）：asm 裸 `ld` 链 backtrace 时未传 `--export-dynamic`（cc 路径的 `-rdynamic` 对裸 ld 无效）

manifest：`tests/baseline/std-backtrace-symbolicate.tsv`

```
xlang: [XLANG_STD_BACKTRACE_SYM] status=ok run=1 obs=0|1|2 skip=0
std-backtrace-symbolicate gate OK
```

F-backtrace v1／v2 仍硬委托本闸（须保持 exit 0）。

### 5.1 Changelog

- 2026-06-17：v1 symbolicate 实装 + gold_anchor 金样。
- 2026-08-26：Honesty v1.1（prefer asm；check 观测；smoke_c→seed；`## 5. Gate`；报告 `check=`／`c_gold=`／`x=`）。
- 2026-08-28：Honesty residual v1.2（拒 XLANG fallthrough／auto-make／bootstrap-link／ensure 重建／C gold auto-make；报告 `run=`／`obs=`／`skip=`；未啃产品 `std/backtrace`／`--export-dynamic`）。

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | symbolicate 实装 + gold_anchor 金样 |
| v1.1 | 2026-08-26 | Gate honesty：prefer asm／LINK／check 观测；smoke_c→seed；`## 5. Gate` |
| v1.2 | 2026-08-28 | Honesty residual：拒 XLANG fallthrough／auto-make／ensure；报告 `run=`／`obs=`／`skip=` |
