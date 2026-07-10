# G-02f P2 — `parser_asm_thin` mega 拆分 RFC（f-278 / f-304）

> **状态**：草案可执行（2026-07-11）  
> **对象**：`compiler/seeds/parser_asm_thin_c.from_x.c`（≈22k LOC 主 TU + `seeds/parser_asm/*_slice.inc`）→ 产品 `parser_asm_thin_glue.o`  
> **对标**：[`G-02f-P2-runtime-mega-RFC.md`](G-02f-P2-runtime-mega-RFC.md)、[`G-02f-P2-link-abi-mega-RFC.md`](G-02f-P2-link-abi-mega-RFC.md)  
> **约束**：不破坏 G05 51 objs；默认仍单 seed `cc` → 单 `parser_asm_thin_glue.o`；**禁止无 RFC 硬啃**（本文件即闸门）。

---

## 1. 目标与非目标

### 1.1 目标

1. 把 **parser EMIT_HEAVY thin glue** 切成可独立真迁/审计的子系统（册），每步只动一册。  
2. 承认并纳入已有 **物理 slice `.inc`**（`seeds/parser_asm/`），避免「假装整文件仍是铁板一块」。  
3. 明确 **🔒 永久 seed** 边界：stretch audit 巨石、深控制流 C 路径、与 `parser.x` ABI 布局同步的 padding 结构体。  
4. 给出 **首个可运行切片** 与门禁，使 f-305+（parser 真迁）有序。  
5. 保持产品：`g05_ensure` 热路径  
   `seeds/parser_asm_thin_c.from_x.c` + `-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -Isrc/asm -Iseeds/parser_asm`  
   → `parser_asm_thin_glue.o`。

### 1.2 非目标

- 本步不把 G05 的 `parser_asm_thin_glue.o` 拆成多个正式 objs（仍单 `.o`；hybrid 用 `ld -r`）。  
- 不默认打开 `SHUX_G05_PREFER_X_O`。  
- 不并行大改 `parser.x` / `pipeline` / typeck（仅允许为薄门闩所需的前向声明同步）。  
- 不在本 RFC 落地代码步（代码步 = f-305+ 或本跟进表 f-279+）。  
- 不追求一次 PR 吞掉 `parser_asm_emit_heavy_stretch_suite_slice.inc`（≈28k LOC）。

---

## 2. 现状（量化）

| 项 | 值 |
|----|-----|
| 主 seed | `compiler/seeds/parser_asm_thin_c.from_x.c` |
| 逻辑锚 | `compiler/src/asm/parser_asm_thin_c.x`（≈91 LOC 锚点） |
| 产物 | `compiler/parser_asm_thin_glue.o`（G05 热路径；非 `src/` 下） |
| ensure | `g05_ensure`：seed 新于 `.o` 则 `cc -c`（G-02f-10） |
| 主 TU 约 LOC | **~21 935**（未展开 `#include`） |
| 物理 slice | `seeds/parser_asm/*_slice.inc` **21 个**（合计远超主 TU；suite stretch 独占 ≈28k） |
| 约非 static 函数定义 | **~198**（主 seed 启发式） |
| 关键词密度（主 seed 文本） | `asm_` 极高；`lex_`/`parse_`/`import_`/`match_` 密 |
| 关键 flags | `-DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE` |
| Include 路径 | `-I. -Iinclude -Isrc -Isrc/lexer -Isrc/asm -Iseeds/parser_asm` |
| 兄弟 | `src/asm/parser_asm_parse_expr_link.o`（已独立 G05 obj） |

**角色**：`parser.x` **EMIT_HEAVY** 第二遍 `skip_heavy` 桩的 **C 目标**——宿主编译器 X emit 失败时，由 thin glue 提供 peek/skip/balanced/控制流/表达式等可链入实现；与 `token.h` / `ast.h` / `parser_gen` 布局锁死。

### 2.1 已有物理 slice（按 LOC 升序，2026-07-11）

| LOC | 文件 |
|-----|------|
| 79 | `parser_asm_type_alias_slice.inc` |
| 88 | `parser_asm_body_let_slice.inc` |
| 114 | `parser_asm_top_level_let_slice.inc` |
| 195–284 | block / if_expr / simd / as_suffix / finish_struct_lit / library |
| 481 | `parser_asm_emit_heavy_stretch_slice.inc` |
| 630–1.1k | type_ref / unary / ternary_assign / one_function_buf / struct_layout / match_subject / expr_binop |
| 1.3–1.9k | if_stmt / primary / seed_parse_into_buf |
| **≈28.5k** | **`parser_asm_emit_heavy_stretch_suite_slice.inc`**（审计/压力；单独册） |

> **事实**：拆分不是从零开始——**主 mega 已是「壳 + `#include` 册」**。RFC 的任务是：**册边界签字、真迁顺序、hybrid 宏、永久 seed 清单**，而不是再发明一套文件名。

---

## 3. 子系统边界（建议册 P0–P9）

按依赖方向（词法/布局 → 表达式 → 语句 → 顶层 → stretch 🔒）：

| 册 | 代号 | 内容摘要 | 代表 / 现有 slice | 难度 | 🔒 |
|----|------|----------|------------------|------|-----|
| **P0** | `pthin_layout` | Token/Lexer/Result padding 结构体；与 `parser.x` / gen 布局注释锁 | 主 seed 头 struct | 易 | 布局同步债 |
| **P1** | `pthin_lex_skip` | peek/consume/skip_balanced/delim 深度探针 | 主 seed 前部 + stretch 探针调用点 | 中 | 少 |
| **P2** | `pthin_let_alias` | body let / top-level let / type alias | `body_let` / `top_level_let` / `type_alias` | 易 | 无 |
| **P3** | `pthin_type_ref` | type_ref 解析 | `type_ref_slice` | 中 | 无 |
| **P4** | `pthin_expr` | primary / unary / binop / ternary_assign / as_suffix / struct_lit | 对应 6× slice | 中高 | 无 |
| **P5** | `pthin_ctrl` | if_expr / if_stmt / match_subject | 对应 3× slice | 中高 | 无 |
| **P6** | `pthin_fn_block` | one_function_buf / block_from_res / library / struct_layout | 对应 slice | 高 | ABI 结果结构体 |
| **P7** | `pthin_simd` | simd_builtin | `simd_builtin_slice` | 中 | 平台敏感少 |
| **P8** | `pthin_seed_parse` | seed_parse_into_buf 主编排 | `seed_parse_into_buf_slice`（≈1.9k） | 高 | 与 parse 入口紧耦 |
| **P9** | `pthin_stretch` | emit_heavy stretch + **suite** 审计 | stretch + **suite 28k** | 极高 | **审计/压力 🔒 可后置** |

**禁止再塞回 thin mega 的兄弟**（已独立 G05 / 其它 seed）：

- `parser_asm_parse_expr_link`  
- `runtime_*` / `link_abi` / `pipeline_abi`  
- 主 `parser.x` 产品路径（X emit 成功时不走 thin）

---

## 4. 拆分策略（不破坏 G05）

### 4.1 逻辑源 vs 链接单元

| 阶段 | 做法 |
|------|------|
| **A. 逻辑切片（默认，与 link_abi 一致）** | `src/asm/pthin_*.x` + `seeds/pthin_*.from_x.c` 或继续演进现有 `*_slice.inc` → 真 `.from_x.c`；mega `#ifndef SHUX_PTHIN_*_FROM_X`；prefer 时 `ld -r` 合成 **单** `parser_asm_thin_glue.o` |
| **B. 物理多 `.o`（后期）** | 仅当 A 稳定后修订 `g05_relink_env`；需 c08 / STRICT 同步 |

**首阶段只做 A**。现有 `.inc` 视为 **A0（已物理但未 hybrid 宏）**。

### 4.2 宏约定

```text
SHUX_PTHIN_LAYOUT_FROM_X     // P0
SHUX_PTHIN_LEX_SKIP_FROM_X   // P1
SHUX_PTHIN_LET_ALIAS_FROM_X  // P2
SHUX_PTHIN_TYPE_REF_FROM_X   // P3
SHUX_PTHIN_EXPR_FROM_X       // P4
SHUX_PTHIN_CTRL_FROM_X       // P5
SHUX_PTHIN_FN_BLOCK_FROM_X   // P6
SHUX_PTHIN_SIMD_FROM_X       // P7
SHUX_PTHIN_SEED_PARSE_FROM_X // P8
SHUX_PTHIN_STRETCH_FROM_X    // P9（默认可关闭 suite）
```

- 默认：宏未定义 → 逻辑在 `parser_asm_thin_c.from_x.c` + `#include` slice。  
- 试验：`SHUX_G05_PREFER_X_O=1` 或后续 `SHUX_PTHIN_HYBRID=1` 时切片 `cc` + rest `ld -r`。  
- **产品默认关闭 hybrid**。  
- 保留 **`PARSER_ASM_THIN_GLUE_NO_SEED_PARSE`**（产品路径语义；勿与 hybrid 宏混淆）。

### 4.3 weak / 重复符号

- 与 `parser.x` 生成物 / stretch audit 同名：单强定义；试验 hybrid 时可用 `G05_X_O_WEAK=1`。  
- suite stretch 若 dual link：优先 **不链 suite**（审计专用宏 `PARSER_ASM_STRETCH_AUDIT_*`）。

### 4.4 与 runtime / link_abi hybrid 的关系

| mega | 产物 | hybrid 开关 |
|------|------|-------------|
| runtime | `runtime_driver_no_c.o` | `SHUX_G05_PREFER_X_O` + `SHUX_RT_*` |
| link_abi | `runtime_link_abi.o` | 同上 + `SHUX_LABI_*`（L0–L9 已齐） |
| **parser thin** | **`parser_asm_thin_glue.o`** | 本文落地后同 prefer 或 `SHUX_PTHIN_HYBRID` |

建议：**首切片复用 `SHUX_G05_PREFER_X_O`**，ensure 过重再拆开关。

---

## 5. 建议真迁顺序

| 序 | 切片 | 理由 | 验收 |
|----|------|------|------|
| **1** | **P2 let/alias** | 已最小 `.inc`；无深表达式依赖 | unit + 不回归 hello |
| **2** | **P3 type_ref** | 中等；表达式上游 | type 相关 gate |
| **3** | **P1 lex/skip pure helpers** | 被全树调用；先表驱动/薄纯函数 | peek/skip 烟测 |
| **4** | **P4 expr 子册分拆** | primary → unary → binop 分 commit | 表达式测试 |
| **5** | **P5 ctrl** | 依赖 P4 | if/match 测试 |
| **6** | **P6 fn/block/library** | ABI 结果结构体多 | parse_one / library |
| **7** | **P7 simd** | 相对独立 | simd gate |
| **8** | **P8 seed_parse** | 入口编排 | 全量 parse 烟测 |
| **9+** | **P9 stretch** | suite 28k **单独轨**；默认可不进产品 hybrid | audit 宏开时才编 |

**禁止**：

- 一次 PR 同时改 P4 表达式全栈 + P8 入口。  
- 无门禁合并 stretch suite。  
- 与 `invoke_cc`/`invoke_ld` 同批大改（跨 mega）。

---

## 6. 首个可运行切片规格（建议：P2 let/alias）

### 6.1 范围

| 项 | 说明 |
|----|------|
| 现有 | `parser_asm_body_let_slice.inc` / `top_level_let` / `type_alias` |
| 目标形态 | `seeds/pthin_let_alias.from_x.c` + `src/asm/pthin_let_alias.x`（或保留 inc 名 + hybrid 宏） |
| mega | `#ifndef SHUX_PTHIN_LET_ALIAS_FROM_X` 包住 `#include` 或内联体 |

### 6.2 非范围

- stretch suite  
- seed_parse_into_buf  
- expr primary 全量  

### 6.3 门禁（P2 落地时）

```bash
cd compiler
# 默认产品
G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
# prefer hybrid（落地后）
SHUX_G05_PREFER_X_O=1 G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
# 最小：nm 导出 + hello/lang-unsafe 双绿（与现 G05 口径一致）
nm -g parser_asm_thin_glue.o | head
```

双平台：**macOS arm64 + Ubuntu x86_64**。

---

## 7. 永久 seed / 语言限制（🔒 登记）

| 类别 | 例子 | 策略 |
|------|------|------|
| Stretch audit suite | `*_stretch_suite_slice.inc` ≈28k | 审计宏；默认产品可不展开/不 hybrid |
| 布局锁死 struct | `parser_asm_token` / `OneFuncResult` padding | 注释 + 测试；真迁须与 `parser.x` 同批 |
| 深循环 / 递归 skip | balanced delim 超深 | 可留 C；或分册但禁止「伪 .x」空壳 |
| 与 gen C ABI | `parser_gen` / `lexer_gen` 字段序 | 变更必须 gen 同步或禁止 |

---

## 8. 风险与缓解

| 风险 | 缓解 |
|------|------|
| 22k+28k 体量 | **按册**；suite 单独轨 |
| include 顺序敏感 | 保持现有 `#include` 序；hybrid 仅替换一册 |
| G05 51 抖动 | 不增正式 obj；只 `ld -r` 合成 |
| X emit 与 thin 双路径语义漂移 | 每册落地前后 hello + 相关 gate；优先对照 `parser.x` 行为 |
| 误删 `NO_SEED_PARSE` | ensure/Makefile 注释钉死；CI 编失败即红 |

---

## 9. 与跟进表编号

| 编号 | 含义 |
|------|------|
| **f-278 / f-304** | **本文 RFC**（God-View + 切片序） |
| **f-279+ / f-305+** | 按 §5 每步一册真迁（首荐 P2 let/alias） |
| Wave C 原 f-304 | 与 f-278 合并记账：RFC 已写即勾选 |

---

## 10. 验收（RFC 本身）

- [x] 量化主 seed + 物理 slice 表  
- [x] P0–P9 边界与 🔒  
- [x] 拆分策略（A hybrid / 不默认 prefer）  
- [x] 真迁顺序与禁止项  
- [x] 首切片规格 + 双平台门禁命令  
- [ ] 代码步：f-279 P2 let/alias（后续 commit）

---

## 11. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-11 | f-278 / f-304 初版：parser thin God-View；承认 `seeds/parser_asm/*_slice.inc` 为 A0；首迁 P2 let/alias；suite stretch 后置 |
| 2026-07-11 | **f-279 P2 let/alias 落地**：`pthin_let_alias.x` + `seeds/pthin_let_alias.from_x.c`（include body_let/top_level_let/type_alias）；`SHUX_PTHIN_LET_ALIAS_FROM_X`；prefer hybrid `P2+rest → parser_asm_thin_glue.o` |
| 2026-07-11 | **f-280 P3 type_ref 落地**：`pthin_type_ref.*`（type_ref_slice.inc）；`SHUX_PTHIN_TYPE_REF_FROM_X`；rest 保留 `ast_Type`/TypeKind；prefer hybrid **P2+P3+rest** |
| 2026-07-11 | **f-281 P1 lex/skip 落地**：`pthin_lex_skip.*` + `parser_asm_lex_skip_slice.inc`（lex_from_result / copy_slice / skip_balanced / skip_generic_angle / is_*_token）；`SHUX_PTHIN_LEX_SKIP_FROM_X`；`lex_from_result_val_into` 升为非 static（expr 各 slice 去掉 static 前向）；prefer hybrid **P1+P2+P3+rest** |
| 2026-07-11 | **f-282 P4 primary 首册**：`pthin_expr_primary.*`（`finish_struct_lit`+`primary` 同 TU，因 static `parse_struct_lit_fields`）；`SHUX_PTHIN_EXPR_PRIMARY_FROM_X`；prefer hybrid **P1+P2+P3+P4primary+rest** |
| 2026-07-11 | **f-283 P4 unary**：`pthin_expr_unary.*`（unary_slice.inc）；`SHUX_PTHIN_EXPR_UNARY_FROM_X`；prefer hybrid **P1–P4unary+rest** |
| 2026-07-11 | **f-284 P4 binop**：`pthin_expr_binop.*`（term…logor 十级）；`SHUX_PTHIN_EXPR_BINOP_FROM_X`；prefer hybrid **P1–P4binop+rest** |
| 2026-07-11 | **f-285 P4 收口**：`pthin_expr_as_suffix.*` + `pthin_expr_ternary.*`；`SHUX_PTHIN_EXPR_AS_SUFFIX_FROM_X` / `SHUX_PTHIN_EXPR_TERNARY_FROM_X`；prefer hybrid **P1–P4 全 + rest**（expr 册齐） |
| 2026-07-11 | **f-286 P5 ctrl**：`pthin_ctrl.*`（if_stmt + match_subject + if_expr；simd 仍 rest）；`SHUX_PTHIN_CTRL_FROM_X`；rest 保留 `parse_block_result`；prefer hybrid **P1–P5+rest** |
| 2026-07-11 | **f-287 P6 fn/block**：`pthin_fn_block.*`（struct_layout + library + one_function_buf + block_from_res）；`SHUX_PTHIN_FN_BLOCK_FROM_X`；library scan 仍 rest；prefer hybrid **P1–P6+rest** |
| 2026-07-11 | **f-288 P7 simd**：`pthin_simd.*`（simd_builtin_slice）；`SHUX_PTHIN_SIMD_FROM_X`；从 CTRL 块旁路独立出来；prefer hybrid **P1–P7+rest** |
