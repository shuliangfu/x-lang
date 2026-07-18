# STD-023/024 std.process 管道与 Windows spawn v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2 P0、`tests/run-process.sh`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-023 | `spawn_io` stdin/stdout/stderr 重定向；`pipe()` 三平台 |
| STD-024 | Windows `CreateProcess` + `waitpid` 金样（`cmd.exe /c exit 0`） |

---

## 2. STD-023：管道与重定向

### 2.1 API

| API | 说明 |
|-----|------|
| `pipe(read_fd, write_fd)` | 创建匿名管道；0 成功 |
| `SpawnIo` | `{ stdin_fd, stdout_fd, stderr_fd }`；**fd < 0** 表示继承 |
| `spawn_io(program, argv, io)` | 同 `spawn`，附带 stdio 重定向（`process_spawn_io_c`） |

### 2.2 平台

| 能力 | POSIX | Windows |
|------|-------|---------|
| `pipe` | `pipe(2)` | `CreatePipe` + `_open_osfhandle` |
| `spawn_io` | `fork` + `dup2` + `execve` | `CreateProcess` + `STARTF_USESTDHANDLES` |

### 2.3 金样烟测

`tests/process/spawn_pipe_echo.x`：

1. `pipe` 得 read/write fd  
2. `spawn_io(/bin/echo, argv, stdout=write_fd)`  
3. 父进程 `fs_read` 得 `hello\n`  
4. Windows 回退：`cmd.exe /c echo hello`

---

## 3. STD-024：Windows spawn_wait

| 用例 | 脚本 | linux | macos | windows |
|------|------|-------|-------|---------|
| `spawn_wait_posix` | `spawn_wait.x` | must | must | skip |
| `spawn_wait_win` | `spawn_wait_win.x` | skip | skip | must |

`spawn_wait_win.x`：`cmd.exe /c exit 0` + `waitpid` → 0。

---

## 4. 验收

- manifest：`tests/baseline/std-process-pipe-spawn.tsv`
- 门禁：`tests/run-std-process-pipe-spawn-gate.sh`
- 报告：`shux: [SHUX_STD_PROCESS_PIPE_SPAWN] status=ok`
- CI：`tests/run-portable-suite.sh`

---

## 5. 演进

- `spawn_io` 合并环境变量 / cwd 选项  
- 命名管道与异步 IO 集成  
- 语言层 `Command` 构建器
