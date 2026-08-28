# STD-124：std.regex 原子分组 `(?>...)` v1

> 更新时间：2026-08-28  
> 状态：**定版（v1）＋ honesty Gate**  
> 关联：STD-099 占有型量词、STD-063 分组、STD-051 纯引擎

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 |
| 2 | `tests/baseline/std-regex-atomic-manifest.tsv` |
| 3 | `./tests/run-std-regex-atomic-gate.sh` |
| 4 | 烟测：`tests/regex/atomic_match.x` |

---

## 2. 原子分组（v1）

| 语法 | 说明 |
|------|------|
| `(?>...)` | 非捕获原子组；组内匹配成功后禁止回溯 |
| `(?` 非 `>` | 编译失败 |

**语义**：组内 `atomic_nest>0` 时 `*`/`+`/`?` 按占有型处理。

**烟测向量**：`(a+)a` 匹配 `aaa`；`(?>(a+))a` 失败（组内 `a+` 吞掉全部 `a` 后无法匹配尾 `a`）。

C 烟测入口：`regex_min_smoke_c`（`pat20` 原子组，父 STD-051 `regex_min_ok.c`）。`.x` 烟测：`tests/regex/atomic_match.x`。

---

## 3. Gate

Honesty soft→硬绿（2026-08-28）：prefer product `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏／缺 native 硬 die；host-C 仅 prebuilt `std/regex/regex.o`＝obs（拒 soft `ensure_std_c_o`／auto-make／prefer-c／SKIP→OK）；check＝obs（暂停）；tip 产品 `-o` UNDEF／missing-main／exit≠0＝obs（产品另案；与 STD-051 xplat `atomic_match.x` 同残）。报告 `run=`／`obs=`／`skip=`（退役 `c=`／`x=`）。父 STD-051 MANIFEST_ONLY 硬委托（已诚实收口）。

```bash
./tests/run-std-regex-atomic-gate.sh
```

```
xlang: [XLANG_STD124_REGEX_ATOMIC] status=ok run=N obs=M skip=K
std-regex-atomic gate OK
```

PLATFORM: SHARED archaeology — Ubuntu gold still required.

---
