# STD-142：std.process 跨平台行为一致性 v1

> 状态：**定版（v1）**  
> 关联：`STD-023/024`、`TST-002`、`ENG-003`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-142 | 三平台 process 行为向量 + 聚合烟测 + 子 gate 注册 |

聚合 `getpid/cwd/pipe/spawn` 可移植子集；Windows 专项见 `spawn_wait_win.sx`（STD-024）。

---

## 2. 行为矩阵

| API | Linux | macOS | Windows | v1 说明 |
|-----|-------|-------|---------|---------|
| `getpid` | ✅ | ✅ | ✅ | 正数 pid |
| `getppid` | ✅ | ✅ | -1 | Win 无简单 API |
| `getcwd` / `getcwd_ptr` | ✅ | ✅ | ✅ | 缓冲 + 零拷贝 |
| `self_exe_path` | ✅ | ✅ | ✅ | 可执行路径 |
| `pipe` | ✅ | ✅ | ✅ | CreatePipe |
| `spawn_simple` | ✅ | ✅ | ⚠️ | POSIX `/bin/true`；Win 烟测 skip |
| `spawn_io` | ✅ | ✅ | ✅ | fd<0 继承（STD-023） |
| `waitpid` | ✅ | ✅ | ✅ | 退出码低 8 位 |
| `exec` | ✅ | ✅ | -1 | Win 不替换当前进程 |

---

## 3. 烟测与门禁

| 用例 | 路径 |
|------|------|
| 聚合 | `tests/process/xplat_behavior.sx` |
| 边界 | `tests/process/boundary.sx`（TST-002） |
| Windows spawn | `tests/process/spawn_wait_win.sx` |
| pipe 重定向 | `tests/process/spawn_pipe_echo.sx` |

```bash
./tests/run-std-process-xplat-gate.sh
```

报告：`shux: [SHUX_STD142_PROCESS_XPLAT]`

---

## 4. 演进

- Windows `spawn_simple` 默认可执行探测（`where.exe`）
- 子进程环境块继承与 `std.env` 编码联动（STD-132）
