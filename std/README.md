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
| **std.fmt** | std/fmt/ | 重导出 core.fmt、print/println、多参数 format |
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
| **std.http** | std/http/ | GET/POST/HEAD、Context 超时、server/pool、WebSocket Upgrade 辅助 |
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
| **std.sqlite** | std/sqlite/ | deprecated → `std.db.sqlite` |
| **scheduler.c** | std/async/ | 异步调度 C 层（async C） |
| **spawn_simple** | std/process/ | 最小 spawn 烟测路径 |
| **resolve_ex** | std/net/ | STD-029 可诊断 DNS（`resolve_err_*`） |
| **env_iter** | std/env/ | STD-025 环境变量/参数迭代 |
| **panic_hook_collect** | std/runtime/ | STD-028 panic 崩溃证据收集 |
| **NEXT.md** | 根目录 | Phase 2 路线图与 gate 清单 |

---

## 六、参考

- 优先级与全量清单：`analysis/std标准库全量清单与优先级.md`（P0～P4、对标 Zig/Rust）。
- 各子目录下的 `README.md`（若有）描述该模块 API、编译与平台说明。
