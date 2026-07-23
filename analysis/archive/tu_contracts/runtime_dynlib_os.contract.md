# TU Contract: runtime_dynlib_os

## 1. 当前权威源
- x 源：`src/asm/runtime_dynlib_os.x`
- seed 源：`seeds/runtime_dynlib_os.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 2 个 wrapper（1 IMPL + 1 DIRECT），seed/rest 提供 _impl + 5 个平台函数

## 3. 导出符号合同
- thin/.x 导出：3（doc_anchor + 2 wrapper）
- seed/rest 导出：5（rest 函数，全平台）
- only_x：3（doc_anchor + 2 Windows-only thin wrapper）

### 3.1 必须由 thin/.x 提供
- `runtime_dynlib_os_x_doc_anchor`
- `dynlib_win_load_library_w_utf8`（IMPL，调用 `_impl`，Windows only）
- `dynlib_win_normalize_path`（DIRECT，直接实现，Windows only）

### 3.2 当前仍由 seed/rest 提供
- `dynlib_win_load_library_w_utf8_impl`（Windows only，UTF-8 路径转宽字符 + LoadLibraryW）
- `dynlib_os_copy_last_error_c`（全平台，dlerror/GetLastError）
- `dynlib_os_open_c`（全平台，dlopen/LoadLibrary）
- `dynlib_os_sym_c`（全平台，dlsym/GetProcAddress）
- `dynlib_os_close_c`（全平台，dlclose/FreeLibrary）
- `dynlib_os_win_path_smoke_c`（全平台，Windows 路径烟测）

## 4. ABI Manifest
- _impl 残余列表：`dynlib_win_load_library_w_utf8_impl`（Windows only）
- thin+rest 宏边界：`XLANG_RUNTIME_DYNLIB_OS_FROM_X`
- 内部调用更新：
  - `dynlib_os_open_c` 中 `dynlib_win_load_library_w_utf8` → `_impl`
  - `dynlib_os_win_path_smoke_c` 中 `dynlib_win_load_library_w_utf8` → `_impl`
- `dynlib_win_load_library_w_utf8_impl` 调用 `dynlib_win_normalize_path`（thin，Windows 块内，rest 模式下由 thin 提供）

## 5. 验证状态
- prove_x_o：ok
- ld -r：ok（macOS merged 8 T + Ubuntu rest 5 T）
- smoke/probe：pending

## 6. 备注
- 混合模式：1 IMPL wrapper（`dynlib_win_load_library_w_utf8` 调用 `_impl`）+ 1 DIRECT wrapper（`dynlib_win_normalize_path` 直接实现）
- thin 函数和 `_impl` 仅 Windows 有定义；.x thin wrapper 在非 Windows 平台引用 `_impl`（U 符号），但不被引用故不影响链接
- `dynlib_win_normalize_path` 返回类型差异：seed 用 `size_t`，.x 用 `i32`（语义等价，ABI 兼容）
- Linux 链接需 `-ldl`（dlopen/dlsym/dlclose/dlerror）
