# STD-052：std.backtrace 符号化 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：TOOL-005（调试符号）、SAFE-007（崩溃证据）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
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

**金样锚点**：`backtrace_gold_anchor_c`（`backtrace_glue.c`），烟测期望符号名含 `gold_anchor`。

---

## 3. 已知帧金样

| ID | 类型 | 期望 |
|----|------|------|
| `gold_anchor_direct` | C 烟测 | `symbolicate` 解析锚点地址，名含 `gold_anchor` |
| `capture_symbolicate` | C / `.x` | `capture` 后 `symbolicate` 至少 1 帧有符号 |

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

## 5. 门禁

```bash
./tests/run-std-backtrace-symbolicate-gate.sh
```

```
shux: [SHUX_STD_BACKTRACE_SYM] status=ok c_gold=1 x=1 skip=0 host=Darwin/arm64
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | symbolicate 实装 + gold_anchor 金样 |
