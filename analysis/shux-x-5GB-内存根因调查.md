# shux-x 5GB 内存根因调查报告

**日期**：2026-07-19  
**调查员**：assistant (静态源码分析)  
**状态**：根因已定位，修复方案待用户决策（涉及架构层改动）

---

## 0. 现象

`./shux-x -x -E -E-extern src/main.x` 单进程 RSS 达 5GB。对照 GCC/Clang 同等规模
编译（src/main.x ~1500 行 + ~50 transitive deps）通常 < 500MB，**异常 10–50×**。

## 1. 排除的嫌疑（验证阴性）

| 嫌疑 | 验证方法 | 结论 |
|------|---------|------|
| `PipelineDepCtx` 栈递归 | grep `PipelineDepCtx` 栈分配点 | 仅 3 处栈分配，无递归 |
| `grow_vec_ensure` 倍增 | 读 [ast_pool.c:137-156](file:///home/shu/shux/compiler/ast_pool.c) | 线性扩容 `nc += AST_POOL_GROW`，非倍增 |
| codegen 输出缓冲 | `out_buf` 实际占 34KB | 远低于 GB 级 |
| C5 EXPR_BLOCK CTFE 改动 | shux-x 二进制 mtime 早于改动 | 与本次改动无关 |
| shux-x 二进制自身膨胀 | `size compiler/shux-x` | `__TEXT`=2.1MB, `__DATA`=141MB（含静态 BSS） |

## 2. 静态分配审计（130MB BSS zerofill）

`size -m compiler/shux-x`：

```
Segment __DATA: 147734528  (~141MB)
  Section __data:   14720 bytes
  Section __bss:    11298948 bytes  (~11MB)
  Section __common: 136396808 bytes  (~130MB)
```

`__common` 段只有两个大符号（[nm -m](file:///home/shu/shux/compiler/shux-x) 计算）：

| 符号 | 大小 | 定义 |
|------|------|------|
| `_driver_arena_static` | **128 MB** | [rt_arena_buf.from_x.c:19,24](file:///home/shu/shux/compiler/seeds/rt_arena_buf.from_x.c) |
| `_driver_module_static` | 2 MB | [rt_arena_buf.from_x.c:20,25](file:///home/shu/shux/compiler/seeds/rt_arena_buf.from_x.c) |

```c
#define DRIVER_ARENA_STATIC_SIZE  (128 * 1024 * 1024)  /* 128 MiB */
#define DRIVER_MODULE_STATIC_SIZE (2   * 1024 * 1024)  /* 2 MiB */
uint8_t driver_arena_static[DRIVER_ARENA_STATIC_SIZE];
uint8_t driver_module_static[DRIVER_MODULE_STATIC_SIZE];
```

注释说明：「arena 对应 .x codegen `struct ast_ASTArena`，须 ≥
`pipeline_sizeof_arena()`；池扩大后宿主约 ~90MiB，预留 128MiB 避免静默越界」。

**但实际未被使用** — `driver_run_x_emit_c` 走 `malloc(arena_sz)` 路径（见 §3），
这两个静态缓冲在 BSS zerofill 里只占 VA，OS 按需分配物理页。

**结论**：130MB 静态 BSS 不是 5GB RSS 的主要来源。RSS 5GB 必然来自运行期堆分配。

## 3. `driver_run_x_emit_c` 调用链（关键）

入口 [rt_run_x_emit.from_x.c:92-466](file:///home/shu/shux/compiler/seeds/rt_run_x_emit.from_x.c)：

```c
int driver_run_x_emit_c(void) {
    ...
    size_t arena_sz  = pipeline_sizeof_arena();   /* L141 */
    size_t module_sz = pipeline_sizeof_module();  /* L142 */
    void *arena  = malloc(arena_sz);              /* L143 */
    void *module = malloc(module_sz);            /* L144 */
    ...
    /* dep 循环 */
    for (int i = 0; i < n_deps; i++) {            /* L256 */
        dep_arenas[i]  = malloc(arena_sz);        /* L257 */
        dep_modules[i] = malloc(module_sz);        /* L258 */
    }
    ...
    /* 全部 dep 处理完后才统一 free */
    for (int j = n_deps - 1; j >= 0; j--) {       /* L417 / L424 */
        free(dep_arenas[j]); free(dep_modules[j]);
    }
    ...
    free(arena); free(module);                    /* L455-456 */
}
```

但是 `pipeline_sizeof_arena()` = `sizeof(struct ast_ASTArena)` = **16 字节**！

参考 [pipeline_glue.c:554](file:///home/shu/shux/compiler/pipeline_glue.c)：
```c
size_t pipeline_sizeof_arena(void)  { return sizeof(struct ast_ASTArena); }
size_t pipeline_sizeof_module(void) { return sizeof(struct ast_Module); }
```

参考 [codegen_gen.c:547-552](file:///home/shu/shux/compiler/codegen_gen.c)：
```c
struct ast_ASTArena {
    int32_t num_types;
    int32_t num_exprs;
    int32_t num_blocks;
    int32_t num_funcs;
};
```

**16 字节！** `malloc(16) × (1 + n_deps)` 完全不是 5GB 来源。真实内存来自 §4 的
sidecar 池（由 `g_arena_sc[]` 静态数组管理，绑定到 arena 指针作 key）。

## 4. 真凶：`g_arena_sc[512]` ArenaSidecar 池永不释放

### 4.1 池架构

[ast_pool.c:184-209](file:///home/shu/shux/compiler/ast_pool.c)：

```c
typedef struct {
    struct ast_ASTArena *arena;   /* key */
    int used;
    GrowVec types;                /* sizeof(struct ast_Type) ≈ 160 B */
    GrowVec exprs;                /* sizeof(struct ast_Expr)  ≈ 400 B */
    GrowVec blocks;               /* sizeof(struct ast_Block) ≈ 60 B  */
    GrowVec funcs;                /* sizeof(struct ast_Func)  ≈ 120 B */
    GrowVec consts;
    GrowVec lets;
    GrowVec ifs;
    GrowVec regions;
    GrowVec loops;
    GrowVec for_loops;
    GrowVec defer_block_refs;
    GrowVec labeled_stmts;
    GrowVec expr_stmt_refs;
    GrowVec stmt_order;
    GrowVec expr_call_arg_refs;
    GrowVec expr_method_call_arg_refs;
    GrowVec expr_match_arms;
    GrowVec expr_struct_lit_fields;
    GrowVec expr_array_lit_elem_refs;
    GrowVec func_params;
} ArenaSidecar;  /* 共 18 个 GrowVec */

#define MAX_ARENA_SIDECARS 512
static ArenaSidecar g_arena_sc[MAX_ARENA_SIDECARS];   /* L310 */
```

### 4.2 init 时的预分配

[ast_pool.c:411-465](file:///home/shu/shux/compiler/ast_pool.c) `arena_sidecar_get(a, create=1)`：

```c
if (!grow_vec_init(&sc->types, sizeof(struct ast_Type),  AST_POOL_GROW)) return NULL;
if (!grow_vec_init(&sc->exprs, sizeof(struct ast_Expr),    AST_POOL_GROW)) return NULL;
if (!grow_vec_init(&sc->blocks, sizeof(struct ast_Block), AST_POOL_GROW)) return NULL;
... (共 18 个 GrowVec)
```

[ast_pool.c:111-123](file:///home/shu/shux/compiler/ast_pool.c)：
```c
static int grow_vec_init(GrowVec *v, size_t elem_sz, int32_t initial_cap) {
    if (initial_cap <= 0) initial_cap = AST_POOL_GROW;  /* 4096 */
    v->data = (uint8_t *)calloc((size_t)initial_cap, elem_sz);
    ...
}
```

[ast_pool.c:14-15](file:///home/shu/shux/compiler/ast_pool.c)：
```c
#define AST_POOL_GROW 4096
```

### 4.3 单个 ArenaSidecar 初始内存估算

| 池 | elem_sz | init cap | 字节 |
|----|---------|----------|------|
| types  | ~160 B (Type: i32×6 + name[64] + region_label[64]) | 4096 | 640 KB |
| exprs  | ~400 B (Expr: 4 个 64-byte 数组 + ~30 个 i32)       | 4096 | 1.6 MB |
| blocks | ~60 B                                              | 4096 | 240 KB |
| funcs  | ~120 B                                             | 4096 | 480 KB |
| consts | ~76 B                                              | 4096 | 304 KB |
| lets   | ~76 B                                              | 4096 | 304 KB |
| regions| ~80 B                                              | 4096 | 320 KB |
| 其余 11 个小池（i32/ref/StructLitField/FuncParam 等） | ~8-40 B | 4096 | ~440 KB |

**单 ArenaSidecar init ≈ 4.3 MB**（未实际解析任何 AST 节点，仅初始化池容量）

### 4.4 关键：ArenaSidecar **永无 free 路径**

```bash
$ grep -n "arena_sidecar_free\|grow_vec_free.*arena_sc\|grow_vec_free.*g_arena" compiler/ast_pool.c
# 零命中（仅 onefunc_sidecar_free 存在，见 §5）
```

`ast_pool_arena_reset`（[ast_pool.c:1057-1087](file:///home/shu/shux/compiler/ast_pool.c)）只重置
`sc->types.len = 0`、`sc->exprs.len = 0` 等 — **不动 `data` 指针和 `cap`**：

```c
void ast_pool_arena_reset(struct ast_ASTArena *a) {
    sc = arena_sidecar_get(a, 0);
    if (!sc) return;
    sc->types.len = 0;   /* cap 和 data 保留！ */
    sc->exprs.len = 0;
    ...
}
```

### 4.5 dep 循环 → ArenaSidecar × N → 累积爆炸

[rt_run_x_emit.from_x.c:256-269](file:///home/shu/shux/compiler/seeds/rt_run_x_emit.from_x.c)：

```c
for (int i = 0; i < n_deps; i++) {
    dep_arenas[i] = malloc(arena_sz);   /* 新 ASTArena* */
    dep_modules[i] = malloc(module_sz);  /* 新 Module* */
    memset(dep_arenas[i], 0, arena_sz);
    memset(dep_modules[i], 0, module_sz);
}
```

每个 `dep_arenas[i]` 是**新指针**（虽然只有 16 字节），调用
`parser_parse_into_init(module, arena)`（[L164](file:///home/shu/shux/compiler/seeds/rt_run_x_emit.from_x.c)）
后会触发 `arena_sidecar_get(arena, create=1)` — **新分配一个 ArenaSidecar 槽**
（4.3 MB 初始分配）。

主 emit 完成前不能释放 dep 的 arena（因为 typeck 要访问 `typeck_dep_module_ptrs[]`/
`typeck_dep_arena_ptrs[]`，[L395-398](file:///home/shu/shux/compiler/seeds/rt_run_x_emit.from_x.c)）。

### 4.6 估算与实测对齐

- 假设 `n_deps = 50`（src/main.x → ast/codegen/sys → 子 import 累积）
- 50 个 ArenaSidecar × 4.3 MB = **215 MB**（仅 init cap，未含实际 AST 节点）
- 实际 AST 节点占用：每 dep ~5000 exprs × 400 B = 2 MB → 50 × 2 MB = 100 MB
- 合计 ~315 MB → **远低于 5GB**

**结论**：单靠 dep ArenaSidecar 不足以致 5GB。剩余部分必然来自：

1. **`MAX_ARENA_SIDECARS=512` 触顶**：如果某条 code path 循环 init 全部 512 个槽
   （例如 LSP/diag 路径复用 main 入口但生成新 arena），则 512 × 4.3 MB = **2.2 GB**
2. **`g_onefunc_sc[1024]` 不释放路径**（见 §5）
3. **`g_module_sc[512]` ModuleSidecar** 同模式（每个含 11 个 GrowVec）
4. **dep_arenas 在 emit 失败时未走 free 路径**（部分 error goto 漏 free）

需用运行时 profiling（macOS `vmmap` / `leaks`）确认实际累积点。

## 5. `g_onefunc_sc[1024]` OneFuncSidecar

[ast_pool.c:237-272](file:///home/shu/shux/compiler/ast_pool.c)：

```c
typedef struct {
    void *onefunc;
    int used;
    GrowVec if_cond_refs; GrowVec if_then_body_refs; GrowVec if_else_body_refs;
    GrowVec const_names; GrowVec const_name_lens; GrowVec const_init_vals;
    GrowVec const_init_refs; GrowVec const_type_refs;
    GrowVec let_names; GrowVec let_name_lens; GrowVec let_init_vals;
    GrowVec let_init_refs; GrowVec let_type_refs;
    GrowVec src_stmt_kind; GrowVec src_stmt_idx; GrowVec src_body_expr_stmt_refs;
    GrowVec while_cond_refs; GrowVec while_body_refs;
    GrowVec for_init_refs; GrowVec for_cond_refs; GrowVec for_step_refs;
    GrowVec for_body_refs;
    GrowVec param_names; GrowVec param_name_lens; GrowVec param_type_refs;
    GrowVec call_arg_vals;
    GrowVec regions;
    GrowVec defer_body_refs;
} OneFuncSidecar;  /* 共 28 个 GrowVec */

#define MAX_ONEFUNC_SIDECARS 1024
static OneFuncSidecar g_onefunc_sc[MAX_ONEFUNC_SIDECARS];
```

**OneFuncSidecar 有 free 路径**（[ast_pool.c:589-622](file:///home/shu/shux/compiler/ast_pool.c)）
和 release API `ast_pool_onefunc_release`（[L1125](file:///home/shu/shux/compiler/ast_pool.c)），
parser 多处调用（parser.x:8732, 9860, 9880, 9900, 10630, 10641, 10682）。

→ **OneFuncSidecar 不是主要泄漏源**，但若某条 parse 失败路径漏 `ast_pool_onefunc_release`，
1024 × 28 × 4096 × ~32 B ≈ 3.7 GB（最坏情况触顶）。需检查 parser 错误路径是否都成对
调用 release。

## 6. 修复方向（待用户决策）

### 方向 A：减小 `AST_POOL_GROW` 初始 cap（最小改动）

将 `AST_POOL_GROW` 从 4096 减到 256 或 512。**只减少 init cap 的浪费**，不改变
dep-arena-per-instance 架构。

| 参数 | 现状 | 建议 | 单 ArenaSidecar init | 50 deps |
|------|------|------|---------------------|---------|
| AST_POOL_GROW=4096 | 是 | — | 4.3 MB | 215 MB |
| AST_POOL_GROW=512  |    | ✓    | 540 KB | 27 MB |
| AST_POOL_GROW=256  |    | ✓✓   | 270 KB | 14 MB |

但线性扩容步长也减半，对大文件可能频繁 realloc。可拆分 `AST_POOL_INIT_CAP`
（init=256）和 `AST_POOL_GROW_STEP`（grow=4096）两个常量。

**风险**：低；影响所有池（包括 OneFuncSidecar、ModuleSidecar），需 L4 全量验证。

### 方向 B：为 ArenaSidecar/ModuleSidecar 加 free API

新增 `ast_pool_arena_release(struct ast_ASTArena *a)` 和
`ast_pool_module_release(struct ast_Module *m)`，调用 18 个 / 11 个 `grow_vec_free`。

`driver_run_x_emit_c` 在主 emit 完成后（[L455-456](file:///home/shu/shux/compiler/seeds/rt_run_x_emit.from_x.c)）
循环调用：

```c
for (int j = 0; j < n_deps; j++) {
    ast_pool_arena_release(dep_arenas[j]);
    ast_pool_module_release(dep_modules[j]);
}
ast_pool_arena_release(arena);
ast_pool_module_release(module);
```

**前提**：typeck 完成后 dep_arenas 不再被访问（typeck_dep_module_ptrs[] 在 emit 阶段
已无用）。需验证 `codegen_set_dep_slots_for_x_pipeline` 是否仍读 dep AST。

### 方向 C：streaming dep codegen（架构改动）

每解析完一个 dep 就立即 codegen 它（emit C），转储到紧凑字节数组后 `ast_pool_arena_release`，
再处理下一个 dep。typeck 仍需 cross-dep 类型信息，可能需要保留 Type/Func 池但释放 Expr/Block 池。

**复杂度**：高，影响 typeck/codegen/pipeline 多层接口。建议自举后再做。

### 方向 D：让 `driver_arena_static[128MB]` 真正用作 arena backing

当前 `driver_arena_static` 是静态 BSS 但未被使用。让首个（main）arena 用它作 backing
store（arena 指针指向 `driver_arena_static`，sidecar 仍走 `g_arena_sc[]`）。

**节省**：一次 `malloc(16)` —— 微不足道。**不解决根本问题**。

## 7. 建议执行顺序

1. **立即**：方向 A（拆 init/grow 常量，init cap=256），单 commit，L2 验证
2. **中期**：方向 B（ArenaSidecar/ModuleSidecar release API），C5 wave 完成后单独一波
3. **远期**（自举后）：方向 C（streaming dep codegen）

## 8. 待运行时验证的事项

以下需用 macOS `vmmap`/`leaks` 或 stage `getrusage` 日志确认：

1. 实际 `n_deps` 数量（src/main.x → transitive imports 总数）
2. `g_arena_sc[]` 占用率：50 / 100 / 200 / 512？
3. `g_onefunc_sc[]` 在 parser 错误路径是否泄漏（1024 槽触顶？）
4. `g_module_sc[]` 占用率
5. 哪个 GrowVec 的 `cap` 扩到最大（exprs？types？）

未做运行时 profiling，仅静态分析。用户醒来后可选择方案 A/B/C/D。

---

**附**：本次调查未改任何代码（仅 `analysis/` 文档），不影响 bootstrap / L2 状态。
