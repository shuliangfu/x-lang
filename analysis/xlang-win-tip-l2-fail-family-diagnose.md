# Win tip L2 fail family diagnose（刀 11.44）

> Gate：`tests/run-win-tip-l2-fail-family-diagnose-gate.sh`。
> 基线：Win tip L2 **1/5**＠`58e34910f`（再验 tip `65cd8c224` 仍 **1/5**）**勿 regress**。
> 闸位 HOLD：Soft Cap Prefer `09fe`／钉 ecdb／tiphead 9ecd／Cap tip／code tip **不升**。禁假绿／SoftCap-parity／CloudAgent。
> 只 LAN `windows-server`（`192.168.8.158`）；禁 `windows-remote-server`。

## Matrix（tip PE `compiler/xlang_asm.exe`）

| probe | tip PE＠65cd8c224 | Soft Cap Prefer PROD `09fe`（`/c/xlang_tmp/prod_softcap/lab_SoftCap_76795.exe`，sha256 前缀 `09fe181dbd0e`） |
|-------|-------------------|----------------------------------------------------------------------------------------------------------|
| rv | OK build0 run42 | OK build0 run42 |
| opt | **FAIL_BUILD CG002** `elf ctx code_len=0` | FAIL_BUILD **T001** `no impl … some_ptr_u8`（≠ tip CG002） |
| si | **FAIL_BUILD CG002** `elf ctx code_len=0` | FAIL_BUILD **T001** `no impl … some_i32` |
| hello | **FAIL_BUILD P012／XP001／XP008** | FAIL_BUILD **P012**（同族） |
| f32 | **FAIL_RUN 139**（SEGV） | **OK build0 run0**（对照绿） |

pass=1 fail=4＝基线形态；**勿**把 Soft Cap Prefer f32 绿写成 tip L2 抬分。

## 失败族（对照 11.15–11.17）

### 11.15 CG002（opt／si）

- tip PE：`codegen error[CG002]: asm_codegen failed`＋`note: elf ctx code_len=0 num_labels=0 num_patches=0`。
- Soft Cap Prefer 09fe：同探针停在 **typeck T001**（未进 tip 同款 CG002）。
- 残＝**tip PE** codegen／ELF ctx 空；勿 SoftCap-parity 空转 plant；勿升 Soft Cap。

### 11.16 hello／fmt P012／XP008

- `examples/hello.x` 仅 **7** 行；报错行号 `hello.x:79`／`:76` 为**错挂**。
- 最小复现：`xlang_asm.exe -o out core/fmt/mod.x` → **P012**＠`core/fmt/mod.x:79:7`：
  - `let num_digits: i32 = 0;`（`fmt_u32_to_buf` **函数内** local let）
  - tip／Soft Cap Prefer PE 均把该 local 误判为 top-level duplicate binding。
- `std/fmt/mod.x` 同族：P012＠`267:7` `let len: i32 = 0;`。
- Darwin tip（同 tip SHA 源）`examples/hello.x` **OK**（Mac L2 5/5 对照）。
- 残＝**Windows PE 解析／作用域**（local let→假 top-level）；hyg eol=lf 非抬分点（源已 LF）。

### 11.17 f32 FAIL_RUN 139

- tip PE：build0 → 产物 PE32+ → run **SEGV／139**。
- Soft Cap Prefer 09fe：**run0** 对照绿 → 残明确在 **tip PE**（非源 `tests/float/f32_f64.x`）。
- 勿把 Soft Cap Prefer 对照绿写成 tip L2 产品绿。

## 下一步（未做；须另粒诚实）

1. tip PE：修 Windows local-let 作用域（清 11.16）或确认为已知 PE parse 债后 HOLD。
2. tip PE：CG002 `code_len=0`（11.15）与 f32 SEGV（11.17）分粒；对照 Soft Cap Prefer 仅作对照，**禁止** host-swap／升 Soft Cap 当 tip 绿。
3. 三端 tip L2 全绿后才排 L4；然后才回 toml0／Soft Cap Prefer。
