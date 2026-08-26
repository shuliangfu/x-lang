# STD-142：std.process 跨平台行为一致性 v1

> 状态：**定版（v1）**  
> 关联：`STD-023/024`、`TST-002`、`ENG-003`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-142 | 三平台 process 行为向量 + 聚合烟测 + 子 gate 注册 |

聚合 `getpid/cwd/pipe/spawn` 可移植子集；Windows 专项见 `spawn_wait_win.x`（STD-024）。

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

## 3. Smokes

| Case | Path |
|------|------|
| Aggregate | `tests/process/xplat_behavior.x` (hard green) |
| Boundary | `tests/process/boundary.x` (TST-002; hard green) |
| Windows spawn | `tests/process/spawn_wait_win.x` (observational; XT001) |
| Pipe redirect | `tests/process/spawn_pipe_echo.x` (observational; XT001) |

---

## 4. Gate

Honesty (2026-08-26): prefer `xlang_asm` + pin `XLANG_LINK_XLANG`; check
observational (paused 2026-08-05); `xplat_behavior.x` + `boundary.x` exit 0
hard-fail (no soft SKIP when native present). `spawn_wait_win` /
`spawn_pipe_echo` observational only (product XT001; not soft). Report
`check=` / `xplat=` / `boundary=` / `skip=`.

```bash
./tests/run-std-process-xplat-gate.sh
```

Report prefix: `xlang: [XLANG_STD142_PROCESS_XPLAT]`

---

## 5. Evolution

- Windows `spawn_simple` default executable probe (`where.exe`)
- Child env-block inheritance linked with `std.env` encoding (STD-132)
