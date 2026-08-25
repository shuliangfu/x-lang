# STD-077 std.cli v1

> 更新时间：2026-06-18  
> 状态：**可用** — 选项/子命令/usage + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-cli-manifest.tsv` |
| 3 | `./tests/run-std-cli-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `CliResult` | 子命令/标志/位置参数结果 |
| `parse_from_iter` | 与 `std.env.args_iter` 集成 |
| `is_help` / `is_version` | 标准选项检测 |
| `match_long` / `match_short` | `-f` / `--flag` |
| `write_usage` | usage 自动生成 |
| `err_ok` / `err_help` / `err_unknown` | 退出码约定（0/1/-1） |

Cookbook：`examples/cookbook/cli_subcommand.x`（gate 烟测同逻辑）。

---

## 3. Gate

### 假权威诚实验收（2026-08-25）

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期 check 闸门暂停 2026-08-05）；不硬失败。
- 可跑烟测 `tests/std-cli/roundtrip.x` exit **0** 硬失败；有原生 xlang 时 **禁 soft SKIP**。
- C smoke 仅观测（archaeology host-C；非硬绿信号）。
- 报告：`check=`／`run=`／`skip=`（`run=1` 为硬绿信号）。

```
xlang: [XLANG_STD_CLI] status=ok check=0|1 run=1 skip=0
std-cli gate OK
```
