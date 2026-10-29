# dig_body_fill CLOSE — body[0] write-site nail

## Verdict
body[0] fill write-site is **nailed**:

1. **Module.num_funcs / body[0]** written ONLY in
   `pipeline_module_func_alloc_slot`
   (`runtime_pipeline_abi_module_func_thin.x`):
   `w324_store_i32(m, 0, w324_gv_len(sc, W324_MSC_FUNCS))`
   SoftCap RVA **0x140203be1**.

2. **W324_FN_BODY (=276)** written ONLY in
   `pipeline_module_func_set_body_ref`:
   `w324_store_i32(f, W324_FN_BODY, body_ref)`
   SoftCap RVA **0x140203f83**.

3. **Parser pairs them** (alloc_slot → … → set_body_ref):
   - `parser.x` parse_into slice commit ~10952 / ~10973
   - `parser.x` parse_into buf commit ~13102 / ~13120
   - `module_register_arena_func` ~8847 / ~8857

No other writer of body[0]. W324_FN_BODY never written unless alloc_slot succeeded (fi>=0).

## SoftCap live对照 (Mac→ssh windows-server, INT3 one-shot, ASLR-safe Rip-rewind)
Lab = BACKUP copy. No COUNTFN / tip / SoftCap emit E9 / mega amplify.

| case | alloc_slot | set_body_ref | tl_alloc | blk | arena_fn | SoftCap natural |
|------|------------|--------------|----------|-----|----------|-----------------|
| letret7 | 1 | 1 | 0 | 1 | 1 | PASS |
| two_lets_ret_a | 1 | 1 | 0 | 1 | 1 | (parse commits) |
| three_lets | 1 | 1 | 0 | 1 | 1 | (parse commits) |
| ret_add | 1 | 1 | 0 | 1 | 1 | (parse commits) |
| ret0 | 1 | 1 | 0 | 1 | 1 | (parse commits) |
| **two_lets** | **0** | **0** | **1** | **0** | **0** | CG002 labels=2 |
| **one_let_add** | **0** | **0** | **1** | **0** | **0** | CG002 labels=1 |
| add2 | 0 | 0 | 0 | 0 | 0 | CG002 labels=0 |
| if0 | 0 | 0 | 0 | 0 | 0 | CG002 labels=0 |

## 真因 (fill miss)
SoftCap never reaches parser commit `alloc_slot`+`set_body_ref` for
`return <ident> + <expr>` shapes (`two_lets` / `one_let_add`).
Lets are misrouted to `pipeline_module_top_level_let_alloc` (RVA 0x14029ba1f);
Module.num_funcs stays 0 → mega body[0]=0 → cfn=0 → CG002.
`return <ident>` / `return <lit>+<lit>` / multi-let with ident-only return DO commit.

add2/if0: different miss (no slot, no tl) — still empty Module at mega.

## LIVE vs SoftCap
- LIVE `xlang_live.exe` 5140671: **8/8**
- SoftCap L PROD Restored 7961399: **1/8** (letret7 only)
- I fold held: **7945801**

## Bans held
禁硬拧 COUNTFN／禁 tip 叶子／禁 SoftCap emit E9／禁 mega 放大／未绿勿 push.

## Next (not done this close)
Isolate SoftCap parse path that should call alloc_slot for ident-binop
return (onefunc/body final_expr) vs LIVE — root fix still open.
