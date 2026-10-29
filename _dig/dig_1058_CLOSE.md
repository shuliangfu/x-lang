# 10.58 CLOSE — Win Soft Cap stack args beyond shadow

**2026-10-29 15:31 CST (Asia/Shanghai)** · manager ✅ · SoftCap PROD sha12 **`7a2cf5da581a`**

## Done
- Root: `enc_mov_rax_to_arg_reg` Win path emitted arg_idx≥4 as r8/r9; never `mov [rsp+0x20+],rax`.
- Fix: plant `48 89 44 24 20/28` at TABLE+30; arg4/5 LEA+len=5.
- Tri-end stack5/6/sum/reg4 → 7; 10.54 float+i32 10/10 preserved (Win≡prior).
- bak `59560be0128f` @ `C:/xlang_tmp/p1058/bak/`; Restored／I=7945801 kept; pin ecdb5cc1e **unchanged**.
- Debt → 10.60: arg_idx>5 (clamp=5; else always `[rsp+0x28]`) — needs clamp raise + chain/stub, not cheap.

## Artifacts
- PROD `compiler/xlang.exe` sha12 `7a2cf5da581a`
- DIG `_dig/dig_1058_PROGRESS.md` · `C:/xlang_tmp/p1058/`
