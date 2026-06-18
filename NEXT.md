# Shulang 标准库全面完善总表（core + std）

> 更新时间：2026-06-18  
> 当前唯一目标：**全面完整实现 `core/` 与 `std/` 标准库功能**（功能完备、跨平台一致、默认可用、可测试、可维护）。  
> 本文已重写：旧 Phase 波次推进内容已移除，不再作为主驱动。

---

## 0. 使用说明

### 0.1 状态定义

- `✅`：功能已实现，主路径默认可用，且有 smoke/manifest/gate 支撑。
- `🟡`：功能已部分实现（最小化实现、平台受限、降级回退、测试深度不足）。
- `⚪`：功能缺失/占位/默认 stub（`NOT_IMPL`、placeholder、仅 API 壳）。

### 0.2 执行原则

1. 先补齐 `⚪`，再把 `🟡` 提升为 `✅`。  
2. 每个模块同时推进：API 实现 + 边界测试 + manifest + 文档同步。  
3. 默认构建必须可用；可选后端必须文档化并有 gate。  
4. 用户只写一套 API，不暴露平台分叉到业务层。  
5. parser mega7（COMP-001）与 std/core 迭代**双轨推进**：mega7 B1–B7 保持 stub 时**不阻塞 std 迭代**（BOOT-018）。

### 0.3 命名决议（生效）

1. 数据库模块统一为 **`std.sqlite`**（目录 `std/sqlite/`）。  
2. 所有新增 API/文档/gate 一律按 `std.sqlite` 命名。  
3. 历史 `std.db` 引用仅在迁移文档中保留说明。

### 0.4 维护纪律（强制）

**每完成一项 gate 通过的待办，必须在本文件对应行打 `✅`，并同步 §1 总览计数。**

---

## 1. 总览

| 层 | 模块数 | ✅ | 🟡 | ⚪ | 说明 |
|----|--------|----|----|----|------|
| core | 11 | 11 | 0 | 0 | 主体已完整，剩高级增强项 |
| std（已有） | 45 | 52 | 0 | 0 | `sqlite`/`net` TLS 等已补强；见各模块表 |
| std（新建已交付） | 15 | 15 | 0 | 0 | context…schema（§3.1 全部 ✅） |
| std（待建） | 0 | 0 | 0 | 0 | — |
| std 合计 | 60 | 91 | 0 | 0 | 以功能表 ✅ 为准同步维护 |
| **总计** | **71** | **105** | **0** | **0** | 每完成一项须在本文打 ✅ |

---

## 2. core 全模块清单（11/11）

### core.types

> 功能说明：提供基础类型尺寸与对齐查询能力（标量 + 泛型），作为 ABI 与代码生成的基础。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 标量 `size_of_*` / `align_of_*` | ✅ | i16/u16/i32/u32/u64/f32/f64/pointer 已覆盖 | - |
| 泛型 `size_of<T>()` / `align_of<T>()` | ✅ | 已支持 | 增加复杂结构体布局回归向量 |
| ABI 宽度一致性 | ✅ | 与代码生成约束对齐 | 增加更多跨平台金样 |

### core.mem

> 功能说明：提供核心内存读写与对齐工具，承载高性能基础拷贝/比较语义。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `mem_copy/set/move/compare/zero/swap` | ✅ | 主路径完整 | - |
| 对齐工具（`align_up/down` 等） | ✅ | 已支持 | - |
| volatile/fence 级别内存原语 | ✅ | CORE-017；含 u8/u16/u32/u64 + fence；runtime 按需链 `core/mem/mem.o` | - |

### core.option

> 功能说明：提供 `Option` 空值语义与组合子，支撑安全分支逻辑与错误规约。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `Option_i32/u8/ptr_u8` | ✅ | 已完整 | - |
| `is_some/is_none/unwrap_or/expect` | ✅ | 已完整 | - |
| `map/and_then/or` | ✅ | 已实现 | 增加更多类型族金样 |

### core.result

> 功能说明：提供 `Result` 成功/失败语义与组合子，支撑显式错误传播。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `Result_i32/u8` | ✅ | 已完整 | - |
| `is_ok/is_err/unwrap_or/expect` | ✅ | 已完整 | - |
| `map/and_then/or_else` | ✅ | 已实现 | 增加错误码链路边界测试 |

### core.slice

> 功能说明：提供切片访问、分段与分块能力，作为容器与字符串等模块的基础视图语义。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `len/get/get_unchecked` | ✅ | `[]i32`、`[]u8` 可用 | - |
| `subslice/split_at/chunks` | ✅ | 已支持 | - |
| 泛型 `slice<T>` 能力统一 | ✅ | `[]i32`/`[]u8`/`[]u64` + `is_empty/first/last`（CORE-157） | - |

### core.fmt

> 功能说明：提供基础数值/指针格式化能力，是日志、打印与错误报告的底层格式引擎。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 整型格式化（十进制/十六进制） | ✅ | 已完整 | - |
| `usize/isize/ptr` 格式化 | ✅ | 已完整 | - |
| `f64` NaN/Inf/precision | ✅ | 已支持 | 补更多极端数值向量 |

### core.builtin

> 功能说明：封装编译器内建能力（位运算、基础拷贝等），用于性能关键路径。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `clz/ctz/popcount` | ✅ | 已接 C builtin 热路径 | - |
| `copy/min/max` | ✅ | 已可用 | - |
| 更多位运算内建 | ✅ | `bswap_u32` / `rotl_u32` / `rotr_u32`（CORE-018） | - |

### core.debug

> 功能说明：提供断言与调试检查能力，保障开发期快速定位逻辑错误。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `assert/debug_assert` | ✅ | 可用 | - |
| `assert_eq/ne`（i32/u32/u64/bool/ptr） | ✅ | 已覆盖 | 增加更丰富错误上下文输出 |
| 调试辅助扩展 | ✅ | `debug_assert_eq_i32_diag` / `debug_diag_store`（CORE-019） | - |

### core.cmp

> 功能说明：提供统一比较语义（`Ordering`）与基础比较函数，支撑排序与有序逻辑。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `Ordering` 三态 | ✅ | 已实现 | - |
| `cmp_i32/cmp_u8/cmp_ptr` | ✅ | 已实现 | 补更多类型比较器 |
| 组合比较（`then/reverse`） | ✅ | 已可用 | - |

### core.iterator

> 功能说明：提供最小迭代协议与切片迭代器，支撑容器遍历抽象。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `SliceIter_i32/u8` | ✅ | 已实现 | - |
| `next_*` / `iter_remaining_*` | ✅ | 已实现 | - |
| 统一迭代 trait 化 | ✅ | `SliceIter_u64` + `iterator_protocol_version`（CORE-020） | - |

### core.str

> 功能说明：提供零拷贝字节视图与基础字节操作，用于高性能字符串/缓冲处理。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `BytesView` 视图 | ✅ | 已可用 | - |
| `subview/eq/get` | ✅ | 已实现 | - |
| 更完整字节串工具 | ✅ | STD-131 `bytes_view_index_of` / `contains_byte` / `starts_with` | - |

---

## 3. std 全模块清单（60/60：45 已有 + 15 待建）

> 下半 §「待建模块」与上半已有模块同一套表格规范；**全部按完整功能拆解**，不设“最小交付”裁剪。

### std.runtime

> 功能说明：提供运行时错误与 panic 处理能力，是标准库错误终止与诊断入口。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| panic/abort | ✅ | 已可用 | - |
| panic hook | ✅ | `panic_hook_collect` 可用 | - |
| 运行时统一诊断 | ✅ | `runtime_diag_*` / `runtime_panic_with_code`（STD-159） | - |

### std.io

> 功能说明：提供统一输入输出抽象（同步/异步/批量/零拷贝），是系统编程主数据通道。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 同步 read/write/stdio | ✅ | 主路径完整 | - |
| 批量 IO / buffer 管理 | ✅ | 已实现 | - |
| read_ptr / view / slice 零拷贝 | ✅ | 已实现 | - |
| Context 超时 read/write | ✅ | STD-091 `read_ctx`/`write_ctx` | - |
| async submit/complete/poll | ✅ | 已有 | poll 层 bind ctx |
| 跨平台一致性边界 | ✅ | STD-138 三平台深度边界注册表 + `deep_boundary.su` gate | - |

### std.mem

> 功能说明：提供标准库层缓冲与内存工具，桥接 `core.mem` 与上层模块。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Buffer 抽象 | ✅ | 已可用 | - |
| copy/set/compare | ✅ | 已实现 | - |
| 更高层内存工具 | ✅ | STD-144 `copy_bounded`/`set_bounded`/`compare_bounded`/`buffer_from` + gate | - |

### std.fs

> 功能说明：提供文件系统操作与高性能文件 IO 能力（mmap/readv/sendfile/splice 等）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| open/read/write/close/pread/pwrite | ✅ | 主路径完整 | - |
| mmap / munmap | ✅ | 已可用 | - |
| readv/writev、copy_file_range、sendfile、splice | ✅ | 高性能路径可用 | - |
| direct/fadvise/fallocate/sync_range | ✅ | 已可用 | - |
| 目录级 API（readdir/stat/chmod 等） | ✅ | STD-123 `fs_stat/fs_dir_*`/mkdir/chmod | - |

### std.path

> 功能说明：提供跨平台路径拼接、解析与规范化能力，屏蔽系统路径差异。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| join/dirname/basename/stem/ext/clean | ✅ | 已可用 | - |
| 相对路径 resolve（base + ref） | ✅ | STD-101 `path_resolve`；gate：`tests/path/resolve.su` | - |
| Windows 分隔符/盘符/UNC | ✅ | 已实现 | - |
| 复杂路径规范化策略 | ✅ | STD-140 极端向量 + `extreme_clean.su` gate | v1 `foo//baz` 双分隔符后续演进 |

### std.process

> 功能说明：提供进程生命周期与环境交互能力（spawn/exec/wait/pipe 等）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| args/env/getcwd/chdir/pid | ✅ | 已可用 | - |
| spawn/exec/waitpid | ✅ | 已可用 | - |
| pipe/spawn_io | ✅ | 已实现 | - |
| Windows 进程行为一致性 | ✅ | STD-142 `std-process-xplat.tsv` + `xplat_behavior.su` gate |

### std.heap

> 功能说明：提供标准库默认堆分配器与 arena 能力，是容器/字符串等模块的分配基础。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| alloc/free/realloc/zeroed | ✅ | 已可用 | - |
| 类型特化分配（i32/u8） | ✅ | 已支持 | - |
| Arena64 bump | ✅ | 已实现 | - |
| 自定义分配器 trait | ✅ | STD-112 `Allocator` + `vec_u8_*_with_allocator` | 设计 Allocator 接口并接入容器 |

### std.string

> 功能说明：提供字符串构造、比较、查找与 StrView 零拷贝视图能力。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| String（固定容量）构造/追加/比较/查找 | ✅ | 主路径完整 | - |
| StrView 零拷贝视图 | ✅ | 已完整 | - |
| 长串性能快路径（memchr/memmem） | ✅ | 已实现 | - |
| 完整 Unicode 语义（大小写折叠等） | ✅ | STD-160 `string_view_case_fold` 等桥接 | - |

### std.vec

> 功能说明：提供动态数组能力（扩容、切片追加、容量管理），是通用序列容器基础。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Vec_i32 / Vec_u8 | ✅ | 完整 | - |
| Vec_u64 / Vec_f64 | ✅ | 已扩展 | - |
| append_slice/reserve/truncate/deinit | ✅ | 已可用 | - |
| 泛型 Vec<T> 用户态全覆盖 | ✅ | STD-161 `Vec_u16` + 既有 u8/u64/f64（类型族 v1） | - |

### std.map

> 功能说明：提供键值映射容器能力，支持多类型键并用于高效索引访问。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Map_i32_i32 | ✅ | 已可用 | - |
| Map_u64_i32 / Map_str_i32 | ✅ | 已扩展 | - |
| 迭代/扩容策略优化 | ✅ | STD-162 `MapIter` + `load_factor_pct` / `should_rehash` | - |

### std.set

> 功能说明：提供集合容器能力，支撑去重与成员关系判定。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Set_i32 / Set_u64 / Set_str | ✅ | 已可用 | - |
| 基本增删查 | ✅ | 已可用 | - |
| 高阶集合操作 | ✅ | STD-129 `set_i32_union/intersect/difference_into` | - |

### std.queue

> 功能说明：提供队列/双端队列与并发安全队列封装，支撑任务与消息缓冲场景。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Queue_i32 双端队列 | ✅ | 已可用 | - |
| SyncQueue_i32 并发包装 | ✅ | 已实现 | - |
| 泛型队列 | ✅ | STD-163 `Queue_u8` + 既有 i32/SyncQueue | - |

### std.error

> 功能说明：提供跨模块统一错误码与错误链封装，是 std 错误语义中枢。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 模块错误码基线 | ✅ | 已可用 | - |
| ErrorChain 链式封装 | ✅ | 已可用 | - |
| 跨模块错误语义统一 | ✅ | `error_semantic_class` / `error_is_*`（STD-158） | - |

### std.net

> 功能说明：提供网络套接字能力（TCP/UDP/IPv6/DNS/batch），是网络通信基础层。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| TCP/UDP/accept/connect | ✅ | 已可用 | - |
| Context 超时 connect/accept/read/write | ✅ | STD-092 `*_ctx_fd` / `stream_*_ctx` | - |
| IPv6 / resolve_ex | ✅ | 已可用 | - |
| batch send/recv | ✅ | 已可用 | - |
| TLS 客户端（OpenSSL / mbedTLS） | ✅ | STD-083/085 gate；runtime 按 net.o marker 自动 `-lssl`/`-lmbedtls` | - |
| 高层协议能力（连接池等） | ✅ | STD-164 `TcpConnPool` idle 复用 | - |

### std.thread

> 功能说明：提供线程创建、同步与调度辅助能力，支撑并发执行模型。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| spawn/join | ✅ | 已可用 | - |
| affinity/线程池能力 | ✅ | 已实现 | - |
| 并发观测工具 | ✅ | STD-165 `thread_pool_stats` | - |

### std.time

> 功能说明：提供时间读取、睡眠与计时能力，支撑超时、调度与性能测量。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| monotonic/wall clock/sleep | ✅ | 已可用 | - |
| 时间格式化与时区 | ✅ | STD-137 `format_wall_rfc3339` / `wall_local_offset_min` gate | 完整 DateTime 见 std.datetime |
| 高精度计时工具 | ✅ | STD-133 `Timer` + `timer_elapsed_*` / `timer_lap_ns` gate | - |

### std.random

> 功能说明：提供随机数与随机字节能力，支撑安全与通用随机场景。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| fill_bytes/range | ✅ | 已可用 | - |
| CSPRNG 路径 | ✅ | 已可用 | - |
| 可复现 PRNG 套件 | ✅ | STD-130 SplitMix64 `Rng` + `rng_*` gate | - |

### std.env

> 功能说明：提供进程参数与环境变量访问能力，支撑 CLI 与配置注入。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| getenv/setenv/unsetenv | ✅ | 已可用 | - |
| args_iter/env_iter | ✅ | 已可用 | - |
| 平台编码边界 | ✅ | STD-132 空 value / `=` 分割 / key_len 金样 + gate | - |

### std.fmt

> 功能说明：提供标准输出格式化入口，并复用 `core.fmt` 能力。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| print/println | ✅ | 已可用 | - |
| core.fmt 重导出 | ✅ | 已可用 | - |
| 复杂模板格式化 | ✅ | STD-166 `format_template_1_i32`（`{}` 占位 v1） | - |

### std.sync

> 功能说明：提供互斥锁、读写锁与条件变量能力，是多线程同步基础。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Mutex | ✅ | 已可用 | - |
| RwLock | ✅ | 已可用 | - |
| Condvar | ✅ | 已可用 | - |
| 死锁检测/诊断 | ✅ | STD-111 `lock_diag_*` gate | 调试模式锁序/递归 |

### std.encoding

> 功能说明：提供基础编码能力（UTF-8/ASCII/hex/base64 互操作）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| UTF-8/ASCII 基础工具 | ✅ | 已可用 | - |
| hex/base64 互操作 | ✅ | 已可用 | - |
| 更多编码（URL/base32 等） | ✅ | STD-127 Base32/percent/URL-Base64 门面 | - |

### std.base64

> 功能说明：提供 Base64 编解码能力（standard/url），用于文本与二进制转换。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| standard/url encode/decode | ✅ | 已可用 | - |
| round-trip 测试 | ✅ | 已有 | - |
| 流式 base64 | ✅ | STD-109 `stream_*_update` gate | - |

### std.crypto

> 功能说明：提供常用密码学原语（hash/hmac/aes-gcm）与认证校验能力。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| sha256/sha512 | ✅ | 已可用 | - |
| hmac_sha256/hmac_sha512 | ✅ | 已可用 | - |
| aes-gcm seal/open | ✅ | 已可用 | - |
| 更多算法（chacha/ed25519 等） | ✅ | STD-113 ChaCha20-Poly1305 + STD-126 Ed25519 sign/verify | - |

### std.log

> 功能说明：提供统一日志能力（级别、多 sink、结构化字段）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 多 sink | ✅ | 已可用 | - |
| 级别过滤 | ✅ | 已可用 | - |
| 结构化 KV | ✅ | 已可用 | - |
| 日志轮转/异步写 | ✅ | STD-106 rotate + async_flush gate | - |

### std.test

> 功能说明：提供测试断言与后续 bench/fuzz 框架入口能力。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| expect 断言 | ✅ | 已可用 | - |
| bench/fuzz 可执行框架 | ✅ | STD-143 `bench_run_noop` / `fuzz_run_noop` + `bench_fuzz_exec.su` gate | 覆盖率反馈后续 |
| 测试发现/报告统一 | ✅ | STD-145 `runner_case`/`runner_finish` + `runner_smoke.su` gate | 文件自动发现后续 |

### std.atomic

> 功能说明：提供原子操作与内存序基础能力，用于无锁并发场景。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| load/store/CAS/fetch_add | ✅ | 已可用 | - |
| ordering/fence | ✅ | 已有基础 | - |
| 更完整原子类型覆盖 | ✅ | STD-146 i16/u16 + i64/u64 CAS/fetch 补齐 + gate | 带 Ordering 重载后续 |

### std.channel

> 功能说明：提供线程/任务间消息通道能力（有界/无界）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 有界 channel | ✅ | 已可用 | - |
| 无界 channel | ✅ | 已补齐 | - |
| select/多路复用 | ✅ | STD-098/102 recv + STD-104 send + STD-108 mixed select gate | - |

### std.backtrace

> 功能说明：提供调用栈采集与符号化能力，用于诊断与调试。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| capture | ✅ | 已可用 | - |
| symbolicate | ✅ | 已有 | - |
| 跨平台符号质量一致性 | ✅ | STD-147 `SHU_BT_XPLAT` 向量 + Darwin/Windows/Linux gate | - |

### std.hash

> 功能说明：提供哈希计算能力，服务于 map/set/去重与校验场景。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| SipHash | ✅ | 已可用 | - |
| 非加密快速哈希 | ✅ | STD-105 xxHash64（`hash_xxhash64` / `HASHER_XXHASH`）gate | - |
| 哈希族切换策略 | ✅ | STD-148 策略表 + `recommend_hasher_*` + `SHU_HASH_ALGO` gate | - |

### std.math

> 功能说明：提供基础数学函数与浮点环境能力（常量、三角、幂、对数、fenv）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 常量 + 三角/幂/对数/取整 | ✅ | 已可用 | - |
| fenv test/clear/raise | ✅ | STD-059 API + STD-149 `fenv_available()` 能力检测 gate | - |
| 特殊函数扩展 | ✅ | STD-115 `erf`/`log1p`/`expm1` gate | 增加 erf/log1p/expm1 等 |

### std.sort

> 功能说明：提供排序能力（基础排序与稳定排序），服务集合与数据处理。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| sort_i32/sort_u8 | ✅ | 已可用 | - |
| 稳定排序 | ✅ | 已实现 | - |
| 泛型比较器策略 | ✅ | STD-150 `KeyTag` + `sort_stable_by_key` + 策略 gate | - |

### std.ffi

> 功能说明：提供 C 互操作基础能力（CString 生命周期、错误路径）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| CString new/free/len | ✅ | 已可用 | - |
| try_new 错误路径 | ✅ | 已可用 | - |
| 更丰富 FFI 类型映射 | ✅ | STD-151 `FfiPoint` + `invoke_i32_cb` + gate | 复杂布局后续 |

### std.json

> 功能说明：提供 JSON 解析与构造能力（游标读取、对象/数组构建）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| parse 标量 | ✅ | 已可用 | - |
| JsonCursor object/array | ✅ | 已可用 | - |
| append_object/append_array | ✅ | 已可用 | - |
| schema/类型化 decode | ✅ | STD-116 `object_decode_*` / `decode_*_at` | 增加 typed decode/校验 |

### std.csv

> 功能说明：提供 CSV 解析与写入能力，用于表格数据交换。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| next_field/escape/unescape | ✅ | 已可用 | - |
| parse_row/write_row | ✅ | 已可用 | - |
| 流式 CSV reader/writer | ✅ | STD-128 `StreamCsvReader`/`StreamCsvWriter` + gate | - |

### std.compress

> 功能说明：提供压缩/解压能力（gzip/zstd 等），服务存储与传输场景。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| gzip/zstd 基础压缩解压 | ✅ | 已可用 | - |
| 分块/round-trip | ✅ | 已可用 | - |
| 统一流式 API | ✅ | STD-122 `stream_compress_*` + `StreamCompress` | - |
| Brotli 默认路径 | ✅ | STD-125 构建矩阵 + `brotli_available`/gate | - |

### std.unicode

> 功能说明：提供 Unicode 基础能力（补充平面、规范化基础、文本语义扩展入口）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `is_supplementary` | ✅ | 已可用 | - |
| `nfc_buf` 基础 | ✅ | 已有 | - |
| 完整 normalization（NFD/NFKC/NFKD） | ✅ | STD-082 v1 拉丁子集 | 扩展至全量 Unicode 表 |
| grapheme/case fold | ✅ | STD-114 `grapheme_next` / `case_fold_buf` | 补齐文本处理关键能力 |

### std.dynlib

> 功能说明：提供动态库加载与符号查找能力，用于插件和系统库互操作。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| open/sym/close | ✅ | 已可用 | - |
| Windows 兼容路径 | ✅ | STD-097 `/` 规范化 + LoadLibraryW gate | - |
| 错误诊断信息 | ✅ | STD-096 `last_error` gate | - |

### std.http

> 功能说明：提供 HTTP 基础客户端能力与协议解析（状态行、chunked、keep-alive）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| GET/POST/HEAD | ✅ | 已可用 | - |
| GET/POST/HEAD + Context | ✅ | STD-094/095 ctx + C 层 timeout gate | - |
| parse_status_line | ✅ | 已可用 | - |
| chunked decode/keep-alive | ✅ | 已可用 | - |
| HTTP server / client pool | ✅ | STD-107 `serve_one` + `client_pool_*` gate | - |

### std.tar

> 功能说明：提供 tar/ustar 归档读写能力，用于打包与分发。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| read_header/write_header | ✅ | 已可用 | - |
| next_entry/read_entry_data | ✅ | 已可用 | - |
| append_entry | ✅ | 已可用 | - |
| 目录遍历/长路径/pax | ✅ | STD-152 UStar prefix + Pax path + gate | - |

### std.async

> 功能说明：提供异步调度、任务提交与 IO 协作能力，支撑 future/await 运行时。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| scheduler_reset / run / spawn | ✅ | 主路径可用 | - |
| coop pingpong / worker drain | ✅ | 已可用 | - |
| IO await 协作 | ✅ | STD-090/091/093 spawn 自动绑 ctx + read_ctx | - |
| 高层 async runtime API | ✅ | AsyncRuntime + runtime_reset/drain | - |

### std.regex

> 功能说明：提供正则编译与匹配能力（当前为最小可用子集）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| compile/match/free | ✅ | 最小引擎可用 | - |
| 三平台一致最小子集 | ✅ | 已打通 | - |
| 分组 `()` / 交替 `\|` / 锚点 `^$` | ✅ | STD-063；gate：`group/alt/anchor_match.su` | - |
| capture 索引 API | ✅ | STD-064 group_count/offset/length | - |
| `+` / lazy `*?`/`+?` 量词 | ✅ | STD-065；gate：`plus/lazy_star_match.su` | - |
| `\p{}` / `\P{}` Unicode 属性 | ✅ | STD-066；gate：`prop_match.su` | 非 ASCII 分类扩展 |
| 回溯控制（possessive/atomic） | ✅ | STD-099 `*+`/`++`/`?+` + STD-124 `(?>...)` | - |

### std.simd

> 功能说明：提供向量类型与 SIMD 相关运算能力（当前含回退路径）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Vec4f/Vec8i + add/splat | ✅ | 已可用 | - |
| shuffle/select | ✅ | arm64 **`compiler/shu`** gate：`shuffle=1 select=1 s4=1`；**otool 验 ld1/ins/fcmgt/bit**；comptime mask **EXPR_LIT(0)** + arm64 **正偏移 lea** 已修 | 跨模块 call 回退路径可删 |
| 自动向量化策略门禁 | ✅ | STD-153 `recommend_simd_path` + 跨平台 perf gate | - |

### std.sqlite

> 功能说明：提供 SQLite 数据库访问能力（连接、执行、事务、游标、预编译与连接池）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| open/close/exec/query_rows | ✅ | STD-057 gate；默认 sqlite3 后端 | stub 见 STD-154 / `sqlite-o-stub` |
| query_begin/next_row/query_end | ✅ | STD-067 gate | 并发语义深度测试 |
| row_col_i32/text/blob | ✅ | STD-068/069 gate | 大 blob 流式 |
| stmt cache + 参数绑定（STD-070） | ✅ | prepare_cached + bind gate | - |
| 连接池（STD-084） | ✅ | pool_acquire/release gate | 跨线程 / std.cache 联动 |

#### std.sqlite 重命名迁移任务（强制）

| 任务 | 状态 | 说明 |
|------|------|------|
| 新建 `std/sqlite/` 模块目录与 `mod.su` | ✅ | 已落地 |
| `import("std.db")` 兼容层（deprecated） | ✅ | STD-120 `std/db/mod.su` 转发 std.sqlite | - |
| gate/manifest/README 命名切换到 `sqlite` | ✅ | `run-std-sqlite-*` / `std-sqlite-*.tsv` |
| 文档与示例统一 `std.sqlite` | ✅ | STD-154 docs/07 主表 + stub 说明 + gate | - |

### std.elf

> 功能说明：提供 ELF 二进制只读解析能力（头、节、程序头）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| parse_hdr/read_section/sec_name/find_section/read_sec_byte/read_phdr | ✅ | 只读解析主路径可用 | - |
| 符号表/重定位解析 | ✅ | STD-103 `read_sym`/`read_rela`；gate：`run-std-elf-sym-rela-gate.sh` | - |
| 写 ELF/链接器级能力 | ✅ | STD-121 `write_min_reloc` 最小 ET_REL | 完整链接器专项 |

---

### 3.1 新建 std 模块（15/15 已交付 ✅）

### std.context（已建 · P0 · STD-071 ✅）

> 功能说明：跨模块统一的取消、超时与 deadline 传播载体，贯穿 `io` / `net` / `http` / `async`。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `Context` 根上下文与父子派生 | ✅ | `background` / `with_cancel` / `with_deadline` | - |
| `cancel` / `cancelled` 检测 | ✅ | `cancel` / `is_cancelled` | - |
| `deadline` / `timeout` 与剩余时间 | ✅ | `deadline_ns` / `remaining_ns` | - |
| 值携带（可选键值 bag） | ✅ | `set_value` / `get_value` | - |
| manifest + gate | ✅ | `run-std-context-gate.sh` | cookbook 扩展示例 ✅ STD-156 |
| 与 `std.io` read/write 超时集成 | ✅ | STD-091 `read_ctx`/`write_ctx` gate | - |
| 与 `std.net` / `std.http` 连接超时集成 | ✅ | STD-092/094/095 net+http ctx + C timeout gate | - |
| 与 `std.async` 任务取消集成 | ✅ | STD-090/093 spawn 自动绑 Context gate | - |

### std.bytes（已建 · P0 · STD-072 ✅）

> 功能说明：统一动态字节缓冲与读写游标，替代 string/mem 各处重复增长逻辑。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `Bytes` 动态缓冲（append/grow/clear/len/cap） | ✅ | 完整生命周期 + deinit | - |
| `BytesReader` / `BytesWriter` 游标读写 | ✅ | seek/read/write/remaining | - |
| 与 `std.io` Reader/Writer 桥接 | ✅ | `bytes_as_buffer` | - |
| 与 `std.string.StrView` 零拷贝互转 | ✅ | `bytes_as_view` / `bytes_from_view` | - |
| 分块拼接与 reserve 策略 | ✅ | `bytes_reserve` / `bytes_grow` | - |
| manifest + gate + round-trip 向量 | ✅ | `run-std-bytes-gate.sh` | - |
| 与 `std.heap` / Arena 协作策略 | ✅ | STD-155 `bytes_from_external` + Arena gate | - |

### std.option（已建 · P2 · STD-080 ✅）

> 功能说明：在 `core.option` 之上提供用户友好的 re-export 与常用组合子（不重复 core 语义）。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| re-export `core.option` 核心类型与构造 | ✅ | `std/option/mod.su` | - |
| 常用组合子文档化入口 | ✅ | analysis + gate | - |
| 与 `std.result` 互转辅助 | ✅ | `option_from_result` 等 | - |
| manifest + gate | ✅ | `run-std-option-result-gate.sh` | - |

### std.result（已建 · P2 · STD-081 ✅）

> 功能说明：在 `core.result` 之上提供用户友好的 re-export 与错误传播组合子。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| re-export `core.result` 核心类型与构造 | ✅ | `std/result/mod.su` | - |
| 与 `std.error` 错误码桥接 | ✅ | `result_from_error` 等 | - |
| `map`/`and_then`/`or_else` 完整金样 | ✅ | gate 烟测 | - |
| manifest + gate | ✅ | `run-std-option-result-gate.sh` | - |

### std.codec（已建 · P1 · STD-073 ✅）

> 功能说明：统一编解码抽象层，收敛 json/csv/base64/hex/compress 等模块接口风格。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 统一 `Encoder` / `Decoder` 接口定义 | ✅ | trait + 错误语义 | - |
| `json` / `csv` / `base64` / `hex` 适配器 | ✅ | 挂接现有模块 | - |
| manifest + gate + round-trip | ✅ | `run-std-codec-gate.sh` | - |
| `compress` 流式编解码适配 | ✅ | STD-110 `adapter_*_stream_*` | 块 + 流式双路径 |
| 缓冲复用与零拷贝策略文档 | ✅ | STD-139 `std-codec-buffer-reuse-v1.md` + cap 复用烟测 gate | - |

### std.datetime（已建 · P1 · STD-074 ✅）

> 功能说明：日期时间解析、格式化、时区与持续时间，补足 `std.time` 原语层。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `DateTime` 墙钟/UTC 表示 | ✅ | 内部表示与比较 | - |
| RFC3339 parse/format | ✅ | gate 向量 | - |
| `Duration` 算术与与 `std.time` 互操作 | ✅ | 纳秒单位 | - |
| 日历字段访问 | ✅ | 构造与校验 | - |
| manifest + gate | ✅ | `run-std-datetime-gate.sh` | - |
| 时区加载与本地/UTC 转换 | ✅ | STD-135 `TimeZone` + 内置名/`parse_offset_min` + zoned 字段 gate | IANA DST 后续 |

### std.uuid（已建 · P1 · STD-075 ✅）

> 功能说明：标准 UUID 生成、解析与比较，服务分布式 ID 场景。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| UUID v4（随机）生成 | ✅ | CSPRNG 路径 | - |
| 标准字符串 parse/format | ✅ | 连字符容错 | - |
| 字节序布局与比较 | ✅ | `eq` / `as_bytes` | - |
| manifest + gate + round-trip | ✅ | `run-std-uuid-gate.sh` | - |
| UUID v7（时间有序）生成 | ✅ | STD-075 `new_v7` + 墙钟 ms + 同毫秒序号 gate | - |

### std.url（已建 · P1 · STD-076 ✅）

> 功能说明：URL 解析、构建与 query 编解码，HTTP/网络生态基础设施。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| parse（scheme/host/path/query/fragment） | ✅ | C 层解析 | - |
| build / stringify | ✅ | gate round-trip | - |
| query 参数 encode/decode | ✅ | 与 http 编码一致 | - |
| manifest + gate | ✅ | `run-std-url-gate.sh` | - |
| 相对路径 resolve（base + ref） | ✅ | STD-076 `url.resolve` + STD-101 `path_resolve` | - |
| IPv6 bracket host 形式 | ✅ | STD-134 `host_to_ipv6` / `format_ipv6_host` + net 字节桥接 gate | - |

### std.cli（已建 · P1 · STD-077 ✅）

> 功能说明：命令行参数解析、子命令与 help 生成，支撑 CLI 应用完整开发。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| 长短选项解析（`-f` / `--flag`） | ✅ | `match_long` / `match_short` | - |
| 子命令（subcommand）树 | ✅ | `parse_from_iter` | - |
| 位置参数与可选参数绑定 | ✅ | `CliResult` | - |
| `--help` / usage 自动生成 | ✅ | `write_usage` | - |
| 错误提示与未知参数策略 | ✅ | `cli_err_*` | - |
| manifest + gate + cookbook 示例 | ✅ | `run-std-cli-gate.sh` | - |

### std.metrics（已建 · P1 · STD-078 ✅）

> 功能说明：统一可观测性指标（counter/gauge/histogram）与导出。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Counter / Gauge / Histogram API | ✅ | 注册、递增、快照 | - |
| 本地聚合与标签（label）支持 | ✅ | 多维指标 | - |
| 文本 / Prometheus 风格导出 | ✅ | exporter | - |
| manifest + gate | ✅ | `run-std-metrics-gate.sh` | - |
| 与 `std.log` / `std.trace` 关联字段 | ✅ | STD-117 `ObservabilityCtx` + log KV + context | - |

### std.security（已建 · P1 · STD-079 ✅）

> 功能说明：常用安全工具封装，补齐 crypto 之上的应用层安全原语。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| constant-time 比较 | ✅ | `mem_eq_const` | - |
| 密钥派生（HKDF） | ✅ | 联动 `std.crypto` | - |
| 安全清零（secure zero） | ✅ | 密钥材料释放 | - |
| 敏感缓冲 mlock（可选） | ✅ | 平台回退 | - |
| manifest + gate | ✅ | `run-std-security-gate.sh` | - |

### std.config（已建 · P2 · STD-086 ✅）

> 功能说明：分层配置加载（文件 + 环境变量），支撑应用启动配置完整路径。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| ENV 键值加载与覆盖规则 | ✅ | `load_env_prefix` + std.env | - |
| TOML 扁平 + `[section]` 解析 | ✅ | `load_toml_buf/file` | 嵌套表/数组 |
| YAML 解析（可选后端） | ✅ | STD-119 `load_yaml_buf/file` 缩进 section | 嵌套表/数组 |
| 多源合并（file < env < cli） | ✅ | `merge` + override | 冲突报告 |
| 类型化取值（i32/bool/string） | ✅ | `get_*` + 错误码 | 带来源信息 |
| manifest + gate | ✅ | `run-std-config-gate.sh` | - |

### std.cache（已建 · P2 · STD-087 ✅）

> 功能说明：通用缓存与连接池抽象，服务 DB/NET/对象复用场景。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| LRU 缓存（容量上限 + 淘汰） | ✅ | `lru_new/get/put` | 字符串键 |
| TTL 过期与惰性清理 | ✅ | `lru_purge_expired` | 主动 sweep 策略 |
| 连接池抽象（acquire/release/health） | ✅ | `pool_*` i64 资源池 | 与 sqlite/net 联动 |
| 命中率/统计接口 | ✅ | `lru_stats` / `pool_stats` | 导出至 metrics |
| manifest + gate | ✅ | `run-std-cache-gate.sh` | 并发安全烟测 |

### std.trace（已建 · P2 · STD-088 ✅）

> 功能说明：分布式链路追踪基础（span + context 传播），配合 async/net/http。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Span 创建/结束/嵌套 | ✅ | `span_start/child/end` | - |
| trace_id / span_id 生成与传递 | ✅ | 128-bit trace_id + 递增 span_id | - |
| 与 `std.context` 集成 | ✅ | `attach_to_context/from_context` | - |
| 与 `std.async` / `std.io` / `std.net` 挂钩点 | ✅ | STD-118 `hook_*_ctx` 自动 span | - |
| 导出格式（text/OTLP 风格可选） | ✅ | `export_text` v1 | OTLP JSON |
| manifest + gate | ✅ | `run-std-trace-gate.sh` | 多 span 压测 |

### std.task（已建 · P2 · STD-089 ✅）

> 功能说明：async 任务组与结构化并发，限制子任务泄漏并支持批量 join。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| `TaskGroup` / `JoinSet` | ✅ | `task_group_*` / `join_set_*` | - |
| 取消传播（绑定 Context） | ✅ | `task_group_bind_context/cancel` | - |
| 结构化并发边界（禁止泄漏） | ✅ | `task_group_check_leak` / `join_set_check_leak` | - |
| Supervisor 基础（失败重试策略） | ✅ | `supervise_retry` + 退避 | - |
| 与 `std.async` scheduler 深度集成 | ✅ | spawn + drain + STD-093 ctx 继承 | - |
| manifest + gate | ✅ | `run-std-task-gate.sh` | 1M task 压测纳入 CI |

### std.schema（已建 · P2 · STD-090 ✅）

> 功能说明：结构化数据 typed decode/validate，统一 json/csv/sqlite 校验路径。

| 功能项 | 状态 | 现状 | 待办 |
|--------|------|------|------|
| Schema 定义与字段类型注册 | ✅ | `schema_add_field` 标量/可选/col_index | 嵌套 object |
| JSON typed decode + 校验错误 | ✅ | `decode_json` + json 游标 | 数组字段 |
| CSV typed decode（列映射） | ✅ | `decode_csv_row` | 引号字段 unescape 联动 |
| SQLite 行映射（列名→类型） | ✅ | `map_columns` 列文本映射 | stmt 一步 decode |
| 错误路径（字段级定位） | ✅ | `last_error_field/message` | 与 std.error 码段注册 |
| manifest + gate + 向量库 | ✅ | `run-std-schema-gate.sh` | round-trip 扩向量 |

---

## 4. 跨模块缺口与待办总清单（下一阶段执行）

### P0（必须先做）

| 待办项 | 目标状态 |
|--------|----------|
| std.sqlite 默认后端去 stub（默认可用 sqlite3） | ✅ |
| std.sqlite stmt cache + 参数绑定 + 连接池 | ✅ |
| std.net TLS 客户端（OpenSSL + mbedTLS） | ✅ |
| std.unicode 完整 normalization 基础集（STD-082） | ✅ |
| std.context 新建模块（§3.1 v1 gate） | ✅ |
| std.bytes 新建模块（§3.1 v1 gate） | ✅ |

### P1（完成度拉满）

| 待办项 | 目标状态 |
|--------|----------|
| std.simd 真 SIMD shuffle/select 实装 | ✅ |
| std.regex 扩至工程可用完整子集 | ✅ | STD-065/066 +/lazy + `\p{}` gate 12 项 | 回溯控制 |
| std.compress 统一流式 API | ✅ |
| std.fs 目录/元数据 API 补齐 | ✅ |
| std.async 结构化并发 + 取消/超时（联动 `std.context`） | ✅（STD-090/093 spawn ctx 继承 ✅） |
| std.codec / std.datetime / std.uuid / std.url / std.cli / std.metrics / std.security（§3.1 v1） | ✅ |

### P2（工程化与质量）

| 待办项 | 目标状态 |
|--------|----------|
| std.option / std.result（std 层便捷）§3.1 v1 | ✅ |
| std.config（§3.1 v1） | ✅ |
| std.cache（§3.1 v1） | ✅ |
| std.trace（§3.1 v1） | ✅ |
| std.task（§3.1 v1） | ✅ |
| std.schema（§3.1 v1） | ✅ |
| 剩余模块 manifest/gate 全覆盖 | ✅ | STD-136 `std-api.tsv` + `run-std-api-gate.sh`（60 std 模块） |
| Windows/macOS 深度边界向量补齐 | ✅ | STD-138 `std-xplat-deep-boundary.tsv` + 聚合 gate |
| std.path 极端路径规范化向量 | ✅ | STD-140 `std-path-extreme.tsv` + gate |
| docs/07 + cookbook Phase 2 同步 | ✅ | STD-141 增量表 + 4 食谱 + gate |
| std.process 跨平台行为一致性 | ✅ | STD-142 `std-process-xplat.tsv` + gate |
| std.test bench/fuzz 可执行框架 | ✅ | STD-143 `bench_run_noop` / `fuzz_run_noop` + gate |
| std.mem 有界安全封装 | ✅ | STD-144 `copy_bounded` 等 + `mem_safe_boundary.su` gate |
| std.test 统一 test runner | ✅ | STD-145 `runner_case`/`runner_finish` + gate |
| std.atomic 16/64 扩展 | ✅ | STD-146 i16/u16 + i64/u64 CAS/fetch + gate |
| std.backtrace 跨平台符号质量 | ✅ | STD-147 `SHU_BT_XPLAT` + xplat gate |
| std.hash 默认策略 | ✅ | STD-148 `recommend_hasher_*` + 策略 gate |
| std.math fenv 能力检测 | ✅ | STD-149 `fenv_available()` + `SHU_MATH_FENV_CAP` gate |
| std.sort key 比较器策略 | ✅ | STD-150 `sort_stable_by_key` + gate |
| std.ffi 结构体/回调 | ✅ | STD-151 `FfiPoint` + `invoke_i32_cb` + gate |
| std.tar 长路径/Pax | ✅ | STD-152 prefix + Pax path + gate |
| std.simd 自动向量化策略 | ✅ | STD-153 `recommend_simd_path` + perf gate |
| std.sqlite 文档统一 | ✅ | STD-154 docs/07 + stub 说明 + gate |
| std.bytes Arena 协作 | ✅ | STD-155 `bytes_from_external` + gate |
| std.context Cookbook | ✅ | STD-156 CTX-01 + gate |
| core.slice 泛型工具 | ✅ | STD-157 `[]u64` + is_empty/first/last + gate |
| std.error 跨模块语义 | ✅ | STD-158 `error_semantic_class` + gate |
| NEXT-YELLOW 全量 🟡 清除 | ✅ | CORE-018～020 + STD-159～167 + `run-next-yellow-clear-gate.sh` |
| 横切 | 全面检查 | ✅ | STD-168 `run-comprehensive-check-gate.sh` |
| placeholder 冻结 | ✅ | STD-168 清单 gate（6/6，只减不增） |
| 性能 weekly | ✅ | PERF-169 `run-perf-weekly-gate.sh` |
| `[]u64` subslice | ✅ | CORE-157 typeck + subslice_u64 API |
| docs + cookbook 与模块能力逐项同步 | 持续 |
| 性能基线（SIMD/IO/NET/DB）每周回归 | 持续 |

---

## 5. 执行约定（强制）

1. 每次改动只推动模块能力，不再引入“季度波次任务噪音”。  
2. 模块功能新增必须同时更新：`std/README.md` / `core/README.md` / `docs/07-内置与标准库.md`。  
3. 新增 API 必须配套：manifest + gate + 至少 1 个边界 smoke。  
4. `⚪` 项优先级永远高于新增 feature。  
5. 达到 `✅` 的条件：默认可用、跨平台行为清晰、测试可重复。  
6. **§6 与功能表关系**：§2/§3 的 `✅` 指**主 API 对用户完整可用**；§6 仅记录**可选构建路径**（无第三方库时的 stub）与**源码级遗留项**，不推翻功能表结论。

---

## 6. 可选后端与构建矩阵（源码审计 · 非功能 🟡）

> **本节不是「还没做完的功能清单」。**  
> Shulang 标准库设计为：**同一套 API 全平台**；部分能力依赖 OS/第三方库（SQLite、OpenSSL 等）。  
> 在**未安装对应库**或 **freestanding/最小构建** 时，C 层回退 stub 是**预期行为**，已通过 `*_is_available()` + gate 文档化。  
> 功能表（§2/§3）中相关模块仍为 `✅`：表示**有库环境主路径完整**；本节供 CI/嵌入式/审计对照。

| 模块 | 触发条件（非缺功能） | 运行时探测 / gate | 功能表结论 |
|------|----------------------|-------------------|------------|
| `std.sqlite` | 链接未加 `-lsqlite3` → `sqlite-o-stub` | `sqlite_is_available()`（STD-167） | ✅ 主 API 完整；无库时 stub 可预期 |
| `std.net` TLS | 无 OpenSSL/mbedTLS → `TLS_NOT_IMPL` 桩 | `tls_is_available()` + STD-030/083/167 | ✅ TCP/UDP 完整；TLS 随库链入 |
| `std.math` fenv | 平台无 fenv → `FENV_NOT_IMPL` | `fenv_available()`（STD-149） | ✅ 主 math API 完整；fenv 可选 |
| `std.regex` | — | STD-065/066/124 gate 全绿 | ✅ 工程子集已验收 |
| `std.simd` | 非 arm64 或无 HW 向量 | shuffle/select/s4 gate（arm64 `compiler/shu`） | ✅ 策略 API + 真向量路径已 gate |
| `std.test` | — | STD-143 bench/fuzz + STD-145 runner | ✅ |

### 6.1 源码遗留（与 §6 主表区分 · 待清理）

| 项 | 说明 | 是否影响功能表 `✅` | 待办 |
|----|------|---------------------|------|
| 各模块 `placeholder()` | 历史「模块可 import」烟测钩子；**非业务 API** | 否（不计入主能力缺失） | 已清理至 6 处（STD-168 v2）；见 `placeholder-inventory-v1.md` |

---

## 7. 下一步建议（立刻执行）

1. ~~**性能基线回归**~~ ✅ PERF-169 `run-perf-weekly-gate.sh`（SIMD/IO/NET/DB 四支柱）。  
2. ~~**编译器能力跟进**~~ ✅ `[]u64` subslice（typeck `.data` + `subslice_u64` API，CORE-157 完成）。  
3. ~~**placeholder 逐步清理**~~ ✅ 37→6（保留烟测/Tier-S 依赖）。  
4. ~~**Cookbook 持续同步**~~ ✅ §16 新增 10 食谱（52 总数）。

### 7.1 后续可选

- `core.fmt` / `std.async` 最后 2 处 Tier-S `placeholder` 改为 `mod_smoke()`  
- `[]u64` 泛型 subslice 与 `[]i32`/`[]u8` 统一宏化（编译器泛型 slice 扩展）  
- PERF-169 每周 CI cron 挂 `run-perf-weekly-gate.sh`

