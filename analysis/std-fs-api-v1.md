# std.fs API v1 稳定化（STD-003）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`STD-001`（std.io 联合 fd API）、`ZC-005`（pipe splice）、`tests/run-io-unified-gate.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **API 冻结边界** | `import("std.fs")` 的稳定面与平台/实验面 |
| **三平台对齐** | Linux / macOS / Windows 同一套 `.sx` 烟测 |
| **兼容矩阵** | 零拷贝/内核提示等差异可查询 |
| **变更流程** | 与 STD-001 同级评审规则 |

验收标准（NEXT STD-003）：**Linux/macOS/Windows 对齐测试** + 兼容矩阵 + 变更流程。

---

## 2. 模块分层

```
import("std.fs")          ← 用户稳定面（本文档 §3）
    ├── std.io         ← 已 re-export read_fd/write_fd/batch（§3.5）
    └── std/fs/fs.c    ← C 桥接（不直接 import）
```

**v1 规则**：文件路径由 `std.path` 拼接；**用户仅** `import("std.fs")` 即可用 fd + io 批量路径。

---

## 3. 稳定 API 清单（Tier S）

完整符号见 `tests/baseline/std-fs-api.tsv`（37 个，门禁校验）。

### 3.1 基础 I/O

| 符号 | 说明 |
|------|------|
| `fs_open_read` / `fs_open_write` / `fs_close` | 只读/写（截断）/关闭 |
| `fs_open_append` / `fs_open_create` | 追加 / 存在不截断 |
| `fs_read` / `fs_write` | 顺序大块（建议 ≥ `fs_read_chunk()`） |
| `fs_pread` / `fs_pwrite` | 带 offset 并发读/写 |
| `fs_read_chunk` | 推荐块大小（1MiB） |
| `fs_last_error` | 上次失败 errno / GetLastError |
| `fs_path_readable` | 路径可读探测（工具链用） |
| `fs_invalid_handle` | 常量 -1 |

### 3.2 mmap

| 符号 | 说明 |
|------|------|
| `fs_mmap_ro` / `fs_mmap_rw` / `fs_munmap` | 整文件映射 |

### 3.3 向量 I/O

| 符号 | 说明 |
|------|------|
| `fs_readv2` / `fs_writev2` | 2 段 readv/writev |
| `fs_readv4` / `fs_writev4` | 4 段 |
| `fs_readv_buf` / `fs_writev_buf` | 1..16 段（`FsIovecBuf`） |

### 3.4 内核提示与零拷贝

| 符号 | 说明 |
|------|------|
| `fs_fadvise_sequential` / `fs_fadvise_willneed` | Linux fadvise |
| `fs_open_read_direct` / `fs_direct_align` | O_DIRECT / F_NOCACHE / NO_BUFFERING |
| `fs_copy_file_range` | 文件→文件内核复制 |
| `fs_sendfile` | 文件→socket |
| `fs_pipe_splice` | ZC-5 pipe splice |
| `fs_sync_range` / `fs_sync` | 范围/整文件刷盘 |
| `fs_fallocate` | 预分配 |

### 3.5 std.io 联合（re-export）

| 符号 | 说明 |
|------|------|
| `handle_from_fd` | fd → io handle |
| `read_fd` / `write_fd` | 单次大块（io_uring/kqueue/IOCP） |
| `read_batch_fd` / `write_batch_fd` | 最多 4 段 batch |

---

## 4. 兼容矩阵（v1）

图例：**✅** 全支持 · **⚠️** 回退/受限 · **❌** 不支持（须用替代 API）

| API 组 | Linux | macOS | Windows |
|--------|-------|-------|---------|
| **open/read/write/close** | ✅ | ✅ | ✅ |
| **pread/pwrite** | ✅ | ✅ | ✅ |
| **mmap ro/rw** | ✅ madvise | ✅ | ✅ MapViewOfFile |
| **readv2/4、readv_buf** | ✅ readv | ✅ readv | ✅ 多段 ReadFile |
| **read_fd/write_fd/batch** | ✅ io_uring | ✅ kqueue | ✅ IOCP |
| **fadvise** | ✅ | ❌ no-op | ❌ no-op |
| **O_DIRECT 族** | ✅ | ⚠️ F_NOCACHE | ⚠️ NO_BUFFERING |
| **copy_file_range** | ✅ 内核 | ⚠️ read+write | ⚠️ read+write |
| **sendfile** | ✅ | ❌ | ⚠️ TransmitFile |
| **pipe_splice（ZC-5）** | ✅ splice | ⚠️ read/write | ⚠️ read/write |
| **sync_range** | ✅ | ⚠️ fsync 代理 | ❌ no-op |
| **fallocate** | ✅ | ⚠️ 有限 | ⚠️ SetEndOfFile |

---

## 5. 跨平台对齐测试（v1）

| 资源 | 说明 |
|------|------|
| 矩阵 | `tests/baseline/std-fs-crossplatform.tsv` |
| 统一 .sx | `tests/fs/crossplatform_core.sx` |
| 门禁 | `tests/run-std-fs-crossplatform-gate.sh` |
| CI | `run-portable-suite.sh` 全 job 调用 |

策略：

| policy | 含义 |
|--------|------|
| **must** | 当前平台必须 exit 0 |
| **skip** | 不跑（如 Linux-only splice） |
| **optional** | 跑但失败仅 WARN（v1 未用） |

---

## 6. 变更流程（v1）

与 `analysis/std-io-api-v1.md` §6 一致：

1. **Tier S 变更**须 PR 说明 + 更新 `std-fs-api.tsv` + 跑 `run-std-fs-api-gate.sh`
2. **破坏性改动**须 minor 版本 bump 说明（文档 + NEXT 状态）
3. **平台行为变化**须同步更新 §4 兼容矩阵
4. **新增 Tier S** 默认须 crossplatform `must` 三平台或文档标注 skip

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 用户 README | `std/fs/README.md` |
| 性能评估 | `std/fs/PERF-ASSESSMENT.md` |
| API 门禁 | `tests/run-std-fs-api-gate.sh` |
| 跨平台门禁 | `tests/run-std-fs-crossplatform-gate.sh` |
| 现有烟测 | `tests/run-fs.sh` |

**STD-003 状态：定版 ✅**
