# 10.54 OPEN — Win float param receive

**Asia/Shanghai 2026-10-29 14:50** · after 10.46✅ closeout tip `52d2b088b`

## 题面
Windows 浮点参数（f32、f64）接收错；三端浮点传参都对才 ✅。

## 隔离／禁
- Win 串；改动隔离；禁牵坏 Mac／Ubuntu
- 禁 CloudAgent／升钉 ecdb5cc1e／10.74／mega／HARD BAN／LEGACY／tip 叶子

## 首拍基线（PROD Soft Cap `cca095a70725`）
| probe | result |
|-------|--------|
| sanity i32 param | RUN rc=7 OK |
| f32/f64 **local** let | RUN rc=7 OK |
| f32 **param**（ignore body／as i32／==cmp） | **compiler SEGV ec=139** |
| f64 param | **compiler SEGV ec=139** |

→ SoftCap 在 **编** 带 f32/f64 形参的函数时即 SEGV（未到运行收错）。DIG 根＝Win 形参／prologue／XMM 槽路径，非仅 callee 读错。

## 首拍计划（下一步）
1. ISOL 拷 PROD；对照 Darwin／Ubuntu 同探针（应绿）
2. DIG SEGV 点：parse vs typeck vs emit_prologue／param_home（f32→XMM0）
3. 最小 cave／thin；禁 mega；有牵再跑双端门

## 基线
- PROD Soft Cap sha12 `cca095a70725`；钉盘 ecdb5cc1e 不升
- log：`C:/xlang_tmp/p1054_baseline2.log`
