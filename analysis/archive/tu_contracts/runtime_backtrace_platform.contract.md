# TU Contract: runtime_backtrace_platform

## 1. 当前权威源
- x 源：`src/asm/runtime_backtrace_platform.x`
- seed 源：`seeds/runtime_backtrace_platform.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 3 个 wrapper（2 IMPL + 1 DIRECT），seed/rest 提供 _impl + 14 个平台函数

## 3. 导出符号合同
- thin/.x 导出：4（doc_anchor + 3 wrapper）
- seed/rest 导出：16（2 _impl + 14 rest 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_backtrace_platform_x_doc_anchor`
- `backtrace_u8_hex2`（IMPL，调用 `_impl`）
- `backtrace_capture_and_check_gold_c`（IMPL，调用 `_impl`）
- `name_has_gold_anchor`（DIRECT，调用 `backtrace_name_has_gold_anchor_c`）

### 3.2 当前仍由 seed/rest 提供
- `backtrace_u8_hex2_impl`（单字节转两位十六进制）
- `backtrace_capture_and_check_gold_c_impl`（capture + check gold anchor）
- `backtrace_read_frame_addr_c`（读帧地址）
- `backtrace_write_frame_addr_c`（写帧地址）
- `backtrace_copy_sym_name_c`（复制符号名）
- `backtrace_format_hex_addr_c`（十六进制回退）
- `backtrace_name_has_gold_anchor_c`（检查 gold_anchor 子串）
- `backtrace_capture_c`（调用栈捕获）
- `backtrace_symbolicate_c`（符号化）
- `backtrace_gold_anchor_addr_c`（金样锚点地址）
- `backtrace_gold_anchor_c`（noinline 锚点函数）
- `backtrace_gold_anchor_smoke_enter_c`（烟测回调）
- `backtrace_symbolicate_smoke_c`（C 烟测）
- `backtrace_xplat_platform_name_c`（平台名）
- `backtrace_xplat_quality_c`（跨平台质量探测）
- `shux_crash_evidence_collect_c`（crash evidence 落盘）

## 4. ABI Manifest
- _impl 残余列表：`backtrace_u8_hex2_impl`, `backtrace_capture_and_check_gold_c_impl`
- thin+rest 宏边界：`SHUX_RUNTIME_BACKTRACE_PLATFORM_FROM_X`
- 内部调用更新：
  - `backtrace_format_hex_addr_c` 中 `backtrace_u8_hex2` → `backtrace_u8_hex2_impl`
  - `backtrace_gold_anchor_smoke_enter_c` 中 `backtrace_capture_and_check_gold_c` → `backtrace_capture_and_check_gold_c_impl`
  - `backtrace_xplat_quality_c` 中 `name_has_gold_anchor` → `backtrace_name_has_gold_anchor_c`（避免依赖 thin wrapper）

## 5. 验证状态
- prove_x_o：ok
- ld -r：ok（macOS merged 20 T + Ubuntu rest 16 T）
- smoke/probe：pending

## 6. 备注
- 混合模式：2 IMPL wrapper（调用 `_impl`）+ 1 DIRECT wrapper（调用外部 C 函数 `backtrace_name_has_gold_anchor_c`）
- `backtrace_xplat_quality_c` 原调用 thin wrapper `name_has_gold_anchor`，rest 模式下改为直接调用 `backtrace_name_has_gold_anchor_c`（rest 函数），避免 U 符号
- 依赖 `diag.h`（在 `include/` 目录），Ubuntu 编译需 `-Iinclude`
- 平台依赖：execinfo/dladdr（Linux/macOS）、DbgHelp（Windows）
