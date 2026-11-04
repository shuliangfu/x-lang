# Win tip L2 opt INDEX rvalue（matrix beat `win_tip_l2_product_matrix_5_5`）· **WIP grain**

> Beat：`win_tip_l2_product_matrix_5_5`。本粒：Win tip Soft Cap mega `pipeline_asm_emit_index_elf_c` → tip.x-faithful thin。
> tip PE **`a57b37b01eed…`→`aa906979afb141af`**（`.c78eidx` emit_index thin）。
> 禁 Soft Cap 体拷／假绿／CloudAgent／升钉／自 CLOSE。

## DIG（诚实根因）

- Soft Cap mega `pipeline_asm_emit_index_elf_c`（frame `0x1188`／pipe_store cells）在 Win tip／Prefer 上对 **rvalue INDEX** 一律 CG002（`buf[0]` code_len≈84；`bp[0]`／opt≈6361 `.Lf0_1`）。
- **ADDR_OF INDEX**（`&buf[0]`／`&bp[0]`）已绿：leftover `glue_emit_index_eff_addr_scaled_elf_c`＋`glue_emit_index_eff_addr_base_elf_c`（含 `*T` holds_indirect LOAD）OK。
- Mac／Ubuntu tip.x thin emit_index（scaled → load by esz）对 `buf[0]`／`bp[0]` 绿。
- Soft Cap Prefer 同红（非 oracle；禁体拷）。

## 修（tip-only）

1. seed：`compiler/seeds/win_tip_pe_overrides/emit_index_elf_thin_override.c`  
   - tip.x-faithful：`index_elem` → `glue_emit_index_eff_addr_scaled_elf_c` → load zext8／i32／i64／struct16；ARRAY leave-addr；无 assign-addr cache。
2. inject：`compiler/scripts/win_tip_pe_inject_emit_index_elf_override.py` → `.c78eidx`  
   - JMP tip mega emit_index＠`0x1401425d0`（steal 12：`push rbp; mov rbp,rsp; push rbx; sub rsp,0x1188`）。

## 验收（本粒）

- `p_i32`／`p_idx_only`（`*u8 bp[0]`）**build0 run=1**。
- `tmp_opt_ret102`（option 至 `bp[0]` 检查后 `return 102`）**build0**（INDEX 段过）。
- Win `product_l2_matrix`：**仍 pass=4**（rv／hello／f32／si）；**opt FAIL_BUILD rc=139 SEGV**（见残）。
- Mac／Ubuntu L2 仍 **5/5**（本粒只改 Win PE）。

## Residual（移交同 beat — 仍挡 5/5）

1. **tip SEGV** 编 `tests/option/main.x` 末行  
   `return a + b + c + (u1 as i32) + (u2 as i32) + extra;`  
   - `let s = <同式>; return s;` **可 build**；`return a+b+c`  alone 亦 SEGV。  
   - gdb：`movzbl (%rax),%eax` 坏指针（非 emit_index 帧）。  
   - 与 Soft Cap mega INDEX 无关；INDEX 修后才暴露。
2. **`or_i32` 值返 dual-GP**（独立于 INDEX；pre `.c77nlay` tip 同红）：  
   - tip 编的 `core_option_or_i32` **只 `mov rax, low8; ret`**，丢 value＠+8（本在 rdx／slot+8）。  
   - caller 调用后也 **只 store rax**（双写同一槽），`-0x128` 高半未写。  
   - `is_some(o1)` 绿；`expect_i32(o1)!=99` → **runtime -3**。  
   - 根因链：`.c77nlay` 将 `w1545_win_mid_named_sz` nop→0，避免 mid byref／sret≠param_home；连带 `w1521_rs_mid_named_field`／call retval pair 不走 16B dual-GP。  
   - 长线：return／call-result 对 named size∈[9,16] 走 dual-GP（**不**恢复 mid byref），再 tip 重编 `option.o`／`result.o`。

## Reproduce

```bash
gcc -c -O0 -fno-omit-frame-pointer -o /tmp/eidx.o \
  compiler/seeds/win_tip_pe_overrides/emit_index_elf_thin_override.c
python3 compiler/scripts/win_tip_pe_inject_emit_index_elf_override.py \
  compiler/xlang_asm.exe /tmp/eidx.o
# probes
./compiler/xlang_asm.exe -o /tmp/p_idx p_idx_only.x  # run=1
```

## 非目标／禁

- Soft Cap 体拷；假绿改 option 测试／`return 102` 顶替真式；CloudAgent；`_dig` 入 git；升钉；自 CLOSE。

## store_retval dual-GP band（`.c79srvp`）· WIP

- Soft Cap mega `glue_store_retval_pair_to_rbp_elf_c`＠`0x14012ae98` for named size 9–16 called a 2-arg helper instead of `backend_enc_store_rdx_to_rbp_arch(elf, half2, ta)` → caller dropped value@+8.
- tip-only inject `.c79srvp`: size=`max(size_simple,dual_gp)`; if 9..16 store rax@slot + rdx@slot−8 (x86); else trampoline Soft Cap mega.
- PE `aa906979afb141af`→`173da296e3783371`. Matrix **4/5** (si green; full-body store_retval override without trampoline SEGV'd si — kept band-only).
- Residual unchanged for opt: (1) tip SEGV compiling `return a+b+c+…` (byte-index `movzbl (%rax)` rax=0x40; `let s=…; return s` builds, run −3) (2) `or_i32` callee return still rax-only (emit_expr VAR interceptor does not hit param return path).

## reinject lock（`.c79srvp`）· 2026-11-05

- Seed polarity：tip.x x86 high-end `half2 = slot_off - 8`（`+8` Soft Cap Win 实验＠`8287b41b6`→matrix **3/5** si+opt SEGV；revert＠`2365ca4de`）。
- **Inject MUST compile seed `-O2`**（or reuse `/c/xlang_tmp/srvp.o`）：`-O0 -fno-omit-frame-pointer` → PE `8c2c29e8389ac20e` breaks **si** (tip SEGV on compile). `-O2` → PE **`173da296e3783371`** matrix **4/5**.
- Live：tip `2365ca4de`／PE `173da296e378…`／pass=4 fail=1（opt return-binop SEGV；`or_i32` still rax-only — Soft Cap return VAR fast-path bypasses `glue_load_var`／emit_expr；peel attempts regress expect）.
