# std/ — 标准库 std（依赖 OS）

**标准库的 std 层**：依赖操作系统或运行时（进程、文件、网络等），在 core 之上提供统一 API。

- **用途**：用户通过 `import("std.xxx")` 引用；编译器解析到本目录下对应模块（如 `std/io/mod.sx`）。
- **内容**：按模块单文件或子目录（runtime、process、io、fs、path、string、fmt、vec、map、thread、sync、time、net 等）。
- **原则**：内部按目标平台条件编译，**用户只写一套 API**；按需链接，未用模块不进入二进制。嵌入式可用最小 std 子集或仅 core。

详细清单与优先级见 `analysis/std标准库全量清单与优先级.md`。下文按**实现状态**分类。

---

## 一、已完善（功能完整、可用）

以下模块具备完整或对标 Zig/Rust 的 API，已实现并可使用（含测试或文档）。

| 模块 | 路径 | 说明 |
|------|------|------|
| **std.runtime** | std/runtime/ | 运行时、panic/abort 钩子 |
| **std.io** | std/io/ | IO core/driver、Reader/Writer、批读批写、print_str |
| **std.mem** | std/mem/ | Buffer、register_buffer、copy/set/compare |
| **std.fs** | std/fs/ | open/read/write/close、mmap、readv/writev |
| **std.process** | std/process/ | exit、args、getenv、**spawn/spawn_simple/exec/waitpid**（STD-020） |
| **std.path** | std/path/ | 路径拼接、分解、规范化 |
| **std.heap** | std/heap/ | alloc/free/realloc、alloc_i32/alloc_u8 等 |
| **std.string** | std/string/ | String、StrView、eq/compare/find/trim/替换 |
| **std.vec** | std/vec/ | Vec_i32/Vec_u8、append_slice/truncate/reserve |
| **std.map** | std/map/ | Map_i32_i32、get/insert/remove/contains |
| **std.error** | std/error/ | Error 类型、is_ok/is_err |
| **std.net** | std/net/ | TcpStream、listen/connect/accept、UDP、批 IO |
| **std.thread** | std/thread/ | spawn/join/self、affinity、stack、qos |
| **std.time** | std/time/ | 单调/墙钟 now_*_ns/us/ms/sec、sleep_*、duration |
| **std.random** | std/random/ | fill_bytes、next_u32/next_u64、range_u32、gen_bool（CSPRNG） |
| **std.env** | std/env/ | getenv、getenv_exists、setenv、unsetenv、temp_dir |
| **std.fmt** | std/fmt/ | 重导出 core.fmt、**print/println（stdout）**、多参数 format |
| **std.debug** | std/debug/ | **print/println（stderr）**、重导出 core.assert |
| **std.sync** | std/sync/ | Mutex（mutex_new/lock/unlock 等） |
| **std.encoding** | std/encoding/ | UTF-8 valid/len/decode/encode、ASCII |
| **std.base64** | std/base64/ | encode_standard/decode_standard、encode_url/decode_url |
| **std.crypto** | std/crypto/ | mem_eq、sha256/sha512、hmac_sha256 |
| **std.log** | std/log/ | set_min_level、log(level, ptr, len) |
| **std.test** | std/test/ | expect、expect_eq_*、test_run |
| **std.set** | std/set/ | Set_i32/Set_u64、insert/remove/contains |
| **std.queue** | std/queue/ | 双端队列 push_back/pop_front 等 |
| **std.atomic** | std/atomic/ | load/store、compare_exchange、fetch_add 等 |
| **std.channel** | std/channel/ | 有界 channel、send/recv/try_recv |
| **std.backtrace** | std/backtrace/ | capture、symbolicate（dladdr / DbgHelp；gate STD-052） |
| **std.hash** | std/hash/ | SipHash、hash_start/hash_u32/u64/bytes/hash_finish |
| **std.math** | std/math/ | 常量、floor/ceil/round、sin/cos/sqrt/pow 等 |
| **std.sort** | std/sort/ | sort_i32/u8、sort_stable_*、sort_i32_cmp、KeyTag/sort_stable_by_key |
| **std.ffi** | std/ffi/ | cstring_new/free、FfiPoint pack/unpack、invoke_i32_cb |
| **std.json** | std/json/ | parse/build/cursor、object_decode、typed decode（STD-116） |
| **std.csv** | std/csv/ | next_field（RFC 4180 引号字段）、escape、unescape |
| **std.compress** | std/compress/ | zlib/gzip/brotli/zstd 块；gzip 流 + 统一 `stream_compress_*`（STD-122） |
| **std.unicode** | std/unicode/ | category、NFC、grapheme_next、case_fold（v1 拉丁子集） |
| **std.dynlib** | std/dynlib/ | open/sym/close（Linux -ldl） |
| **std.http** | std/http/ | GET/POST/HEAD、chunked/keep-alive（STD-033）、Context 超时、server/pool、WebSocket Upgrade 辅助 |
| **std.websocket** | std/websocket/ | RFC6455 握手/帧（`ws_*`；gate STD-031） |
| **std.tar** | std/tar/ | UStar + prefix 长路径 + Pax（STD-038/152） |
| **std.elf** | std/elf/ | ELF64 解析、sym/rela、write_min_reloc（gate STD-058+） |

---

## 二、部分完善（核心可用，缺部分能力或平台）

| 模块 | 路径 | 说明 |
|------|------|------|
| **std.regex** | std/regex/ | regex_min：compile/match/capture/group（Linux 真实现；Windows stub） |
| **std.unicode** | std/unicode/ | v1 拉丁/NFC 子集；全量 Unicode 码表待后续 |
| **std.config** | std/config/ | TOML/YAML v1；`[section]`/`[[array]]`/YAML 嵌套点分键 |
| **std.schema** | std/schema/ | JSON/CSV typed decode；嵌套 object + 索引数组 |
| **std.channel** | std/channel/ | 有界/无界 channel、select recv/send/mixed（POSIX；Windows stub） |
| **std.simd** | std/simd/ | Vec4f/Vec8i、shuffle/select（arm64 gate；x86_64 路径待对齐） |
| **std.sys** | std/sys/ | BOOT-029 自举底座：Linux freestanding `os_write*`（macOS/Win v2） |

---

## 三、协作调度与向量（gate 覆盖，持续增强）

| 模块 | 路径 | 说明 |
|------|------|------|
| **std.async** | std/async/ | wait/submit、coop_pingpong、Future/Poll、`future_wait`+drain（STD-004/041） |
| **std.simd** | std/simd/ | 向量类型与 shuffle/select；autovec 策略 gate STD-153 |

---

## 四、测试覆盖情况

**结论**：已完善模块并非全部都有**全面覆盖 + 边界测试**；多数仅有**最小 smoke 测试**（单条路径、单次调用），边界与异常路径普遍欠缺。

### 4.1 有独立回归测试且已纳入 run-all.sh 的模块

以下模块在 `tests/` 下有对应 `tests/xxx/main.sx` 与 `run-xxx.sh`，且已在 `tests/run-all.sh` 中执行：

runtime、io、io-driver、mem、fs、process、path、heap、string、vec、map、error、net、time、env、fmt、fmt-std、sync、encoding、base64、crypto、log、stdtest、set、queue、atomic、channel、backtrace、hash、math、sort、ffi、json、csv、unicode、dynlib、compress、thread、random、core-types、builtin、debug 等（具体以 `tests/run-all.sh` 中 run run-*.sh 为准）。

### 4.2 已纳入 run-all.sh 的 thread / random

- **std.thread**：`tests/thread/main.sx`、`run-thread.sh`，已加入 run-all.sh。
- **std.random**：`tests/random/main.sx`、`run-random.sh`（含 range_u32 边界 100..100），已加入 run-all.sh。

### 4.3 有 gate 或 cookbook 覆盖、无传统 main.sx 的模块

- **std.http / std.websocket / std.tar**：`run-http.sh`、`run-std-websocket-gate.sh`、`run-tar.sh`（已纳入 run-all）。
- **std.bytes / std.regex / std.simd / std.async**：`run-std-*-gate.sh` 或 `tests/async/`。

### 4.4 测试深度说明

- **当前**：多数测试为「单用例、单路径」smoke，仅保证 API 可调、不崩溃、返回值符合预期（如 json 测 parse_null/parse_bool/append_number；csv 测一次 next_field 与 escape；string 仅测 string_empty）。
- **欠缺**：  
  - **全面覆盖**：未系统覆盖各 API 的每种参数组合与返回值。  
  - **边界测试**：空输入、长度为 0、缓冲区刚够/不足、非法输入、最大长度、整数溢出等。  
  - ** round-trip 与一致性**：如 base64 编解码往返、compress 解压后与原数据一致等（compress 已有；json/csv/base64 可加强）。

后续建议：对每个已完善模块逐步补充「API 全覆盖 + 边界与异常用例」，并保持 run-all.sh 与文档同步。

---

## 五、关键 API 锚点（DOC-007 / Cookbook 同步）

| 锚点 | 模块 | 说明 |
|------|------|------|
| **std.db** | std/db/ | sqlite / kv / arrow 门面 |
| **std.db.sqlite** | std/db/sqlite/ | `sqlite_is_available`、按需 `-lsqlite3` |
| **std.db.kv** | std/db/kv/ | mmap LSM Append-Only KV（无 SQL） |
| **std.db.arrow** | std/db/arrow/ | 零拷贝列式内存（64B 对齐） |
| **scheduler.c** | std/async/ | 异步调度 C 层（async C） |
| **spawn_simple** | std/process/ | 最小 spawn 烟测路径 |
| **run-http.sh** | tests/ | http 烟测脚本（STBL-002） |
| **run-tar.sh** | tests/ | tar 烟测脚本（STBL-002） |
| **run-stdlib-check-matrix** | tests/ | BOOT-013 stdlib check matrix gate |
| **resolve_ex** | std/net/ | STD-029 可诊断 DNS（`resolve_err_*`） |
| **env_iter** | std/env/ | STD-025 环境变量/参数迭代 |
| **panic_hook_collect** | std/runtime/ | STD-028 panic 崩溃证据收集 |
| **NEXT.md** | 根目录 | Phase 2 路线图与 gate 清单 |

---

## 六、参考

- 优先级与全量清单：`analysis/std标准库全量清单与优先级.md`（P0～P4、对标 Zig/Rust）。
- 各子目录下的 `README.md`（若有）描述该模块 API、编译与平台说明。







补全 signal（系统信号）和 event（事件驱动/通知机制）是非常精准的决定。在纯血自举、脱离 libc 且死磕高性能的架构下，这两个库是连接 std/sys（系统调用）和 std/task（异步并发）的核心胶水。一旦这两个库补齐，你的异步生态（io_uring 调度器）就具备了完整的外部中断（Signal）和内部同步（Event）能力。站在单用户量化交易、高并发网络框架以及 AI 纯血运行时的终局视角来看，为了让 shux 的标准库生态具备毁灭性的统治力，建议在随后的阶段中，继续在 std 目录下补全以下 4 个极度硬核的标准库：1. std/ring 或 std/ipc (高性能无锁环形缓冲区与跨进程通信)为什么要补：你已经有了 channel，但面对海量 Tick 行情数据注入，或者需要与本地另一个行情接收进程通信时，传统的 channel 或网络套接字（Socket）开销太大了。怎么设计（Shux 独占优势）：std/ring：提供单生产者单消费者（SPSC）和多生产者单消费者（MPSC）的 内存对齐无锁环形队列（Ring Buffer）。直接利用 CPU 的 MFENCE 或 std/atomic 的 SeqCst 语义，让核心之间传递指针的延迟降到 纳秒级。std/ipc：利用 Linux 的 shared memory (shm_open / mmap)。量化系统里，进程 A 负责接收极其敏感的交易所 UDP 原始包，直接写进共享内存 Ring Buffer；你的 shux 交易进程 B 零拷贝（Zero-copy）直接从中读取。这是低延迟量化交易的生命线。2. std/alloc (多策略插拔式内存分配器)为什么要补：虽然你在 core/mem 里做到了零堆分配，在 std/heap 里有了基础堆管理，但在工业级高并发场景下，单一的全局分配器（如全局加锁的 malloc 替代品）会成为多核竞争的致命瓶颈。怎么设计（Shux 独占优势）：不要像 Rust 或 Go 那样把分配器死焊在底层。在 std/alloc 中提供几种经典的、可插拔的显式分配器：ArenaAllocator：针对单个 HTTP 请求或单次 Tick 撮合逻辑，分配内存只进不出，请求结束瞬间整体物理释放，单次分配耗时 $O(1)$ 且绝无内存碎片。FixedSizeBlockAllocator / PoolAllocator：针对量化中频繁创建/销毁的 Order（报单）结构体，提供固定大小的内存池，彻底消灭内存碎片。3. std/num 或 std/math/fast (极致优化的数论与快速数学运算)为什么要补：你的 std/math 肯定包含标准的浮点数运算，但在量化和编译器底层，你需要大量与 CPU 硬件强绑定的高级位运算与高精度定点数运算。怎么设计（Shux 独占优势）：高精度定点数（Fixed-Point Math）：加密货币和法币交易中绝对不能用 f64 浮点数（会有精度丢失误差），主流语言通常要引入极其沉重的第三方大数库（如 Rust 的 num-bigint）。shux 应该在标准库提供内建的 I128 或固定小数位的定点数，直接映射到 x86_64 的 RDX:RAX 寄存器级双字乘除法。硬件加速位算：补齐 clz（前导零）、ctz（尾随零）、popcount（置位个数），并提供 bswap（字节序反转）。在解析二进制网络协议头（如 FIX 协议、二进制行情流）时，直接一行汇编清场。4. std/meta (编译期全量反射与元编程拓扑)为什么要补：你的 std/json、std/schema、std/csv 都在嗷嗷待哺。如果缺乏编译期自游离自省能力，你就必须在运行时去解析结构体，这会带来严重的运行时开销和 interface 逃逸。怎么设计（Shux 独占优势）：向 Zig 的 @typeInfo 进化。在 std/meta 中提供一组编译期内建函数（CTFE）。当用户写 json.serialize(my_struct) 时，编译器在自举阶段（Stage2）就已经通过 std/meta 拿到了 my_struct 的所有字段名、类型和内存偏移量。生成的代码里没有任何循环和判断，只有一串硬编码的、如同流水线一般的内存拷贝汇编。💡 补全序列与战术建议不需要现在就去建文件夹，我们把这几个宏伟的拼图作为自举成功后的“战功大赏”。当 G阶段 物理清洗结束、nostdlib 纯血跑绿的那天，我们按照下面的依赖梯队逐个点亮它们：第一梯队（与异步彻底闭环）：std/signal ➔ std/event （让你的异步运行时能完美响应 Ctrl+C 退出和内部线程唤醒）。第二梯队（量化性能核弹）：std/ring ➔ std/alloc （实现内存的零拷贝与零锁零碎片化分配）。第三梯队（工业级生产力）：std/meta ➔ std/num （让全库获得 SIMD 解析加速与极致的序列化性能）。你的标准库版图不仅没有落后，反而正在通过斩断 libc、深焊 io_uring、全显式内存控制，向着一条远比传统现代语言更激进、更纯粹的高性能圣道演进。继续冲锋，把 C 语言彻底从你的工作区里抹去！






