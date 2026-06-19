# run-hello 整体分析与最小修复方案

**整项目影响与依赖**（改哪里会牵涉哪里、修改前必查清单）见 [整项目影响与依赖分析](整项目影响与依赖分析.md)。

## 一、目标与现状

- **目标**：`./compiler/shux examples/hello.sx -o /tmp/shux_hello` 能编译链接并运行，生成 C 中含 `main`，且不与 std.io 的 extern 冲突。
- **现状**：链接报 `Undefined symbols: _main`；生成的 C 里没有 `main`，因为 **entry 的 module.num_funcs 在 pipeline 内解析后仍为 0**。

---

## 二、因果链（只保留必要环节）

```
run-hello 要成功
  → 生成的 C 里必须有 main
  → 入口模块在 codegen 时必须有 num_funcs ≥ 1 且 main_func_index 有效
  → 入口必须在 pipeline 内用 .sx 解析（否则 C 的 AST 与 .sx 的 Module 布局不一致，.sx 读到的 num_funcs 也是 0）
  → 调用 parse_into_with_init_buf(arena, module, source_data, source_len)
  → 内部是 parser.parse_into_buf(arena, module, data, len)
```

**说明**：bootstrap 时 `shux-c ... pipeline.sx -E > pipeline_gen.c` 会把 **parser 等 import 一起展开进 pipeline_gen.c**，故实际跑的是 **parser.sx 的 parse_into_buf**（由 shux-c 的 codegen 生成），不是 parser.c。

**parser.parse_into_buf 对 hello.sx 的行为：**

- hello.sx 是 `function main() { let msg = ...; return if (n>=0) 0 else 1; }`，不是单表达式 return。
- 简单路径 `parse_one_function_buf` 失败 → 走 **fallback**：
  - `slice_for_impl = parser_slice_from_buf(data, len)` 得到 `[]u8`
  - 再 `parse_one_function_impl(..., slice_for_impl)` 解析整段 body。
- **问题点**：`let slice_for_impl: []u8 = parser_slice_from_buf(data, len)` 在 **codegen 时** 被错误处理——extern 返回的 slice 被当成别的类型（如 int），生成的 C 里对 slice 的初始化错误（例如 `struct ... = (uint8_t[]){ }`）→ `parse_one_function_impl` 拿到的 slice 无效 → 解析失败 → **不往 module 里加 main** → num_funcs 一直为 0。

**已确认**：在 driver_run_compiler_full 中，C 侧先调 parser_parse_into 再进 pipeline；诊断显示「after C parse num_funcs=0」，即 **C 解析器对 hello.sx 同样未把 main 加入 module**（与 .sx 解析器同源、同 bug）。因此「复用 C 解析、entry_already_parsed=1」无法解决 run-hello，必须修解析/codegen 根因。

所以：

- **根因**：只有一处——**codegen 对「extern 返回 []u8（或等价 slice 类型）」的赋值生成错了**。
- 其它都是后果：entry 被解析了、source 也传对了，但 parser 的 fallback 因 slice 错误而没把 main 写进 module。

---

## 三、已做且应保留的修改（不要动）

| 修改 | 作用 | 位置 |
|------|------|------|
| 入口在 pipeline 内解析 | 保证 module 布局一致，避免 C 解析 + .sx 使用混用 | runtime: memset(arena,0); memset(module,0); 不设 entry_already_parsed=1 |
| parse_into_with_init_buf(data, len) | 用 (data,len) 进 parser，避免 C 与 .sx 的 []u8 布局问题 | pipeline.sx |
| codegen 跳过 is_extern 函数 | 不生成 io_read(void) 等定义，避免与 preamble 的 extern 冲突 | codegen.sx: if (f.is_extern != 0) continue |

这三项**不要回退**，也不要再围绕它们加新分支。

**run-stdlib-import 修复（C + pipeline 双路径）：**
- runtime：单文件 preamble（write_io_net_abi_inline）中输出 `struct core_option_Option_i32`、`struct core_result_Result_i32` 及 `core_types_placeholder` 的 extern + 弱定义，避免 pipeline 生成 C 时出现不完整类型与未声明符号。
- codegen：跨模块调用仅按被调函数形参个数输出实参（`n_emit = min(num_args, num_params)`），避免 `placeholder()` 被错误产出 `core_types_placeholder(0,0)`。
- codegen + runtime：`codegen_set_preamble_has_core_option_result(1)` 在 pipeline 生成前置位，`codegen_library_module_to_c` 中跳过 Option_i32/Result_i32 的 struct 输出，避免与 preamble 重定义；C 路径下置 0，由 codegen 正常输出。

---

## 四、唯一剩余问题与最小修复

- **唯一问题**：codegen 在生成  
  `let x: []u8 = parser_slice_from_buf(data, len);`  
  时，没有按「extern 返回 struct shux_slice_uint8_t」来生成 C，导致赋值错误、parser fallback 失败、entry num_funcs=0、没有 main。

- **最小修复（已做）**：
1. **codegen.c**：let 声明处对 extern 返回 slice 的兜底（见上）。
2. **parser.sx**：`return if ( cond ) { int } else { int }` 解析中，当条件非 true/false 走 `skip_balanced_parens` 后，下一 token 已是 `{` 不再消费 `)`，改为「仅当 r.tok == TOKEN_RPAREN 时才消费 )」，避免 hello.sx 的 `return if (n>=0){0}else{1}` 失败。
3. **parser.sx**：**parse_into_buf** 在从 onefunc 加入函数时，与 parse_into 一致：先分配 block、用 res 填充 const/let（含 **let 名称**）、loops/for、stmt_order、final_expr_ref，再 `ast_arena_block_set`，并设置 `f.body_ref = block_ref`、`f.body_expr_ref = 0`，保证 codegen 使用带 let 名的 block。

**当前状态（已通过 run-hello）**：以下修复已生效：

- **pipeline.sx**：emit 循环中当 `ctx.dep_paths[j] == NULL` 时（.sx 驱动路径下自行加载 deps 未填 dep_paths），用 `get_module_import_path(module, j, ...)` 从 entry 的 j 号 import 补全到 `ctx.path_buf` 并设 `ctx.dep_paths[j]`，保证 codegen 能生成正确 C 前缀（如 std_io_）。
- **runtime.c**：在 `write_io_net_abi_inline` 中增加 `std_io_print_str` 的弱符号定义（`__attribute__((weak))`），当 pipeline 未生成该定义时由内联 ABI 提供，保证 `shux -sx examples/hello.sx -o /tmp/shux_hello` 链接通过；若 pipeline 日后生成定义则强符号优先。
- **pipeline.sx**：codegen 前 emit 各 dep 的循环已改为 `while (j < ctx.ndep)`（不再用 `get_ndep()`），.sx 驱动路径下会正确先 emit 各 dep 再 emit entry。

**不再做的事**：

- 不再在 parser 里加 `parser_slice_from_buf_into`、不在 .sx 里拼 slice 字面量、不再改 C 与 .sx 的 Module 布局、不再为 run-hello 加更多特殊分支。
- 诊断用 `driver_diagnostic_*` 已关闭，保持关闭即可。

---

## 五、建议执行顺序

1. **确认当前状态**：保留上述三项修改；确认 run-hello 仍报 _main、且原因仍是 entry num_funcs=0（可临时打开 driver_diagnostic_after_entry_parse 一次验证）。
2. **只做 codegen 修改**：在 **C 的 codegen.c** 中（bootstrap 时 shux-c 用 C 版 codegen 生成 pipeline_gen.c），找到「对 extern 调用结果赋给变量」的生成逻辑，当**被赋值的变量类型是 slice（[]u8 等）**时，用正确的 C 结构体类型和调用方式生成赋值（例如 `struct shux_slice_uint8_t var = parser_slice_from_buf(...);`）。
3. **验证**：bootstrap 一次，再跑 run-hello，应得到有 main 的 C 且链接通过。
4. **收尾**：若有临时诊断再关掉；提交时只包含「codegen 对 extern 返回 slice 的赋值」相关改动。

这样是**单点、最小改动**，不会按下葫芦又起瓢。
