# DIG `fwd_2c6174` — isomorphic smash chain after SoftCap r9-home

**2026-10-30 ~18:45 CST Asia/Shanghai** · tip parent `95f49d9a4`

## Nail

1. SoftCap `@2be53e mov [rbp+0xf8],r9` and `@2c614f` `@2c6174 mov [rbp+0x138],r9` both alias **Capless `[rsp+0x20]`** (call_rsp+0x20). Confirmed frame math:
   - SoftCap: `sub rsp,0x150; lea rbp,[rsp+0x80]` → `[rbp+0xf8]=call_rsp+0x20`
   - `@2c614f`: `sub rsp,0x190; lea rbp,[rsp+0x80]` → `[rbp+0x138]=call_rsp+0x20`
2. SoftCap has **no /GS cookie** in prol/epi (homes + zeros; epi = `add rsp,0x150; pop; ret`). Miss path `@2be734→@2be90a` HIT for **both** fwd and let.
3. SoftCap r9 **home-only** retarget `@2be53e→[rbp+0xb0]` (sha `e8e372731782`) or nopr9: SoftCap epi pop `@2be911` aligns fwd=INT3=let. **Not** a stable Isol alone (fwd still GS later; nopr9 lit/local 抖 AV — do not treat as Isol).
4. SoftCap `[rbp+0xf8]` also **read** at `@2be7f5/@2be832/@2be850` (hit paths). `@2c614f` `[rbp+0x138]` read at `@2c618f/@2c6514/@2c654c/@2c6668` (incl. epi arg to `@25f72e`).
5. Capless `@57656c`: `sub rsp,0x500; lea rbp,[rsp+0x80]`; call chain after kind-`0x30` SoftCap:
   - `@576692` SoftCap → `@5766ec @2c614f` → `@576746 0x46a4db` → `@5767a0 0x493d31` → … → epi `@578278`
   - Capless restores `[rsp+0x20]=[rbp+0x4b0]` before **each** callee; each lea-frame callee r9-home **re-smashes** it.
6. **Next isomorphic smash (this beat’s tip for Isol):** `0x46a4db` `@46a500 mov [rbp+0x198],r9d`
   - Frame: `sub rsp,0x1f0; lea rbp,[rsp+0x80]` → `[rbp+0x198]=call_rsp+0x20`
   - With SoftCap home_b0 + `@2c614f` full 0x138→0x100 retarget (`b0_h2c` sha `3af14cdc276f`): SoftCap pop / h2c pop / store_2c / call_46 all HIT; **`after_46` fwd=GS** (let INT3). GS locus = inside `0x46a4db`.
7. Extending retarget/nop to `0x46a4db` / `0x493d31` (also isomorphic `@493d56 [rbp+0x208]`) turns fwd **GS→AV**; lit/local often OK; let flaky; **no p_ret_fwd green**. Letter-stacking callee homes ≠ stable Isol (banned cave字母堆).

## Plants tried (none stable Isol)

| plant | sha12 | lit | fwd | local | let | 注 |
|---|---|---|---|---|---|---|
| cmk0_irdx_sub20（对照） | 3f43f1609d70 | OK run0 | **GS** | OK run1 | OK | |
| scs home_b0 only | e8e372731782 | OK | GS | OK | OK | SoftCap epi 齐；fwd 仍 GS |
| b0_h2c (scs home_b0 + 2c 0x138→0x100 all) | 3af14cdc276f | OK | **GS** | OK | AV∽ | after_46 fwd=GS＝46a4db |
| dual SoftCap+2c nopr9 | 7a17f9ce5df9 | OK∽ | GS | OK∽ | AV∽ | DIG only；caller_after GS |
| chain/iso3/iso4/trip_nop | * | OK | **AV** | OK | OK∽AV | 46/493 扩链；非 Isol |

## 证伪

- Capless `r9=[rsp+0x20]` before SoftCap（写回 `[4b0]`）：SoftCap pop **仍 GS** for fwd → SoftCap epi GS **不是**「smash 值≠[4b0]」单因。
- SoftCap home 换槽（0xb0）可齐 epi → 问题在 **写到 Capless`[rsp+0x20]` 槽本身**／其后同构链，不是 miss-kind。
- force-kind／frame enlarge／epi-raise／nopr9-as-Isol／LIVE／mega：仍禁；本拍未用。

## 下一单点

- **`fwd_46a500`**：DIG/plant Capless callee `0x46a4db` r9d-home smash `@46a500→call_rsp+0x20`（SoftCap+`@2c6174` 已可齐之后的 GS 落点）→可 Isol。禁 tip@121278／join／epi-raise／LIVE／mega／字母堆／假绿 force-kind／`[4b0]=1`／依赖 nopr9 抖 AV。

## 脚本／log

`_dig/dig_fwd_2c6174{,_2..8}.py`／`.log`；本笔记。

PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**。
