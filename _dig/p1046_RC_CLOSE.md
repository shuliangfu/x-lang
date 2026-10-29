# p1046_RC_CLOSE — knife 10.46 SoftCap 正式验收

**Asia/Shanghai 2026-10-29 14:45**

## 结论
**三端全绿 → 10.46✅ 收刀（经理已批）**。WORK→PROD 已升；钉盘 ecdb5cc1e **不升**。

## WORK
| 项 | 值 |
|----|-----|
| WORK9 | `C:/xlang_tmp/xlang_softcap_cave_work_9of9.exe` |
| sha12 | `cca095a70725` |
| size | 7961399 |
| 来源 | ISOL `xlang_softcap_cave_isol.exe`／freeze `isol_v2_9of9` **原样拷贝**（cave v2＋SEGV asm＋if0 `@0x5ebaf4`＋add2） |
| 冻本 v2_7of9 | `aeba8d4e83b8` **未毁** |
| PROD Restored | `c478856d6bb9`（`xlang_comboB_L_before_mega_fail_bisect.exe`）**未毁** |
| I bak | `fe85f8816ec9` size=7945801 **未动** |
| 钉盘 | ecdb5cc1e **未升** |

## Win Soft Cap 侧验 9/9（WORK9）
log: `C:/xlang_tmp/side9_work9.log` · 2026-10-29T14:44:12+0800

| case | run | exp | |
|------|-----|-----|---|
| letret7 | 7 | 7 | PASS |
| two_lets | 7 | 7 | PASS |
| one_let_add | 7 | 7 | PASS |
| two_lets_ret_a | 3 | 3 | PASS |
| three_lets | 3 | 3 | PASS |
| ret_add | 7 | 7 | PASS |
| ret0 | 0 | 0 | PASS |
| add2 | 7 | 7 | PASS |
| if0 | 0 | 0 | PASS |

**WORK9_SIDE=9/9_GREEN**

## Darwin Cap soft
- tip Mac docs leaf：`67e466cf5`
- log：`/tmp/cap_soft_1046rc_67e466cf5.log`
- **OK=267 MISMATCH=0 CRASH=0 SKIP=84 · CAP_SOFT_RC=0**

## Ubuntu tip-cold 真 RC
- tip 工作 tip：`7b85bd1a9`
- log：`/tmp/tipcold1046rc_7b85bd1a9.log`（host `/tmp/xlang_l4_Linux_7b85bd1a9.log`）
- wall=13m2s · run-all-bstrict 131 scripts OK
- **L4_END_RC=0 · product_l4_true_cold OK**

## 补丁根因（承 ISOL CLOSE）
- SEGV＝漏 `01 d8`（`add %ebx,%eax`）
- if0＝`@0x5ebaf4` realign_into 误写 Source* → `mov $1,%eax; ret; nop`
- dig：`C:/xlang_tmp/dig_add2_if0_CLOSE.md`／`C:/xlang_tmp/dig_if0/dig_if0ak.py`

## 禁项遵守
禁 push／升钉／CloudAgent／10.74／HARD BAN／mega／tip 叶子／emit E9／硬拧 COUNTFN／LEGACY。compiler/xlang.exe 未覆盖；PROD／I／冻本未动。

## 收口
1. WORK→PROD：`compiler/xlang.exe` sha12 `cca095a70725`；PROD 侧验 9/9_GREEN
2. Restored `c478856d6bb9`／I=7945801 保留；钉盘不升
3. 下一刀 **10.54**（Win 浮点传参）
