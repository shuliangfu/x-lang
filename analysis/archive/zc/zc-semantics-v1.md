# ZC-006 零拷贝语义白皮书 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 读者：标准库/性能路径开发者  
> 关联：`ZC-001..005` 门禁、`TYPE-002`（slice 域）、`std.io` / `std.fs` / `std.string`

---

## 1. 北极星与三层模型

**目标**：核心数据路径 **0 次用户态冗余拷贝**——语义、库实现、内核路径一致。

```
┌─────────────────────────────────────────────────────────────┐
│ L — Language   │ T[]<label> region、Linear(T)、slice 视图      │
├────────────────┼────────────────────────────────────────────┤
│ B — Library    │ read_ptr / StrView / mmap / provided buf    │
├────────────────┼────────────────────────────────────────────┤
│ K — Kernel     │ splice / sendfile / copy_file_range / mmap  │
└─────────────────────────────────────────────────────────────┘
```

| 层 | 职责 | 失败时 |
|----|------|--------|
| **L** | 编译期阻止 slice 逃逸（UAF） | typeck error |
| **B** | API 选型：视图 vs 拷贝 | 文档 + gate |
| **K** | 平台 syscall 零拷贝 | 回退 read/write 循环 |

---

## 2. 「拷贝」定义（v1）

| 类别 | 算拷贝？ | 说明 |
|------|----------|------|
| 内核 → 用户缓冲 `read`/`read_into` | ✅ 1 次 | 不可避免的用户态可见拷贝 |
| `read_ptr` / provided buffer 视图 | ❌ 无额外库内拷贝 | 数据已在 TLS/注册缓冲；**有生命周期约束** |
| `write`/`write_from` 用户 ptr | ❌ 无库内二次拷贝 | ptr 直传 submit/io_uring |
| `fs_mmap_ro/rw` | ❌ 映射视图 | 页 fault 由 OS 负责 |
| `fs_sendfile` / `fs_pipe_splice` | ❌ 内核管道 | 用户态不 touch 字节 |
| `string_from_slice` / `String` 拥有 | ✅ 堆拷贝 | 拥有内存；对比 `StrView` |
| `StrView` / `string_view_subview` | ❌ 视图 | 仅 (ptr,len) |
| `T[N]` → `T[]` 在 region 内 | ❌ 视图 | ZC-3；见 `region_array_smoke.x` |
| `vec_i32_data_ptr` + len | ❌ 内部缓冲视图 | 勿在 grow 后继续使用 |

**冗余拷贝**：在已有稳定视图或内核可零拷贝路径上，标准库再次 `memcpy` 到中间缓冲。

---

## 3. ZC-1..5 能力地图

| ID | 能力 | 典型 API | 门禁 |
|----|------|----------|------|
| **ZC-1** | Provided Buffers | `register_provided_buffers`、`read_provided_fd` | `run-zc1-gate.sh` |
| **ZC-2** | read_ptr 绝对视图 | `read_ptr`、`ReadPtrView`、`read_ptr_gen_valid` | `run-zc2-gate.sh` |
| **ZC-3** | slice 域 | `u8[]<io_read_ptr>`、`region` | `run-zc3-gate.sh` |
| **ZC-4** | String 视图 | `StrView`、`stack_str_view`、Arena64 concat | `run-zc4-gate.sh` |
| **ZC-5** | splice/sendfile | `fs_pipe_splice`、`fs_sendfile` | `run-zc5-gate.sh` |

统一入口：`./tests/run-zc-gates.sh`

---

## 4. 拷贝触发点（Catalog）

### 4.1 IO 读路径

| API | 拷贝 | 规避 |
|-----|------|------|
| `read` / `read_stdin` / `read_into` | 内核→用户 buf | 短生命周期扫描用 `read_ptr` |
| `read_ptr` / `read_ptr_slice` | 无库内拷贝 | 见 §5 生命周期；绑 `io_read_ptr` 域 |
| `read_batch_fd` | 每 iovec 一次 | 高吞吐用 provided buffers (ZC-1) |
| `read_provided_fd` | 无（已在注册 buf） | Linux io_uring 5.19+ |

### 4.2 IO 写路径

| API | 拷贝 | 说明 |
|-----|------|------|
| `write` / `write_from` | 无库内二次拷贝 | 用户 ptr 直传 driver |
| `write_batch_fd` | 无 | scatter 直传 |

### 4.3 文件系统

| API | 拷贝 | 规避 |
|-----|------|------|
| `fs_read` / `fs_write` | 用户 buf 一次 | 大文件只读 → `fs_mmap_ro` |
| `fs_mmap_ro/rw` | 映射 | 长生命周期只读/可写 |
| `fs_copy_file_range` | 内核内（Linux） | 替代用户态 read+write |
| `fs_sendfile` | 内核 file→socket | `zero_copy_sendfile.x` |
| `fs_pipe_splice` | 内核 pipe 代理 | ZC-5 bench |

### 4.4 字符串 / 容器

| API | 拷贝 | 规避 |
|-----|------|------|
| `string_from_slice` | ✅ 堆分配+拷贝 | 只读解析用 `string_view` |
| `string_append_slice` | ✅ 可能 realloc+拷贝 | 批量拼接用 Arena64 |
| `string_view` / `string_view_subview` | ❌ | 解析/比较/查找 |
| `stack_str_view` | ❌ | SSO 栈内联 → StrView |

---

## 5. 生命周期与 slice 域（L 层）

### 5.1 read_ptr（ZC-2）

1. 指针指向 **单线程 TLS 缓冲**；只读，勿 `free`。
2. 有效至 **同线程** 下一次 `read_ptr` 成功返回前。
3. 大文件/跨 await → 用 `read_into` 或 `fs_mmap_ro`。
4. `ReadPtrView.gen` + `read_ptr_gen_valid` 检测 stale 指针。

### 5.2 Provided Buffers（ZC-1）

1. 先 `register_provided_buffers`。
2. `provided_buffer_ptr(bid)` 只读至 bid 被内核复用。
3. 非 Linux 回退 `read_batch_fd`。

### 5.3 region / `T[]<label>`（ZC-3）

- `read_ptr_slice` 返回 `u8[]<io_read_ptr>`；**不得**赋给未标注 `u8[]`。
- `region ra { let s: i32[] = arr; }` — 块内数组转 slice 为视图。
- 详 `analysis/type-region-v1-rfc.md`。

---

## 6. API 选型决策树

```
数据是否要长期持有？
├─ 否，单次处理
│   ├─ 网络/IO 热路径 + Linux io_uring → ZC-1 provided
│   ├─ 同步读且可接受 TLS 约束 → read_ptr / read_ptr_slice (ZC-2/3)
│   └─ 否则 → read_into 用户 buf（1 拷贝，最简单）
├─ 是，只读大文件 → fs_mmap_ro (K+L)
├─ 是，字符串解析 → StrView (ZC-4)，结束再决定是否 string_from_slice
└─ 文件→socket / pipe 代理 → fs_sendfile / fs_pipe_splice (ZC-5)
```

---

## 7. 平台差异（v1）

| 能力 | Linux | macOS | Windows |
|------|-------|-------|---------|
| ZC-1 provided | io_uring 5.19+ | N/A → 回退 | N/A → 回退 |
| ZC-2 mmap 绝对视图 | ✅ | ✅ | 部分 |
| ZC-5 splice | ✅ | 回退 | TransmitFile 等 |
| copy_file_range | ✅ | read+write | read+write |

门禁在非 Linux 上对 ZC-1/ZC-5 **允许 SKIP**；语义仍须遵守 L/B 层规则。

---

## 8. 门禁与测试索引

| 主题 | 测试 | 脚本 |
|------|------|------|
| 统一 ZC | — | `run-zc-gates.sh` |
| read_ptr | `tests/io/read_ptr.x` | `run-io.sh` |
| slice 域 | `tests/slice/region_array_smoke.x` | `run-zc3-gate.sh` |
| StrView | `tests/string/view_zerocopy.x` | `run-zc4-gate.sh` |
| sendfile | `tests/bench/zero_copy_sendfile.x` | perf IO |

---

## 9. PR 自检（5 题）

1. 新读 API 是否必要 `memcpy`？能否 `read_ptr` 或 provided？  
2. 返回 slice 是否标注域？能否逃逸到未标注 `u8[]`？  
3. 字符串解析是否可用 `StrView` 代替 `String`？  
4. 大文件是否考虑 `mmap` 而非 slurp 到 vec？  
5. Linux 专有路径是否有 documented 回退？

ZC-007 PR 声明与证明测试模板见 `analysis/zc-copy-proof-v1.md`、`tests/templates/zc-pr-copy-declaration.txt`。

---

## 10. 深入阅读

| 资源 | 路径 |
|------|------|
| slice 域 | `analysis/type-region-v1-rfc.md` |
| IO 模块头 | `std/io/mod.x`（Z2/ZC-1 生命周期） |
| FS 零拷贝 | `std/fs/README.md` |
| String ZC-4 | `std/string/mod.x` |
| 内存安全指南 | `analysis/doc-memory-safety-error-v1.md` |

**ZC-006 状态：定版 ✅**
