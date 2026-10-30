# DIG `fwd_46_post76f` — surgical smash after `@46a774` in `0x46a4db`

**2026-10-30 ~18:55 CST Asia/Shanghai** · tip parent `187c1942a`

## Nail

1. Prior beat: hollow_only `@46a4e3` greens lit/local/fwd/let but **skips 46 body** (not semantic close). Smash when body runs to real epi → `after_46` fwd=GS.
2. INT3 under base: all post-76f sites through `ret1@46af65` **HIT**; `after_46@57674b` fwd=GS — reach ret site but Capless does not land (retaddr/state smash in body).
3. Hollow bisect:
   - `@46a774` / `@46a8a5` → **green** (USER `e411d7260d78` run OK) — never enter `8a5+` / never finish post-76f.
   - `@46a97a` → fwd **compile OK** USER `f4839df16ab1` **run=GS** — `8a5..97a` already changed emit.
   - `@46a9c6`+ → fwd compile **GS**.
4. Root: Capless writes only 5th `[rsp+0x20]` before `call 0x46a4db`; body uses **`[rbp+0x1a0]` (6th)** and **`[rbp+0x1a8]` (7th)** unset.
   - `call@46a967 → 0x469aa4` loads `[rbp+0x1a0]` as stack arg.
   - `call@46a99d → 0x47a492` loads `[rbp+0x1a0]` + `[rbp+0x1a8]`.
5. Plants:
   - `skip99d` alone: fwd compile OK / run GS (USER f483).
   - `z1a0` (zero 1a0/1a8 via buffer-clear slots): calls **HIT** but USER f483 run GS — zeros ≠ valid args.
   - **`skip_1a0_calls`**: nop both `call@46a967` and `call@46a99d` (`xor eax,eax; nop*3`) → lit/local/fwd/let **OK run OK** sha `79f39a84ead4`. Keeps pre-76f body + `8a5` checks + post-99d; skips only the two miss-stack calls.
6. Emit under `skip_1a0_calls` equals hollow USER `e411d7260d78` — gates green, but **46's two callee works still skipped**; not full semantic close. Need Capless to supply real 6th/7th (or Isol-native homes) so calls can run.

## Plants

| plant | sha12 | lit | fwd | local | let | 注 |
|---|---|---|---|---|---|---|
| cmk0_irdx_sub20（对照） | 3f43f1609d70 | OK run0 | **GS** | OK run1 | ∽ | |
| hollow_only `@46a4e3` | 18b229af77bd | OK | OK run0 | OK | OK | 跳过 body；对照 |
| h8a5 | 16e9fedabe3e | OK | OK | OK | OK | 跳 8a5+ |
| skip99d | e001a1f2b0ee | OK | OK/**run GS** | OK | OK | compile 过 |
| z1a0 | a20801275579 | OK | OK/**run GS** | OK | crc1 | 零填≠真参 |
| **skip_1a0_calls** | **79f39a84ead4** | **OK run0** | **OK run0** | **OK run1** | **OK** | **Isol；保 body，跳两 call** |

## Isol plant recipe（skip_1a0_calls）

Host baseline `host_cmk0_irdx_sub20.exe` sha12 `3f43f1609d70`.

```
@46a967  E8 xx xx xx xx  →  31 c0 90 90 90   ; xor eax,eax; nop*3  (skip call 0x469aa4)
@46a99d  E8 xx xx xx xx  →  31 c0 90 90 90   ; xor eax,eax; nop*3  (skip call 0x47a492)
```

Result sha12 `79f39a84ead4`. Cave host: `host_skip_1a0_calls.exe`.

## 证伪

- 整函数 hollow / h8a5：门绿但过度跳 body。
- 仅 skip76f / 仅 skip967 / 仅 skip99d / force8a5：不解或仍 GS。
- z1a0 零填 6th/7th：call 可达但仍 USER run GS。
- b0_h2c + skip99d：不解 USER run GS。
- force-kind／frame enlarge／epi-raise／LIVE／mega／字母堆：未用。

## 下一单点

- **`fwd_46_capless_1a0`**：Capless `@57673f` 前为 `call_46` 写实 6th/7th（`[rsp+0x28]`/`[rsp+0x30]`）或 Isol 内为 `[rbp+0x1a0]`/`[rbp+0x1a8]` 填真参，使 `@46a967`/`@46a99d` **可跑**且 USER≠hollow 假绿。禁 tip@121278／join／epi-raise／LIVE／mega／字母堆／假绿 force-kind／再整函数 hollow 当收刀。

## 脚本／log

`_dig/dig_fwd_46_post76f{,_2,_3,_4}.py`／`.log`；本笔记。

PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**。
