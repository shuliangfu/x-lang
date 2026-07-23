# TU Contract: runtime_string_fast

## 1. 当前权威源
- x 源：`src/asm/runtime_string_fast.x`
- seed 源：`seeds/runtime_string_fast.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 4 个 pure helpers，seed/rest 提供 4 个 libc 包装函数

## 3. 导出符号合同
- thin/.x 导出：5（doc_anchor + 4 thin 函数）
- seed/rest 导出：4（rest 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_string_fast_x_doc_anchor`
- `xlang_string_memrchr_c`
- `xlang_string_memchr_c`
- `xlang_string_portable_memmem_c`
- `xlang_string_memmem_c`

### 3.2 当前仍由 seed/rest 提供
- `xlang_string_ptr_at_c`（ptr + off，null 检查）
- `xlang_string_memcmp_c`（libc memcmp 包装）
- `xlang_string_memcmp_at_c`（带偏移 memcmp）
- `xlang_string_copy_c`（libc memcpy 包装）

## 4. ABI Manifest
- _impl 残余列表：无（DIRECT 模式，.x 直接实现）
- thin+rest 宏边界：`XLANG_RUNTIME_STRING_FAST_FROM_X`
- rest 函数不调用 thin 函数，无需 extern 声明

## 5. 验证状态
- prove_x_o：ok
- ld -r：ok（macOS merged 9 T + Ubuntu rest 4 T）
- smoke/probe：pending

## 6. 备注
- DIRECT 模式：.x 直接实现 4 个 pure helpers（memrchr/memchr/portable_memmem/memmem）
- 实现差异：.x 用手写字节循环（无 libc 依赖）；seed 用 libc memchr/memcmp/memcpy
- thin 函数内部调用链：`xlang_string_memmem_c` → `xlang_string_memchr_c` + `xlang_string_portable_memmem_c`（thin 调 thin，OK）
- rest 函数（ptr_at/memcmp/memcmp_at/copy）不调用 thin 函数，rest 模式下自包含
