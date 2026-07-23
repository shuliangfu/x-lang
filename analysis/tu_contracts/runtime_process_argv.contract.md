# TU Contract: runtime_process_argv

## 1. 当前权威源
- x 源：`src/asm/runtime_process_argv.x`（G-02f-106 薄门闩）
- seed 源：`seeds/runtime_process_argv.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 1 个 IMPL wrapper，seed/rest 提供 1 个 _impl + 4 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：2（1 IMPL wrapper + 1 doc_anchor）
- seed/rest 导出：5（1 _impl + 4 rest 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- IMPL wrapper（1）：`xlang_process_argv_bind_from_crt`

### 3.2 当前仍由 seed/rest 提供
- _impl（1）：`xlang_process_argv_bind_from_crt_impl`（含 `#if defined(__APPLE__)`/`#elif defined(__linux__)` 平台条件）
- rest（4）：`process_xlang_argc_get`、`process_xlang_argv_get`、`process_args_count_c`（weak）、`process_arg_c`（weak）

## 4. ABI Manifest
- _impl 残余列表：1 个
- DIRECT 符号列表：无
- thin+rest 宏边界：`XLANG_RUNTIME_PROCESS_ARGV_FROM_X`
- 前向声明：1 个（`xlang_process_argv_bind_from_crt`）

## 5. 验证状态
- prove_x_o：ok
- ld -r：ok（macOS merged 7 T + 2 U macOS CRT；Ubuntu merged 7 T/W U=0）
- smoke/probe：pending

## 6. 备注
- IMPL 模式切割：1 个 wrapper 由 .x 提供，调用 seed 中的 _impl
- 签名修复：.x 中 `xlang_process_argv_bind_from_crt` 原为 `(argc: i32, argv: *u8)`，seed 为 `(void)`，已修复 .x 为无参数（_impl 从 CRT 读取 argc/argv，不需调用方传入）
- 平台条件：_impl 含 `#if defined(__APPLE__)`（_NSGetArgc/_NSGetArgv）和 `#elif defined(__linux__)`（/proc/self/cmdline），是语言限制
- weak 函数：`process_args_count_c`/`process_arg_c` 为 weak fallback（供 minimal 链，process.x 强符号覆盖）
- `xlang_process_argv_ctor_bind`（constructor）调用 thin wrapper，需前向声明
