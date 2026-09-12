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
| Mega 去 pin M4（阶段 7） | 🟡 | 冷链关 pin；**7.2.1b leftover flatten 完**；深链分批覆盖戏停；**已 T 缩壳**：P9 hybrid 跳过 suite 46k；**Route C 产品化**：P9b stretch lite＋P1b lex_skip＋P19b helpers＋P4b primary ident＋P3b type_ref＋P7b simd ident pack／callee 名＋P4ub unary TOKEN→ExprKind＋P4bb binop TOKEN→ExprKind＋P14b skip_if 走查＋P12b skip_tl struct／enum／extern 走查＋P18b body_tl scalar 表＋let／const／if skip 走查＋P10b glue skip_one_function_full 走查＋P13b try_skip_allow padding 走查＋P11b skip_imports 走查＋P5b if_stmt 注释感知花括号字节扫描／kw_at_pos＋P5c scan_sync pos＋P15b library_scan＋P17b diag_late after_structs／fail＋**P11c consume_path／try_skip**（collect／copy_token_bytes 仍 C；g05 `-E`+cc，pure-asm CG002）＋**P18c cfg_skip／diag_first_ident**（P010–P014／onefunc_param_name_dup 仍 C；pure-asm 过）＋**P1c skip_generic_angle_list_count**（g_gp_pending_*／register_pending 仍 C；g05 `-E`+cc，pure-asm CG002）＋**P17c G.7 diag_skip_let_const_buf trampoline over P18b into**；残＝产品 `.inc` 切片仍 host-cc（含 glue_tail 包装、primary parse、P19 rewind／run_len、skip_tl trait-reg、try_skip_allow parse_into、collect_imports 走查、if_stmt parse／realign）、lite／suite／lex_skip／helpers／primary ident／type_ref／simd／unary／binop／skip_if walks／skip_tl struct／enum／extern／body_tl skip／glue skip_one_function_full／try_skip_allow padding／skip_imports／consume_path／try_skip／ctrl brace-skip／scan_sync／library_scan／diag_late after_structs／fail／body_tl cfg_skip／diag_first_ident／lex_skip count portable 冷回退、`parser_asm_thin_c.from_x.c` 443KiB 仅冷 rest 回退；parser seed 物理删 ⬜ |
| Pinned gen 退役（阶段 8） | ✅ | 30/30 FULLY CLOSED |
| 非 gen 产品 C／8.3 | 🟡 | `pipeline_x` 仍 host-cc；from_x 全表策略 ⬜ |
| Cap residual 消灭（阶段 9） | ✅ | 9.1–9.7 全系列 ✅ |
| 语言能力 L2（阶段 10） | 🟡 | 主面多 ✅；残 NT／MSVC／qemu／Win 实机 |
| xbuild／MG（阶段 11） | 🟡 | Makefile 物理删 ✅；终局／零 cc CI 仍开 |
| 冷启动零 cc（阶段 12） | 🟡 | LINK／`.s` 大半 ✅；全路径零 cc ⬜ |
| 终局 MG+BC+PC+v2==v3（阶段 13） | 🟡 | MG 文件层 ✅；BC／PC／v2==v3 未终 |
| 产品 L4 钉盘 | ✅ | **`5cac88d00`**（双端 L4＋bstrict 129） |
| BC（编译层零 host-cc） | 🟡 | `pipeline_x` 仍 host-cc mega |
| PC（产品默认 asm） | 🟡 | 门控已收；`labi_invoke_cc` 未删 |
| `pipeline_abi` mega pure-asm | ⬜ 硬禁 | 须点名 |
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

- 🟡 **7.2.1b** parser_asm suite audit B-minus — leftover flatten **完**（unique 0／helpers 0）；深链分批覆盖戏停；**已 T 缩壳**：P9 hybrid 跳过 suite 46k；**Route C 产品化**：P9b 编 `pthin_stretch.x` 跳过 lite；P1b 编 `pthin_lex_skip.x` 跳过 kind／copy／skip_walk；**P1c** 有则补全 skip_generic_angle_list_count（g_gp_pending_*／register_pending 仍 C；g05 `-E`+cc，pure-asm CG002）；P19b 编 `pthin_helpers.x` 跳过 kind／copy／pos／match-kw；P4b 编 `pthin_expr_primary.x` 跳过 ident 拼写／asm-option-bit；P3b 编 `pthin_type_ref.x` 跳过 token_starts_type／ident_is_dyn／builtin TypeKind／vector IDENT pack；P7b 编 `pthin_simd.x` 跳过 shuffle／select ident pack／callee 名填充；P4ub 编 `pthin_expr_unary.x` 跳过 TOKEN→ExprKind；P4bb 编 `pthin_expr_binop.x` 跳过 TOKEN→ExprKind；P14b 编 `pthin_skip_if.x` 跳过 trait／impl＋if-core／statement 走查；P12b 编 `pthin_skip_tl.x` 跳过 skip_one_struct／enum／extern 走查；P18b 编 `pthin_body_tl.x` 跳过 is_fn_sig_scalar＋diag／body skip 走查＋skip_one_top_level let／const；**P18c** 有则补全 cfg_skip／diag_first_ident（P010–P014／onefunc_param_name_dup 仍 C；pure-asm 过）；**P10b** 编 `pthin_glue.x` 跳过 skip_one_function_full 走查（glue 包装仍 C；pure-asm 过）；**P13b** 编 `pthin_try_skip_allow.x` 跳过 padding 走查（write_result／parse_into 仍 C；pure-asm 过）；**P11b** 编 `pthin_imports.x` 跳过 skip_imports 走查；**P11c** 有则补全 consume_path／try_skip（collect／copy_token_bytes 仍 C；collect AUDIT 前缀仅 audit 宏；g05 `-E`+cc，pure-asm CG002）；**P5b** 编 `pthin_ctrl.x` 跳过注释感知花括号字节扫描／kw_at_pos；**P5c** 有则补全 scan_sync pos（parse／realign／match／if_expr 仍 C；parse AUDIT 前缀仅 audit 宏；g05 `-E`+cc，pure-asm CG002）；**P15b** 编 `pthin_library.x` 跳过 library_scan 走查（into／buf parse／lex_from 仍 C；into／buf AUDIT 前缀仅 audit 宏；pure-asm 过）；**P17b** 编 `pthin_diag_late.x` 跳过 after_structs／fail_at_token_kind 走查（buf AUDIT 前缀仅 audit 宏；pure-asm 过）；**P17c** G.7 `diag_skip_let_const_buf` trampoline over P18b into（body_skip_buf 已是 trampoline；禁新 .x 导出）；残＝产品 `.inc` 切片仍 host-cc、lite／suite／lex_skip／helpers／primary ident／type_ref／simd／unary／binop／skip_if walks／skip_tl struct／enum／extern／body_tl skip／glue skip_one_function_full／try_skip_allow padding／skip_imports／ctrl brace-skip／scan_sync／library_scan／diag_late after_structs／fail portable 冷回退、`parser_asm_thin_c.from_x.c` 443KiB 仅冷 rest 回退（G-02f-330 omit rest）；PP002 heap entry ✅；import ctx 4MiB heap orch ✅；resolve_read embed 诚实拒 ✅  
  - [x] ABI＝B-minus（opaque＋lexer-step 桥；RFC §5）  
  - [x] 桥面／P9a／三契约／生成器 v1→v5.7／等价 harness  
  - [x] 栈 kinds[]／peek_kind_chain 根（toplevel_kind_peek 族）  
  - [x] parse_suite 可迁面 1936／1936（v5.38 L012-fit compress＋攀尽）  
  - [x] out 参族 9／9（＋trait_methods；生成器 v5.0 elide void `&r.next_lex`）  
  - [x] array／slice bracket 头粗探（同波双步进根修解锁）  
  - [x] 深链组合器首批（v5.1：score+=／负字节链／拒 advance_to；诚实＋34；trait_impl 红未入）  
  - [x] 厚 buf score 墙首批（v5.2：`&sl,`／`&lex, data, len`／尾旗／`&out`→0；诚实＋15）  
  - [x] advance_to 薄展开首批（v5.3：struct/enum/trait/match body＋buf；诚实＋7）  
  - [x] peek_ident_ptr 源字节根修＋impl_type 族（v5.4：诚实＋12）  
  - [x] function_advance 展开（v5.5：诚实＋9）  
  - [x] after_imports／deep-scan（v5.6：诚实＋27）  
  - [x] if_stmt_body 混用游标＋layout_name（v5.7：诚实＋34）  
  - [x] PP002 heap entry（preprocess_x_buf *u8 尊 source_len／out_cap；malloc_impl scratch=max(4MiB, raw_len) i32-fit；PipelineDepCtx embed 4MiB pin 不动）  
  - [x] leftover helper Route C 首批（v5.39：bind 薄包装／kind 分类／skip_allow inout；诚实＋19；余 advance_to／lexer_result）  
  - [x] leftover helper Route C flatten（v5.40：spawn_kw／brace_head／import_dot／match_subject_ident；诚实＋4；拒 import_path_post finalize 链；余 advance_to／next_lex／peek_kind）  
  - [x] leftover helper Route C flatten lookahead（v5.41：simd_builtin／import_as；诚实＋2；拒 from_at paren 走／peek_kind／validate／path_post／advance_to）  
  - [x] leftover helper Route C flatten from_at（v5.42：lookahead 标量＋lex_after_ident 走 paren；诚实＋1；拒 peek_kind／validate／path_post／advance_to）
  - [x] leftover helper Route C flatten peek_kind_chain（v5.43：kinds 数组＋指针游标；诚实＋1；拒 validate／path_post／advance_to）
  - [x] leftover helper Route C flatten expr_binop_kinds_probe（v5.44：kinds 匹配集＋指针游标；诚实＋1；拒 validate／path_post／advance_to）  
  - [x] leftover helper Route C flatten skip_* 链（v5.45：skip_balanced／skip_type_suffix／skip_one_param_type 指针 ABI；诚实＋3；拒 validate／path_post／advance_to）
  - [x] leftover helper Route C flatten advance_to 族（v5.46：struct／enum／trait／impl／if／function／match 指针 ABI；诚实＋7；拒 validate／path_post／collect_imports／mega_buf）
  - [x] leftover helper Route C flatten mega_buf wrap_buf（v5.47：diag_fn_mega_full_deep_buf 薄包装；诚实＋1；拒 validate／path_post／collect_imports）
  - [x] leftover helper Route C flatten import leftover 链（v5.48：import_path_post validate 薄包装＋collect_imports kinds＋classify；诚实＋2；拒 validate_toplevel）
  - [x] leftover helper Route C flatten validate_toplevel（v5.49：kind／ident_len／token_start 标量＋桥 bounds；诚实＋1；不抄 token_run_len／verify_kw 表；leftover-to-audit unique 0）
  - [x] import ctx 4MiB heap orch（pin-safe：load_import_from_disk_c 改 view＋PP002 malloc；seed impl_c 同语义；C thin overlay WEAK `_c`；PipelineDepCtx embed 4MiB 不动）
  - [x] resolve_read embed 诚实拒（pipeline_read_file_x 改 view＋拒 length>4MiB；seed 同语义；C thin overlay WEAK `pipeline_read_file_x`；pin embed 不动；产品 import 仍走 heap orch）
  - [x] leftover_helpers kind-scalar eq（v5.50：6／30；独立 TU 穷尽 TokenKind，避开 twins.h static 阴影；classify／score 留 stretch.x；余 24＝name/len／source+off／复合 ABI）
  - [x] leftover_helpers name/len eq（v5.51：8／30；独立 TU ident 字节类＋长度角，避开 twins.h static 阴影；C twin 薄包 bind_name_validate；classify／score 留 stretch.x；余 16＝source+off／复合 ABI）
  - [x] leftover_helpers source+off eq（v5.52：6／30；独立 TU ident 字节类＋长度＋token_start 角，避开 twins.h static 阴影；C twin 薄包 bind_name_validate on data+off；vector_type_ident 加 i3x*／Vec*；classify／score 留 stretch.x；余 10＝复合 ABI）
  - [x] leftover_helpers kind+source+off eq（v5.53：2／30；独立 TU 穷尽 TokenKind＋IDENT ident 字节类／长度／token_start 角，避开 twins.h static 阴影；C twin 薄包 bind_name_validate on data+off；import_dot_segment 加 I32／ASYNC 恒 1；classify／score 留 stretch.x；余 8＝复合 ABI）
  - [x] leftover_helpers two-kind+source+off eq（v5.54：1／30；独立 TU 穷尽 TokenKind at／ident 各一维＋AT+IDENT shuffle／select 拼写／长度／token_start 角，避开 twins.h static 阴影；C twin 拼写检查非 bind_name_validate；classify／score 留 stretch.x；余 7＝复合 ABI）
  - [x] leftover_helpers 7-param as-bind eq（v5.55：1／30；独立 TU 穷尽 TokenKind kind／next_kind 各一维＋IDENT+"as" 拼写／长度／token_start 角＋next-ident 字节类／长度／next_start 角；7 参 first-kind ABI 不能进 k_cases；C twin 拼写检查＋bind_name_validate on data+next_start；classify／score 留 stretch.x；余 6＝复合 ABI）
  - [x] leftover_helpers kinds-array eq（v5.56：2／30；独立 TU 短 snippet＋guard／max_peek／num_kinds 角＋若干 start-pos，避开 twins.h static 阴影；C twin 拷 *lex＋lexer_next_into；.x peek/step/restore；peek_kind_chain_buf 仍是 lex-first k_cases；classify／score 留 stretch.x；余 4＝复合 ABI 单件）
  - [x] leftover_helpers validate_toplevel eq（v5.57：1／30；独立 TU 穷尽 TokenKind ident_len≤0／in-span／overflow＋ident_len／token_start／slen 角含 wrap；无 twins.h static；first-kind ABI 不能进 k_cases；C twin EOF／ident_len≤0／span；不抄 token_run_len／verify_kw 表；classify／score 留 stretch.x；余 3＝复合 ABI 单件）
  - [x] leftover_helpers import_path_post eq（v5.58：1／30；独立 TU ident 字节／点／非法字节／长度角含 path_len>63 cap；无 twins.h static；first-path_buf ABI 不能进 k_cases；C twin 薄包 import_path_validate；不抄 ident_continue 表；classify／score 留 stretch.x；余 2＝preamble／from_at）
  - [x] leftover_helpers collect_imports_preamble eq（v5.59：1／30；独立 TU 穷尽 TokenKind 每槽一维＋classify-hit 小笛卡尔＋null／live／nodata／empty；无 twins.h static；first-kind ABI 不能进 k_cases；C twin 薄包 classify_toplevel；不抄 classify 表；诚实 flatten＝live source→1／null→0；classify／score 留 stretch.x；余 1＝from_at）
  - [x] leftover_helpers simd_builtin_deep_from_at eq（v5.60：1／30；独立 TU 穷尽 TokenKind null lex＋AT+IDENT ident 角＋短 live-lex snippet；twins.h static 阴影；first-at_kind ABI 不能进 k_cases；C twin 薄组合 simd_builtin／vector_type_ident／paren_expr_head／builtin_vec_token；不抄 classify／score 表；诚实 flatten＝C 空 lex 跳 paren／.x paren 空 lex→0；IDENT remaining≥ident_len；classify／score 留 stretch.x；余 0）
  - [x] 深链分批 smoke ultra_mega 层（v5.61：25／270 soft-deep；exact ultra_mega 非 HARD BAN 子串；daily 默认 SKIP_SYNTH=1＋STRIDE=4；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝super_mega 25／270）
  - [x] 深链分批 smoke super_mega 层（v5.62：25／270 soft-deep；exact super_mega 非 HARD BAN 子串、不在 is_deep_climb_name；daily 默认 SKIP_SYNTH=1＋STRIDE=4；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝hyper_mega 须精确过滤禁吞 ultra_hyper）
  - [x] 深链分批 smoke hyper_mega 层（v5.63：25／270 soft-deep；exact hyper_mega 非 HARD BAN 子串、在 is_deep_climb_name；harness eq_tok_hits_name 拒 ultra_ 前缀吞 575；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝ultra_hyper 须精确过滤禁吞 max_ultra）
  - [x] 深链分批 smoke ultra_hyper 层（v5.64：25／270 soft-deep；exact ultra_hyper 非 HARD BAN 子串、在 is_deep_climb_name；harness eq_tok_hits_name 拒 max_ 前缀吞 550；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝max_ultra 须精确过滤禁吞 apex_max）
  - [x] 深链分批 smoke max_ultra 层（v5.65：25／270 soft-deep；exact max_ultra 非 HARD BAN 子串、在 is_deep_climb_name；harness eq_tok_hits_name 拒 apex_ 前缀吞 525；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝apex_max 须精确过滤禁吞 summit_apex）
  - [x] 深链分批 smoke apex_max 层（v5.66：25／270 soft-deep；exact apex_max 非 HARD BAN 子串、在 is_deep_climb_name；harness eq_tok_hits_name 拒 summit_ 前缀吞 500；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝summit 仍 HARD BAN 禁 daily）
  - [x] 深链分批 smoke crown_pinnacle 层（v5.67：25／270 soft-deep；EQ_ONLY 非 HARD BAN 子串、pinnacle／crown 在 is_deep_climb_name；跳过 HARD BAN 层 summit／peak／zenith／pinnacle_zenith；harness eq_tok_hits_name 拒 supreme_ 前缀吞 375；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝supreme_crown 须精确过滤禁吞 ultimate_supreme）
  - [x] 深链分批 smoke supreme_crown 层（v5.68：25／270 soft-deep；EQ_ONLY 非 HARD BAN 子串、crown 在 is_deep_climb_name；跳过 HARD BAN 层 summit／peak／zenith／pinnacle_zenith；harness eq_tok_hits_name 拒 ultimate_ 前缀吞 350；daily 默认 SKIP_SYNTH=1＋STRIDE=4＋DEEP_MAX_FILE_OFF=0；vx／summit／peak／zenith／versal 仍立卡；classify／score 留 stretch.x；续＝ultimate_supreme 须精确过滤禁吞 absolute_ultimate）
  - [x] 深链分批 smoke 3 层 75／150（v5.69 收口后 **停**：覆盖戏不减 host-cc；续＝8.3.6／已 T 冷孪生缩壳，禁再 eq 已 T combinator）
  - [x] 已 T 冷孪生缩壳起步（P9 hybrid 跳过 suite 46k 预处理；classify／score 迁 lite；冷 lane 仍 include suite；禁再 eq 已 T combinator）
  - [x] Route C 产品化（P9b 编 `pthin_stretch.x`；hybrid 跳过 lite 564 行；token.h `_Static_assert` 钉 classify 针；冷 lane 仍 include lite；禁再 eq 已 T combinator）
  - [x] P1b Route C＋B-minus（编 `pthin_lex_skip.x`；hybrid 跳过 kind／copy／skip_balanced／generic_into；token.h `_Static_assert`；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - [x] P1c B-minus（`pthin_lex_skip.x` 有则补全 skip_generic_angle_list_count；hybrid 跳过 C 孪生；g_gp_pending_*／register_pending 仍 C；语言无 global u8[8][64]，C trampoline 持 dest buf 再写入静态表；依赖 P9a 桥；g05 `-E`+cc，pure-asm CG002 同 P1b；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_generic_angle_list_into；禁开新 P 道）
  - [x] P19b Route C（编 `pthin_helpers.x`；hybrid 跳过 kind／copy／pos／match-kw；`first_token_kind_buf` 已 T AUDIT 探针仅 audit 宏；rewind／run_len 仍 C；token.h `_Static_assert`；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - [x] P4b Route C（编 `pthin_expr_primary.x`；hybrid 跳过 ident 拼写／asm-option-bit；`parse_primary_into` 已 T AUDIT 探针仅 audit 宏；parse／arena 仍 C；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - [x] P3b Route C（编 `pthin_type_ref.x`；hybrid 跳过 token_starts_type／ident_is_dyn／builtin TypeKind／vector IDENT pack；parse／arena 仍 C；skip_tl TOKEN→TypeKind 转调同一表；token.h `_Static_assert`；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - [x] P7b Route C（编 `pthin_simd.x`；hybrid 跳过 shuffle／select ident pack／callee 名填充；parse／arena 仍 C；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - [x] P4ub Route C（编 `pthin_expr_unary.x`；hybrid 跳过 TOKEN→ExprKind；parse／wrap／arena 仍 C；已 T AUDIT 探针仅 audit 宏；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - [x] P4bb Route C（编 `pthin_expr_binop.x`；hybrid 跳过 TOKEN→ExprKind；parse／wrap／peek／single_tok_chain 仍 C；parse_logor 已 T AUDIT 探针仅 audit 宏；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁与 unary 表合并）
  - [x] P14b B-minus（编 `pthin_skip_if.x`；hybrid 跳过 trait／impl＋if-core／statement 走查；enum register 仍 C；依赖 P9a 桥＋P1b skip_balanced；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_balanced）
  - [x] P12b B-minus（编 `pthin_skip_tl.x`；hybrid 跳过 skip_one_struct／enum／extern 走查；trait-reg／enum register／parse_one_extern 仍 C；依赖 P9a 桥＋P1b skip_balanced／skip_generic_angle；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_balanced／skip_generic_angle）
  - [x] P18b Route C＋B-minus（编 `pthin_body_tl.x`；hybrid 跳过 is_fn_sig_scalar＋diag_skip／body_skip＋skip_one_top_level let／const；P010–P014／diag_first_ident／cfg_skip 仍 C；依赖 P9a 桥＋P14b skip_one_if；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_one_if）
  - [x] P18c B-minus（`pthin_body_tl.x` 有则补全 cfg_skip／diag_first_ident；hybrid 跳过 C 孪生；P010–P014／onefunc_param_name_dup 仍 C；语言无 lexer_init，C trampoline 持 inited lexer；依赖 P9a 桥＋P14b skip_one_if＋P12b skip_one_struct＋P10b skip_one_function_full；**pure-asm 过**；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_one_struct／skip_one_function_full／skip_one_if；禁开新 P 道）
  - [x] P10b B-minus（编 `pthin_glue.x`；hybrid 跳过 skip_one_function_full 走查；glue 包装／parse glue 仍 C；依赖 P9a 桥＋P1b skip_balanced＋P12b skip_one_extern；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_balanced／skip_one_extern）
  - [x] P13b B-minus（编 `pthin_try_skip_allow.x`；hybrid 跳过 padding 走查；write_result／parse_into 仍 C；依赖 P9a 桥＋P1b skip_balanced；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_balanced）
  - [x] P11b B-minus（编 `pthin_imports.x`；hybrid 跳过 skip_imports 走查；try_skip／consume_path／collect 仍 C；collect AUDIT 前缀仅 audit 宏；依赖 P9a 桥＋peek_int_val；pure-asm 过；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 consume_path）
  - [x] P11c B-minus（`pthin_imports.x` 有则补全 consume_path／try_skip；hybrid 跳过 C 孪生；collect／copy_token_bytes 仍 C；语言无 local u8[128]，C trampoline 持 path buf；依赖 P9a 桥＋P1b copy＋P9b validate／finalize；g05 `-E`+cc，pure-asm CG002 同 P1b／P5b；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 copy_slice／validate／finalize；禁开新 P 道）
  - [x] P5b Route C（编 `pthin_ctrl.x`；hybrid 跳过注释感知花括号字节扫描／kw_at_pos；parse／scan_sync／match／if_expr 仍 C；parse_if_stmt 已 T AUDIT 前缀仅 audit 宏；禁包 leftover else-if AUDIT；禁再抄 P1b token skip_balanced；skip_ws 仍 P9b；g05 `-E`+cc，pure-asm CG002 同 P1b／P19b；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - [x] P5c Route C（`pthin_ctrl.x` 有则补全 scan_sync pos；hybrid 跳过 scan_sync C 孪生；C trampoline 重建 by-value lexer；parse／realign／match／if_expr 仍 C；禁迁 dead sync_lex_after_if_cond_paren；禁包 leftover else-if AUDIT；禁再抄 P1b token skip_balanced／P9b skip_ws；g05 `-E`+cc，pure-asm CG002 同 P5b；冷 lane 仍 full .inc；禁再 eq 已 T combinator）
  - [x] P15b B-minus（编 `pthin_library.x`；hybrid 跳过 library_scan 走查；into／buf parse／lex_from 仍 C；into／buf AUDIT 前缀仅 audit 宏；依赖 P9a 桥＋P1b copy；**pure-asm 过**；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 copy_slice）
  - [x] P17b B-minus（编 `pthin_diag_late.x`；hybrid 跳过 after_structs／fail_at_token_kind 走查；buf AUDIT 前缀仅 audit 宏；依赖 P9a 桥＋P1b is_pointee＋P12b skip_one_struct＋P18b scalar／body_skip；**pure-asm 过**；冷 lane 仍 full .inc；禁再 eq 已 T combinator；禁再抄 skip_one_struct／body_skip／is_fn_sig／is_pointee）
  - [x] P17c G.7（`diag_skip_let_const_buf` trampoline over P18b into；hybrid／冷均不再编 buf C 走查孪生；body_skip_buf 已是 trampoline；禁再抄 into；禁开新 P 道；禁新 .x 导出）
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
- 🟡 **8.3.6** from_x 全表退役策略终稿 — 残：有引用冷孪生三分处置（pthin suite 46k、lite 564、lex_skip portable／count、helpers kind／copy／pos／match-kw、primary ident、type_ref kind／dyn／builtin／vector IDENT、simd ident／callee 名、unary TOKEN→ExprKind、binop TOKEN→ExprKind、skip_if walks、skip_tl struct／enum／extern walks、body_tl scalar／skip walks／cfg_skip／diag_first_ident、glue skip_one_function_full、try_skip_allow padding、skip_imports、consume_path／try_skip、ctrl brace-skip／kw_at_pos／scan_sync、library_scan、diag_late after_structs／fail 已从 hybrid 预处理拿掉，文件仍留作冷回退；glue_tail 包装、primary parse、P19 rewind／run_len、skip_tl trait-reg、try_skip_allow parse_into、collect_imports 走查、if_stmt parse／realign 仍 host-cc）  
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
| `pipeline_abi` mega pure-asm | ⬜ 硬禁 | 须点名 |
| nest 冻 64 | ✅ 纪律 | — |

---

## 附录

### 钉盘

| 项 | 值 |
|----|-----|
| 产品 L4 放行钉盘 | **`5cac88d00`** |
| bstrict | 129 |
| 升钉条件 | 用户点名 L4／谈自举；禁止微步升钉 |

### 推荐推进序（非流水）

1. 日常软刀／PC 底盘（非 mega；须点名才动 check／mega）  
2. 🟡 **7.2.1b leftover flatten 完**＋**8.3.6 有引用冷孪生三分**（P9 suite 46k＋lite 564＋P1b lex_skip portable＋P1c skip_generic_angle_list_count＋P19b helpers kind／copy／pos／match-kw＋P4b primary ident＋P3b type_ref kind／dyn／builtin／vector IDENT＋P7b simd ident／callee 名＋P4ub unary TOKEN→ExprKind＋P4bb binop TOKEN→ExprKind＋P14b skip_if walks＋P12b skip_tl struct／enum／extern walks＋P18b body_tl scalar／skip walks＋P18c cfg_skip／diag_first_ident＋P10b glue skip_one_function_full＋P13b try_skip_allow padding＋P11b skip_imports＋P11c consume_path／try_skip＋P5b ctrl brace-skip／kw_at_pos＋P5c scan_sync＋P15b library_scan＋P17b diag_late after_structs／fail＋P17c G.7 diag_skip_let_const_buf trampoline over P18b into hybrid 已跳过；残＝产品 `.inc` 切片仍 host-cc含 glue_tail 包装、P19 rewind／run_len、skip_tl trait-reg、try_skip_allow parse_into、collect_imports 走查、if_stmt parse／realign；**禁**再深链分批 eq；pipeline_x mega 须点名）＋ **BC + 8.3** 
3. ⬜ **7.2.1／7.2.2** parser seed 物理删／去 pin  
4. 🟡 **阶段 10** 残（NT／MSVC／qemu／Win 实机）  
5. ⬜ **阶段 12–13** 最小 seed · 全路径零 cc · v2==v3 · 公告  

---

> **使用**：完成一步只改对应 `⬜`→`🟡`→`✅`。不要在本文写 tip／wave／日志路径。
