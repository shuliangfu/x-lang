# STD-077 std.cli v1

> 更新时间：2026-08-29  
> 状态：**可用** — 选项/子命令/usage + gate honesty（残 auto-make 已退役）

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

Honesty（2026-08-29 残 auto-make）：prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏 XLANG／缺 native 硬 die；拒 soft `xlang_compiler_make` 重建 cli.o；host-C 仅现成 `.o`＝obs；`check` 观测；`roundtrip.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`。

```
xlang: [XLANG_STD_CLI] status=ok run=1 obs=2 skip=0
std-cli gate OK
```

（Darwin 上 `check` CHK residual＝obs；host-C 现成 `.o` 或缺 `.o` 均为 obs。硬绿信号是 `run=1`。）

---

## 4. Changelog

- 2026-08-29：残 soft auto-make（host-C 前 `xlang_compiler_make` 重建 cli.o）退役；host-C 仅现成 `.o`＝obs；报告 `run=`／`obs=`／`skip=`。
- 2026-08-25：闸／TSV／DOC 假权威诚实化；钉盘不升。
- 2026-06-18：v1 初版（parse / usage / cookbook + gate）。
