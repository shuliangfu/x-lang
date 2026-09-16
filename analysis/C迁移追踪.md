# C → .X 迁移追踪（状态待办地图）

> **用途**：终局债 **状态 only**（✅／🟡／⬜ + 短事实）。  
> **禁止**：tip 流水账、wave／SHA 日记、双端日志、「证：…」长叙事。波次流水只写 [`自举进度.md`](自举进度.md) §6。  
> **考古全文**（瘦身前）：[`archive/C迁移追踪-流水账归档-20260910.md`](archive/C迁移追踪-流水账归档-20260910.md) · 更早：[`archive/C迁移追踪-流水账归档-20260825.md`](archive/C迁移追踪-流水账归档-20260825.md)  
> **刷新**：2026-09-10 · tip **`736960fe0`** · 钉盘 **`5cac88d00`**

### 维护约定

1. 做到 → **🟡**；完成 → **✅**；未开 → **⬜**。  
2. ✅ 只留 **编号＋一句话标题**；🟡／⬜ 可加一两句路径／验收条件。  
3. **禁止**往本文追加「本波做了什么」／验收流水／SHA 日记。  
4. MG／Makefile 叶映射 → [`Makefile迁移表.md`](Makefile迁移表.md)。

---

## 0. 仪表盘

| 轨道／债 | 状态 | 事实（短） |
|----------|------|------------|
| 库层 .X 化（阶段 1） | ✅ | 100% |
| Thin 退役（阶段 2） | ✅ | T 18/18 |
| Prove 注册（阶段 3） | ✅ | N 111/111 |
| Cap 能力解锁（阶段 4） | 🟡 | 3 leave-off ⬜ |
| R2 真迁（阶段 5） | 🟡 | ~120/128；余绑平台债 |
| Mega 拆分 M1–M3（阶段 6） | ✅ | 3/3 |
| Mega 去 pin M4（阶段 7） | 🟡 | 冷链关 pin；**7.2.1b leftover flatten 完**；深链分批覆盖戏停；**已 T 缩壳**：P9 hybrid 跳过 suite 46k；**Route C 产品化**：P9b stretch lite＋P1b lex_skip＋P19b helpers＋**P19c run_len extra／lex_at_token／rewind**＋**P19d struct_field_name／ident_is_unsafe**＋**P19e align_lex（in-place _into_c；P9a 门同 P5d/P12b）**＋P4b primary ident＋P3b type_ref＋**P3c type-inst mangle**＋**P3d consume_qualified／angle close**＋**P3e TYPE_DYN wrap dest-buffer**＋**P3g postfix array/slice dest-buffer**＋**P3h prefix `[N]T`／`[]T` dest-buffer**＋**P3i type-position `function(...): Ret` dest-buffer**＋**P3j prefix `*T` dest-buffer**＋P7b simd ident pack／callee 名＋**P7c simd callee+CALL wrap dest-buffer**＋**P7d simd parse dest-buffer**＋P4ub unary TOKEN→ExprKind＋**P4uc unary wrap dest-buffer**＋**P4ud unary parse dest-buffer**＋P4bb binop TOKEN→ExprKind＋**P4bc binop wrap dest-buffer**＋**P4bd binop parse dest-buffer**＋**P4tb ternary wrap dest-buffer**＋**P4as as_suffix wrap dest-buffer**＋**P4ad as_suffix parse dest-buffer**＋**P4tc assign wrap dest-buffer**＋**P4td ternary parse dest-buffer**＋**P4te assign parse dest-buffer**＋**P4bh remaining parse_primary dest-buffer**＋**P4bi parse_struct_lit_fields dest-buffer**＋**P5g match wrap dest-buffer**＋**P5h match subject parse dest-buffer**＋**P5i match struct-fields parse dest-buffer**＋**P5j parse_match_into dest-buffer**＋**P6e parse_struct_record_layout dest-buffer**＋**P2b parse_one_top_level_let／type_alias dest-buffer**＋**P2c parse_cond_expr dest-buffer**＋**P5k leftover if_stmt C twin T-shrink**＋P14b skip_if 走查＋**P14c module_try_register_enum_name**＋**P6b struct_layout name-match**＋**P6c packed／soa modifiers**＋**P6d library wrap dest-buffer**＋P12b skip_tl struct／enum／extern 走查＋**P12c skip_one_impl dest-buffer**＋**P12d generic_bound_scan dest-buffer**＋**P12e skip_one_enum_register／append_variants**＋**P12i skip_name_is_self／self_matches_for**＋**P12j named_eq_self／rewrite_self**＋**P12k register_type_params／type_param_index**＋**P12l concrete_implements_trait**＋**P12m bound_check_type_args**＋**P12n impl-seen accessors**＋**P12o bound_check**＋**P12p F3 lookup**＋**P12q F3 simple getters**＋**P12r dest-extras elem_array_dim**＋**P12s method_on_param**＋**P12t skip_hoist_default_methods**＋**P12u trait_check_impls_complete**＋P18b body_tl scalar 表＋let／const／if skip 走查＋P10b glue skip_one_function_full 走查＋P13b try_skip_allow padding 走查＋P11b skip_imports 走查＋P5b if_stmt 注释感知花括号字节扫描／kw_at_pos＋P5c scan_sync pos＋**P5e match_dest_enum_tag**＋**P5f parse_if_expr**＋P15b library_scan＋P17b diag_late after_structs／fail＋**P11c consume_path／try_skip**（g05 `-E`+cc，pure-asm CG002）＋**P11d collect_imports dest-buffer**（copy_token_bytes 已 P1f；g05 `-E`+cc，pure-asm CG002）＋**P18c cfg_skip／diag_first_ident**＋**P18d P010–P014／dup**（msg 表仍 C＝STRING_LIT 64B；sticky 仍 C；g05 `-E`+cc）＋**P1c skip_generic_angle_list_count**（g_gp_pending_*／register_pending 仍 C；g05 `-E`+cc，pure-asm CG002）＋**P1d ASI advance_past_stmt_semicolon／cond_rparen**（rewind／run_len／align／first_token 仍 C；g05 `-E`+cc，pure-asm CG002）＋**P1e parse_peek_function_name／first_token_kind**（rewind／run_len／align 仍 C；g05 `-E`+cc，pure-asm CG002）＋**P17c G.7 diag_skip_let_const_buf trampoline over P18b into**；残＝产品 `.inc` 切片仍 host-cc（含 glue_tail 包装、skip_tl skip_one_trait／parse_one_extern、try_skip_allow parse_into、if_stmt parse／realign；P12g 后 skip_one_trait 已纯 asm 默认）、lite／suite／lex_skip／helpers／primary ident／type_ref／simd／unary／binop／skip_if walks／skip_tl struct／enum／extern／impl header／body_tl skip／glue skip_one_function_full／try_skip_allow padding／skip_imports／consume_path／try_skip／collect_imports／ctrl brace-skip／scan_sync／library_scan／diag_late after_structs／fail／body_tl cfg_skip／diag_first_ident／lex_skip count portable 冷回退、`parser_asm_thin_c.from_x.c` 443KiB 仅冷 rest 回退；parser seed 物理删 ⬜ |
| Pinned gen 退役（阶段 8） | ✅ | 30/30 FULLY CLOSED |
| 非 gen 产品 C／8.3 | ✅ | `pipeline_x` mega **已 wave309 从产品链退役**（g05 恒 skip；残留仅 .bak/mk）——旧表「仍 host-cc」系陈旧 |
| Cap residual 消灭（阶段 9） | ✅ | 9.1–9.7 全系列 ✅ |
| 语言能力 L2（阶段 10） | 🟡 | 主面多 ✅；残 NT／MSVC／qemu／Win 实机 |
| xbuild／MG（阶段 11） | 🟡 | Makefile 物理删 ✅；终局／零 cc CI 仍开 |
| 冷启动零 cc（阶段 12） | 🟡 | LINK／`.s` 大半 ✅；全路径零 cc ⬜ |
| 终局 MG+BC+PC+v2==v3（阶段 13） | 🟡 | MG 文件层 ✅；BC／PC／v2==v3 未终 |
| 产品 L4 钉盘 | ✅ | **`5cac88d00`**（双端 L4＋bstrict 129） |
| BC（编译层零 host-cc） | ✅ | `pipeline_x` 已退役（wave309）——BC 面余量转 8.3.6 冷孪生三分 |
| PC（产品默认 asm） | 🟡 | 门控已收；`labi_invoke_cc` 未删 |
| `pipeline_abi` mega pure-asm | ⬜ 硬禁 | 已知 hang／CG002 地雷（不只是点名手续） |
| nest 冻帽 | ✅ 纪律 | **64** |
| check 闸门 | ⏸ 暂停 | 自举期须点名才 dogfood |

**终局三义**：MG ✅ · BC 🟡 · PC 🟡。

---

## 阶段 0–3 · 已闭

- ✅ **阶段 0** 基建与方法论  
- ✅ **阶段 1** 库层 .X 化  
- ✅ **阶段 2** Thin 退役 T 18/18  
- ✅ **阶段 3** Prove 注册 N 111/111  

---

## 阶段 4 · Cap 能力解锁 🟡

### 已闭

- ✅ Cap dest／dyn／nest17–64／METHOD／STRUCT_LIT 等主面（细节见归档）

### 开项

- 🟡 **4.2.8** AST name 槽 128B→256B layout raise（content 127→255）— **下波主刀**（v5.29 absolute L012 墙；解锁余 18＋control_flow ultimate buf）  
- ⬜ **4.2.9** LANG-006 标量 bool→int — 有意保留 soft  
- ⬜ **4.2.16** `*T[N]` 解析序 — 有意保留 soft（`*[N]T`＝指针到数组）  

### 纪律

- nest **冻 64**；禁抬 nest 65；禁无界 assemble mega 当冷路径  

---

## 阶段 5 · R2 真迁 🟡

- ✅ 已真迁 ~120／128 prove 模块  

### 开项

- ⬜ **5.2.2** Darwin stage2 rv／strict multi-def  
- ⬜ **5.2.3** host `_impl` 后缀命名 — leave-off  
- ⬜ **5.2.4** Darwin `int64_t main` 硬要求 int  
- ⬜ **5.2.5** Windows MSYS2 hybrid 未重跑  
- ⬜ **5.2.6** mac CTFE 常 fold 假绿  
- ⬜ **5.2.7** mac `-dead_strip` 假绿当 Ubuntu 全链已过  

---

## 阶段 6 · Mega 拆分 M1–M3 ✅

- ✅ **6.1** runtime mega 拆分  
- ✅ **6.2** parser thin mega 拆分  
- ✅ **6.3** link_abi mega 拆分  

---

## 阶段 7 · Mega 去 pin（M4）🟡

### 已闭

- ✅ **7.1** runtime monofile 物理退役  
- ✅ **7.2.1a** 入口素材 70 件清零（11 迁 `.x`＋10 D 类＋1 回滚卡）  
- ✅ **7.2.3／7.3／7.4.1／7.4.2／7.4.3** 冷链／Stage2／prefer `.x`  
- ✅ **7.4.4** 双权威闸全家族（v1 drift-gate／v2 pin-mtime／v3 `-lib-name`＋driver_gen 再生／CI＋staged-diff）  
- ✅ **7.4.5–7.4.10** typeck pin 孪生／leftover PE unique 0  

### 开项

- 🟡 **7.2.1b** parser_asm suite audit B-minus — leftover flatten **完**（unique 0／helpers 0）；深链分批覆盖戏停；**已 T 缩壳**：P9 hybrid 跳过 suite 46k；**Route C 产品化**：P9b 编 `pthin_stretch.x` 跳过 lite；P1b 编 `pthin_lex_skip.x` 跳过 kind／copy／skip_walk；**P1c** 有则补全 skip_generic_angle_list_count（g_gp_pending_*／register_pending 仍 C；g05 `-E`+cc，pure-asm CG002）；**P1d** 有则补全 ASI advance_past_stmt_semicolon／cond_rparen（rewind／run_len／align／first_token／peek_function_name 仍 C；C trampoline 在 helpers.inc；g05 P19 带 P1 BODIES 宏；禁给 P19 加 P9a 硬闸；g05 `-E`+cc，pure-asm CG002）；**P1e** 有则补全 parse_peek_function_name／first_token_kind（rewind／run_len／align 仍 C；禁包 leftover peek-name AUDIT；g05 `-E`+cc，pure-asm CG002）；**P1f** 有则补全 copy_token_bytes 128 零填（slice trampoline 留 imports.inc；禁并进 param32／name64）；P19b 编 `pthin_helpers.x` 跳过 kind／copy／pos／match-kw；**P19c** 有则补全 run_len extra／lex_at_token pos／rewind kind（align／ident_is_unsafe_stmt／parse_block_return_end_tail 仍 C；禁并进 stretch run_len；禁给 P19 加 P9a 硬闸；g05 `-E`+cc，pure-asm CG002）；**P19d** 有则补全 struct_field_name／ident_is_unsafe（align／parse_block_return_end_tail 仍 C；禁并进 P4b；g05 `-E`+cc，pure-asm CG002）；P4b 编 `pthin_expr_primary.x` 跳过 ident 拼写／asm-option-bit；P3b 编 `pthin_type_ref.x` 跳过 token_starts_type／ident_is_dyn／builtin TypeKind／vector IDENT pack；P7b 编 `pthin_simd.x` 跳过 shuffle／select ident pack／callee 名填充；P4ub 编 `pthin_expr_unary.x` 跳过 TOKEN→ExprKind；P4bb 编 `pthin_expr_binop.x` 跳过 TOKEN→ExprKind；P14b 编 `pthin_skip_if.x` 跳过 trait／impl＋if-core／statement 走查；**P14c** 有则补全 module_try_register_enum_name（hybrid 跳过 C 孪生；P12e 仍 extern；sidecar＝pipeline_module_enum_*）；P12b 编 `pthin_skip_tl.x` 跳过 skip_one_struct／enum／extern 走查；**P12c** 有则补全 skip_one_impl dest-buffer（skip_one_trait／generic_bound／enum_register 仍 C；g05 `-E`+cc，pure-asm CG002）；**P12d** 有则补全 generic_bound_scan dest-buffer（skip_one_trait／enum_register／parse_one_extern 仍 C；g05 `-E`+cc，pure-asm CG002）；**P12e** 有则补全 skip_one_enum_register／append_variants（skip_one_trait／parse_one_extern 仍 C；g05 `-E`+cc，pure-asm CG002）；P18b 编 `pthin_body_tl.x` 跳过 is_fn_sig_scalar＋diag／body skip 走查＋skip_one_top_level let／const；**P18c** 有则补全 cfg_skip／diag_first_ident（P010–P014／onefunc_param_name_dup 当时仍 C；pure-asm 过）；**P18d** 有则补全 P010–P014／onefunc_param_name_dup（msg 表 parser_body_tl_p0xx_msg_c 仍 C＝bootstrap STRING_LIT 64B；sticky／allow_bare_self／cur_module 仍 C；g05 `-E`+cc）；**P10b** 编 `pthin_glue.x` 跳过 skip_one_function_full 走查（glue 包装仍 C；pure-asm 过）；**P13b** 编 `pthin_try_skip_allow.x` 跳过 padding 走查（write_result／parse_into 仍 C；pure-asm 过）；**P11b** 编 `pthin_imports.x` 跳过 skip_imports 走查；**P11c** 有则补全 consume_path／try_skip（g05 `-E`+cc，pure-asm CG002）；**P11d** 有则补全 collect_imports dest-buffer（copy_token_bytes 已 P1f；语言无 local u8[N]，C trampoline 持 128 字节 dest buf；module 写入走既有 pipeline_module_import_*；g05 `-E`+cc，pure-asm CG002）；**P5b** 编 `pthin_ctrl.x` 跳过注释感知花括号字节扫描／kw_at_pos；**P5c** 有则补全 scan_sync pos（parse／realign／match／if_expr 仍 C；parse AUDIT 前缀仅 audit 宏；g05 `-E`+cc，pure-asm CG002）；**P15b** 编 `pthin_library.x` 跳过 library_scan 走查（into／buf parse／lex_from 仍 C；into／buf AUDIT 前缀仅 audit 宏；pure-asm 过）；**P17b** 编 `pthin_diag_late.x` 跳过 after_structs／fail_at_token_kind 走查（buf AUDIT 前缀仅 audit 宏；pure-asm 过）；**P17c** G.7 `diag_skip_let_const_buf` trampoline over P18b into（body_skip_buf 已是 trampoline；禁新 .x 导出）；残＝产品 `.inc` 切片仍 host-cc、lite／suite／lex_skip／helpers／primary ident／type_ref／simd／unary／binop／skip_if walks／skip_tl struct／enum／extern／impl header／body_tl skip／glue skip_one_function_full／try_skip_allow padding／skip_imports／ctrl brace-skip／scan_sync／library_scan／diag_late after_structs／fail portable 冷回退、`parser_asm_thin_c.from_x.c` 443KiB 仅冷 rest 回退（G-02f-330 omit rest）；PP002 heap entry ✅；import ctx 4MiB heap orch ✅；resolve_read embed 诚实拒 ✅  
  - ✅ ABI＝B-minus（opaque＋lexer-step 桥；RFC §5）  
  - ✅ 桥面／P9a／三契约／生成器 v1→v5.7／等价 harness  
  - ✅ 栈 kinds[]／peek_kind_chain 根（toplevel_kind_peek 族）  
  - ✅ parse_suite 可迁面 1936／1936（v5.38 L012-fit compress＋攀尽）  
  - ✅ out 参族 9／9（＋trait_methods；生成器 v5.0 elide void `&r.next_lex`）  
  - ✅ array／slice bracket 头粗探（同波双步进根修解锁）  
  - ✅ 深链组合器首批（v5.1：score+=／负字节链／拒 advance_to；诚实＋34；trait_impl 红未入）  
  - ✅ 厚 buf score 墙首批（v5.2：`&sl,`／`&lex, data, len`／尾旗／`&out`→0；诚实＋15）  
  - ✅ advance_to 薄展开首批（v5.3：struct/enum/trait/match body＋buf；诚实＋7）  
  - ✅ peek_ident_ptr 源字节根修＋impl_type 族（v5.4：诚实＋12）  
  - ✅ function_advance 展开（v5.5：诚实＋9）  
  - ✅ after_imports／deep-scan（v5.6：诚实＋27）  
  - ✅ if_stmt_body 混用游标＋layout_name（v5.7：诚实＋34）  
  - ✅ PP002 heap entry（preprocess_x_buf *u8 尊 source_len／out_cap；malloc_impl scratch=max(4MiB, raw_len) i32-fit；PipelineDepCtx embed 4MiB pin 不动）  
  - ✅ leftover helper Route C 首批（v5.39：bind 薄包装／kind 分类／skip_allow inout；诚实＋19；余 advance_to／lexer_result）  
  - ✅ leftover helper Route C flatten（v5.40：spawn_kw／brace_head／import_dot／match_subject_ident；诚实＋4；拒 import_path_post finalize 链；余 advance_to／next_lex／peek_kind）  
  - ✅ leftover helper Route C flatten lookahead（v5.41：simd_builtin／import_as；诚实＋2；拒 from_at paren 走／peek_kind／validate／path_post／advance_to）  
  - ✅ leftover helper Route C flatten from_at（v5.42：lookahead 标量＋lex_after_ident 走 paren；诚实＋1；拒 peek_kind／validate／path_post／advance_to）
  - ✅ leftover helper Route C flatten peek_kind_chain（v5.43：kinds 数组＋指针游标；诚实＋1；拒 validate／path_post／advance_to）
  - ✅ leftover helper Route C flatten expr_binop_kinds_probe（v5.44：kinds 匹配集＋指针游标；诚实＋1；拒 validate／path_post／advance_to）  
  - ✅ leftover helper Route C flatten skip_* 链（v5.45：skip_balanced／skip_type_suffix／skip_one_param_type 指针 ABI；诚实＋3；拒 validate／path_post／advance_to）
  - ✅ leftover helper Route C flatten advance_to 族（v5.46：struct／enum／trait／impl／if／function／match 指针 ABI；诚实＋7；拒 validate／path_post／collect_imports／mega_buf）
  - ✅ leftover helper Route C flatten mega_buf wrap_buf（v5.47：diag_fn_mega_full_deep_buf 薄包装；诚实＋1；拒 validate／path_post／collect_imports）
  - ✅ leftover helper Route C flatten import leftover 链（v5.48：import_path_post validate 薄包装＋collect_imports kinds＋classify；诚实＋2；拒 validate_toplevel）
  - ✅ leftover helper Route C flatten validate_toplevel（v5.49：kind／ident_len／token_start 标量＋桥 bounds；诚实＋1；不抄 token_run_len／verify_kw 表；leftover-to-audit unique 0）
  - ✅ import ctx 4MiB heap orch（pin-safe：load_import_from_disk_c 改 view＋PP002 malloc；seed impl_c 同语义；C thin overlay WEAK `_c`；PipelineDepCtx embed 4MiB 不动）
  - ✅ resolve_read embed 诚实拒（pipeline_read_file_x 改 view＋拒 length>4MiB；seed 同语义；C thin overlay WEAK `pipeline_read_file_x`；pin embed 不动；产品 import 仍走 heap orch）
  - ✅ leftover_helpers kind-scalar eq（v5.50：6／30；独立 TU 穷尽 TokenKind，避开 twins.h static 阴影；classify／score 留 stretch.x；余 24＝name/len／source+off／复合 ABI）
  - ✅ leftover_helpers name/len eq（v5.51：8／30；独立 TU ident 字节类＋长度角，避开 twins.h static 阴影；C twin 薄包 bind_name_validate；classify／score 留 stretch.x；余 16＝source+off／复合 ABI）
  - ✅ leftover_helpers source+off eq（v5.52：6／30；独立 TU ident 字节类＋长度＋token_start 角，避开 twins.h static 阴影；C twin 薄包 bind_name_validate on data+off；vector_type_ident 加 i3x*／Vec*；classify／score 留 stretch.x；余 10＝复合 ABI）
  - ✅ leftover_helpers kind+source+off eq（v5.53：2／30；独立 TU 穷尽 TokenKind＋IDENT ident 字节类／长度／token_start 角，避开 twins.h static 阴影；C twin 薄包 bind_name_validate on data+off；import_dot_segment 加 I32／ASYNC 恒 1；classify／score 留 stretch.x；余 8＝复合 ABI）
  - ✅ leftover_helpers two-kind+source+off eq（v5.54：1／30；独立 TU 穷尽 TokenKind at／ident 各一维＋AT+IDENT shuffle／select 拼写／长度／token_start 角，避开 twins.h static 阴影；C twin 拼写检查非 bind_name_validate；classify／score 留 stretch.x；余 7＝复合 ABI）
  - ✅ leftover_helpers 7-param as-bind eq（v5.55：1／30；独立 TU 穷尽 TokenKind kind／next_kind 各一维＋IDENT+"as" 拼写／长度／token_start 角＋next-ident 字节类／长度／next_start 角；7 参 first-kind ABI 不能进 k_cases；C twin 拼写检查＋bind_name_validate on data+next_start；classify／score 留 stretch.x；余 6＝复合 ABI）
  - ✅ leftover_helpers kinds-array eq（v5.56：2／30；独立 TU 短 snippet＋guard／max_peek／num_kinds 角＋若干 start-pos，避开 twins.h static 阴影；C twin 拷 *lex＋lexer_next_into；.x peek/step/restore；peek_kind_chain_buf 仍是 lex-first k_cases；classify／score 留 stretch.x；余 4＝复合 ABI 单件）
  - ✅ leftover_helpers validate_toplevel eq（v5.57：1／30；独立 TU 穷尽 TokenKind ident_len≤0／in-span／overflow＋ident_len／token_start／slen 角含 wrap；无 twins.h static；first-kind ABI 不能进 k_cases；C twin EOF／ident_len≤0／span；不抄 token_run_len／verify_kw 表；classify／score 留 stretch.x；余 3＝复合 ABI 单件）
  - ✅ leftover_helpers import_path_post eq（v5.58：1／30；独立 TU ident 字节／点／非法字节／长度角含 path_len>63 cap；无 twins.h static；first-path_buf ABI 不能进 k_cases；C twin 薄包 import_path_validate；不抄 ident_continue 表；classify／score 留 stretch.x；余 2＝preamble／from_at）
  - ✅ leftover_helpers collect_imports_preamble eq（v5.59：1／30；独立 TU 穷尽 TokenKind 每槽一维＋classify-hit 小笛卡尔＋null／live／nodata／empty；无 twins.h static；first-kind ABI 不能进 k_cases；C twin 薄包 classify_toplevel；不抄 classify 表；诚实 flatten＝live source→1／null→0；classify／score 留 stretch.x；余 1＝from_at）
  - ✅ leftover_helpers simd_builtin_deep_from_at eq（v5.60：1／30；独立 TU 穷尽 TokenKind null lex＋AT+IDENT ident 角＋短 live-lex snippet；twins.h static 阴影；first-at_kind ABI 不能进 k_cases；C twin 薄组合 simd_builtin／vector_type_ident／paren_expr_head／builtin_vec_token；不抄 classify／score 表；诚实 flatten＝C 空 lex 跳 paren／.x paren 空 lex→0；IDENT remaining≥ident_len；classify／score 留 stretch.x；余 0）
  - ✅ 深链分批 smoke ultra_mega 层（v5.61：25／270 soft-deep；exact ultra_mega 非 HARD BAN 子串；daily 默认 SKIP_SYNTH=1＋STRIDE=4；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝super_mega 25／270）
  - ✅ 深链分批 smoke super_mega 层（v5.62：25／270 soft-deep；exact super_mega 非 HARD BAN 子串、不在 is_deep_climb_name；daily 默认 SKIP_SYNTH=1＋STRIDE=4；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝hyper_mega 须精确过滤禁吞 ultra_hyper）
  - ✅ 深链分批 smoke hyper_mega 层（v5.63：25／270 soft-deep；exact hyper_mega 非 HARD BAN 子串、在 is_deep_climb_name；harness eq_tok_hits_name 拒 ultra_ 前缀吞 575；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝ultra_hyper 须精确过滤禁吞 max_ultra）
  - ✅ 深链分批 smoke ultra_hyper 层（v5.64：25／270 soft-deep；exact ultra_hyper 非 HARD BAN 子串、在 is_deep_climb_name；harness eq_tok_hits_name 拒 max_ 前缀吞 550；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝max_ultra 须精确过滤禁吞 apex_max）
  - ✅ 深链分批 smoke max_ultra 层（v5.65：25／270 soft-deep；exact max_ultra 非 HARD BAN 子串、在 is_deep_climb_name；harness eq_tok_hits_name 拒 apex_ 前缀吞 525；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝apex_max 须精确过滤禁吞 summit_apex）
  - ✅ 深链分批 smoke apex_max 层（v5.66：25／270 soft-deep；exact apex_max 非 HARD BAN 子串、在 is_deep_climb_name；harness eq_tok_hits_name 拒 summit_ 前缀吞 500；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝summit 仍 HARD BAN 禁 daily）
  - ✅ 深链分批 smoke crown_pinnacle 层（v5.67：25／270 soft-deep；EQ_ONLY 非 HARD BAN 子串、pinnacle／crown 在 is_deep_climb_name；跳过 HARD BAN 层 summit／peak／zenith／pinnacle_zenith；harness eq_tok_hits_name 拒 supreme_ 前缀吞 375；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝supreme_crown 须精确过滤禁吞 ultimate_supreme）
  - ✅ 深链分批 smoke supreme_crown 层（v5.68：25／270 soft-deep；EQ_ONLY 非 HARD BAN 子串、crown 在 is_deep_climb_name；跳过 HARD BAN 层 summit／peak／zenith／pinnacle_zenith；harness eq_tok_hits_name 拒 ultimate_ 前缀吞 350；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝ultimate_supreme 须精确过滤禁吞 absolute_ultimate）
  - ✅ 深链分批 smoke 3 层 75／150（v5.69 收口后 **停**：覆盖戏不减 host-cc；续＝8.3.6／已 T 冷孪生缩壳，禁再 eq 已 T combinator）
  - ✅ 已 T 冷孪生缩壳起步（P9 hybrid 跳过 suite 46k 预处理；classify／score 迁 lite；冷 lane 仍 include suite；禁再 eq 已 T combinator）
  - ✅ Route C 产品化（P9b 编 `pthin_stretch.x`；hybrid 跳过 lite 564 行；token.h `_Static_assert` 钉 classify 针；冷 lane 仍 include lite；禁再 eq 已 T combinator）
  - ✅ P1b Route C＋B-minus（编 `pthin_lex_skip.x`；hybrid 跳过 kind／copy／skip_balanced／generic_into；token.h `_Static_assert`；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P1c B-minus（`pthin_lex_skip.x` 有则补全 skip_generic_angle_list_count；hybrid 跳过 C 孪生；g_gp_pending_*／register_pending 仍 C；语言无 global u8[8][64]，C trampoline 持 dest buf 再写入静态表；依赖 P9a 桥；g05 `-E`+cc，pure-asm CG002 同 P1b；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_generic_angle_list_into；禁开新 P 道）
  - ✅ P1d B-minus（`pthin_lex_skip.x` 有则补全 advance_past_stmt_semicolon／advance_past_cond_rparen；hybrid 跳过 helpers.inc C 孪生；rewind／run_len／align／first_token／peek_function_name 仍 C；C trampoline 在 helpers.inc 回放 lexer_next_into 填 *r_out；g05 P19 编译带 P1 BODIES 宏（禁给 P19 加 P9a 硬闸）；依赖 P9a 桥；g05 `-E`+cc，pure-asm CG002 同 P1b／P1c；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁把 helpers ident_is_unsafe_stmt 并进 P4b buf；禁开新 P 道）
  - ✅ P1e B-minus（`pthin_lex_skip.x` 有则补全 parse_peek_function_name／first_token_kind；hybrid 跳过 helpers.inc C 孪生；rewind／run_len／align 仍 C；first_token_kind_buf 仍 wrap over slice（AUDIT 仅 audit 宏）；C trampoline 在 helpers.inc（buf 包 slice；first_token 先 lexer_init）；语言无 lexer_init／local u8[N]；g05 P19 带 P1 BODIES 宏（禁给 P19 加 P9a 硬闸）；依赖 P9a 桥＋P1b copy；g05 `-E`+cc，pure-asm CG002 同 P1b／P1c／P1d；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁包 leftover peek-name AUDIT；禁开新 P 道）
  - ✅ P1f Route C（`pthin_lex_skip.x` 有则补全 copy_token_bytes 128 字节零填行；hybrid 跳过 lex_skip.inc C 孪生；历史 slice 名 `parser_asm_copy_token_bytes_to_buf64` 留 imports.inc trampoline；禁并进 param32（宽 256）／name64（不补零）；register_pending 仍 C；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁开新 P 道；禁抄 copy 循环）
  - ✅ P19b Route C（编 `pthin_helpers.x`；hybrid 跳过 kind／copy／pos／match-kw；`first_token_kind_buf` 已 T AUDIT 探针仅 audit 宏；rewind／run_len／align／first_token／peek_function_name 仍 C；advance_past 已 P1d；token.h `_Static_assert`；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P19c Route C（`pthin_helpers.x` 有则补全 run_len extra／lex_at_token pos／rewind kind；hybrid 跳过 helpers.inc C 孪生；align／ident_is_unsafe_stmt／parse_block_return_end_tail 仍 C；C trampoline 持 by-value lexer／token ABI；双编号保留：stretch compact 表先、token.h extra 在 .x，禁并进 stretch run_len；禁给 P19 加 P9a 硬闸；禁把 ident_is_unsafe 并进 P4b；g05 `-E`+cc，pure-asm CG002 同 P19b；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁开新 P 道）
  - ✅ P19d Route C（`pthin_helpers.x` 有则补全 struct_field_name／ident_is_unsafe；hybrid 跳过 helpers.inc C 孪生；align／parse_block_return_end_tail 仍 C；C trampoline 持 by-value lexer_result；IDENT 字段名走 P1b at_end copy（禁再抄 copy_slice）；禁给 P19 加 P9a 硬闸；禁把 ident_is_unsafe 并进 P4b；g05 `-E`+cc，pure-asm CG002 同 P19b／P19c；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁开新 P 道）
  - ✅ P4b Route C（编 `pthin_expr_primary.x`；hybrid 跳过 ident 拼写／asm-option-bit；`parse_primary_into` 已 T AUDIT 探针仅 audit 宏；parse／arena 仍 C；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P3b Route C（编 `pthin_type_ref.x`；hybrid 跳过 token_starts_type／ident_is_dyn／builtin TypeKind／vector IDENT pack；parse／arena 仍 C；skip_tl TOKEN→TypeKind 转调同一表；token.h `_Static_assert`；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P3c B-minus（`pthin_type_ref.x` 有则补全 type-inst mangle dest-buffer；hybrid 跳过 C 孪生；C trampoline 在 primary.inc 持 suf[64]；parse／suffix_loop 仍 C 调历史 7-arg；禁并 codegen／typeck suffix；禁抄进 parse；禁开新 P 道；禁碰 P4b pending_n；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P3d B-minus（`pthin_type_ref.x` 有则补全 consume_qualified IDENT 路径＋type_angle_close GT／`>>`；hybrid 跳过 C 孪生；C trampoline 持 lexer_result／转发 next_lex＋first ident_len；walk 走既有 P9a peek／step；名拷贝走 P1b at_end；parse_type_ref 仍 C；禁抄 copy 循环为第二套权威；禁开新 P 道；禁碰 P4b pending_n；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P3e B-minus（`pthin_type_ref.x` 有则补全 TYPE_DYN wrap dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 name[256]；kind／named_name 走既有 pipeline_type_*；TYPE_DYN 写入走 P3 seed `pipeline_type_init_dyn_c`（G.7 一 writer；禁 FORCE pabi mega；禁复用 init_compound_kind_at——kind_ord 帽 15 且 pipe_ty_kind_from_ord 把 >16 钳成 I32）；parse_type_ref 仍 C；禁抄 wrap 进 parse；禁并 P3c mangle；禁 dest-buffer IDENT generic type-arg get/set；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P3g B-minus（`pthin_type_ref.x` 有则补全 postfix array/slice dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 `T[]`／`T[]<label>`／`T[N]`／`T[N][M]…`；空 `[]` 仅第一后缀为 slice（`T[N][]` fail-closed）；ARRAY 写复用 `pipeline_type_init_compound_kind_at`（kind 10）；SLICE+label 走 P3 seed `pipeline_type_init_slice_c`（禁 `set_region_label_at`——会清 elem_type_ref）；C trampoline 持 label[64]；parse_type_ref 仍 C；禁抄 wrap 进 parse；禁 dest-buffer parse_type_ref（P3f 曾 hello／fmt 红）；禁开新 P 道；禁 FORCE pabi mega；g05：POSTFIX 独立门，缺 postfix_x 则回落 C 孪生、不丢 P3b–P3e；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P3h B-minus（`pthin_type_ref.x` 有则补全 prefix `[N]T`／`[]T`／`[]T<label>` dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 `[`；空 `[]` 为 slice 再 recurse T（label 在 T 后，异于 postfix `T[]<label>`）；`[N]` 包 ARRAY 再 recurse（多维 `[2][3]T` 是 recurse 不是 dim 环）；ARRAY／SLICE writer＝P3g；elem 走既有 primary parse_type_ref_ptr shim（G.7 一 shim；禁 dest-buffer parse_type_ref——P3f 曾 hello／fmt 红）；C trampoline 持 label[64]；parse_type_ref_impl 仍 C；禁抄 wrap 进 parse；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；g05：PREFIX 独立门，缺 prefix_x 则回落 C 孪生、不丢 P3g；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P3i B-minus（`pthin_type_ref.x` 有则补全 type-position `function(T0, T1, ...): Ret` dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 `function` 然后 `(`；空 `()` 为 n_params=0；params／ret 走既有 primary parse_type_ref_ptr shim（G.7 一 shim；禁 dest-buffer parse_type_ref——P3f 曾 hello／fmt 红）；TYPE_FN writer＝P3 seed `pipeline_type_init_fn_c`（kind=18 raw；禁 FORCE pabi mega；禁复用 init_compound cap 15）；params 走既有 `pipeline_type_append_type_arg` sidecar（G.7）；不跟 postfix（C 孪生也不跟）；parse_type_ref_impl 仍 C；禁抄 wrap 进 parse；禁并 wrap；禁开新 P 道；g05：FN 独立门，缺 fn_x 则回落 C 孪生、不丢 P3h；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P3j B-minus（`pthin_type_ref.x` 有则补全 prefix `*T`／`**T`／`*[]T`／`*[N]T` dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走一或多颗 `*`；`*[`／`*dyn`／`*impl` 走既有 primary parse_type_ref_ptr shim（G.7 一 shim；禁 dest-buffer parse_type_ref——P3f 曾 hello／fmt 红）；scalar／IDENT pointee 镜像 alloc_pointee（IDENT＝consume_qualified＋`pipeline_type_init_named_at`；builtin 含 VOID＝`pipeline_type_init_primitive_kind_at` 0..16）；PTR wrap＝`pipeline_type_init_compound_kind_at`（kind 9）；C 风格 `*T[N]` postfix＝既有 P3g array helper；C trampoline 持 name[256]＋qn_len＋label[64]（禁 local u8[N]、禁 &local i32）；parse_type_ref_impl 仍 C；禁抄 wrap 进 parse；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；g05：STAR 独立门，缺 star_x 则回落 C 孪生、不丢 P3i；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P7b Route C（编 `pthin_simd.x`；hybrid 跳过 shuffle／select ident pack／callee 名填充；parse／arena 仍 C；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P7c B-minus（`pthin_simd.x` 有则补全 callee VAR＋CALL wrap dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 name[256]；kind／var_name 走既有 pipeline_expr_*；call_callee 走既有 pabi set_call_c；call_resolved=-1 走既有 init_call_resolve_at_ref（G.7 各一 writer；禁 FORCE pabi mega；禁并 P4b suffix CALL wrap）；parse dest-buffer 是 P7d；禁抄 wrap 进 parse；禁包 AUDIT；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P7d B-minus（`pthin_simd.x` 有则补全 parse dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 IDENT／LPAREN／args／RPAREN；pack 仍 P7b ident_pack；CALL wrap 仍 P7c 经 C name-buffer trampoline（语言无 local u8[N]）；args 走既有 primary parse_expr ptr shim（G.7 一 shim）；C trampoline 留 AUDIT、写 next_lex；禁 `break` 出嵌套 while（P4bh parse 会静默丢整函数）；禁抄 wrap 进 parse；禁 dest-buffer parse_match／parse_type_ref；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4ub Route C（编 `pthin_expr_unary.x`；hybrid 跳过 TOKEN→ExprKind；parse／wrap／arena 当时仍 C；已 T AUDIT 探针仅 audit 宏；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4uc B-minus（`pthin_expr_unary.x` 有则补全 wrap_operand dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 parse_expr_result*；setter `pipeline_expr_set_unary_operand_c` 落 P4u seed（pabi inject-only 不带新 rest 符号）；parse dest-buffer 是 P4ud；禁抄进 parse_unary；禁并 binop_wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4ud B-minus（`pthin_expr_unary.x` 有则补全 parse_unary dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 unary 前缀；primary 走 unary.inc 零算法 ptr shim；C trampoline 留 AUDIT、写 next_lex；wrap 仍 P4uc；禁抄 wrap 进 parse；禁 dest-buffer parse_primary；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4bb Route C（编 `pthin_expr_binop.x`；hybrid 跳过 TOKEN→ExprKind；parse／wrap／peek／single_tok_chain 当时仍 C；parse_logor 已 T AUDIT 探针仅 audit 宏；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁与 unary 表合并）
  - ✅ P4bc B-minus（`pthin_expr_binop.x` 有则补全 wrap dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 parse_expr_result*；setter `pipeline_expr_set_binop_operands_c` 落 P4b seed（pabi inject-only 不带新 rest 符号）；parse dest-buffer 是 P4bd；禁抄进 parse_*；禁并 unary wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4bd B-minus（`pthin_expr_binop.x` 有则补全 parse dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 term…logor 十层左结合链；level 0 lower 走 binop.inc 零算法 parse_cast ptr shim（unary+as_suffix 仍 C）；C trampoline 留 AUDIT、写 next_lex；wrap 仍 P4bc；禁抄 wrap 进 parse；禁 dest-buffer parse_cast／as_suffix；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4tb Route C（编 `pthin_expr_ternary.x` 首体；hybrid 跳过 EXPR_TERNARY wrap；C trampoline 持 parse_expr_result*；if_* 走既有 P5 seed `pipeline_expr_set_if_c`（G.7 一 writer；禁 FORCE pabi mega；禁抄 set_if 进 P4t seed）；parse dest-buffer 是 P4td；parse_assign 仍 C；assign wrap 是 P4tc；禁抄 wrap 进 parse；禁并 unary／binop wrap；禁并 skip_if_expr_finish；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4as Route C（编 `pthin_expr_as_suffix.x` 首体；hybrid 跳过 TRY_PROPAGATE＋EXPR_AS wrap；C trampoline 持 parse_expr_result*；unary_operand 走既有 P4u seed `pipeline_expr_set_unary_operand_c`；as_* 走 P4as seed `pipeline_expr_set_as_c`（G.7 各一 writer；禁 FORCE pabi mega；禁抄 set_unary／set_as）；parse dest-buffer 是 P4ad；禁抄 wrap 进 parse；禁并 unary／binop／ternary wrap；禁把 assign wrap 当 extra；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4ad B-minus（`pthin_expr_as_suffix.x` 有则补全 parse dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 `?`／`as type` 后缀链；`?` vs ternary 走 as_suffix.inc 零算法 peek_kind_after；type_ref 走既有 primary ptr shim（G.7 一 shim；禁 dest-buffer parse_type_ref——P3f 曾 hello／fmt 红）；C trampoline 留 AUDIT、写 next_lex；wrap 仍 P4as；禁抄 wrap 进 parse；禁 dest-buffer parse_cast／parse_ternary／parse_assign；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4tc Route C（`pthin_expr_ternary.x` 有则补全 assign wrap dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 parse_expr_result*；binop left/right 走既有 P4bc seed `pipeline_expr_set_binop_operands_c`（G.7 一 writer；禁 FORCE pabi mega；禁抄 set_binop；禁扩 P4bc wrap 加 line/col——P4bc 写 0,0，assign 写 token line/col）；parse dest-buffer 是 P4te；禁抄 wrap 进 parse；禁并 unary／binop／ternary wrap；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4td B-minus（`pthin_expr_ternary.x` 有则补全 parse dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 `?`／`:` 右结合；logor 走 ternary.inc 零算法 ptr shim；then 走既有 primary parse_expr_ptr（G.7 一 shim；C then＝parse_expr_into）；else 递归本 dest-buffer；C trampoline 留 AUDIT、写 next_lex；wrap 仍 P4tb；禁抄 wrap 进 parse；禁 dest-buffer parse_assign／parse_type_ref；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4te B-minus（`pthin_expr_ternary.x` 有则补全 parse_assign dest-buffer；hybrid 跳过 C 孪生；P9a peek/step＋peek_tok_line/col 走 `=`／compound；left/right 走本文件 parse_ternary dest-buffer；C 孪生从同一起点 parse_ternary 两次，.x 用 P9a cursor trio save/restore 而不「修」双 parse；非赋值／非左值停游标；compound／lvalue 走既有 is_compound_assign_token_c＋compound_assign_token_to_expr_kind_from_glue＋pipeline_expr_ref_is_assign_lvalue（G.7 不抄表）；C trampoline 留 AUDIT、写 next_lex；wrap 仍 P4tc；禁抄 wrap 进 parse；禁 dest-buffer parse_type_ref／parse_match；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4bh B-minus（`pthin_expr_primary.x` 有则补全 remaining parse_primary dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 STRING concat／RETURN／PANIC／paren／array／LBRACE；IF 走既有 P5f parse_if_expr_x；MATCH／AT 走零算法 ptr shim（parse 仍 C）；decode／anonymous-struct alloc 仍 C（local u8[N]）；block wrap 走既有 P5f wrap_block_ref（G.7 type_ref=0）；unary operand 走既有 P4uc set_unary_operand_c；INT／FLOAT TOKEN 钉收到 token.h 80／81（C 回退曾藏 133／134 假钉）；C trampoline 留 AUDIT、写 next_lex；IDENT 头仍 P4bg；suffix_loop 不涨（XT001）；禁 dest-buffer parse_type_ref／parse_match；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P4bi B-minus（`pthin_expr_primary.x` 有则补全 parse_struct_lit_fields dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 IDENT／COLON／COMMA／RBRACE；字段名经 C name-buffer trampoline（语言无 local u8[N]）转发 pipeline_expr_append_struct_lit_field／shorthand VAR alloc；field: expr 走既有 parse_expr（C 持 struct_field_value_depth）；ident_len<=0 或 >255 失败（C 孪生，不钳 127）；禁 `break` 出字段 while；C trampoline 留 AUDIT、写 next_lex；anonymous alloc／finish_struct_lit_from_type_ident 仍 C；禁抄 wrap 进 parse；禁 dest-buffer parse_type_ref／parse_match_into／anonymous-struct alloc；禁并 wrap；禁涨 suffix_loop；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P14b B-minus（编 `pthin_skip_if.x`；hybrid 跳过 trait／impl＋if-core／statement 走查；enum register 当时仍 C；依赖 P9a 桥＋P1b skip_balanced；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_balanced）
  - ✅ P14c B-minus（`pthin_skip_if.x` 有则补全 module_try_register_enum_name；hybrid 跳过 C 孪生；ABI 已是 pointer（opaque module＋name bytes）；P12e 仍 extern 调此符号；sidecar 权威＝pipeline_module_enum_*；禁抄进 skip_one_enum_register；禁开新 P 道；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P6b B-minus（`pthin_fn_block.x` 有则补全 struct_layout_name_exists／first_name_match／placeholder_idx；hybrid 跳过 C 孪生；ABI 已是 pointer（opaque module＋name bytes）；parse_struct_record_layout／library_slice 仍 C 调此符号；sidecar 权威＝pipeline_module_struct_layout_*；禁抄进 parse／library；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P6c B-minus（`pthin_fn_block.x` 有则补全 packed／soa 修饰符谓词 dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 lexer_result*／slice*；parse_struct_record_layout 仍 C 调历史 static；禁并 P19d field-name kind；禁抄进 parse／library；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P6d B-minus（`pthin_fn_block.x` 有则补全 library-shape TYPE_BOOL／TYPE_NAMED／VAR／FIELD／ENUM／EQ wrap dest-buffer；hybrid 跳过 C 孪生；C trampoline 转发 scan name 缓冲；kind／var_name／field 走既有 pipeline_expr_*／pipeline_type_init_*；binop 走既有 P4bc set_binop_operands_c（G.7 一 writer；禁 FORCE pabi mega；禁并 P4bc wrap／P5g match wrap／P3e TYPE_DYN wrap）；parse_one_function_library 仍 C；禁抄 wrap 进 parse_type_ref／P15 scan；禁 dest-buffer parse；禁抄 name-match 进 library_slice；禁包 AUDIT；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P6e B-minus（`pthin_fn_block.x` 有则补全 parse_struct_record_layout dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 IDENT 名／可选 `<T,U>`／packed｜soa／`{ align? let? field: T ;|, ... }`；name-match 仍 P6b；packed／soa 仍 P6c；type_ref 走既有 primary ptr shim（G.7 一 shim；禁 dest-buffer parse_type_ref——P3f 曾 hello／fmt 红）；C trampoline 持 sname／fname／tp pack（语言无 local u8[N]／u8[8][256]）；skip-generic／skip-braces 仍 P1b；字段名仍 P19d from_kind；禁 `break` 出字段 while；C trampoline 入口＝未消耗 struct 名、成功停在 `}` 后；禁抄 wrap 进 parse；禁并 wrap；禁 mix range_for；禁开新 P 道；禁 FORCE pabi mega；g05：P6 thin 缺 parse_struct_record_layout_x 则回落 C parse 孪生（不丢 P6b／P6c／P6d）；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P2b B-minus（`pthin_let_alias.x` 有则补全空桩 parse_one_top_level_let＋parse_one_type_alias dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 let／const 可选 mut／IDENT／可选 `: T`／`= expr ;` 与 `type Alias = T ;`；C trampoline 持 name[256] pack（语言无 local u8[N]）；type_ref／expr 走既有 primary ptr shim（G.7 各一 shim；禁 dest-buffer parse_type_ref——P3f 曾 hello／fmt 红）；P010／P012／P014 仍既有 C reporter；body_let_bracket／parse_cond_expr 当时仍 C；禁抄 wrap 进 parse；禁并 wrap；禁 dest-buffer parse_cond_expr 进本波；禁开新 P 道；禁 FORCE pabi mega；g05：P2 thin 缺两枚 parse_x 则回落 C parse 孪生；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P2c B-minus（`pthin_let_alias.x` 有则补全 parse_cond_expr dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 INT 后 `as` 则回绕 INT 起点再 parse_expr（与 return 0 as T 同路径）；其它头从入口 parse_expr；expr 走既有 primary ptr shim（G.7 一 shim）；C trampoline 写 next_lex；AUDIT 仍冷孪生；body_let_bracket 仍 C；禁抄 wrap 进 parse；禁并 wrap；禁 dest-buffer body_let_bracket；禁 dest-buffer parse_type_ref；禁开新 P 道；禁 FORCE pabi mega；g05：LET_ALIAS_COND_FROM_X 独立门，缺 parse_cond_expr_x 则回落 C 孪生、不丢 P2b；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P5k T-shrink（`pthin_ctrl.x` 有则补全 leftover parse_if_stmt C twin；hybrid 跳过 `parse_if_stmt_into_slice_c`＋unused is_ws_byte／dead sync_lex_after_if_cond_paren；trampoline 仍调 `.x` parse_if_stmt_x；g05：P5 thin 缺 parse_if_stmt_x 则回落 C 孪生；AUDIT 仍冷孪生；禁 wrap leftover else-if AUDIT；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12b B-minus（编 `pthin_skip_tl.x`；hybrid 跳过 skip_one_struct／enum／extern 走查；trait-reg／enum register／parse_one_extern 仍 C；依赖 P9a 桥＋P1b skip_balanced／skip_generic_angle；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_balanced／skip_generic_angle）
  - ✅ P12c B-minus（`pthin_skip_tl.x` 有则补全 skip_one_impl dest-buffer；hybrid 跳过 C 孪生；skip_one_trait／generic_bound／enum_register／parse_one_extern 仍 C；语言无 file-local 静态表，C trampoline 持 dest buf 再写入 impl-seen 表；依赖 P9a 桥＋P1b skip_generic_angle／copy；g05 `-E`+cc，pure-asm CG002（P12b 仅 struct／enum／extern 时曾过）；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁包 skip_one_trait；禁再抄 skip_generic_angle／copy_slice；禁开新 P 道；禁 skip_balanced_braces）
  - ✅ P12d B-minus（`pthin_skip_tl.x` 有则补全 generic_bound_scan dest-buffer；hybrid 跳过 C 孪生；skip_one_trait／enum_register／parse_one_extern 仍 C；语言无 file-local 静态表，C trampoline 持 dest buf 再写入 g_fn_bound_*／g_call_*／g_fn_gp_* 表；依赖 P9a 桥＋P1b skip_generic_angle／copy；g05 `-E`+cc，pure-asm CG002 同 P12c；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁包 skip_one_trait；禁再抄 skip_generic_angle／copy_slice；禁开新 P 道）
  - ✅ P12e B-minus（`pthin_skip_tl.x` 有则补全 skip_one_enum_register／append_variants；hybrid 跳过 C 孪生；skip_one_trait／parse_one_extern 仍 C；语言无 local u8[N]，C trampoline 持 128 字节 dest buf；module 写入走既有 try_register／pipeline_module_enum_append_variant；依赖 P9a 桥＋P1b copy；g05 `-E`+cc，pure-asm CG002 同 P12c／P12d；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁包 skip_one_trait；禁抄 skip_one_enum；禁开新 P 道）
  - ✅ P12f B-minus（`pthin_skip_tl.x` 有则补全 parse_one_extern_skip；hybrid 跳过 C 孪生；skip_one_trait／parse_one_extern_and_add 仍 C；语言无 local u8[N]／结构体按值，C trampoline 持 dest buf；type_ref 走既有 parse_type_ref_for_arena（pointer-ABI wrap）；onefunc append／set 仍 pipeline helper；依赖 P9a 桥＋P1b copy；g05 `-E`+cc，pure-asm CG002 同 P12c／P12d／P12e；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁包 skip_one_trait；禁抄 skip_one_extern；禁开新 P 道）
  - ✅ P12i B-minus（`pthin_skip_tl.x` 有则补全 skip_name_is_self＋skip_impl_self_matches_for dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 gnm[64]；concrete_implements_trait 仍 C（file-local impl-seen 表）；sidecar 权威＝pipeline_type_*；禁抄进 typeck；禁并 P6b name-match；禁抄 skip_name_is_self 进 P4b；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12j B-minus（`pthin_skip_tl.x` 有则补全 named_eq_self＋rewrite_self dest-buffer；hybrid 跳过 C 孪生；named_eq_self 指针 ABI；rewrite_self C trampoline 持 gnm[64]＋for_copy[64]；seed twin 仍 C；sidecar 权威＝pipeline_type_*（含既有 find_or_alloc）；禁抄进 typeck；禁并 P6b；禁并 concrete_implements_trait；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12k B-minus（`pthin_skip_tl.x` 有则补全 register_type_params＋type_param_index dest-buffer；hybrid 跳过 C 孪生；C trampoline 传 g_fn_gp_*（与 P12d scan 同表 layout）；register_pending／method_on_param／bound_check 仍 C；禁并 P1c pending；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12l B-minus（`pthin_skip_tl.x` 有则补全 concrete_implements_trait dest-buffer；hybrid 跳过 C 孪生；C trampoline 传 g_xlang_skip_impl_*（trait stride 64／for-name stride 64／cap 16）并持 gnm[64]；复用 P12i self_matches_for；accessors／method_on_param／bound_check 仍 C；禁抄进 typeck；禁并 P6b；禁并 trait-reg accessors；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12m B-minus（`pthin_skip_tl.x` 有则补全 bound_check_type_args dest-buffer；hybrid 跳过 C 孪生；C trampoline 传 g_fn_bound_*＋g_xlang_skip_impl_*（stride 64／bound cap 16／impl cap 16）；diag 走 C varargs helper（.x 无 printf）；bound_check_c／method_on_param／accessors 仍 C；禁抄进 typeck；禁并 fat trait-reg；禁包 method_on_param；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12n B-minus（`pthin_skip_tl.x` 有则补全 F4 impl-seen accessors dest-buffer：seen_count／trait_name_into／for_type_into；hybrid 跳过 C 孪生；C trampoline 传 g_xlang_skip_impl_*（trait stride 64／for-name stride 64／cap 16；for_type 另传 for_kinds／for_is_ptr）；历史公开名仍 trampoline（已是 `_into_c` 的两条用 `_dest_into_c`）；method_on_param／F3／bound_check_c 仍 C；禁并 concrete_implements；禁抄进 typeck／codegen；禁包 method_on_param；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12o B-minus（`pthin_skip_tl.x` 有则补全 bound_check dest-buffer；hybrid 跳过 C 孪生；C trampoline 传 g_call_*（callee stride 64／typeargs 32x4x64／args cap 4／call cap 32）；每站点转调历史公开 type_args `_c`（P12m 注入 bound/impl 表）；method_on_param／F3 仍 C；禁并 type_args（迭代器 vs 单站点）；禁抄进 typeck；禁包 method_on_param；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12p B-minus（`pthin_skip_tl.x` 有则补全 F3 lookup dest-buffer：find_reg／method_count／method_slot／method_name；hybrid 跳过 C 孪生；C trampoline 传 g_xlang_skip_trait_reg[] 字节镜像（stride＝sizeof(ent)／cap 16；偏移＝P12g pins）；is_registered 仍薄包装 find_reg；method_on_param／F3 标量 getter 仍 C；禁抄进 typeck／codegen；禁包 method_on_param；禁把剩余 F3 标量 getter 当 extra；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12q B-minus（`pthin_skip_tl.x` 有则补全 F3 simple scalar getters dest-buffer：slot i32／param i32／simple ret+param dims／ret+param name copy；hybrid 跳过 C 孪生；C trampoline 传 fat trait-reg 字节镜像＋offsetof；dest-extras elem_array_dim 是 P12r；is_registered 仍薄包装；method_on_param 仍 C；禁抄进 typeck／codegen；禁包 method_on_param；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12r B-minus（`pthin_skip_tl.x` 有则补全 F3 dest-extras elem_array_dim dest-buffer：ret_elem_array_dim／param_elem_array_dim；hybrid 跳过 C 孪生；C trampoline 传 fat trait-reg 字节镜像；wrap soup 在单一 helper（ndims＝-2／0／dim_ix≥ndims unused slots）；is_registered 仍薄包装；method_on_param 是 P12s；禁抄进 typeck／codegen；禁并 simple ret／param array_dim；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12s B-minus（`pthin_skip_tl.x` 有则补全 method_on_param dest-buffer；hybrid 跳过 C 孪生；C trampoline 传 g_fn_bound_*＋fat trait-reg 字节镜像；type_param_index 走 P12k 历史 `_c`；method 走查在本函数（arity continue ≠ method_slot first-match）；is_registered 仍薄包装；register_pending 仍 C；禁抄进 typeck／codegen；禁并 bound_check_type_args；禁并 F3 lookup；禁复用 skip_copy_row64／ret_name_dest；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12t B-minus（`pthin_skip_tl.x` 有则补全 skip_hoist_default_methods dest-buffer；hybrid 跳过 C 孪生；C trampoline 传 g_xlang_skip_impl_*＋fat trait-reg 字节镜像＋stash src＋持 gnm[64]；parse+commit 走 C `xlang_skip_hoist_inject_one_c`（onefunc 按值）；self_matches_for 走 P12i dest-buffer；trait_check_impls_complete 是 P12u；register_pending 仍 C；禁抄进 typeck／codegen；禁并 method_on_param；禁并 F3 lookup；禁把 trait_check 当 extra；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P12u B-minus（`pthin_skip_tl.x` 有则补全 trait_check_impls_complete dest-buffer 外层走查；hybrid 跳过 C 孪生；C trampoline 传 g_xlang_skip_impl_*＋fat trait-reg 字节镜像＋stash src＋持 gnm[64]；dest-SLICE param/ret 形状核＋varargs diag 走 C helper；hoist 走 P12t trampoline；bound_scan/check 走历史 `_c`；find-func 不是 skip_hoist_method_exists（first-name fallback vs override skip）；register_pending 仍 C；禁抄进 typeck／codegen；禁并 skip_hoist／method_on_param／F3 lookup；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P18b Route C＋B-minus（编 `pthin_body_tl.x`；hybrid 跳过 is_fn_sig_scalar＋diag_skip／body_skip＋skip_one_top_level let／const；P010–P014／diag_first_ident／cfg_skip 仍 C；依赖 P9a 桥＋P14b skip_one_if；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_one_if）
  - ✅ P18c B-minus（`pthin_body_tl.x` 有则补全 cfg_skip／diag_first_ident；hybrid 跳过 C 孪生；P010–P014／onefunc_param_name_dup 当时仍 C；语言无 lexer_init，C trampoline 持 inited lexer；依赖 P9a 桥＋P14b skip_one_if＋P12b skip_one_struct＋P10b skip_one_function_full；**pure-asm 过**；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_one_struct／skip_one_function_full／skip_one_if；禁开新 P 道）
  - ✅ P18d B-minus（`pthin_body_tl.x` 有则补全 P010–P014 reports＋onefunc_param_name_dup；hybrid 跳过 C 孪生；msg 表 parser_body_tl_p0xx_msg_c 仍 C（bootstrap STRING_LIT 64B）；sticky／allow_bare_self／cur_module 仍 C；.x 经 parser_sig_type_hard_set_c 拉 sticky；依赖既有 P18c 门；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁开新 P 道；禁把长 diag 字面量写进 .x）
  - ✅ P10b B-minus（编 `pthin_glue.x`；hybrid 跳过 skip_one_function_full 走查；glue 包装／parse glue 仍 C；依赖 P9a 桥＋P1b skip_balanced＋P12b skip_one_extern；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_balanced／skip_one_extern）
  - ✅ P13b B-minus（编 `pthin_try_skip_allow.x`；hybrid 跳过 padding 走查；write_result／parse_into 仍 C；依赖 P9a 桥＋P1b skip_balanced；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_balanced）
  - ✅ P11b B-minus（编 `pthin_imports.x`；hybrid 跳过 skip_imports 走查；try_skip／consume_path／collect 仍 C；collect AUDIT 前缀仅 audit 宏；依赖 P9a 桥＋peek_int_val；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 consume_path）
  - ✅ P11c B-minus（`pthin_imports.x` 有则补全 consume_path／try_skip；hybrid 跳过 C 孪生；collect／copy_token_bytes 当时仍 C；语言无 local u8[128]，C trampoline 持 path buf；依赖 P9a 桥＋P1b copy＋P9b validate／finalize；g05 `-E`+cc，pure-asm CG002 同 P1b／P5b；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 copy_slice／validate／finalize；禁开新 P 道）
  - ✅ P11d B-minus（`pthin_imports.x` 有则补全 collect_imports dest-buffer；hybrid 跳过 C 孪生；copy_token_bytes buf-path 已 P1f；语言无 local u8[N]，C trampoline 持 128 字节 path／bind dest buf；module 写入走既有 pipeline_module_import_*；依赖 P9a 桥＋P11c consume_path＋P18 cfg_skip＋P1b copy；g05 `-E`+cc，pure-asm CG002 同 P11c；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁抄 skip_imports；禁包 leftover collect walk AUDIT；禁开新 P 道）
  - ✅ P5b Route C（编 `pthin_ctrl.x`；hybrid 跳过注释感知花括号字节扫描／kw_at_pos；parse／scan_sync／match／if_expr 仍 C；parse_if_stmt 已 T AUDIT 前缀仅 audit 宏；禁包 leftover else-if AUDIT；禁再抄 P1b token skip_balanced；skip_ws 仍 P9b；g05 `-E`+cc，pure-asm CG002 同 P1b／P19b；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P5c Route C（`pthin_ctrl.x` 有则补全 scan_sync pos；hybrid 跳过 scan_sync C 孪生；C trampoline 重建 by-value lexer；parse／realign／match／if_expr 仍 C；禁迁 dead sync_lex_after_if_cond_paren；禁包 leftover else-if AUDIT；禁再抄 P1b token skip_balanced／P9b skip_ws；g05 `-E`+cc，pure-asm CG002 同 P5b；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P5e B-minus（`pthin_ctrl.x` 有则补全 match_dest_enum_tag dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 ename[256]；parse_match 仍 C 调历史 static；sidecar 权威＝pipeline_module_enum_*；禁并 P14c register；禁抄进 parse_match／P12e；禁开新 P 道；禁 FORCE pabi mega；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P5f B-minus（`pthin_ctrl.x` 有则补全 parse_if_expr dest-buffer＋wrap_block_ref；hybrid 跳过 C 孪生；C trampoline 持 parse_expr_result；cond／block 走既有 ptr shim；EXPR_IF／EXPR_BLOCK 走 pipeline_expr_set_kind／zeros／resolved／line_col＋P5 seed consumer-wave writer set_block_ref／set_if（禁 FORCE pabi mega）；else-if 递归本 dest-buffer（expr-ref 作 if_else，不是 if_stmt block-wrap）；禁抄 wrap 进 parse_unary／primary；禁并 P4uc unary wrap；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P5g B-minus（`pthin_ctrl.x` 有则补全 match wrap-family dest-buffer；hybrid 跳过 C 孪生；C trampoline 持 name[256]；kind／var_name／int_val／field_access 走既有 pipeline_expr_*；binop 走 P4bc set_binop（G.7 一 writer；禁 FORCE pabi mega；禁并 P4bc wrap）；match_matched_ref 走 P5 seed `pipeline_expr_set_match_matched_c`；parse dest-buffer 是 P5h／P5i／P5j；禁抄 wrap 进 parse；禁并 P5e dest-enum-tag；禁开新 P 道；g05 `-E`+cc；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P5h B-minus（`pthin_ctrl.x` 有则补全 parse_match_subject dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 IDENT vs CALL／INDEX／FIELD 后缀 vs parse_expr 回落；VAR wrap 仍 P5g 经 C name-buffer trampoline（语言无 local u8[N]）；后缀 cursor trio 回入口（C 孪生 rewind 到 by-value lex）；非 IDENT／postfix 走既有 primary parse_expr ptr shim（G.7 一 shim）；C trampoline 留 AUDIT、写 next_lex；禁抄 wrap 进 parse；parse_match_into dest-buffer 是 P5j；禁 dest-buffer parse_type_ref；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P5i B-minus（`pthin_ctrl.x` 有则补全 parse_match_struct_fields dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 IDENT／COLON／INT／UNDERSCORE／COMMA／RBRACE；FIELD wrap 仍 P5g 经 C name-buffer trampoline（语言无 local u8[N]）；LIT／EQ／LOGAND wrap 仍 P5g；禁 `break` 出字段 while；C trampoline 入口＝LBRACE 后游标、成功停在 `}` 后；parse_match_into dest-buffer 是 P5j；禁抄 wrap 进 parse；禁 dest-buffer parse_type_ref；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P5j B-minus（`pthin_ctrl.x` 有则补全 parse_match_into dest-buffer；hybrid 跳过 C 孪生；P9a peek/step 走 MATCH／subject／LBRACE／arm／RBRACE；subject 走 P5h；struct-fields 走 P5i；MATCH wrap 走 P5g wrap_into（G.7 一 wrap；禁抄 wrap）；arm expr／`if` guard 走既有 primary parse_expr ptr shim；C trampoline 持 16-pattern pack（reset／n／append／commit）＋enum/variant name[128] dest-tag（语言无 local u8[N]／i32[16]）；禁 `break` 出臂／pattern while；C trampoline 入口＝未消耗 MATCH、成功停在 `}` 后；禁抄 wrap 进 parse；禁 dest-buffer parse_type_ref；禁并 wrap；禁开新 P 道；禁 FORCE pabi mega；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - ✅ P15b B-minus（编 `pthin_library.x`；hybrid 跳过 library_scan 走查；into／buf parse／lex_from 仍 C；into／buf AUDIT 前缀仅 audit 宏；依赖 P9a 桥＋P1b copy；**pure-asm 过**；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 copy_slice）
  - ✅ P17b B-minus（编 `pthin_diag_late.x`；hybrid 跳过 after_structs／fail_at_token_kind 走查；buf AUDIT 前缀仅 audit 宏；依赖 P9a 桥＋P1b is_pointee＋P12b skip_one_struct＋P18b scalar／body_skip；**pure-asm 过**；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_one_struct／body_skip／is_fn_sig／is_pointee）
  - ✅ P17c G.7（`diag_skip_let_const_buf` trampoline over P18b into；hybrid／冷均不再编 buf C 走查孪生；body_skip_buf 已是 trampoline；禁再抄 into；禁开新 P 道；禁新 .x 导出）
  - 机制 → [`7.2.1-parser-inc-port-ABI-RFC.md`](7.2.1-parser-inc-port-ABI-RFC.md)；逐波 → 自举进度 §6 
- 🟡 **7.2.2** parser_gen 去 pin — 产品默认 pin-first；`FROM_X=1` 仅显式 assemble  
- ⬜ **7.2.1** parser seed 物理删（史诗；依赖 7.2.1b／8.3）  

---

## 阶段 8 · Pinned gen 退役 ✅ · 8.3 非 gen 🟡

### 已闭

- ✅ **8.1** PRODUCT RETIRED 23／23  
- ✅ **8.2** NON_PRODUCT 7／7  
- ✅ **合计 30／30 FULLY CLOSED**  
- ✅ **8.3.4／8.3.5／8.3.7／8.3.9** leave／stubs／孤儿清理  
- ✅ glue 壳／typedefs／standalone deleted；bc-inventory present product C rows **0**  
- ✅ **8.3.6** 死件删除累计 114 件（−157k 行；普查＋三～五片）  

### 开项

- 🟡 **8.3.1** `pipeline_glue` → .x／域 thin — 父项未离 host-cc  
- 🟡 **8.3.2** `ast_pool` → .x — 父项仍 host-cc 入 `pipeline_x`  
- 🟡 **8.3.3** field_access／soa — 叶 leave ✅；父项因 `pipeline_x` 仍 host-cc  
- ✅ **8.3.6 三分表定稿（2026-09-14）**：种子（pthin_*.from_x.c ~700K/19 件含 443K thin_c）＝**产品承重件全保留**（lane thin+rest 编译输入，非冷质量）；真正冷质量＝各 .inc 的 #else 分支＝保留至「L4 验证全 .x 冷引导」终局条件（与考古钉同波退役）。旧残项清单留档：
- 🟡 **8.3.8** `build_asm/gen_driver/*.c` — 确认 `pipeline_gen.c` 残留  
- ⬜ **8.3.10** `editors/tree-sitter-xlang/` 第三方 .c  
- ⬜ **BC 终局** `pipeline_x` 整 TU 离 host-cc  

---

## 阶段 9 · Cap residual 边界消灭 ✅

- ✅ **9.1** OS 系统调用 9.1.1–9.1.12  
- ✅ **9.2** 第三方库勘正／standing（zlib／sqlite／libm／mbedtls／arrow／ed25519）  
- ✅ **9.3** 宏／host lit／atomic／SIMD 桥 standing  
- ✅ **9.4** C ABI／fnptr／argv／线程（含 9.4.2／9.4.3 残）  
- ✅ **9.5** FILE／fprintf／va_list／fdprint／有界读  
- ✅ **9.6** 全局／static／modlet／字串池／RELA  
- ✅ **9.7** driver_abi 平台层 9.7.1–9.7.7  

> standing C＝系统库／语言极限（有意不迁）。细节见归档。

---

## 阶段 10 · 语言能力补齐 🟡

### 已闭（摘要）

- ✅ **10.1.1／10.1.2** Linux x86_64／arm64 syscall 内建  
- ✅ **10.2.1** x86_64 inline asm slice0–16  
- ✅ **10.3.1–10.3.3** fnptr 类型／cast／间接 call／作参返回字段  
- ✅ **10.4.1／10.4.2** atomic＋内存屏障  
- ✅ **10.5.1／10.5.2** AVX／SSE／NEON／SVE  
- ✅ **10.6.1／10.6.3** Linux／Darwin 线程＋全平台 sync Cap  
- ✅ **10.7.1** va_list POSIX／host-C 单实例（MSVC 残）  
- ✅ **10.7.2** Cap vsnprintf slice0–21（纯 .x fmt／MSVC 残）  

### 开项

- ⬜ **10.1.3** Windows NT API 内建 — 暂缓（无 Windows 金标宿主）  
- 🟡 **10.1.4** raw FFI — slice1–2 ✅；残 NT→10.1.3  
- 🟡 **10.2.2** arm64 inline asm — slice0–3 ✅；残 qemu  
- 🟡 **10.2.3** Windows inline asm — slice0–1 ✅；残 MSYS Win 运行时  
- 🟡 **10.6.2** Windows CreateThread — 源码＋gate ✅；残 MSYS／Win 实机  
- 🟡 **10.7.1 残** MSVC va — 须切 Windows  
- 🟡 **10.7.2 残** 纯 .x fmt · MSVC  

---

## 阶段 11 · xbuild + Makefile 退役（MG）🟡

### 已闭

- ✅ **11.2.2** `./xbuild l4`  
- ✅ **11.2.3／11.2.5／11.4.1／11.4.3／11.4.6** 编排入口  
- ✅ **11.3／11.3.1** Makefile 物理删除；catalog 单权威；bootstrap 0 make  

### 开项

- 🟡 **11.1.1–11.1.6** 依赖图／调度／平台／链接／`build.x`／吞并 g05 — 终局未完  
- ⬜ **11.2.1** stage1→2→3 编排 + 自动 v2==v3  
- ⬜ **11.2.4** Windows／MSYS2 本地 xbuild 入口  
- ⬜ **11.3.3** 其它 make 碎片（含 tree-sitter）  
- ⬜ **11.3.4** 「无 make + 无 cc」CI 闸门  
- 🟡 **11.4.5** docker 仍装 gcc／make  
- 🟡 **11.5.1–11.5.4** bench／tests 宿主 `.c` 策略（卸 cc→阶段 12）  
- ⬜ **11.6.1** `editors/tree-sitter-xlang/`  

全量叶映射 → [`Makefile迁移表.md`](Makefile迁移表.md)。

---

## 阶段 12 · 冷启动零 cc 🟡

### 已闭（摘要）

- ✅ LINK 全零 cc · `.s` COMPILE 零 cc · stub weak · `forbid_host_cc`  
- ✅ prefer 族／硬闸／ALLOW_TREE 地图  

### 开项

- 🟡 **12.0.5** asm backend 覆盖 — **`pipeline_abi` mega 仍硬禁**  
- ⬜ **12.1.1** 手写 asm seed（或极简二进制）  
- ⬜ **12.1.2** seed 产出 xlang_v1（无需 `-E`→cc）  
- ⬜ **12.1.3** 与 pin 退役衔接  
- 🟡 **12.2.1** 零 cc 验证 — ⬜ **全路径**零 `execve(cc)`  
- ⬜ **12.2.2** 双端冷启动验证（零 cc 闭环）  
- 🟡 **12.2.3** 产品默认后端 — `labi_invoke_cc` 未删  

---

## 阶段 13 · 终局 🟡

### 已闭

- ✅ **13.1.1** 前置闸门定义  
- ✅ **13.1.3** 阶段 9 residual 勘正收口  

### 开项

- ⬜ **13.1.2** 阶段 8 gen + 8.3／BC 完成（gen ✅；8.3／BC 未终）  
- ⬜ **13.1.4** v2 == v3 语义自举  
- ⬜ **13.1.5** D-03 bit-identical（可选）  
- ⬜ **13.2.1** 双端 L4 真冷 + 129 bstrict（**零 make · 零 host-cc**）  
- 🟡 **13.2.2** Makefile 物理删除验收 — 文件层 ✅；调用面／host-cc residual 🟡  
- ⬜ **13.2.3** 零 cc 三义验收（MG+BC+PC）  
- 🟡 **13.2.4** `labi_invoke_cc`／`-backend c` 退役或隔离  
- ⬜ **13.3.1** 物理删 seed 业务体  
- ⬜ **13.3.2** 宣布自举完成  

---

## 产品软残（日常软刀池）

> 已收软刀细节见归档。此处只留未完。

| 项 | 状态 | 备注 |
|----|------|------|
| STD／CORE／gate soft SKIP 邻域 | 🟡 | 主池多空；余 soft／obs／leave 见归档软残表 |
| `pipeline_abi` mega pure-asm | ⬜ 硬禁 | 已知 hang／CG002 地雷（不只是点名手续） |
| nest 冻 64 | ✅ 纪律 | — |

---

## 附录

### 钉盘

| 项 | 值 |
|----|-----|
| 产品 L4 放行钉盘 | **`ecdb5cc1e`** |
| bstrict | 129 |
| 升钉条件 | 用户点名 L4／谈自举；禁止微步升钉 |

### 推荐推进序（非流水）

1. **最优真减 host-cc**：P3j prefix `*T` dest-buffer 已开（有则补全 P3i；init_compound 写 TYPE_PTR kind=9；scalar＝init_primitive 0..16；IDENT＝init_named_at）。P3i type-position `function(...): Ret` dest-buffer 仍开。P3h prefix `[N]T`／`[]T` dest-buffer 仍开。P3g postfix array/slice dest-buffer 仍开。P2c parse_cond_expr dest-buffer 仍开。P5k leftover parse_if_stmt C twin T-shrink 仍开。P2b parse_one_top_level_let＋type_alias `.x` dest-buffer 仍开。P6e parse_struct_record_layout 仍开。P5j parse_match_into 仍开。P4bi parse_struct_lit_fields 仍开。P4bh remaining parse_primary 仍开。P5i parse_match_struct_fields 仍开。P5h match subject parse 仍开。P7d parse_at_simd_builtin 仍开。P4te parse_assign 仍开。P4td parse_ternary 仍开。P4ad parse_as_suffix 仍开。P4bd parse_binop 仍开。P4ud parse_unary 仍开。P4bg IDENT 头仍开。suffix_loop BODIES 仍开（P4bf）。wrap 族已尽。下刀＝glue_tail 包装／type_ref parse（P3f 曾 hello／fmt 红；postfix 已 P3g；prefix 已 P3h；TYPE_FN 已 P3i；`*T` 已 P3j）／parse_block_return_end_tail／register_pending／dest-SLICE／anonymous-struct alloc／body_let_bracket。pipeline_abi mega pure-asm 仍是已知地雷。  
2. 🟡 **7.2.1b leftover flatten 完**＋**8.3.6 有引用冷孪生三分**（P9 suite 46k＋lite 564＋P1b lex_skip portable＋P1c skip_generic_angle_list_count＋P1d ASI advance_past_stmt_semicolon／cond_rparen＋P1e parse_peek_function_name／first_token_kind＋**P1f copy_token_bytes**＋P19b helpers kind／copy／pos／match-kw＋P19c run_len extra／lex_at_token／rewind＋P19d struct_field_name／ident_is_unsafe＋P19e align_lex（2026-09-14；P9a 门）＋P4b primary ident＋P3b type_ref kind／dyn／builtin／vector IDENT＋**P3c type-inst mangle**＋**P3d consume_qualified／angle close**＋**P3e TYPE_DYN wrap dest-buffer**＋**P3g postfix array/slice dest-buffer**＋**P3h prefix `[N]T`／`[]T` dest-buffer**＋**P3i type-position `function(...): Ret` dest-buffer**＋**P3j prefix `*T` dest-buffer**＋P7b simd ident／callee 名＋**P7c simd callee+CALL wrap dest-buffer**＋**P7d simd parse dest-buffer**＋P4ub unary TOKEN→ExprKind＋**P4uc unary wrap dest-buffer**＋**P4ud unary parse dest-buffer**＋P4bb binop TOKEN→ExprKind＋**P4bc binop wrap dest-buffer**＋**P4bd binop parse dest-buffer**＋**P4tb ternary wrap dest-buffer**＋**P4as as_suffix wrap dest-buffer**＋**P4ad as_suffix parse dest-buffer**＋**P4tc assign wrap dest-buffer**＋**P4td ternary parse dest-buffer**＋**P4te assign parse dest-buffer**＋**P4bh remaining parse_primary dest-buffer**＋**P4bi parse_struct_lit_fields dest-buffer**＋**P5g match wrap dest-buffer**＋**P5h match subject parse dest-buffer**＋P14b skip_if walks＋**P14c module_try_register_enum_name**＋**P6b struct_layout name-match**＋**P6c packed／soa modifiers**＋**P6d library wrap dest-buffer**＋**P6e parse_struct_record_layout dest-buffer**＋**P2b parse_one_top_level_let／type_alias dest-buffer**＋**P2c parse_cond_expr dest-buffer**＋**P5k leftover if_stmt C twin T-shrink**＋P12b skip_tl struct／enum／extern walks＋P12c skip_one_impl dest-buffer＋P12d generic_bound_scan dest-buffer＋P12e skip_one_enum_register／append_variants＋P12f parse_one_extern_skip＋**P12i skip_name_is_self／self_matches_for**＋**P12j named_eq_self／rewrite_self**＋**P12k register_type_params／type_param_index**＋**P12l concrete_implements_trait**＋**P12m bound_check_type_args**＋**P12n impl-seen accessors**＋**P12o bound_check**＋**P12p F3 lookup**＋**P12q F3 simple getters**＋**P12r dest-extras elem_array_dim**＋**P12s method_on_param**＋**P12t skip_hoist_default_methods**＋**P12u trait_check_impls_complete**＋P18b body_tl scalar／skip walks＋P18c cfg_skip／diag_first_ident＋**P18d P010–P014／dup**＋P10b glue skip_one_function_full＋**P13b/P13c try_skip_allow padding＋write_result／parse_into**＋P11b skip_imports＋P11c consume_path／try_skip＋P11d collect_imports dest-buffer＋P5b ctrl brace-skip／kw_at_pos＋P5c scan_sync＋**P5d realign 六段走查**（桥 peek 家族补 tok line/col/next_pos；P19 三标量补冷 C 孪生）＋**P5e match_dest_enum_tag**＋**P5f parse_if_expr**＋P15b library_scan＋P17b diag_late after_structs／fail＋P17c G.7 diag_skip_let_const_buf trampoline over P18b into hybrid 已跳过；残＝产品 `.inc` 切片仍 host-cc含 glue_tail 包装、trait_check dest-SLICE 形状核、unary parse 已 P4ud、binop parse 已 P4bd、as_suffix parse 已 P4ad、parse_block_return_end_tail、register_pending（skip_one_trait 已 P12g 纯 asm；align_lex 已 P19e；skip_hoist 已 P12t；trait_check 外层走查已 P12u；if_expr 已 P5f；ternary wrap 已 P4tb；as_suffix wrap 已 P4as；assign wrap 已 P4tc；TYPE_DYN wrap 已 P3e；simd callee+CALL wrap 已 P7c；library wrap 已 P6d）；**禁**再深链分批 eq；pipeline_x mega 须点名）＋ **BC + 8.3** 
3. ⬜ **7.2.1／7.2.2** parser seed 物理删／去 pin  
4. 🟡 **阶段 10** 残（NT／MSVC／qemu／Win 实机）  
5. ⬜ **阶段 12–13** 最小 seed · 全路径零 cc · v2==v3 · 公告  

---

> **使用**：完成一步只改对应 `⬜`→`🟡`→`✅`。不要在本文写 tip／wave／日志路径。
