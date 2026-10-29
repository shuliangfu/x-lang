# 10.54 OPEN — Win float param receive

**Asia/Shanghai 2026-10-29 14:50** · after 10.46✅ closeout

## 题面
Windows 浮点参数（f32、f64）接收错；三端浮点传参都对才 ✅。

## 隔离／禁
- Win 串；改动隔离；禁牵坏 Mac／Ubuntu
- 禁 CloudAgent／升钉 ecdb5cc1e／10.74／mega／HARD BAN／LEGACY／tip 叶子

## 首拍计划
1. 最小探针：`fn take_f32(x: f32) -> i32`／`take_f64`／混合 GP+XMM；Win Soft Cap PROD `cca095a70725` 侧编跑，记期望 vs 实收
2. DIG 根：Win x64 ABI 浮点在 XMM0–3；对照 Darwin／Ubuntu 同探针；查 SoftCap emit_call／callee prologue 是否把 f32/f64 当 GP
3. 最小补丁优先 cave／thin overlay；禁 mega 放大；双端 Cap soft／tip-cold 有牵再跑

## 基线
- PROD Soft Cap sha12 `cca095a70725`（10.46 升）
- tip／钉盘：见进度头；钉盘不升
