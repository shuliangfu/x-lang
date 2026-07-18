# std 开发时序分析

> 在 core 完善完成后，std 的开发顺序、依赖关系，以及 **高性能 Shu IO** 与 **fs** 的设计要点。与 `std/README.md` 阶段 7 清单、`runtime/README.md` 舒 IO 桩、现有 std.io / std.fs / std.io.driver 注释一致。

---

## 一、总览与原则

- **std**：依赖 OS 的标准库（进程、文件、网络、路径等），用户通过 `import("std.xxx")` 引用；内部按目标平台条件编译，**用户只写一套 API**。
- **依赖**：std 依赖 core；std 内部模块之间有依赖（如 std.io.driver 依赖 std.io.core，std.fs 可与 std.io 统一缓冲模型）。
- **目标**：与项目宗旨一致——**高性能**（io/fs 考虑零拷贝、批量化、与「舒 IO」统一）、**轻量级**、全平台一套 API。

---

## 二、std 模块依赖与开发顺序

### 2.1 模块依赖关系（示意）

```
                    core（已完善）✅
                         │
     ┌───────────────────┼───────────────────┬───────────────────┐
     │                   │                   │                   │
     ▼                   ▼                   ▼                   ▼
std.runtime ✅      std.io.core ✅     std.process ✅      std.path ✅
（运行时/panic）     （舒 IO 核心层）    （exit/args）        （路径拼接/规范化）
                         │                   │                   │
                         ▼                   │                   │
                    std.io.driver ✅          │                   │
                    （Buffer/submit）        │                   │
                         │                   │                   │
                    std.mem ✅               │                   │
                    （Buffer ABI/预注册）     │                   │
                         │                   │                   │
     ┌───────────────────┴───────────────────┴───────────────────┤
     ▼                                                             ▼
std.io（对外 API）✅                                          std.fs（文件）✅
     │                                                             │
     └───────────────────────────┬─────────────────────────────────┘
                                 ▼
              std.string ✅ / std.vec ✅ / std.heap ✅ / std.map ✅ / std.error ✅ / std.net
```

### 2.2 推荐开发阶段（按序）

| 阶段 | 模块 / 内容 | 依赖 | 说明 |
|------|-------------|------|------|
| **S0** ✅ | **std.runtime**（运行时 / panic） | core | 运行时初始化、panic 钩子等；自举前必须。 |
| **S1** ✅ | **std.io.core**（舒 IO 核心） | core | 已实现：经 extern 调 std/io/io.c（io_uring/kqueue/IOCP）、固定 buffer、io_wait_readable；见《舒IO实现路线图》。 |
| **S2** ✅ | **std.io.driver**（Buffer / Completion / submit） | std.io.core | 已实现：Buffer ABI 24 字节、submit_read/submit_write、submit_*_batch、wait_readable。 |
| **S3** ✅ | **std.mem**（Buffer ABI / 预注册） | std.io.core | 已实现：Buffer 结构体（ptr+len+handle）24 字节、register_buffer 调 shu_io_register；与 std.io.driver Buffer 同布局。 |
| **S4** ✅ | **std.io**（对外 API） | std.io.driver | 已实现：Reader/Writer、ReadOnlySlice/WriteOnlySlice、read/write 与超时 API、print_str、register_fixed_buffers、wait_readable、read_into_slice/write_from_slice。 |
| **S5** ✅ | **std.fs**（高性能文件） | core, 可选 std.io | 已实现：extern open/read/write/close + fs_open_read/fs_close/fs_read/fs_write 大块读写；可直接用于读 .x、写目标文件。 |
| **S6** ✅ | **std.process** | core | 已实现：exit(code)（codegen 生成）；placeholder 可 import；args/环境变量为后续扩展。 |
| **S7** ✅ | **std.path** | core | 已实现最小可 import（placeholder、path_empty_len）；路径拼接/分解/规范化为下一步扩展。 |
| **S8** ✅ | **std.string** | core | 已实现：String 256 字节、StrView、eq/compare/find/前后缀/trim/替换/零拷贝；≥8/32 走 C memcpy/memcmp，性能压榨见 std/string/README.md。 |
| **S9** ✅ | **std.vec / std.heap / std.map / std.error** | core | 已实现：heap alloc/free/realloc + 块拷贝；vec Vec_i32/Vec_u8 可增长、append_slice/from_slice 大块 memcpy；map Map_i32_i32 哈希表、find 走 C；error Error 类型与 is_ok/is_err；性能见 std/PERF-heap-vec-map.md。 |
| **S10** | **std.net** | std.io.driver | 连接生命周期（connect/listen/accept）；数据读写统一走 std.io.driver（Buffer + submit）。 |

---

## 三、高性能 Shu IO 设计要点

> 与现有代码注释、`runtime/README.md`、`std/io/core.x` / `std/io/driver.x` 一致；实现「自己的高性能 shux io」。

### 3.1 三层结构（已约定）

| 层 | 模块 | 职责 |
|----|------|------|
| **核心层** ✅ | **std.io.core** | `shu_io_register`、`shu_io_submit_read`、`shu_io_submit_write` 等经 extern 走 std/io/io.c（三平台后端、固定 buffer、io_wait_readable）。 |
| **驱动层** ✅ | **std.io.driver** | Buffer（ABI 24 字节）、IO_Result、Completion、AsyncContext；`register`、`submit_read`、`submit_write`、submit_*_batch、wait_readable。 |
| **API 层** ✅ | **std.io** | Reader/Writer trait、ReadOnlySlice/WriteOnlySlice；超时参数 timeout_ms（0=无超时）；同步 = submit + 等一次完成。 |

### 3.2 高并发 IO 约定（第八节 + 三项约定）

- **Buffer ABI**：`ptr + len + handle` = 8+8+8 = **24 字节**（与 slice 兼容扩展）；std.mem.Buffer 与 Buffer 同布局，便于与 std.mem 互通。
- **Err(i32)**：错误码 i32，正/负由文档约定；自举后扩展负载。
- **AsyncContext**：原子位占位（flags 自举后用于原子状态位）；Completion 与 submit 回调/结果对接。

### 3.3 高性能要点

- **零拷贝**：ReadOnlySlice/WriteOnlySlice 为 u8[] 视图，不强制拷贝；Buffer 预注册后由内核/驱动直接 DMA 或零拷贝路径。
- **批量化**：预留 `Buffer[]` 多段扩展（submit_read/submit_write 多段），高吞吐网络与文件可批量提交。
- **统一模型**：文件 fd、网络连接与 driver 的 **handle** 统一，便于同一套 submit 复用（std.net 注释：TcpStream.fd 可与 driver handle 统一）。

---

## 四、高性能 fs 设计要点

> 与「高性能 shux io」统一考虑；避免逐字节、大块读写、可选走舒 IO。

### 4.1 当前状态

- **std.fs** ✅：**API 已写全** — extern open(path, flags, mode) + 薄封装：fs_open_read、**fs_open_write**、fs_close、fs_read、fs_write；路径 NUL 结尾，可与 std.path 配合。
- **高性能** ✅：**默认大块读写** — fs_read(fd, buf, count)、fs_write(fd, buf, count)，count 为 usize，调用方传入大缓冲区即可；文档与注释已明确推荐大块用法。
- **可选后续**：与 std.io.driver handle 统一、平台 splice/io_uring 封装（见 4.3）。

### 4.2 设计要点

| 要点 | 说明 |
|------|------|
| **大块读写** | 提供 `fs_read(fd, buf: *u8, count: usize)`、`fs_write(fd, buf: *u8, count: usize)`，调用方传入足够大缓冲区；避免在 std 内逐字节循环。 |
| **与 core 配合** | 读入缓冲区后可用 core.mem、core.slice 处理；写前用 core.fmt 等格式化到缓冲区再 fs_write。 |
| **可选与舒 IO 对接** | 文件 fd 可作为 std.io.driver 的 **handle**，未来可挂到同一套 submit 模型（优先级低于先实现可靠大块 read/write）。 |
| **路径** | 路径拼接/规范化由 std.path 提供，fs 只接受已处理好的路径或 *u8；避免在 fs 内重复实现路径逻辑。 |

### 4.3 实现顺序建议

1. **先**：保持现有 extern + 薄封装，在文档与示例中**明确推荐大块 read/write**，并配测试（如读整文件到 buf、写整块 buf）。
2. **后**：若需更高性能，再考虑 fs 与 std.io.driver 的 handle 统一、或平台特定 API（如 Linux splice、io_uring）在 std.io.core 内封装。

---

## 五、自举前必须清单（与 std/README.md 一致）

以下模块在自举前需有**最小实现**或可 import 的声明：

| 模块 | 内容概要 |
|------|----------|
| std.runtime ✅ | 运行时初始化、panic 钩子等（最小可 import） |
| std.mem ✅ | Buffer ABI 24 字节（ptr+len+handle）、register_buffer 调 shu_io_register，与 std.io.driver 同布局 |
| std.io ✅ | Read/Write 最小接口、标准输入输出；**舒 IO 三层**（core/driver/mod）已完整实现 |
| std.fs ✅ | open/read/write/close、**大块读写**（fs_read/fs_write）、薄封装可用 |
| std.path ✅ | 路径拼接、分解、规范化（当前最小可 import，扩展为下一步） |
| std.process ✅ | exit（codegen）、args/环境变量占位 |
| std.heap ✅ | 堆分配 alloc/free/realloc、typed alloc_i32/alloc_u8、块拷贝 copy_i32_at/copy_u8_at |
| std.string ✅ | 字符串类型与基本操作（String/StrView、eq/compare/find/前后缀/trim、零拷贝、性能压榨） |
| std.vec ✅ | 动态数组 Vec_i32/Vec_u8（push/pop/append_slice/from_slice、大块 memcpy、热路径 _ptr） |
| std.map ✅ | 映射 Map_i32_i32（insert/get/contains/remove、find 走 C、负载因子 0.75） |
| std.error ✅ | 错误类型 Error、error_ok/error_from_code/error_is_ok/error_is_err |

io/fs 的实现顺序与性能设计见上文第三、四节。

---

## 六、小结

- **开发顺序**：✅ **std.runtime**、**std.io.core** → **std.io.driver** → **std.mem** → **std.io** 已完成；✅ **std.fs**、**std.process**、**std.path**（最小）已完成；✅ **std.string**、**std.vec**、**std.heap**、**std.map**、**std.error** 已完成（全 API + 性能压榨）；下一步 **std.path** 扩展（路径拼接/分解/规范化）或 **std.net**（S10）。
- **高性能 Shu IO** ✅：三层结构（core/driver/io）、Buffer ABI 24 字节、submit 模型、批量与固定 buffer、io_wait_readable；已通过 std/io/io.c 实现三平台后端（见《舒IO实现路线图》）。
- **高性能 fs** ✅：大块 fs_read/fs_write 已提供；可选后续与 driver handle 统一。

---

## 参考

- `std/README.md` — 阶段 7 扩展清单
- `std/PERF-heap-vec-map.md` — std.heap / std.vec / std.map 性能压榨说明
- `runtime/README.md` — 舒 IO 桩、std.io.core 位置
- `std/io/core.x`、`std/io/driver.x`、`std/io/mod.x` — 舒 IO 与高并发 IO 注释
- `std/fs/mod.x` — 当前 fs 薄封装
- `std/string/README.md` — std.string API 与性能说明
- `std/net/mod.x` — 网络与 driver 统一读写约定
- `std/mem/mod.x` — Buffer ABI 与 shu_io_register
