# Windows 平台限制与测试指南

> **文档目的**：记录 XLANG 项目在 Windows（MSYS2/MinGW）平台开发中遇到的所有平台限制、不支持特性、已知问题与修复、测试方法，避免后续开发时重复踩坑。
>
> **维护原则**：每次遇到新的 Windows 平台问题，必须在此文档追加记录，包含根因、修复方案、验证方法。
>
> **最后更新**：2026-07-20

---

## 1. Windows 平台不支持的特性（硬限制）

### 1.1 `__attribute__((weak))` 弱符号

**现象**：PE 格式不支持 weak 函数符号；GNU ld on MinGW 即使存在 weak def 也保留 undefined ref。

**根因**：PE weak externs 使用 `.weak` alias + default 机制，与 ELF/Mach-O 不同；MinGW ld 实现不完整。

**修复**：
- 所有 weak 函数在 stub 文件（`build_asm/seed_host/asm_full_link_stubs.c`）中变为**正常定义**（non-weak）
- 重复定义冲突用 `-Wl,--allow-multiple-definition`（`WIN_LDFLAGS` in Makefile）解决
- `gen_asm_full_link_stubs.pl` 自动检测 Windows perl（`$^O eq 'MSWin32' || 'msys' || 'cygwin'`）并 emit non-weak stubs

**代码示例**：
```c
// Linux/macOS (ELF/Mach-O):
__attribute__((weak)) int32_t platform_coff_write_coff_o_to_buf(void *a, void *b) { return -1; }

// Windows (PE): 必须是强符号
int32_t platform_coff_write_coff_o_to_buf(void *a, void *b) { return -1; }
```

**相关文件**：
- `compiler/scripts/gen_asm_full_link_stubs.pl` L26-28：检测 Windows perl，emit non-weak stubs
- `compiler/makefile`：`ASM_GLUE_DUP_LDFLAGS` 含 `--allow-multiple-definition`

### 1.2 Cygwin/MSYS weak 别名不可靠

**现象**：Cygwin/MSYS 下 weak alias 链接不稳定。

**修复**：bootstrap 链须用**强符号转发**（非 weak alias）。

### 1.3 Win32 `CreateFileA` 不识别 MSYS2 路径映射

**现象**：XLANG 编译器内部用 Win32 `CreateFileA` 打开文件，不识别 MSYS2 的 `/tmp/` 映射（`/tmp/` → `C:\Users\...\AppData\Local\Temp`），也不识别 `/c/...` POSIX 风格路径。报错：`IO001: cannot read file '/tmp/...'` 或 `ERROR_PATH_NOT_FOUND`。

**根因**：Win32 API 不经过 MSYS2 路径转换层；只接受 Windows 原生路径（`C:/xlang_tmp/...`）或相对路径。

**修复**：
- 传给 XLANG 编译器的文件路径必须用 Windows 原生格式（`C:/xlang_tmp/...`）
- 用 `cygpath -m` 强制 mixed-mode 路径转换
- 或用相对路径（从 CWD 解析）

**代码示例**：
```bash
# 错误（XLANG 收到 /tmp/... → CreateFileA 失败）:
SMOKE_SRC="/tmp/xlang_bootstrap_seed_smoke_$$.x"
./xlang.exe -c "$SMOKE_SRC"  # IO001

# 正确（cygpath -m 强制 Windows 路径）:
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    _TMP="$(cygpath -m "${TEMP:-/tmp}" 2>/dev/null || echo "${TEMP:-/tmp}")"
    ;;
  *) _TMP="/tmp" ;;
esac
SMOKE_SRC="${_TMP}/xlang_bootstrap_seed_smoke_$$.x"
./xlang.exe -c "$SMOKE_SRC"  # OK
```

### 1.4 MSYS2 环境变量继承路径转换

**现象**：MSYS2 bash 启动时自动转换 Windows 路径环境变量到 MSYS2 路径。即使设置 `MSYS_NO_PATHCONV=1`，**环境变量继承时的转换不受影响**。

**根因**：`MSYS_NO_PATHCONV` 只控制命令行参数转换，不控制环境变量继承。`TEMP=C:/xlang_tmp` 在子 bash 中可能变成 `TEMP=/c/xlang_tmp`。

**修复**：用 `cygpath -m` 在使用时强制转换回 Windows 路径。

### 1.5 Device Guard / Smart App Control 阻止未签名 exe

**现象**：新链接的 `xlang.exe`（3.2MB 复杂 PE）被 Smart App Control (SAC) 阻止执行：
```
'C:\...\xlang.exe' 已被组织的 Device Guard 阻止
bash: ./xlang.exe: Permission denied
```

**根因**：
- Windows 11 启用 SAC + HVCI (Hypervisor-Protected Code Integrity)
- SAC 基于云信誉 + 启发式检测，新链接的复杂 exe（含 JIT/codegen/汇编器）触发启发式
- 未签名 + 无云信誉 → 阻止
- 简单 hello.exe（64216 bytes）能通过，xlang.exe（3.2MB）不能

**修复**：用 self-signed cert 签名 exe（一次性配置 + 每次链接后签名）：
```powershell
# 1. 创建 cert（一次性，需管理员）
New-SelfSignedCertificate -Type CodeSigningCert -Subject 'CN=XlangDevCert' `
  -CertStoreLocation 'Cert:\LocalMachine\My' `
  -KeyUsage DigitalSignature `
  -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3','2.5.29.19={text}')

# 2. 添加到 Trusted Root + TrustedPublisher（一次性）
$cert = Get-Item 'Cert:\LocalMachine\My\<THUMBPRINT>'
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root','LocalMachine')
$store.Open('ReadWrite'); $store.Add($cert); $store.Close()
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher','LocalMachine')
$store.Open('ReadWrite'); $store.Add($cert); $store.Close()

# 3. 签名 exe（每次重新链接后）
Set-AuthenticodeSignature -FilePath 'C:\...\xlang.exe' -Certificate $cert
```

**注意**：SAC 路径缓存可能让重新链接后未签名的 exe 也能执行（短期），但长期稳定需重新签名。

### 1.6 MinGW gcc 自动给 `-o` 目标加 `.exe` 后缀

**现象**：`gcc -o xlang_bootstrap_smoke_out` 实际生成 `xlang_bootstrap_smoke_out.exe`，导致 `[ -x "$SMOKE_OUT" ]` 失败。

**修复**：Windows 上给 `-o` 目标加 `.exe` 后缀：
```bash
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) SMOKE_OUT="${SMOKE_OUT}.exe" ;;
esac
```

### 1.7 Windows 无 `cc` 命令

**现象**：Windows MSYS2/MinGW 只有 `gcc`，无 `cc` 别名。脚本默认 `CC=cc` 会报 `cc: command not found`。

**修复**：
- 设置 `CC=gcc` 环境变量
- 脚本中用 `CC="${G05_CC:-${CC:-cc}}"` 优先用环境变量

### 1.8 Windows std handle 常量是负数

**现象**：Win32 API 中 `STD_INPUT_HANDLE=-10`，`STD_OUTPUT_HANDLE=-11`，`STD_ERROR_HANDLE=-12`，都是负数。

**陷阱**：用 `if (std_id < 0)` 检查错误会误判所有有效 handle 为错误。

**修复**：用 `if (std_id == -1)` 检查错误（`-1` 是 `win32_std_handle_id_for_fd` 的错误返回值，不是有效的 Windows std handle 常量）。

```x
// std/sys/win32.x
let std_id: i32 = win32_std_handle_id_for_fd(fd);
// Why: Windows std handle constants (-10, -11, -12) are all negative.
//      win32_std_handle_id_for_fd returns -1 for unsupported fd.
if (std_id == -1) {  // NOT: if (std_id < 0)
  return -1;
}
```

### 1.9 Windows MSYS 默认主线程栈 ~2MiB

**现象**：MSYS 默认主线程栈 ~2MiB（`ulimit -s = 2032`），深递归（parse_into/typeck_x_ast/codegen_x_ast）会栈溢出（exit=1）。`driver_bump_stack_limit` 在 Windows 上是 no-op（`#ifndef _WIN32`）。

**修复**：PE `--stack` 设置虚拟地址空间 reserve（OS pager 按需 commit）：
```makefile
# compiler/makefile L1999
MAIN_LINK_FLAGS = -Wl,--stack,268435456  # 256MiB
```

### 1.10 TEMP 路径必须用短路径

**现象**：`xlang-c.exe` 内部调用 gcc 时，如果 TEMP 路径含空格或过长，路径会被截断。

**修复**：设置 `TEMP=C:/xlang_tmp TMP=C:/xlang_tmp`（短路径，无空格）。

### 1.11 Windows rename 限制

**现象**：Windows 不允许 rename 被 `fdopen`/`fopen` 持有的文件（POSIX 允许）。报错 `BLD001 sharing violation`。

**修复**：rename 前**先 close fd**：
```c
int fd = mkstemp(template);
FILE *f = fdopen(fd, "w");
// ... write ...
fclose(f);  // closes fd too
rename(template, final_path);  // OK now
```

### 1.12 `system("make ...")` 调用产生"系统找不到指定的路径"

**现象**：XLANG seed 代码中 `system("make -C ... compiler")` 调用在 Windows 上产生"系统找不到指定的路径"（非致命，8 次）。

**根因**：`system()` 在 Windows 上走 cmd.exe，cmd.exe 的 make 路径解析与 bash 不同。

**状态**：非致命（有 fallback），未修复。

### 1.13 `cannot find -lc` (asm-only link)

**现象**：`ld.exe: cannot find -lc: No such file or directory` — asm-only link 失败。

**状态**：非致命（make 有 fallback：`bootstrap-driver-bstrict: WARN build_xlang_asm intermediate failed; seed ./xlang OK`）。

---

## 2. 已知问题与修复记录

### 2.1 已修复问题（按 commit 顺序）

| Commit | 问题 | 修复 |
|--------|------|------|
| `70dc9929` | `tmp_c` 缓冲区 32 字节不足，rename BLD001 | 扩大到 256 字节 |
| `dea2fd22` | mkstemp fd 未 close 就 rename，BLD001 sharing violation | rename 前 close fd |
| `a5af07e0` | POSIX-only preamble includes 未 gate `_WIN32` | 加 `#ifndef _WIN32` |
| `fec809c9` | POSIX-only preamble extern + inline 未 gate `_WIN32` | 加 `#ifndef _WIN32` |
| `d3230412` | smoke SMOKE_OUT 无 .exe 后缀，MinGW gcc 自动加 | Windows 上加 .exe 后缀 |
| `683332a1` | `win32_write` std_id `< 0` 误判负数 handle | 改为 `== -1` |
| `5bcc62ac` | win32_read_file 硬编码 `/tmp/`，CreateFileA 不识别 | 改用相对路径 |
| `0ecf72d8` | Device Guard 间歇阻止 `/tmp/` 下 .exe | gate 脚本 OUT 用 `${TEMP:-/tmp}` |
| `30a5d463` | g05 脚本 `cc: command not found` | `CC="${G05_CC:-${CC:-cc}}"` |
| `0d88f49a` | smoke SMOKE_SRC 用 `/tmp/`，XLANG IO001 | Windows 上用 `${TEMP:-/tmp}` |
| `b06a1a40` | MSYS2 继承 TEMP 转成 `/c/...`，XLANG IO001 | 用 `cygpath -m` 强制 Windows 路径 |
| `599b0f38` | gate 正则误匹配 info 行 "no cc -c pipeline_gen.c" | 排除 info 行 |

### 2.2 手动一次性配置（非代码修复）

- **创建 XlangDevCert 代码签名证书** + 添加到 Trusted Root / TrustedPublisher
- **签名 xlang.exe**（每次重新链接后需重新签名，或依赖 SAC 路径缓存）

### 2.3 未解决问题

#### 2.3.1 `g05_relink_env.sh` 不支持 MINGW host

**现象**：`g05_relink_env: unsupported host MINGW64_NT-10.0-26200/x86_64 (use Makefile cold path)`

**根因**：`compiler/scripts/g05_relink_env.sh` L30-73 只处理 Darwin 和 Linux，MINGW 落到 `*` 分支报错。

**影响**：`relink-xlang` 失败，`refresh-xlang-asm-gate` 失败，`bootstrap-driver-bstrict` make 失败。但 `xlang_asm` 在 `build_xlang_asm.sh` 阶段已构建，gate 脚本仍能继续。

**待修复**：添加 MINGW 分支：
```bash
MINGW*|MSYS*|CYGWIN*)
  _ASM_GLUE_DUP_LDFLAGS="-Wl,--allow-multiple-definition"
  _MAIN_LINK_O="src/asm/crt0_mingw.o"
  _MAIN_LINK_FLAGS="-Wl,--stack,268435456"
  _PIPELINE_LINK_O="pipeline_x.o"
  _USER_ASM_LINK="build_asm/seed_host/asm_backend_partial.o build_asm/seed_host/asm_full_link_stubs.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/asm/backend_enc_dispatch.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o parser_asm_thin_glue.o src/asm/parser_asm_parse_expr_link.o"
  ;;
```

#### 2.3.2 `asm_full_link_stubs` 增量构建时间戳竞态

**现象**：`user_asm_seed_bridge.o` 重新编译引入新 U 符号（如 `platform_coff_write_coff_o_to_buf`），但 `asm_full_link_stubs.o` 时间戳更新，make 不重新生成 stubs.c，导致链接 undefined reference。

**根因**：makefile L1503 依赖 `$(USER_ASM_SEED_OBJS)`（.o 文件），但 stubs.o 可能因其他依赖触发重新编译而时间戳更新，掩盖了 .o 内容变化。

**临时修复**：删除 `build_asm/seed_host/asm_full_link_stubs.{c,o}` 强制重新生成。

**待修复**：让 stubs 依赖 `.x` 源文件（而非 .o），或用 `.PHONY` 强制每次重新生成。

#### 2.3.3 `win32-read-file-gate` 间歇 Permission denied

**现象**：`C:/xlang_tmp/xlang_win32_read_file.1825.exe: Permission denied`（exit 126）

**根因**：Device Guard 间歇阻止 `C:/xlang_tmp/` 下新编译的 .exe（即使签名 cert 已配置）。

**状态**：间歇性，重跑可能通过。需调查是否需要重新签名 gate 编译的 .exe。

#### 2.3.4 `cannot find -lc` (asm-only link)

见 1.13。

#### 2.3.5 `system("make ...")` 调用"系统找不到指定的路径"

见 1.12。

---

## 3. Windows 测试方法

### 3.1 环境变量组合（必须）

```bash
export TEMP=C:/xlang_tmp
export TMP=C:/xlang_tmp
export CC=gcc
export XLANG_LEGACY_C_FRONTEND=1
export SHELL=/usr/bin/bash
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"
```

**说明**：
- `TEMP/TMP=C:/xlang_tmp`：短路径，避免 gcc 调用时路径截断
- `CC=gcc`：Windows 无 cc
- `XLANG_LEGACY_C_FRONTEND=1`：Windows 必须用 C 前端模式构建 xlang-c.exe（xlang.exe 是 stub）
- `SHELL=/usr/bin/bash`：避免 STATUS_DLL_INIT_FAILED (0xC0000142)
- `MSYS_NO_PATHCONV=1`：阻止 MSYS2 自动转换命令行参数路径
- `MSYS2_ARG_CONV_EXCL="*"`：排除所有参数的路径转换

### 3.2 SSH 连接

```bash
# SSH 默认进入 cmd.exe，需显式调用 bash：
ssh windows-server "\"C:/Program Files/Git/bin/bash.exe\" -lc 'command'"

# 复杂脚本用 base64 / scp 传递（避免引号冲突）：
scp script.sh windows-server:"C:/xlang_tmp/script.sh"
ssh windows-server "\"C:/Program Files/Git/bin/bash.exe\" -lc \"bash /c/xlang_tmp/script.sh\""
```

### 3.3 完整 gate 测试

```bash
# 仓库根目录
XLANG_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh
```

**gate 测试流程**：
1. `make bootstrap-driver-bstrict`（构建 xlang + xlang_asm）
2. smoke return-value 42（xlang_asm 编译 main.x → 执行 → exit=42）
3. `run-win32-write-gate.sh`（std.sys os_write_stdout via WriteFile）
4. `run-win32-read-file-gate.sh`（std.sys os_read_file_into via ReadFile）
5. C-03 检查（B-strict 模式不应 cc -c pipeline_gen.c）

### 3.4 签名 xlang.exe（每次重新链接后）

```powershell
# 查看 cert thumbprint
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq 'CN=XlangDevCert' } | Select-Object Thumbprint

# 签名
$cert = Get-Item 'Cert:\LocalMachine\My\<THUMBPRINT>'
Set-AuthenticodeSignature -FilePath 'C:\Users\shuliangfu\worker\xlang\x-lang\compiler\xlang.exe' -Certificate $cert

# 验证签名
Get-AuthenticodeSignature 'C:\...\xlang.exe' | Select-Object Status, StatusMessage
```

### 3.5 路径处理最佳实践

```bash
# 传给 XLANG 编译器的路径必须用 Windows 原生格式
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*)
    _TMP="$(cygpath -m "${TEMP:-/tmp}" 2>/dev/null || echo "${TEMP:-/tmp}")"
    ;;
  *) _TMP="/tmp" ;;
esac

# bash 写入 Windows 路径 OK
printf '%s\n' '...' > "${_TMP}/file.x"

# XLANG 读取 Windows 路径 OK
./xlang.exe -c "${_TMP}/file.x"
```

### 3.6 冷启动测试（L4）

```bash
# 删除所有 .o 和二进制
cd /c/Users/shuliangfu/worker/xlang/x-lang/compiler
rm -f *.o src/**/*.o build_asm/**/*.o xlang xlang.exe xlang-c xlang-c.exe xlang_asm xlang_asm.exe

# 重新构建
make bootstrap-driver-seed XLANG_LEGACY_C_FRONTEND=1
make bootstrap-driver-bstrict XLANG_LEGACY_C_FRONTEND=1

# 签名（如果 SAC 阻止）
powershell.exe -NoProfile -Command "Set-AuthenticodeSignature -FilePath 'C:\...\xlang.exe' -Certificate (Get-Item 'Cert:\LocalMachine\My\<THUMBPRINT>')"

# 跑 gate
XLANG_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh
```

### 3.7 调试技巧

```bash
# 查看 Device Guard / SAC 阻止原因
powershell.exe -NoProfile -Command "Get-WinEvent -LogName 'Microsoft-Windows-CodeIntegrity/Operational' -MaxEvents 10 | Where-Object { $_.Id -eq 3077 -or $_.Id -eq 3118 } | Select-Object TimeCreated, Message | Format-List"

# 查看 Defender 实时保护状态
powershell.exe -NoProfile -Command "Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled, AntivirusEnabled"

# 查看 SAC 策略
powershell.exe -NoProfile -Command "Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard | Select-Object SecurityServicesConfigured, SecurityServicesRunning, VirtualizationBasedSecurityStatus"

# 保留 XLANG 生成的 C 文件
XLANG_KEEP_C=1 ./xlang.exe -backend c -o out.exe main.x
# 查看生成的 C：out.c 或 /c/xlang_tmp/xlang_*.c
```

---

## 4. 写代码时的注意事项（防踩坑清单）

### 4.1 .x 源文件

- **注释必须英文**（2026-07-18 起）
- **`#[no_mangle]` 紧贴函数定义**：属性直接位于 `export function` / `function` 上方，中间不得插入 docblock
- **`extern function` 默认 X ABI**；C ABI 必须显式 `extern "C"` 并在调用时用 `unsafe`
- **Windows 文件路径**：传给 XLANG 编译器的路径必须用 Windows 原生格式（`C:/...`）或相对路径，**禁止**用 `/tmp/` 或 `/c/...`

### 4.2 C seed 文件

- **`__attribute__((weak))` 在 Windows 不生效**：stub 文件必须提供强符号定义
- **`#include <...>` POSIX-only 头文件**：用 `#ifndef _WIN32` gate
- **`extern` POSIX-only 声明**：用 `#ifndef _WIN32` gate
- **rename 前 close fd**：Windows 不允许 rename 被持有的文件
- **`system("make ...")` 调用**：Windows 上可能失败（非致命），需有 fallback

### 4.3 Makefile / 脚本

- **`CC` 默认 `cc` 在 Windows 失败**：用 `CC="${G05_CC:-${CC:-cc}}"` 优先环境变量
- **`-o` 目标在 Windows 自动加 `.exe`**：检查和执行时加 `.exe` 后缀
- **路径用 `cygpath -m` 强制 Windows 格式**：避免 MSYS2 路径转换问题
- **gate 脚本 OUT 路径用 `${TEMP:-/tmp}`**：避免 Device Guard 阻止 `/tmp/` 下 .exe
- **正则匹配排除 info 行**：避免误报（如 "no cc -c pipeline_gen.c" 被误匹配）

### 4.4 新增平台分支

- **`PLATFORM: SHARED` 改动需双端验证**：macOS + Ubuntu（谈自举前双端冷编译 + 全量 `run-all-bstrict`）
- **`PLATFORM: WINDOWS | MSYS | MINGW` 必须标注**：平台分支、ABI、链接差异、seed pin、syscall 差异
- **跨平台假设禁止**：禁止无注释的跨平台假设（修 A 打坏 B）

---

## 5. 平台对比速查表

| 特性 | Linux (ELF) | macOS (Mach-O) | Windows (PE) |
|------|-------------|-----------------|--------------|
| weak 符号 | ✅ 支持 | ✅ 支持（weak_import） | ❌ 不支持（用强符号 + `--allow-multiple-definition`） |
| 路径 `/tmp/` | ✅ | ✅ | ❌（用 `C:/xlang_tmp/`） |
| `cc` 命令 | ✅ | ✅ | ❌（用 `gcc`） |
| 默认栈大小 | 8MiB（`ulimit -s`） | 8MiB | 2MiB（需 `--stack,256MiB`） |
| rename 持有文件 | ✅ | ✅ | ❌（需先 close fd） |
| exe 后缀 | 无 | 无 | `.exe`（gcc 自动加） |
| 代码签名 | 可选 | 可选（codesign） | 必须（SAC 阻止未签名） |
| `system()` 调用 | 直接 | 直接 | 走 cmd.exe（路径解析差异） |
| XLANG 前端 | X pipeline | X pipeline | LEGACY_C_FRONTEND=1 |
| `xlang.exe` | N/A | N/A | stub（实际用 xlang-c.exe） |
| `-backend` 参数 | ✅ | ✅ | ❌（xlang-c 不支持） |

---

## 6. 故障排查流程

### 6.1 `Permission denied` 执行 .exe

1. **检查 SAC 阻止**：
   ```powershell
   Get-WinEvent -LogName 'Microsoft-Windows-CodeIntegrity/Operational' -MaxEvents 5 | Where-Object { $_.Id -eq 3077 } | Format-List
   ```
2. **签名 exe**：见 3.4
3. **复制到 `${TEMP}` 重试**：Device Guard 可能对特定路径更严格

### 6.2 `IO001: cannot read file`

1. **检查路径格式**：必须是 Windows 原生（`C:/...`）或相对路径
2. **用 `cygpath -m` 转换**：`_TMP="$(cygpath -m "${TEMP:-/tmp}")"`
3. **检查文件是否存在**：`ls -la "$path"`

### 6.3 `undefined reference to platform_*`

1. **检查 stubs.c 是否包含该符号**：`grep platform_ build_asm/seed_host/asm_full_link_stubs.c`
2. **强制重新生成 stubs**：`rm -f build_asm/seed_host/asm_full_link_stubs.{c,o}` 然后 make
3. **检查 `gen_asm_full_link_stubs.pl` 正则**：是否匹配该符号

### 6.4 `cc: command not found`

1. **设置 `CC=gcc`**：`export CC=gcc`
2. **检查脚本默认值**：是否硬编码 `CC=cc`

### 6.5 链接失败 `cannot find -lc`

- **非致命**：asm-only link 失败，make 有 fallback
- **检查是否有 fallback 日志**：`WARN build_xlang_asm intermediate failed; seed ./xlang OK`

---

## 7. 维护日志

- **2026-07-20**：初版，汇总 12 个已修复问题 + 5 个未解决问题 + 完整测试方法
- **后续**：每次遇到新 Windows 问题，必须在此文档追加记录（根因 + 修复方案 + 验证方法）