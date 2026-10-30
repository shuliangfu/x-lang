# DIG `fwd_46a500` — Capless callee `0x46a4db` GS after SoftCap/`@2c` epi

**2026-10-30 ~18:45 CST Asia/Shanghai** · tip parent `e07f6a087`

## Nail

1. Under `b0_h2c` (and baseline): Capless path SoftCap → `@2c614f` → **`call 0x46a4db@576746` HIT**; `0x46a4db` epi `add rsp`/`pop`/`ret` **HIT** for fwd+let; **`after_46@57674b` fwd=GS / let=INT3**. Reach ret but do not land at Capless next insn for fwd → retaddr smash / bad return inside `0x46a4db` body (not SoftCap/`@2c`).
2. Frame of `0x46a4db`:
   - `push rbp; sub rsp,0x1f0; lea rbp,[rsp+0x80]`
   - retaddr `[rbp+0x178]`; saved rbp `[rbp+0x170]`
   - r9d home `@46a500 [rbp+0x198]` = call_rsp+0x20 (= Capless `[rsp+0x20]` isomorphic smash — same class as SoftCap/`@2c6174`)
   - body reads **6th** `[rbp+0x1a8]` (= call_rsp+0x30); Capless only writes 5th at `[rsp+0x20]` before call — **miss-6th**
3. Capless **does** set r9 before call_46: `@57671d mov r9,[rbp+0x4a8]` (on-path after SoftCap/@2c store); not a miss-r9 at call_46.
4. Callers of `0x46a4db`: `@46bac7`, `@46bda6`, `@576746` only.
5. **skip call_46** at Capless (`xor eax,eax` @576746): after_46/call_493 HIT; **fwd USER run=GS** (GS inside/`after` `0x493d31`). Need a real call/return into 46 for later Capless chain.
6. **hollow plant** `@46a4e3` (after `sub rsp,0x1f0`, before `lea rbp`): `xor eax,eax; jmp 0x46af5d` (epi). Stack-balanced early return 0.
   - **hollow_only** (no b0_h2c) sha `18b229af77bd`: lit/local/fwd/let **OK run=OK** — first stable Isol that greens `p_ret_fwd` past GS.
   - b0_h2c+hollow sha `617ba26e47b9`: same green.
7. Bisect under b0_h2c: hollow after first calls (`@46a525`, `@46a549`) and after `@46a76f` return (`@46a774`) still **green**. **skip `@46a76f` call** alone still **after_46 fwd=GS**. GS smash locus = **body after `@46a774` when run to real epi** (not the `@46a76f` call alone).
8. 1a8→1a0 / zero-6th plants: lit AV or fwd still GS — not sufficient Isol.
9. No `security_check_cookie` string in PE; SoftCap/46 lea-frame without cookie check — smash → GS/AV at return sites rather than cookie fail.

## Plants

| plant | sha12 | lit | fwd | local | let | 注 |
|---|---|---|---|---|---|---|
| cmk0_irdx_sub20（对照） | 3f43f1609d70 | OK run0 | **GS** | OK run1 | AV | |
| b0_h2c（诊） | 9eb76632c3b3 | OK | **GS** | OK | OK crc1 | after_46 fwd=GS |
| skip46 Capless（诊） | 922e01140bf6 | OK | OK/**run GS** | OK | OK | 493 GS |
| 1a8→1a0 | a21e71b7eebf | AV | GS | OK | AV | 非 Isol |
| z6th | 653b3e44a586 | OK | GS | OK | AV | 非 Isol |
| skip76f | 7c7174adacf3 | OK | **GS** | OK | OK | after_46 GS |
| **hollow_only `@46a4e3`** | **18b229af77bd** | **OK run0** | **OK run0** | **OK run1** | **OK** | **Isol；跳过 46 body** |
| b0h2c+hollow | 617ba26e47b9 | OK | OK | OK | OK | 同 hollow |
| hollow after 1fe04d/1fe07b/1fb198 | * | OK | OK | OK | OK | bisect；post-76f body 仍是砸点 |

## 证伪

- 扩链 home retarget／字母堆：上拍已证伪 AV；本拍未再扩。
- Capless skip-call_46 ≠ hollow：前者 fwd run GS（493）；后者需真实 call/ret。
- 仅修 6th／`@46a76f` skip：不解 after_46 fwd GS。
- force-kind／frame enlarge／epi-raise／LIVE／mega／nopr9：仍禁；本拍未用。

## Isol plant recipe（hollow_only）

Host baseline `host_cmk0_irdx_sub20.exe` sha12 `3f43f1609d70`. At RVA `0x46a4e3` (7 bytes, was `lea rbp,[rsp+0x80]`):

```
31 c0                xor eax, eax
e9 xx xx xx xx       jmp rel32 → 0x46af5d   ; epi add rsp,0x1f0; pop rbp; ret
```

Result sha12 `18b229af77bd`. Caveat: **skips `0x46a4db` body** (returns 0). Gate tests pass; semantic work of 46 not preserved — next beat should surgical-keep body past `@46a774` smash.

## 下一单点

- **`fwd_46_post76f`**：DIG/plant smash locus in `0x46a4db` body **after `@46a774`** (hollow@46a774 green；full→epi after_46 GS；skip76f 仍 GS) → surgical Isol that keeps 46 work. 禁 tip@121278／join／epi-raise／LIVE／mega／字母堆／假绿 force-kind／依赖 nopr9 抖 AV／再扩链假 Isol.

## 脚本／log

`_dig/dig_fwd_46a500{,_2..8}.py`／`.log`；本笔记。

PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**。
