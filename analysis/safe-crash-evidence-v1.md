# SAFE-007 崩溃最小证据包 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`std.backtrace`、`SAFE-001`（UB panic）、`OBS-003`（bracket 日志）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读 `std/backtrace/mod.x`：`collect_crash_evidence` |
| 2 | 读本文 §2–§4（证据字段、环境变量、panic 挂钩） |
| 3 | `./tests/run-safe-crash-evidence-gate.sh` |

---

## 2. 证据包字段

落盘文件（`$SHUXXX_CRASH_EVIDENCE_DIR/shux-crash-<pid>.txt`）：

| 字段 | 含义 |
|------|------|
| `panic_has_msg` | panic 是否带消息码 |
| `panic_msg` | 消息整型（若有） |
| `frames` | 捕获栈帧数 |
| `pid` | 进程 ID |
| `frameN` | 返回地址（平台相关） |

stderr 摘要（可 grep / 回放定位）：

```
shux: [SHUX_CRASH_EVIDENCE] panic=1 msg=42 frames=8 pid=12345
shux: [SHUX_CRASH_EVIDENCE] bundle=/tmp/.../shux-crash-12345.txt
```

---

## 3. 环境变量

| 变量 | 作用 |
|------|------|
| `SHUX_CRASH_EVIDENCE=1` | 启用收集（manual 或 panic 路径）；bundle 文件便于 **replay** 离线对照栈址。 |
| `SHUX_CRASH_EVIDENCE_DIR` | 可选；设置则写入 bundle 文本文件 |

---

## 4. panic 挂钩

`shux_panic_`（`compiler/src/asm/runtime_panic.c`）在 `abort` 前调用弱符号 `shux_crash_evidence_collect_c`；强实现位于 `std/backtrace/backtrace_glue.c`（链接 `backtrace.o` 时生效）。

---

## 5. 回归用例

| case | 路径 | 说明 |
|------|------|------|
| `case_manual` | `tests/crash/evidence_manual.x` | 显式 `collect_crash_evidence` |
| `case_panic` | `tests/ub/div_zero.x` | 除零 → panic 自动收集 |

联动：`tests/run-ub.sh`（UB 收窄 panic 回归）。

```bash
SHUX_CRASH_EVIDENCE=1 ./tests/run-safe-crash-evidence.sh   # runnable
./tests/run-safe-crash-evidence-gate.sh
```

---

## 6. 验证与门禁

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/safe-crash-evidence-v1.md` |
| manifest | `tests/baseline/safe-crash-evidence.tsv` |
| 库 | `tests/lib/safe-crash.sh` |
| runner | `tests/run-safe-crash-evidence.sh` |
| 门禁 | `tests/run-safe-crash-evidence-gate.sh` |

**SAFE-007 状态：定版 ✅**
