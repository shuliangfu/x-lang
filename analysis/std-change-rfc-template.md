# <MODULE-ID> <变更标题> v<N>

> **本文件由 `analysis/std-change-rfc-template.md` 复制填写；勿删 § 标题。**
>
> 更新时间：YYYY-MM-DD  
> 状态：**草案 / 评审中 / 定版（vN）**  
> 关联：STBL-003、`NEXT.md` §2 任务行、（可选）`ZC-*` / `EXC-*` / `STD-*`

---

## 0. 元数据（必填）

| 字段 | 填写 |
|------|------|
| **模块** | `std.xxx` / `core.xxx` |
| **任务 ID** | 如 `STD-0xx` / `CORE-0xx` |
| **变更类型** | 新增 API · 行为变更 · ABI/链接 · ZC · 错误码 |
| **破坏性** | 是 / 否（若「是」须写迁移路径） |
| **Tier** | S（稳定）/ 实验 / 内部 |
| **manifest** | `tests/baseline/<name>.tsv` |
| **gate** | `tests/run-<name>-gate.sh` |
| **烟测** | `tests/<module>/*.x` |

---

## 1. 动机与范围

<!-- 用 3～5 句说明：解决什么问题、不做什么、与 Phase 2 北极星的关系。 -->

| 在范围内 | 不在范围内（显式排除） |
|----------|------------------------|
| | |

**成功判据（可验收）**

- [ ] …
- [ ] gate 全绿
- [ ] `shux check` 矩阵含本模块

---

## 2. API 面（API）

<!-- 新增/修改/废弃的公开符号；与 Tier-S manifest 列对齐。 -->

### 2.1 新增

| 符号 | 签名摘要 | 语义 | Tier |
|------|----------|------|------|
| `fn_name` | `(...)` → `T` | | S |

### 2.2 修改 / 废弃

| 符号 | 变更 | 迁移 |
|------|------|------|
| | | |

### 2.3 示例

```su
import("std.xxx");
// 最小可编译示例
```

---

## 3. ABI 与链接（ABI）

<!-- C .o、extern、runtime.c 链入、符号前缀、平台差异。 -->

| 项 | 约定 |
|----|------|
| **实现语言** | 纯 `.x` / `xxx.c` + `xxx.o` |
| **C 符号** | `std_xxx_*` / 裸名别名 |
| **链接** | `ensure_std_c_o` / `STD_AND_PANIC_O` / 按需 |
| **runtime.c** | 须/无须登记 `*.o` 路径 |
| **平台** | POSIX / Windows 差异与 SKIP 策略 |

**链接契约检查**

- [ ] `BOOT-014` 矩阵已更新（若新增 `.o`）
- [ ] `import("std.xxx")` 裸名与 `std_xxx_*` 不冲突

---

## 4. 零拷贝语义（ZC）

<!-- 无 ZC 影响写「N/A — 本变更不涉及缓冲借用」。 -->

| API | 读/写 | userland 拷贝 | 生命周期 |
|-----|-------|---------------|----------|
| | | 0 / 1 | 调用方持有 / 视图借入缓冲 |

**ZC 声明**

- [ ] 已对照 `tests/baseline/zc-semantics.tsv`
- [ ] 热路径无隐式分配
- [ ] 文档标明 `view` vs `copy` 回退条件

---

## 5. 错误码与 Result（错误码）

<!-- 遵循 STD-011 / `analysis/std-error-unify-v1.md`。 -->

| API | 成功 | 失败 | Layer | 侧车 |
|-----|------|------|-------|------|
| | `0` / `>0` | 负数 | C / B | `*_last_error()` |

**规则核对**

- [ ] 热路径 `-1` 不与比较 API `-1/0/1` 混淆
- [ ] 新 Layer B 码在 `std/error/mod.x` 有 `error_base_*`
- [ ] `tests/baseline/std-error-unify.tsv` 已更新（若改错误语义）

---

## 6. 测试与门禁

| 类型 | 路径 | 说明 |
|------|------|------|
| 烟测 | `tests/.../main.x` | |
| 边界 | `tests/.../boundary.x` | ≥8 case（P0 模块） |
| round-trip | | 若适用 |
| manifest | `tests/baseline/....tsv` | |
| gate | `tests/run-...-gate.sh` | |

**Gate 报告格式（建议）**

```
shux: [SHUX_<TAG>] status=ok ...
```

---

## 7. 文档同步清单

- [ ] `std/xxx/README.md` 或 `core/xxx/README.md`
- [ ] `std/README.md` 模块表（STBL-002）
- [ ] `NEXT.md` 任务状态 + §7 交付物
- [ ] `tests/baseline/stbl-tier-s-registry.tsv`（若 Tier-S 变更）
- [ ] `docs/07-内置与标准库.md`（若公开 API 变更）
- [ ] `tests/run-portable-suite.sh`（挂 gate）

---

## 8. 未决项 / 后续波次

| ID | 内容 | 阻塞关系 |
|----|------|----------|
| | | 不阻塞 v1 / 阻塞发布 |

---

## 附录 A：填写示例（删除后提交）

参考已填 RFC：

- API + gate：`analysis/std-csv-row-v1.md`（STD-036）
- ZC：`analysis/std-json-zc-v1.md`（STD-008）
- 错误码：`analysis/std-error-unify-v1.md`（STD-011）
- ABI/链接：`analysis/boot-std-link-contract-v1.md`（BOOT-014）
