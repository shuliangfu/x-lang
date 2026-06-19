# 自举：生成 C 与 ABI 问题 — 深度分析与重构方案

> 本文档分析「.sx → 生成 C → 打补丁」导致的反复修、死循环根因，并给出「从根上不再出现此类问题」的可行方案。

---

## 一、当前链路与问题根因

### 1.1 实际数据流

```
.sx 源码 (parser.sx, pipeline.sx, lexer.sx, ...)
    ↓  shuc 编译（解析 + 类型检查 + 代码生成）
    ↓  -E 时：codegen 把 .sx 语义 1:1 翻成 C
生成的 C (pipeline_gen.c, driver_gen.c, ...)
    ↓  fix_pipeline_gen.py / sed / Makefile 规则 打补丁
修补后的 C
    ↓  cc 编译 + 链接
可执行 shuc
```

- **生成 C 的是谁**：当前 shuc 的 **C 后端**（codegen）。.sx 里写 `return OneFuncResult { ... }`，就生成 `return ({ struct parser_OneFuncResult _t = { ... }; _t; });`；写 `r = lexer_next(lex, source)`，就生成 `r = lexer_lexer_next(lex, source);`。即 **codegen 是忠实直译，没有做「ABI 安全」的转换**。
- **为何要打补丁**：部分平台/环境下，**结构体按值返回、按值赋值**（大结构体或特定调用约定）不可靠，导致 `res.ok`、`r.tok.kind` 等写回错误。所以用「void + 静态缓冲区 + _into」在**生成后的 C 文本**上做字符串替换，把「返回/接住结构体」改成「写 out 再 return / 用 _into 接」。

### 1.2 为何会「没完没了改、按下葫芦起来瓢」

- **修的是「结果」而不是「规则」**：  
  规则应该是「这类类型一律不按值返回/赋值」；实际做的是「在已生成的 C 里找特定字符串再改」。所以：
  - 生成代码的**形状**一变（多一个分支、多一种 return、名字/顺序微调），原来的替换就匹配不上或误伤。
  - 每发现一种新形状（例如成功路径的 dummy_name 变体、首次声明 `r = lexer_next`、extern、另一处调用点），就要**再加一条补丁**，且补丁之间还可能互相影响（例如给 _buf 误加了 `return;`）。
- **补丁是「基于字符串」的**：  
  依赖「某段 C 代码长什么样」，而不是「语义上这是不是一次结构体返回/赋值」。因此：
  - 换编译器/优化等级导致生成格式略变，补丁就可能失效。
  - 难以保证「所有这类语义」都被覆盖，只能靠失败用例一个个加。

结论：**根因是「生成 C 的规则」没有把「ABI 不安全」从语义上消除，而是事后在文本上修补**。要彻底不反复，必须把规则收口到**要么改生成规则（codegen/类型系统），要么改 .sx 写法（只用 _into）**，而不是继续在生成出的 C 上打更多补丁。

---

## 二、能不能「不生成那种 C」？— 能

目标：**从设计上就不产出「结构体按值返回/按值接住」的 C**，这样就不需要、也不存在针对这类问题的补丁。

有两种等价思路（任选其一或组合）：

- **从 .sx 源头上**：约定并实现「对 LexerResult / OneFuncResult 等类型只使用 _into API，不写 `r = lexer_next(...)`、不写 `return OneFuncResult { ... }`」→ 生成出的 C 自然就不会有这些模式。
- **从 codegen 上**：在生成 C 之前（或生成时）做一次「ABI 规范化」：对返回这类结构体的函数改为生成 `void func_into(T *out, ...)`，对调用点改为生成 `func_into(&r, ...)`，这样生成的 C 里从一开始就没有「返回/接住结构体」的写法。

下面分方案说清楚「怎么做、做了之后还能不能生成 C、会不会再出现同类问题」。

---

## 三、方案对比（重构后不再出现同类问题）

### 方案 A：.sx 源侧统一 _into（推荐，优先做）

**做法**：

- 在 **parser.sx**（以及所有使用 LexerResult / OneFuncResult 的 .sx）里：
  - **不再**写 `r = lexer_next(lex, source)`，一律改为 `lexer_next_into(&r, lex, source)`（包括首次取 token 和后续每次推进）。
  - **不再**在 `parse_one_function` 里 `return OneFuncResult { ... }`，改为：
    - 要么：函数改为 `void`，内部用静态缓冲区存结果，再提供 `parse_one_function_into(out, ...)` 把缓冲区拷到 `out`；
    - 要么：直接改成 `parse_one_function_into(out, ...)`，所有 return 改为「写 *out 再 return」。
- 保证 lexer/parser 对外只暴露 _into 接口（或至少自举路径上只用 _into），不依赖「返回/赋值结构体」的语义。

**效果**：

- 生成的 C 里**自然就不会出现**：
  - `struct lexer_LexerResult r = lexer_lexer_next(...);`
  - `r = lexer_lexer_next(...);`
  - `return ({ struct parser_OneFuncResult ... });`（在 parse_one_function 内）
  - `res = parser_parse_one_function(...);`
- **fix_pipeline_gen.py 里与 ABI 相关的补丁（1.4 LexerResult、1.9 OneFuncResult void+buf+_into、extern、调用点改 _into）可以删除**，不再依赖对生成 C 的字符串替换来「修」结构体返回/赋值。
- 仍会生成 C（pipeline_gen.c 等），只是生成的 C 从根上就是「out 参数」风格，不会触发当前这类 ABI 问题。

**优点**：

- 不要求改 codegen 逻辑，只改 .sx 的写法和约定。
- 语义清晰：这类类型在 .sx 里就是「用 out 写回」，和 C 侧一致，不会「写的是值语义、生成的是值语义、但 ABI 不保证」。
- 一次改完，后续只要坚持「这类类型只用 _into」，就不会再冒出新的「这里又按值返回/赋值」的坑。

**缺点**：

- 需要一次性把 parser.sx（及涉及到的 lexer 调用、parse_one_function 所有 return 路径）重构干净，工作量集中在前端。

**结论**：**可以完全不生成「那种 C」**，做法就是在 .sx 里不写那种用法；重构后**不会**再出现「因结构体返回/赋值导致的 ABI 反复修」问题。

---

### 方案 B：codegen 层做「ABI 安全」转换

**做法**：

- 在 **codegen**（C 或 .sx 的代码生成）里增加一条规则（或单独做一个「C 发射前」的 pass）：
  - 对「返回类型属于 ABI 不安全集合」的函数（如 LexerResult、OneFuncResult 等），生成 C 时：
    - 函数签名改为 `void func_into(T *out, ...)`；
    - 函数体内所有 `return value` 改为「写 *out = value; return;」。
  - 对「调用该类函数且结果赋给变量」的调用点，生成 `func_into(&lhs, ...)` 而不是 `lhs = func(...)`。
- 这样 .sx 里仍可以写 `r = lexer_next(...)`、`return OneFuncResult { ... }`，由 codegen 统一转成 _into 形式。

**效果**：

- 生成的 C 同样不会出现「结构体返回/接住」的写法，fix 脚本里的 ABI 补丁可以撤掉。
- 仍会生成 C，只是生成规则变了。

**优点**：

- .sx 源码可以保持「值语义」写法，对写 .sx 的人更自然；ABI 细节被后端隐藏。

**缺点**：

- 要动 codegen（且可能要区分的「ABI 不安全类型」会随项目增长），实现和测试成本高；
- 需要维护「哪些类型走 _into」的列表或规则，和类型系统/命名绑定。

**结论**：**也可以不生成那种 C**，做法是让 codegen 在生成 C 时统一做转换；重构后同样不会因为「结构体返回/赋值」再反复打补丁。

---

### 方案 C：不生成 C，用现有 asm 后端（已有能力）

**现状**：

- 项目**已有汇编/机器码后端**（`src/asm/`）：AST 经 `asm_codegen_ast` / `asm_codegen_elf_o` 直接出汇编文本 (.s) 或 ELF/Mach-O/COFF .o，**不经过 C**。
- pipeline 在 `-backend asm` 时走 `asm.asm_codegen_ast`，否则走 `codegen_sx_ast`（出 C）。
- `scripts/build_shuc_asm.sh` 即用「shuc -backend asm -o xxx.o」把各 .sx 编成 .o 再链接，实现**完全不经 C 生成**的自举。

**做法**：

- 自举/日常构建**优先或全部走 asm 后端**：用 `-backend asm` 编译 pipeline、main、parser 等，产出 .o 后链接，**不再生成 pipeline_gen.c / driver_gen.c 等 C 文件**（或仅作调试/兜底保留）。
- 这样**不存在「生成 C → 再打 ABI 补丁」**的链路，也就没有 C 结构体返回/赋值的 ABI 问题。

**效果**：

- 调用约定、布局完全由 asm 后端和 ELF/Mach-O 定义，不依赖 C ABI。
- 不需要 LLVM 或其它外部代码生成器；**现有 asm 后端即可直接使用**。

**注意**：

- 当前 asm 自举路径（build_shuc_asm.sh）仍依赖「先 make bootstrap-driver」得到能跑 -backend asm 的 shuc，且部分运行时仍为 C（如 runtime_asm_build.o、runtime_driver.o）。若要让「从零构建」也完全不生成 C，需保证 asm 后端能编译全部自举所需模块并稳定通过。

**结论**：**不生成 C 完全可以用现有汇编后端做到**，不需要引入 LLVM；方案 C 应理解为「用现有 asm 后端替代 C 生成」，而不是「再做一个新后端」。

**Makefile 已改（全部直接出机器码、不生成 C）**：  
- **`make bootstrap-driver`** = **仅走 asm**：不生成任何 `pipeline_gen.c`、`driver_gen.c` 等 C 文件；用已有 `$(TARGET)` 跑 `build_shuc_asm.sh`，全部 .sx 用 `-backend asm` 编成 `build_asm/*.o` 再链接，产出 shuc_asm 并覆盖 `$(TARGET)`。  
- **首次/从零**：须先执行 **`make bootstrap-driver-seed`**（会生成 C 一次得到种子 shuc），之后 **`make bootstrap-driver`** 即只出机器码、不再生成 C。  
- **`bootstrap-driver-asm-only`** 与 `bootstrap-driver` 同义（仅 asm）。  
- 当前若 asm 后端编不过全部自举 .sx，`make bootstrap-driver` 会报错并提示运行脚本查看具体错误；修好 asm 后端后即可**默认完全不生成 C**。
- **测试**：`make check-6.4` 使用 `bootstrap-driver-seed` 构建 shuc 后跑 return-value；在 seed 能正常解析 .sx 的环境（如部分 Linux）下通过。若本机 seed 存在 ABI/解析问题（如 pr.ok=-1），需先做方案 A 或修 asm 后全量测试才能全绿。

---

## 四、推荐路线（避免死循环、可持续）

1. **短期（立刻可做）**  
   - **采用方案 A**：在 parser.sx（及必要处）全面改为只用 _into，去掉所有「接住 LexerResult / OneFuncResult」的赋值和 parse_one_function 的 return 结构体。  
   - **同步精简 fix_pipeline_gen.py**：删除 1.4、1.9 及与 OneFuncResult/LexerResult ABI 相关的替换；保留与 ABI 无关的修正（zero_u8_p、rela_buf、collect_imports、声明顺序等）。  
   - 这样**生成的 C 从根上就不含「那种」结构体返回/赋值**，自然不会再为这类问题打补丁，也不会「这里修好那里又坏」。

2. **中期（可选）**  
   - 若希望 .sx 侧继续用「值语义」写法，再考虑**方案 B**：在 codegen 里加「返回/赋值 ABI 不安全类型 → 统一生成 _into」的规则，把「不生成那种 C」收口到编译器一层，而不是 .sx 约定。

3. **长期（可选）**  
   - 若希望自举**完全不生成 C**，可直接用**现有 asm 后端**（`-backend asm` + build_shuc_asm.sh），无需 LLVM。

---

## 五、小结（直接回答「有没有好办法」）

- **有没有更好的办法重构？**  
  有：**从「在生成 C 上打补丁」改为「在来源上就不生成会出错的 C」**。要么 .sx 只用 _into（方案 A），要么 codegen 统一把这类返回/赋值改成 _into（方案 B）。

- **重构后还会不会出现这种问题？**  
  只要坚持「这类类型在生成 C 里不出现按值返回/按值赋值」，就**不会**再出现同一类 ABI 问题；补丁不用再跟着生成代码形状追。

- **能不能不去生成那种 C？**  
  能。要么不写那种 .sx（方案 A），要么让 codegen 不发出那种 C（方案 B）。两种都是「不生成那种 C」的可持续做法。

- **有没有好办法解决？**  
  有：**优先做方案 A（.sx 全面 _into）**，并**删除 fix 脚本里依赖「结构体返回/赋值」形状的补丁**。这样解决是可持续的，也不会再陷入「这里修好那里又坏」的死循环。

---

## 六、asm 后端进展（库模块与 Abort）

- **库模块解析**：`parse_into` 在「仅 enum/struct/extern、无 function」时原先返回 `ok: -1`，导致 pipeline 直接报 parse fail。已改为返回 `ok: 0, main_idx: -1`，pipeline 走 `typeck_su_ast_library` 与 `asm_codegen_ast`。  
  - 效果：`token.sx`、`ast.sx`、`preprocess.sx`、`std_fs.sx` 等纯库模块在 `build_shuc_asm.sh` 下显示 **OK**（此前为 SKIP）。
- **库模块 .o 为 0 字节**：`asm_codegen_ast` 在 `num_funcs==0` 时循环不执行，`out_buf.len` 保持 0，写出 0 字节。若需可链接的 .o，需在「库模块 + -o xxx.o」路径上改为走 `asm_codegen_elf_o` 写出最小 ELF，或由脚本对 0 字节 .o 做占位/跳过。
- **剩余问题**：  
  - 部分模块 **SKIP**（pipeline rc=-1，多为 typeck 失败，如 codegen.sx、typeck.sx、lexer.sx 等）。  
  - 部分模块 **Abort trap: 6**（如 x86_64.sx、arm64.sx、asm.sx），发生在 parse 之后（typeck 或 asm 阶段），需用调试器或加边界检查定位。
- **建议下一步**：对 Abort 模块去掉 `2>/dev/null` 单独跑、用 lldb 看 backtrace；对 rc=-1 的模块看 typeck 报错或 typeck_su_ast 返回值；再考虑库模块最小 ELF 产出。

- **ast arena 防护**：在 `ast.sx` 的 `ast_arena_type_get` 中增加了 `ref <= 0` 时返回默认 `TYPE_I32` 的防护，避免 C 生成码里 `ref - 1` 越界触发 `shux_panic_(1, 0)`。

- **Abort 根因与修复（parser_copy_onefunc_into）**：用 lldb 取得 backtrace，确认崩溃在 **parser_copy_onefunc_into**（解析阶段复制 OneFuncResult 时）。原因是 C 代码生成将外层循环变量递增（如 `pi = pi + 1`）误放在循环体**开头**，导致内层循环用 pi=1..16 访问，最后一轮访问 `param_names[16]` 越界触发 panic。已在 **fix_pipeline_gen.py** 中增加 1.10：将 `(void)((pi = pi + 1));` / ci / li 从「内层 while 前」移到「内层 while 后」。修复后 x86_64.sx、arm64.sx 等不再 Abort，改为 pipeline rc=-1（typeck 等后续失败）。

- **driver_gen.c 生成顺序与 -L 生效**（Makefile 后处理）：  
  - **pipeline 调用顺序**：-E-extern 将 `pipeline_run_sx_pipeline_impl` 放在填充 ctx（entry_dir、num_lib_roots、lib_root_bufs）之前，导致 resolve 时 `num_lib_roots=0`、path 仅用默认 "."。Makefile 中 perl 将「pipeline 调用 + len 赋值」移到 `ctx.num_lib_roots` 赋值之后。  
  - **k=0  before lib_root 复制**：path_buf/last_slash 循环后 `k` 已增大，若不在 lib_root 复制前 `k=0`，则 `while (k < n_lib_roots)` 不进入，ctx 的 lib_root 未填。Makefile 在 `while (k < (state)->n_lib_roots && k < 8)` 前插入 `(void)((k = 0));`。  
  - **k=k+1 在内层 while 之后**：生成码把 `(void)((k = k + 1));` 放在内层 `while (r < ... lib_root_lens[k])` 之前，导致内层用 `lib_root_lens[k]` 时 k 已为 8 越界 panic。Makefile 中 perl 将该行移到内层 while 结束后、外层 while 结束前。  
  - **rc=-7 诊断**：`driver_pipeline_fail_code(rc, path)` 在 rc==-7 时打印 resolve 尝试路径，便于排查库根/路径问题。
  - **dep 缓冲（.sx 路径）**：走 .sx 时 `ctx.dep_arenas[i]` / `ctx.dep_modules[i]` 若未赋值，解析依赖会在 `ast_arena_init` 等处写空指针导致 SIGSEGV。由 **runtime.c** 提供 `driver_dep_arena_buf(i)`、`driver_dep_module_buf(i)` 按需分配并缓存在 driver；**pipeline.sx** 在解析第 i 个 import 前调用上述 extern 并将返回值写回 `ctx.dep_arenas[i]`、`ctx.dep_modules[i]`。
  - **resolve path/mod.sx 回退**：`import("std.fs")` 等约定为目录下 **mod.sx**（如 `../std/fs/mod.sx`），若 `path.sx` 不存在则尝试 `path/mod.sx`。**pipeline.sx** 在 `resolve_path_su` 的 lib_roots 与 entry_dir 两处、在打开 path.sx 失败后追加 `/mod.sx` 再试；**fix_pipeline_gen.py** 第 8 条对生成的 C 做同样插入（当 block1 未找到时脚本不再提前 return，继续执行到第 8 条补丁）。
  - 效果：token.sx 等无 import 模块可正常编过 asm；x86_64.sx 等有 import 的模块可过 resolve，后续可能为 typeck/asm 或 SIGSEGV（139）需继续定位。
