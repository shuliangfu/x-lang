# std.compress

压缩封装（P4 可选；对标 Zig std.compress、Rust flate2）。提供 **zlib**、**gzip**（.gz）、**Brotli**（.br）、**zstd**，各格式可选编译。

**实现**：启用对应库时，上述 API 均为**真实压缩/解压**（zlib 用 `compress2`/`uncompress` 与 deflate/inflate 流；Brotli 用 `BrotliEncoderCompress`/`BrotliDecoderDecompress`；zstd 用 `ZSTD_compress`/`ZSTD_decompress`）。未启用时为占位，返回 -1。`tests/compress/main.x` 与 `run-compress.sh` 对 gzip、brotli 做压缩→解压往返校验。

## 目录结构

```
std/compress/
  compress_common.h   # 已删 → common.x（F-std-zero-c）
  mod.x              # 门面：import("std.compress") 聚合各子模块
  zlib/               # RFC 1950 zlib（deflate/inflate）
    libz.x      # F-04 v4：libz FFI
    mod.x            # import("std.compress.zlib")
  gzip/               # .gz 块 + 流式 API
    libz.x      # F-04 v5：libz FFI
    mod.x            # import("std.compress.gzip")
  brotli/             # .br 块 + 流式 API
    lib.x     # F-04 v6：libbrotli FFI
    mod.x            # import("std.compress.brotli")
  zstd/               # zstd 块 + 流式 API
    lib.x       # F-04 v7：libzstd FFI
    mod.x            # import("std.compress.zstd")
```

F-04 v7 起四格式均为 `.x`；**不再构建** `compress.o`。runtime 扫描用户 `.o` 的 marker/符号按需链 `-lz` / `-lzstd` / `-lbrotli*`。

## 格式说明

- **zlib**：2 字节头 + deflate 流 + 4 字节 Adler-32，常用于 HTTP 等协议。API：`deflate` / `inflate`（`std.compress.zlib`）。
- **gzip**：.gz 文件格式，含 gzip 头、deflate 流、8 字节尾。API：`gzip_compress` / `gzip_decompress`；流式见 `gzip_stream_*` 与统一门面 `compress_*`（STD-122，`std.compress.gzip`）。
- **Brotli（.br）**：压缩率通常优于 gzip（尤其文本），HTTP Content-Encoding: br。API：`brotli_compress` / `brotli_decompress`；流式见 `brotli_stream_*`（`std.compress.brotli`）。
- **zstd**：块压缩/解压 API：`zstd_compress` / `zstd_decompress`；流式见 `zstd_stream_*`（需 `-DSHUX_USE_ZSTD -lzstd`，`std.compress.zstd`）。
- **统一流**：`compress_init` / `compress_process` / `compress_end` 支持 gzip/brotli/zstd（STD-122/136，`std.compress`）。

## 平台与系统支持

- **不启用任何库**：所有系统均支持，对应 API 为占位（返回 -1），无额外依赖。
- **zlib / gzip**：Linux、macOS、BSD 上 zlib 多为系统自带或包管理可装（如 `libz-dev` / `zlib-devel`）；Windows 需自行提供 zlib（如 vcpkg、MSYS2 或自带头库）。
- **Brotli**：各系统均需额外安装（如 Linux `libbrotli-dev`、macOS `brew install brotli`、Windows vcpkg 等），非默认自带。
- **zstd**：需 libzstd（如 `brew install zstd`、Linux `libzstd-dev`）。

## 编译与链接

- **不定义**：对应格式为占位，返回 -1，无额外依赖。
- **zlib / gzip**：`libz.x` / `libz.x`（F-04 v4/v5）；链接 `-lz`（runtime 扫描 marker 或 deflate/inflate 符号）。
- **Brotli**：`lib.x`（F-04 v6）；链接 `-lbrotlienc -lbrotlidec`（runtime 扫描 marker）。
- **zstd**：`lib.x`（F-04 v7）；链接 `-lzstd`（runtime 扫描 marker）。
- **Makefile**：`compress-o-*` 目标保留为兼容 no-op；`STD_AND_PANIC_O` 不含 compress.o。

## 块 API

- **deflate(in, in_len, out, out_cap): i32** — 压缩为 zlib 格式，返回写入字节数，失败 -1。
- **inflate(in, in_len, out, out_cap): i32** — 解压 zlib 流，返回写入字节数，失败 -1。
- **gzip_compress(in, in_len, out, out_cap): i32** — 压缩为 gzip 格式（.gz），返回写入字节数，失败 -1。
- **gzip_decompress(in, in_len, out, out_cap): i32** — 解压 gzip 流，返回写入字节数，失败 -1。
- **brotli_compress(in, in_len, out, out_cap): i32** — 压缩为 Brotli 格式（.br），返回写入字节数，失败 -1。
- **brotli_decompress(in, in_len, out, out_cap): i32** — 解压 Brotli 流，返回写入字节数，失败 -1。
- **zstd_compress / zstd_decompress** — zstd 块压缩/解压，失败 -1。

## 流式 API（STD-039 / STD-122）

**低层 gzip 流**（直接操作外置 state 缓冲）：

- `gzip_stream_state_bytes()` — 状态缓冲最小字节数
- `gzip_stream_init_compress` / `gzip_stream_init_decompress`
- `gzip_stream_compress` / `gzip_stream_decompress` — 分块处理；压缩末块 `is_last≠0`
- `gzip_stream_end` — 释放底层 z_stream

**统一门面**（format + mode，与 `std.codec.StreamCodec` 风格对齐）：

- `format_gzip()` — 流格式常量（v1 仅 gzip）
- `mode_compress()` / `mode_decompress()`
- `compress_state_bytes()` / `compress_init` / `compress_process` / `compress_end`
- `StreamCompress` — `{ format, mode, state, state_cap }`

未链 zlib 时 init 失败；gate 烟测以 exit 0 skip（与 STD-039 一致）。
