# std 标准库全量清单与优先级

> 列出 **所有** std 标准库模块（已实现 + 规划），按**优先级**排序，供「丰富标准库」时按序推进。与《std开发时序分析》《接下来做什么-性能压榨与新std》一致；用户只写一套 API，内部条件编译适配平台，按需链接不增体积。
>
> **状态图例**：✅ = 已完成（已实现并可用的模块/规格）。

---

## 一、总览（按优先级分级）

| 优先级 | 含义 | 模块数量 |
|--------|------|----------|
| **P0** | 已实现，自举前必须或已落地 | 14 |
| **P1** | 建议下一步（轻量、无新架构依赖） | 4 |
| **P2** | 短期补齐，**对标 Zig/Rust 标准库**，完整 API（非最小化） | 6 |
| **P3** | 中期扩展，**对标 Zig/Rust 标准库**，完整 API（非最小化） | 10 |
| **P4** | 可选/长期（按需或生态成熟后） | 11 |

---

## 二、P0 — 已实现（按依赖顺序）

以下模块**已存在**于 `std/` 且具备最小可用 API；自举前必须或已满足。

| 序号 | 状态 | 模块 | 路径 | 依赖 | 说明 |
|------|:----:|------|------|------|------|
| 1 | ✅ | **std.runtime** | std/runtime/ | core | 运行时初始化、panic/abort 钩子；extern 对接 runtime_panic。 |
| 2 | ✅ | **std.io.core** | std/io/（core.sx） | core | 舒 IO 核心：shu_io_register、submit_read/submit_write，extern 调 io.c（io_uring/kqueue/IOCP）。 |
| 3 | ✅ | **std.io.driver** | std/io/（driver.sx） | std.io.core | Buffer ABI 24 字节、Completion、submit_*_batch、register_fixed_buffers、wait_readable。 |
| 4 | ✅ | **std.mem** | std/mem/ | std.io.core, std.heap | Buffer(ptr,len,handle)、register_buffer；copy/set/compare 走 heap C 层。 |
| 5 | ✅ | **std.io** | std/io/（mod.sx） | std.io.driver | 对外 API：Reader/Writer、read/write 超时、print_str、read_batch_fd_buf/write_batch_fd_buf、register_fixed_buffers_buf。 |
| 6 | ✅ | **std.fs** | std/fs/ | core, 可选 std.io | open/read/write/close、mmap、readv/writev（fs_readv_buf/fs_writev_buf）；与 std.io 联合批量化。 |
| 7 | ✅ | **std.process** | std/process/ | core | exit、args（argv）、环境变量占位；codegen 生成 exit(code)。 |
| 8 | ✅ | **std.path** | std/path/ | core | 路径拼接、分解、规范化；(ptr,len) 处理，不依赖结尾 NUL。 |
| 9 | ✅ | **std.heap** | std/heap/ | core（extern C） | alloc/free/realloc、alloc_i32/alloc_u8、copy_i32_at/copy_u8_at、map_i32_i32_find_c；heap.c 实现。 |
| 10 | ✅ | **std.string** | std/string/ | core | String(256 字节)、StrView、eq/compare/find/前后缀/trim/替换；≥8/32 走 C memcpy/memcmp。 |
| 11 | ✅ | **std.vec** | std/vec/ | std.heap | Vec_i32/Vec_u8 可增长、append_slice/from_slice、truncate/clear/reserve；大块 memcpy。 |
| 12 | ✅ | **std.map** | std/map/ | std.heap | Map_i32_i32 哈希表、new/with_capacity、get/insert/remove/contains、find 走 C。 |
| 13 | ✅ | **std.error** | std/error/ | core | Error 类型、is_ok/is_err；与 i32 错误码一致（0 成功、非 0 错误）。 |
| 14 | ✅ | **std.net** | std/net/ | std.io.driver | TcpStream、listen/connect/accept、accept_many/connect_many、stream_read_batch_buf/stream_write_batch_buf、UDP recvmmsg/sendmmsg、run_accept_workers。 |
| 15 | ✅ | **std.thread** | std/thread/ | core（extern C） | spawn/join/self、thread_set_affinity_self、thread_create_with_stack、macOS thread_set_qos_class_self；thread.c + pthread。 |

**说明**：std.io 含 core/driver/mod 多文件，计为 io.core、io.driver、io 三个逻辑模块；目录上均为 `std/io/`。

---

## 三、P1 — 建议下一步（轻量、无新架构）

与《接下来做什么-性能压榨与新std》一致；实现成本低、依赖少、立即可用。

**实现原则（P1 统一要求）**：  
- **功能完整**：不做「最小化」子集，每个模块提供**完整可用 API**，覆盖 Zig/Rust 标准库对应模块的常用能力。  
- **API 对标**：命名与语义对齐 **Zig**、**Rust** 标准库，便于迁移与对照文档；必要时提供零拷贝/切片风格接口以贴合我们语言习惯。  
- **性能超越**：实现上优先使用各平台最快路径（如 Linux clock_gettime CLOCK_MONOTONIC、getentropy/getrandom、无锁缓存等），目标为**同场景下性能不低于 Zig/Rust，并争取超越**（通过 benchmark 验证）。

以下各模块给出**完整 API 清单**（对标 Zig/Rust）与**性能目标**；实现时按表逐项落地。

---

### 3.1 std.time — 完整功能规格 ✅

| 能力 | Zig 对应 | Rust 对应 | 我们的 API（完整） | 性能要点 |
|------|----------|-----------|--------------------|----------|
| 单调时间（纳秒） | Timer / clock_gettime(CLOCK_MONOTONIC) | Instant::now() / elapsed() | `now_monotonic_ns(): i64` | 直接 clock_gettime(CLOCK_MONOTONIC) / QueryPerformanceCounter，无额外分配。 |
| 单调时间（秒/毫秒/微秒） | 同上，换算 | Duration::as_* | `now_monotonic_us(): i64`、`now_monotonic_ms(): i64`、`now_monotonic_sec(): i64` | 由 ns 换算或平台一次取合适精度，避免多次系统调用。 |
| 墙钟时间（自 Unix 纪元） | timestamp() / milliTimestamp() / microTimestamp() / nanoTimestamp() | SystemTime::now() / duration_since(UNIX_EPOCH) | `now_wall_sec(): i64`、`now_wall_ms(): i64`、`now_wall_us(): i64`、`now_wall_ns(): i64` | gettimeofday/clock_gettime(CLOCK_REALTIME)/GetSystemTimePreciseAsFileTime；Windows 100ns 粒度需注明。 |
| 睡眠 | sleep(nanoseconds) | thread::sleep(Duration) | `sleep_ns(ns: i64): void`、`sleep_us(us: i64): void`、`sleep_ms(ms: i32): void`、`sleep_sec(s: i32): void` | nanosleep / Sleep()；可接受 spurious wakeup，不保证精度。 |
| 时间差/间隔（可选） | 手算 diff | Duration | `duration_ns(from_ns: i64, to_ns: i64): i64` 等 | 纯算术，零成本。 |

**实现路径**：std/time/ 下 mod.sx + time.c；extern C 封装 clock_gettime/gettimeofday/nanosleep/QueryPerformanceCounter/GetSystemTimePreciseAsFileTime/Sleep；全平台一套 .sx API，内部条件编译。**Benchmark**：单调时间取 100 万次取样的平均延迟，目标 ≤ Zig/Rust 同场景。

---

### 3.2 std.random — 完整功能规格 ✅

| 能力 | Zig 对应 | Rust 对应 | 我们的 API（完整） | 性能要点 |
|------|----------|-----------|--------------------|----------|
| 密码学安全随机字节 | std.crypto 或 getentropy | getrandom crate / rand::rngs::OsRng | `fill_bytes(buf: *u8, len: i32): i32`（返回写入长度或错误码） | getentropy/getrandom/BCryptGenRandom；一次调用填满 buf，避免逐字节。 |
| 密码学安全随机 u32/u64 | 同上 + 截断 | OsRng::next_u32/next_u64 | `u32(): u32`、`u64(): u64` | 内部 fill_bytes 4/8 字节后按平台字节序解释；或平台原生一次生成。 |
| 有界整数（闭区间） | intRangeAtMost | gen_range | `range_u32(lo: u32, hi: u32): u32`（[lo, hi] 含两端） | 拒绝采样法或均匀缩放，避免 bias；文档注明分布。 |
| 布尔 | 由 int 得 | gen_bool | `bool(): i32`（0/1） | 单次 u32 高位或单字节。 |

**实现路径**：std/random/ 下 mod.sx + random.c；仅提供 **CSPRNG**（getentropy/getrandom/BCryptGenRandom），不引入 PRNG 引擎（可放 P2/P3 的 std.hash 或独立 prng 模块）。**Benchmark**：fill_bytes 大块（如 1MB）吞吐与 Zig/Rust 的 OsRng/getentropy 对比，目标 ≥ 二者；小调用（u32/u64）延迟可接受。

---

### 3.3 std.env — 完整功能规格 ✅

| 能力 | Zig 对应 | Rust 对应 | 我们的 API（完整） | 性能要点 |
|------|----------|-----------|--------------------|----------|
| 取环境变量（值写入 buffer） | getenv 等 | env::var() / var_os() | `getenv(key: *u8, key_len: i32, out: *u8, out_cap: i32): i32`（返回写入长度或 -1 不存在/错误） | 可复用 std.process 的 getenv_c，或独立 extern；key 支持 (ptr,len) 避免 NUL。 |
| 取环境变量（是否存在） | — | env::var().is_ok() | `getenv_exists(key: *u8, key_len: i32): i32`（1 存在，0 不存在） | 不拷贝 value，仅查存在性；可 getenv 判空。 |
| 设置/删除环境变量 | putenv/setenv | set_var / remove_var | `setenv(name: *u8, value: *u8, overwrite: i32): i32`、`unsetenv(name: *u8): i32` | 与 std.process 一致时可委托 process；否则本模块 extern。 |
| 当前工作目录 | getCwd | current_dir() | 建议**不重复**：继续使用 std.process.getcwd / getcwd_ptr | 避免两处实现。 |
| 临时目录 | — | temp_dir() | `temp_dir(out: *u8, cap: i32): i32`（可选，P1 可占位） | getenv("TMPDIR")/TEMP/TMP + 回退 /tmp；P1 可只做 getenv 部分。 |

**实现路径**：std/env/ 下 mod.sx；可复用 std.process 的 getenv_c/setenv_c/unsetenv_c，或独立 time.c 风格 C 层。API 上提供 **key 为 (ptr,len)** 的 getenv/getenv_exists，与 std.string/StrView 友好；**性能**：getenv 热点路径无多余分配，目标与 Zig/Rust 同量级。

---

### 3.4 std.fmt — 完整功能规格 ✅

| 能力 | Zig 对应 | Rust 对应 | 我们的 API（完整） | 性能要点 |
|------|----------|-----------|--------------------|----------|
| 格式化到 buffer（已有） | formatInt/formatFloat 等 | format! 写 impl Write | **重导出 core.fmt**：fmt_i32_to_buf、fmt_u32_to_buf、fmt_i64_to_buf、fmt_u64_to_buf、fmt_f64_to_buf、fmt_bool_to_buf、十六进制等 | 保持 core 无 OS 依赖；std.fmt 仅重导出 + 扩展。 |
| 格式化到 stdout | std.log / print | print! / println! | `print(ptr: *u8, len: i32)`、`println(ptr: *u8, len: i32)`；可扩展 `print_i32(x)`、`print_u32(x)` 等（若 codegen 已生成则委托） | 委托 io.print_str 或 write_stdout；零拷贝，不先 format 到 String 再写。 |
| 格式化到 String（可选） | ArrayList + format | format! -> String | `format_i32(x: i32): String` 等返回固定或堆分配字符串（视语言能力）；或 `format_into(s: *String, ...): i32` | 若 String 为固定 256 字节，则 format_into 更稳妥；大数可考虑堆扩展（依赖 std.heap）。 |
| 多参数格式化（占位符） | format | format!("{} {}", a, b) | 阶段目标：**按序拼接** `format_2(buf, cap, a, b)` 或 `format_to_buf(buf, cap, fmt_spec, a, b)`；完整 printf 风格占位符可 P2 | 先保证常用类型多段拼接无额外拷贝；占位符解析可后续扩展。 |

**实现路径**：std/fmt/ 下 mod.sx；依赖 core.fmt + std.io。**完整功能**：重导出 core.fmt 全部 *_to_buf；提供 print/println 与 std.io 结合；提供至少 format_2 或 format_to_buf 多参数写入 buffer；若类型支持可提供 format_into(String)。**性能**：格式化整数/浮点与 Zig/Rust 同量级；打印路径无多余内存分配，目标不低于二者。

---

### 3.5 P1 汇总表（完整 API 与优先级）

| 序号 | 状态 | 模块 | 路径 | 依赖 | 完整功能要点 | 性能目标 |
|------|:----:|------|------|------|--------------|----------|
| 1 | ✅ | **std.time** | std/time/ | core（extern C） | 单调/墙钟 now_*_ns/us/ms/sec；sleep_ns/us/ms/sec；duration 换算 | 单调/墙钟调用延迟 ≤ Zig/Rust；benchmark 验证 |
| 2 | ✅ | **std.random** | std/random/ | core（extern C） | fill_bytes、u32、u64、range_u32、bool；CSPRNG 仅 | 大块 fill_bytes 吞吐 ≥ Zig/Rust |
| 3 | ✅ | **std.env** | std/env/ | core（extern C），可复用 std.process | getenv(key,key_len,out,cap)、getenv_exists、setenv、unsetenv；temp_dir 可选 | getenv 无多余分配，与 Zig/Rust 同量级 |
| 4 | ✅ | **std.fmt** | std/fmt/ | core.fmt, std.io | 重导出 core.fmt；print/println；format_2_i32_i32 多参数 | 格式化与打印路径无多余分配，不低于 Zig/Rust |

---

## 四、P2 — 短期补齐（对标 Zig/Rust，完整 API）

**原则**：P2 不做最小化开发，**对标 Zig 与 Rust 标准库**对应模块，提供完整、可迁移的 API；命名与语义与二者对齐，实现时按「完整功能规格」逐项落地。

| 序号 | 模块 | 建议路径 | 依赖 | 完整 API 规格（对标 Zig/Rust） | 说明 |
|------|------|----------|------|--------------------------------|------|
| 1 | **std.sync** | std/sync/ | core（extern C） | **Mutex** ✅：`mutex_new()`、`mutex_lock(m)`、`mutex_try_lock(m)`、`mutex_unlock(m)`、`mutex_free(m)`。**RwLock**（可选 P2 或 P3）：`rwlock_new`、`read`/`write`、`try_read`/`try_write`、`unlock`。**Once**（可选）：`once_call(fn)` 保证只执行一次。 | 对标 Rust std::sync::Mutex/RwLock/Once、Zig Thread.Mutex；pthread_mutex_t / CRITICAL_SECTION；与 std.thread 配合。 |
| 2 | **std.encoding** ✅ | std/encoding/ | core, std.string | **UTF-8**：`utf8_valid`、`utf8_len_chars`、`utf8_encode_rune`、`utf8_decode_rune`。**ASCII**：`ascii_is_*`、`ascii_to_lower/upper`。 | 表驱动单遍、restrict/LIKELY；对标 Rust std::str + std::ascii。 |
| 3 | **std.base64** ✅ | std/base64/ | core, std.string | `encode_standard`/`decode_standard`、`encode_url`/`decode_url`。 | 单遍、静态表、无分配；对标 Zig std.base64。 |
| 4 | **std.crypto** ✅ | std/crypto/ | core（extern C） | `mem_eq`（常量时间）、`sha256`/`sha512`、`hmac_sha256`。AEAD 可 P3。 | 对标 Zig std.crypto；无外部依赖。 |
| 5 | **std.log** ✅ | std/log/ | core | `set_min_level`、`log(level, ptr, len)`；级别 level_debug/info/warn/error。 | 零分配写 stderr；对标 Zig std.log、Rust log。 |
| 6 | **std.test** ✅ | std/test/ | core.debug | `expect`、`expect_eq_i32/u32`、`expect_ne_i32`、`test_run(fn)`。 | 对标 Zig std.testing、Rust test。 |

---

## 五、P3 — 中期扩展（对标 Zig/Rust，完整 API）

**原则**：P3 同样**对标 Zig 与 Rust 标准库**，不做最小化；每个模块提供完整数据结构/并发/工具能力，与二者对应模块对齐。

| 序号 | 模块 | 建议路径 | 依赖 | 完整 API 规格（对标 Zig/Rust） | 说明 |
|------|------|----------|------|--------------------------------|------|
| 1 | **std.set** | std/set/ | std.heap | **Set_i32 / Set_u64 等**：`new`、`with_capacity`、`insert`、`remove`、`contains`、`len`、`is_empty`、`iter`（若语言支持）/遍历；与 std.map 共享哈希实现时可复用桶结构，无 value 存储。 | 对标 Rust std::collections::HashSet、Zig AutoSet/HashSet；完整集合 API。 |
| 2 | **std.queue** | std/queue/ | std.heap | **双端队列**：`push_back`、`push_front`、`pop_back`、`pop_front`、`len`、`is_empty`、`get(i)`；可固定容量环形或动态扩容。**可选**：BinaryHeap（优先级队列）或单独 std.heap 子模块。 | 对标 Rust VecDeque、Zig std.fifo；先有锁或单线程，无锁可选延后。 |
| 3 | **std.atomic** | std/atomic/ | core（extern C） | **整数**：`load_i32`/`store_i32`、`load_u32`/`store_u32`（及 i64/u64）；`compare_exchange_*`、`fetch_add`/`fetch_sub`/`fetch_and`/`fetch_or`/`fetch_xor`。**Ordering**：至少提供 seq_cst / acquire / release / relaxed 语义（或映射到 C11 atomic 与目标平台）。 | 对标 Rust std::sync::atomic、Zig std.atomic；多线程基础。 |
| 4 | **std.channel** | std/channel/ | std.heap, std.sync | **有界/无界**：`channel_bounded(cap)`、`channel_unbounded()`；`send(ch, ptr, len)` 或类型化 send；`recv(ch, timeout_ns)`、`try_recv`。可先有界 + mutex+cond；与 Rust std::sync::mpsc、Zig 无标准 channel 对齐语义。 | 对标 Rust mpsc；依赖 mutex/cond 或 atomic。 |
| 5 | **std.backtrace** | std/backtrace/ | std.runtime（可选） | `capture(buf: *u8, max_frames: i32): i32`；`symbolicate(buf, len, out_ptrs, out_names, max): i32` 或平台相关 API；panic 时可选挂接。 | 对标 Rust std::backtrace；平台差异大，先提供 capture + 文档说明各平台。 |
| 6 | **std.hash** | std/hash/ | core, std.heap | **Hasher 抽象**：`hash_start()`、`hash_u32/u64/bytes`、`hash_finish(): u64`。**算法**：SipHash-2-4 或等价（与 HashMap 默认一致）；可选 FxHash 等。与 std.map 的哈希可复用。 | 对标 Zig std.hash、Rust std::hash::Hasher；与 HashMap/Set 配合。 |
| 7 | **std.math** | std/math/ | core | **常量**：PI、E、Tau 等。**舍入**：floor/ceil/trunc/round。**三角函数**：sin/cos/tan、asin/acos/atan、atan2。**其他**：sqrt、cbrt、pow、exp、log、abs、signum；min/max 已有可重导出。f32/f64 双精度版本。 | 对标 Zig std.math、Rust std::f32/f64 + std::num；完整常用数学。 |
| 8 | **std.sort** | std/sort/ 或 std/vec | std.heap | **泛型**：`sort_slice(ptr, len, cmp_fn)` 或 `sort_i32`/`sort_u8` 等特化；**不稳定**默认、可选**稳定**。**分块**：`sort_by_key` 语义（cmp 基于 key 抽取）若语言支持。 | 对标 Zig std.sort、Rust Vec::sort/sort_by；可并入 std.vec 或独立模块。 |
| 9 | **std.ffi** | std/ffi/ | core（extern C） | **CStr**：从 `*const u8` 到 NUL 结尾视图；**CString**：分配并 NUL 结尾的 owned。**OsStr/OsString**（可选）：平台编码字符串（Windows UTF-16 等）与我们的 UTF-8 互转。 | 对标 Zig std.cstr、Rust std::ffi（CStr, CString, OsStr, OsString）；C 互操作与平台字符串。 |
| 10 | **std.process 扩展** | std/process/（扩展现有） | core（extern C） | **spawn**：`spawn(args[], env[])` 返回 Child；**Child**：`wait()`、`kill()`、`stdin_pipe`/`stdout_pipe`/`stderr_pipe`（或 fd 封装）。**exec**：当前进程替换（execve 语义）。**管道**：创建 pipe 与子进程 stdio 重定向。 | 对标 Zig std.process.Child、Rust std::process::Command；当前仅有 exit/args，扩展为完整子进程与管道。 |

---

## 六、P4 — 可选/长期（按需或生态成熟后）

以下模块**列入全量清单**，但非近期必做；实现时需注意「轻量、按需链接」。

| 序号 | 模块 | 建议路径 | 依赖 | 说明 |
|------|------|----------|------|------|
| 1 | **std.json** | std/json/ | std.string, std.vec | 最小解析（仅 object/array/string/number/bool/null）+ 生成；不引入大依赖。 |
| 2 | **std.csv** | std/csv/ | std.string, std.io | 按行解析、写回；可基于 string 与 io 切片。 |
| 3 | **std.regex** | std/regex/ | std.heap | 若做：仅最小子集（字面量、字符类、*?）；或委托 C 库（regex.h），体积需评估。 |
| 4 | **std.compress** | std/compress/ | std.heap, std.io | 若做：仅 deflate/zlib 或 lz4 最小封装；依赖与体积需严格控制。 |
| 5 | **std.unicode** | std/unicode/ | core, std.encoding | beyond utf8_len_chars：分类、大小写、正规化等；可依赖小表。 |
| 6 | **std.dynlib** | std/dynlib/ | core（extern C） | 动态加载 .so/.dll：open(path)、sym(lib, name)、close(lib) | 对标 Zig std.DynLib；Rust 在 libloading crate；可选、按需链接。 |
| 7 | **std.http** | std/http/ | std.net, std.io | 最小 HTTP 客户端/服务（可先占位）；Zig 有简单实现，Rust 在生态 | 可选或占位；P4 低优先级。 |
| 8 | **std.tar** | std/tar/ | std.fs, std.io | tar 归档读/写；对标 Zig std.tar | 可选，P4。 |
| 9 | **二进制格式（ELF/COFF 等）** | std/elf/ 等（按需） | core | 编译器/工具链用；Zig 有 std.elf、std.coff、std.macho | 按需占位或不做。 |
| 10 | **async / future** | 预留 | std.io, 语言支持 | 异步运行时；Rust std::future/task，我们当前同步 IO | 长期预留；与语言阶段一致再做。 |
| 11 | **SIMD / arch** | core 或 std/simd/ | 语言/目标架构 | 向量类型、std::arch 类 API；与语言阶段一致 | 长期预留；若有向量类型再放 core 或 std.simd。 |

---

## 七、按类别汇总表（便于检索）

| 类别 | 模块 | 优先级 | 状态 |
|------|------|--------|:----:|
| **运行时与基础** | std.runtime, std.heap, std.error, std.mem | P0 | ✅ |
| **I/O 与文件** | std.io.core, std.io.driver, std.io, std.fs | P0 | ✅ |
| **进程与路径** | std.process, std.path | P0 | ✅ |
| **数据结构** | std.string, std.vec, std.map | P0 | ✅ |
| **网络** | std.net | P0 | ✅ |
| **并发** | std.thread | P0 | ✅ |
| **时间与随机** | std.time ✅, std.random ✅ | P1 | 部分 ✅ |
| **环境与格式化** | std.env ✅, std.fmt ✅ | P1 | ✅ |
| **同步** | std.sync ✅（Mutex） | P2 | ✅ |
| **编码与安全** | std.encoding ✅, std.base64 ✅, std.crypto ✅, std.log ✅, std.test ✅ | P2 | ✅ |
| **更多数据结构与并发** | std.set, std.queue, std.atomic, std.channel, std.backtrace, std.hash, std.math, std.sort, std.ffi, std.process 扩展（spawn/exec） | P3 | |
| **可选/重型** | std.json, std.csv, std.regex, std.compress, std.unicode, std.dynlib, std.http, std.tar, 二进制格式, async/future, SIMD/arch | P4 | |

---

## 八、实现顺序建议（与《std开发时序分析》一致）

1. **P0**：已实现，仅需维护与文档更新。  
2. **P1**：按 **std.time → std.random → std.env → std.fmt** 顺序做；每个模块**完整功能**（见第三章 3.1～3.5）、API 对标 Zig/Rust、性能超越；独立目录、README + 测试 + benchmark。  
3. **P2**：在 P1 收尾后，按 **std.sync → std.encoding → std.base64 → std.crypto → std.log → std.test** 推进；每模块**完整对标 Zig/Rust**（见第四章），不做最小化；std.crypto 需安全审计与文档。  
4. **P3**：按 **std.set → std.queue → std.atomic → std.channel → std.backtrace → std.hash → std.math → std.sort → std.ffi → std.process 扩展** 择序推进；每模块**完整对标 Zig/Rust**（见第五章），不做最小化。  
5. **P4**：按需求与人力择项（std.json、std.csv、std.regex、std.compress、std.unicode、std.dynlib、std.http、std.tar、二进制格式、async/future、SIMD/arch）；每项前评估依赖与体积，保证「轻量、按需链接」；async/SIMD 与语言阶段一致时再做。

---

## 九、约定（与项目宗旨一致）

- **全平台一套 API**：用户只写一套 .sx；平台差异在模块内部用条件编译或 extern C 解决。  
- **按需链接**：未 import 的模块不进入二进制；嵌入式可用最小 std 子集或仅 core。  
- **轻量**：不引入巨型第三方依赖；可选模块（P4）尤其控制体积与依赖。  
- **core 与 std 边界**：core 无 OS 依赖；std 依赖 OS 或 C 运行时（如 heap、thread、time、random）。  
- **P2/P3 对标 Zig/Rust**：P2、P3 模块均按 **Zig 与 Rust 标准库** 对应能力做**完整实现**，不做最小化子集；API 命名与语义与二者对齐，便于迁移与对照文档。

本文档覆盖**全部**规划中的 std 模块；新增模块时请同步更新本清单与优先级。

---

## 十、与 Zig / Rust 对标

以下对照说明：**我们全量清单中的每个 std 模块**在 Zig、Rust 中是否有对应（有则标出对应名，无则说明生态或「无」）。

### 10.1 我们有 → Zig / Rust 是否有

| 我们的模块 | Zig 对应 | Rust 对应 | 备注 |
|------------|----------|-----------|------|
| std.runtime / panic | 无独立 std 模块，内建 @panic | std::panic | 我们与 Rust 类似，独立 runtime。 |
| std.io（含 core/driver） | std.io | std::io | Zig 无 io_uring 内建；我们有高性能 driver。 |
| std.fs | std.fs | std::fs | 三者均有。 |
| std.process | std.process | std::process | 三者均有；我们规划扩展 spawn/exec。 |
| std.path | std.fs.path | std::path | 三者均有。 |
| std.heap | std.heap | std::alloc（alloc crate） | 我们 + std.vec 对标 Rust alloc+vec。 |
| std.mem | std.mem | std::mem | 三者均有。 |
| std.string | 无独立，[]const u8 + std.mem | std::str + std::string | 我们有 String/StrView。 |
| std.vec | ArrayList 等 | std::vec::Vec | 三者均有。 |
| std.map | HashMap/ArrayHashMap | std::collections::HashMap | 三者均有。 |
| std.error | 错误联合类型 | std::error | 三者均有。 |
| std.net | std.net | std::net | 三者均有。 |
| std.thread | Thread | std::thread | 三者均有。 |
| std.time | std.time | std::time | P1。 |
| std.random | std.Random / std.crypto 等 | 实验性 std::random；常用 rand crate | P1；Rust std 无稳定 random。 |
| std.env | 无独立，通过 std.process 等 | std::env | P1。 |
| std.fmt | std.fmt | std::fmt | P1；我们有 core.fmt + std.fmt。 |
| std.sync / std.mutex | 无独立 std.mutex，需锁用 Thread.Mutex 等 | std::sync（Mutex, RwLock, atomic） | P2；Rust 有 sync::atomic。 |
| std.encoding | 无独立 utf8 模块 | std::str 内 UTF-8；char 等 | P2。 |
| std.base64 | std.base64 | 无（生态 base64 crate） | P2；编解码常用。 |
| std.crypto | **std.crypto** | **无**（生态 ring/openssl） | **P2；我们与 Zig 一致做完整实现。** |
| std.log | std.log | 无（生态 log crate） | P2。 |
| std.test | std.testing | 无（生态 test harness） | P2。 |
| std.set | 无独立 Set，用 HashMap 或第三方 | std::collections::HashSet | P3。 |
| std.queue | std.fifo | std::collections 无标准 Queue；VecDeque | P3。 |
| std.atomic | std.atomic | std::sync::atomic | P3。 |
| std.channel | 无标准 channel | std::sync::mpsc | P3。 |
| std.backtrace | 无独立 | std::backtrace | P3。 |
| std.hash | std.hash | std::hash | P3；泛型 Hasher、SipHash 等。 |
| std.math | std.math | 部分在 std::f32/f64；复杂在 std::num | P3；三角函数、sqrt、常量等。 |
| std.sort | std.sort | 无独立，Vec::sort 等 | P3；泛型排序。 |
| std.ffi | std.cstr | std::ffi（CStr, CString, OsStr） | P3；C 互操作与平台字符串。 |
| std.process 扩展（spawn/exec） | std.process.Child | std::process::Command | P3；子进程、管道、env。 |
| std.json | std.json | **无**（生态 serde_json） | P4。 |
| std.csv | 无 | **无**（生态 csv crate） | P4。 |
| std.regex | 无 | **无**（生态 regex crate） | P4。 |
| std.compress | std.compress | **无**（生态 flate2 等） | P4；Zig 有。 |
| std.unicode | 部分在 std.unicode | std::char 等 | P4。 |
| std.dynlib | std.DynLib | std::libloading（crate） | P4；动态加载 .so/.dll。 |
| std.http | std.http | 无（生态 reqwest 等） | P4；可先占位。 |
| std.tar | std.tar | 无 | P4；tar 归档。 |
| 二进制格式（ELF/COFF 等） | std.elf, std.coff, std.macho | 无 | P4；按需占位或不做。 |
| async / future | 无标准 async | std::future, std::task | P4 长期预留；与语言阶段一致。 |
| SIMD / arch | 向量类型在语言层 | std::arch, std::simd（实验） | P4 长期预留；与语言阶段一致。 |

**结论**：我们全量清单与 Zig/Rust 已对齐；多数模块二者有对应，std.crypto 我们与 Zig 一致做完整实现，Rust 无 std 内 crypto。**P2、P3 实现时均按完整 API 对标 Zig/Rust，不做最小化开发**；P4 中 async/SIMD 与语言阶段挂钩，长期预留。
