# 阶段 B 完成标准 v1（NEXT §5）

> **目标**：语言 `#[cfg]`/`#[repr(C)]` + `std.sys` 斩断 C 脐带（读/写/文件/mmap/syscall），**不阻塞**阶段 C/F 的去 C 与 `asm { }` 语法大项。

## 完成定义（v1 = ✅）

| ID | v1 完成标准 | 验收 gate |
|----|-------------|-----------|
| B-01 | `#[cfg(...)]` lex + import 剪枝 + `-target` 烟测 | `run-cfg-attribute-skip-gate.sh` |
| B-02 | `-target` triple 与 cfg 联动 | `run-cfg-target-triple-gate.sh` |
| B-03 | `#[repr(C)]` lex + typeck layout + asm smoke | `run-repr-c-*-gate.sh` |
| B-04 | freestanding **extern→`.s`** syscall 等价内联 asm | `run-b04-freestanding-syscall-gate.sh` |
| B-05 | Codegen MVP 清单 = asm-73 子集 | `run-b05-codegen-mvp-gate.sh` |
| B-06 | ast_pool 边界 + .sx pipeline 可依赖 | `run-b06-ast-pool-gate.sh` |
| B-10～13 | std.sys v0～v3 | `run-std-sys-gate.sh` |
| B-14 | Linux freestanding read/write/open/mmap/openat | `run-linux-*-gate.sh` |
| B-15 | std.sys 层 io_uring **探测门面**（实现在 std/io） | `run-b15-io-uring-sys-gate.sh` |
| B-16 | macOS write/mmap/read | `run-macos-*` + `run-sys-read-file` |
| B-17 | win32 WriteFile/ReadFile/ExitProcess | `run-win32-*` + `run-b17-exit-process-gate.sh` |
| B-18 | win32 网络 **探测门面**（WSA；IOCP 在 std.io） | `run-b18-win32-net-gate.sh` |
| B-19 | mod.sx 统一 os_write/read/mmap/exit | `run-b19-sys-mod-facade-gate.sh` |
| B-20 | generated_c 扫描无 fopen；os_read_file_into | `run-b20-*` + `run-sys-read-file-gate.sh` |
| B-30 | runtime/stubs OS 调用盘点 TSV | `run-b30-stubs-runtime-os-inventory-gate.sh` |
| B-31 | freestanding_io_x86_64.s 极薄 `.s` 登记 | `run-b31-freestanding-io-gate.sh` |
| B-32 | bootstrap **track-only**：审计 `cc -c std/*.c` | `run-b32-no-cc-std-gate.sh` |

## 延后（不阻塞 B v1 ✅）

- **B-04 语法层 `asm { }`** → 阶段 C/E；v1 用 extern→`.s` 等价。
- **B-32 硬禁止 cc 编 std** → 阶段 F（F-06/F-07）；v1 仅 track gate。
- **B-18 完整 IOCP async** → std.io 已有；std/sys 仅 WSA 探测。
