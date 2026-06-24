# std.io API v1 稳定化（STD-001）

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`EXC-001`（错误返回约定）、`TYPE-002`（read_ptr slice 域）、`tests/run-io-unified-gate.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **API 冻结边界** | 明确 `import("std.io")` 的稳定面与平台/实验面 |
| **兼容矩阵** | Linux / macOS / Windows 行为差异可查询 |
| **变更流程** | 破坏性改动须走评审 + 基线 + 门禁 |

验收标准（NEXT STD-001）：**兼容矩阵 + 变更流程** 文档化，且 CI 烟测覆盖稳定 API。

---

## 2. 模块分层

```
import("std.io")          ← 用户稳定面（本文档 §3）
    ├── std.io.driver  ← Buffer、submit_*（高级/内部；变更须同步 mod）
    └── std.io.core    ← C 桥接（不直接 import）
```

**v1 规则**：用户代码 **仅** `import("std.io")`；`std.fs` 重导出 fd 便捷 API，语义与 mod 一致。

---

## 3. 稳定 API 清单（Tier S）

完整符号列表见 `tests/baseline/std-io-api.tsv`（门禁校验）。

### 3.1 类型与 trait

| 符号 | 说明 |
|------|------|
| `ReadOnlySlice` / `WriteOnlySlice` | 只读/只写 slice 视图 |
| `ReadPtrView` | read_ptr 三元组（ptr + len + gen） |
| `Reader` / `Writer` | trait 占位（自举前最小签名） |
| `IO_ASYNC_NOT_READY` | 常量 `-2`，async 未就绪 |

### 3.2 Handle

| 符号 | 说明 |
|------|------|
| `handle_stdin()` / `handle_stdout()` / `handle_stderr()` | 0 / 1 / 2 |
| `handle_from_fd(fd, _unused)` | fd → handle |

### 3.3 同步读写（拷贝路径）

| 符号 | 返回值约定 |
|------|------------|
| `read` / `write` | `>0` 字节，`0`=EOF（读），`-1` 错误 |
| `read_into` / `write_from` | 同 read/write（fs 别名） |
| `read_stdin` / `write_stdout` / `write_stderr` | timeout=0 |
| `read_with_timeout` / `write_with_timeout` / `write_stderr_with_timeout` | 带 timeout_ms |
| `read_fd` / `write_fd` | fd 便捷 |
| `read_into_slice` / `write_from_slice` | `u8[]` 版 |

### 3.4 零拷贝读（read_ptr 族）

| 符号 | 生命周期 |
|------|----------|
| `read_ptr` / `read_stdin_ptr` | TLS 缓冲；下次 read_ptr 前有效 |
| `read_ptr_len` | 最近一次成功 read_ptr 长度 |
| `read_ptr_gen` / `read_ptr_gen_valid` | ZC-2 generation 校验 |
| `read_ptr_backend` | 0=TLS，1=mmap，2=dispatch_data |
| `read_ptr_view` / `read_ptr_view_valid` | 打包视图 |
| `read_ptr_slice` / `read_stdin_ptr_slice` | `u8[]<io_read_ptr>`（M-5 typeck） |

详见 `std/io/mod.sx` 文件头 Z2/ZC-1 注释。

### 3.5 批量与 fixed / provided

| 符号 | 说明 |
|------|------|
| `read_batch_fd` / `write_batch_fd` | 最多 4 段 |
| `read_batch_fd_buf` / `write_batch_fd_buf` | 1..16 段指针式 |
| `register_fixed_buffers` / `register_fixed_buffers_buf` | fixed 池 |
| `read_fixed_fd` / `write_fixed_fd` | 已注册池读写 |
| `register_provided_buffers` / `unregister_provided_buffers` | ZC-1 provided 池 |
| `provided_buffer_ptr` / `provided_buffer_size` | provided 块访问 |
| `read_provided_fd` / `read_batch_provided_fd` | provided recv |

### 3.6 异步（IO-A5）

| 符号 | 说明 |
|------|------|
| `read_async` / `write_async` | submit；返回 slot≥0 |
| `complete_read_async` / `complete_write_async` | 单 in-flight 收割 |
| `complete_read_async_slot` / `complete_write_async_slot` | 按 slot 收割 |

### 3.7 其它

| 符号 | 说明 |
|------|------|
| `wait_readable` | 多 fd 就绪等待 |
| `print_str` / `print_i32` / `print_u32` / `print_i64` | 标准输出 |

---

## 4. 兼容矩阵（v1）

图例：**✅** 全支持 · **⚠️** 回退/受限 · **❌** 不支持（须用替代 API）

| API 组 | Linux | macOS | Windows |
|--------|-------|-------|---------|
| **sync read/write**（read/write/read_fd） | ✅ io_uring→read | ✅ kqueue→read | ✅ IOCP→ReadFile |
| **batch**（read_batch_fd_buf） | ✅ readv / 多 SQE | ✅ readv | ✅ 多 Overlapped |
| **read_ptr TLS** | ✅ | ✅ | ✅ |
| **read_ptr mmap**（常规文件） | ✅ | ⚠️ dispatch_data | ⚠️ 有限 |
| **read_ptr_slice + typeck 域** | ✅ | ✅ | ✅ |
| **fixed buffers** | ✅ io_uring register | ⚠️ 存 ptr/len | ⚠️ 存 ptr/len |
| **provided buffers（ZC-1）** | ⚠️ 需 io_uring 5.19+ | ❌ 回退 read_fixed | ❌ 回退 read |
| **async read/write** | ✅ io_uring async | ⚠️ 部分 | ✅ IOCP |
| **wait_readable** | ✅ poll/epoll/uring | ✅ kqueue | ✅ IOCP |
| **timeout_ms** | ✅ | ✅ | ✅ |

**回退原则**（全平台）：高级路径失败时 **不得 crash**；返回 `-1` 或 `0`（read_ptr 失败），调用方可重试 sync API。

---

## 5. 错误与返回值（与 EXC-001 一致）

| 模式 | 约定 |
|------|------|
| 读写字节数 | `>0` 成功，`0` EOF（读），`-1` 错误 |
| read_ptr | 成功非 null，`0` 失败 |
| register_* | `1` 成功，`0` 失败/不支持 |
| async | slot≥0 已提交，`-1` 失败，`IO_ASYNC_NOT_READY` 未就绪 |

平台 errno：**不**由 std.io 返回；文件路径错误用 `std.fs.fs_last_error()`。

---

## 6. API 变更流程（v1）

### 6.1 分级

| 级别 | 标记 | 变更规则 |
|------|------|----------|
| **S 稳定** | `tests/baseline/std-io-api.tsv` | 禁止删改签名；可增 optional 参数须默认兼容 |
| **P 平台** | 兼容矩阵 §4 | 允许 per-OS 实现差异；须更新矩阵 |
| **E 实验** | mod.sx 注释 `@experimental` | 可随时改；晋升 S 须补基线 + 测试 |

### 6.2 破坏性变更步骤

1. 在 `NEXT.md` 登记（或 STD-00x 子项）并写 migration 段落  
2. 更新 `tests/baseline/std-io-api.tsv`（若动 Tier S）  
3. 跑 `tests/run-std-io-api-gate.sh` + `tests/run-io-unified-gate.sh`  
4. 至少一个发行周期保留 deprecated 别名（若可行）

### 6.3 新增 API 步骤

1. 在 `std/io/mod.sx` 实现并注释  
2. 若属 Tier S：追加 `std-io-api.tsv` 一行  
3. 增加 `tests/io/` 或扩展现有 smoke  
4. 更新本文档 §3/§4

---

## 7. CI 门禁

| 脚本 | 作用 |
|------|------|
| `tests/run-std-io-api-gate.sh` | 稳定符号 manifest + `run-io.sh` |
| `tests/run-io-unified-gate.sh` | 跨平台 batch/read_ptr/ZC-1 smoke |
| `tests/run-io-read-ptr-slice.sh` | M-5 slice 域 |
| `tests/run-zc3-gate.sh` | region typeck + read_ptr |
| `tests/run-pre-push-p5.sh` | 经 `run-zc-gates.sh` 间接覆盖 |

---

## 8. v2 预留

| 项 | 说明 |
|----|------|
| Reader/Writer trait 完整 impl | 文件/网络类型 |
| submit + wait 分离 | 真异步 in-flight |
| Result_i32 化 | 热路径评估后（EXC-001 Layer A） |
| IO_Result enum 对齐 | EXC-002 async 边界 |

---

## 9. 索引

| 资源 | 路径 |
|------|------|
| 实现 | `std/io/mod.sx`、`driver.sx`、`core.sx`、`io.c` |
| 用户 README | `std/io/README.md` |
| 稳定符号基线 | `tests/baseline/std-io-api.tsv` |
| 性能评估 | `std/fs/PERF-ASSESSMENT.md` |

**STD-001 状态：定版 ✅**
