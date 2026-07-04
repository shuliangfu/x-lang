# TST-004：std 模块 sanitizer 夜跑子集 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：SAFE-005（通用泄漏夜跑）、M-6（`-fsanitize=address` 边界插桩）、STD heap/channel

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3（ASAN 策略与用例矩阵） |
| 2 | 打开 `tests/baseline/tst-004-std-sanitize.tsv` |
| 3 | `./tests/run-tst-004-std-sanitize-gate.sh` |
| 4 | 夜跑：`./tests/run-tst-004-std-sanitize-nightly.sh` |

---

## 2. ASAN 策略

| 项 | 说明 |
|----|------|
| 编译 | `shux -fsanitize=address -L . <case>.x -o exe` |
| 运行 | `ASAN_OPTIONS=detect_leaks=1:exitcode=23:halt_on_error=1` |
| 探测器 | 复用 `tests/lib/safe-leak.sh`（与 SAFE-005 一致） |
| 与 M-6 | `tests/run-sanitize-gate.sh` 管 **INDEX 边界插桩**；本任务管 **std 模块运行时泄漏** |
| SKIP | cc 不支持 ASAN 或无 native `shux-c` 时 gate 仅验 manifest |

v1 聚焦 **std.heap**、**std.channel**；后续可追加 `std.string` / `std.ffi` 等行。

---

## 3. std 夜跑用例矩阵

| case_id | 模块 | 烟测 | needs_o |
|---------|------|------|---------|
| `case_heap_std` | `std.heap` | `tests/sanitize/std_heap_asan.x` | `../std/heap/heap.o` |
| `case_channel_std` | `std.channel` | `tests/sanitize/std_channel_asan.x` | `../std/channel/channel.o` |

**heap**：`alloc` / `alloc_zero` / `realloc` / `Arena64` 成对释放。  
**channel**：有界 `send`/`recv`/`close`/`free`；Windows stub 创建失败时返回 0（与 `tests/channel/main.x` 一致）。

---

## 4. 报告格式

```
shux: [SHUX_TST004_SANITIZE] status=ok cases_ok=2 cases_fail=0 skip=0
```

| status | 含义 |
|--------|------|
| `ok` | 全部 case 通过 |
| `fail` | 编译失败、ASAN 泄漏或崩溃 |
| `skip` | 无 ASAN / 无 shux |

---

## 5. 验证与门禁

```bash
./tests/run-tst-004-std-sanitize-gate.sh
```

- manifest：`tests/baseline/tst-004-std-sanitize.tsv`
- 夜跑：`tests/run-tst-004-std-sanitize-nightly.sh`
- 便携回归：`tests/run-portable-suite.sh`
- 交叉引用：SAFE-005 `safe-leak-nightly.tsv`、M-6 `run-sanitize-gate.sh`

---

## 6. 维护

新增 std ASAN case 时：

1. 在 `tests/sanitize/` 添加 `.x`
2. 向 `tst-004-std-sanitize.tsv` 增加 `case_*` 行（含 `needs_o`）
3. 更新 `min_cases` 与本文 §3
