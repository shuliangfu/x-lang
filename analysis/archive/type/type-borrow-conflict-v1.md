# TYPE-003 borrow conflict diagnostic v1

> Updated: 2026-08-28
> Status: **v1 (honesty soft→硬绿)** — unified ownership (linear) + lifetime (region) conflict diagnostics; lower false positives
> Related: `TYPE-001` (linear), `TYPE-002` (region), `LANG-008` (span format)

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 诊断层 B1–B6 |
| 2 | 打开 `tests/baseline/type-borrow-conflict-cases.tsv` |
| 3 | `./tests/run-type-borrow-conflict-gate.sh` |
| 4 | `./tests/run-type-borrow-conflict.sh` |

---

## 2. 诊断层 B1–B6（borrow conflict）

权威：`tests/baseline/type-borrow-conflict.tsv`（**6** 条 `layer_*`）。

| 层级 | 冲突类 | 文案 / 机制 | v1 |
|------|--------|-------------|-----|
| **B1-terminology** | borrow = 所有权 + 生命周期 | 本文 + RFC 交叉引用 | ✅ |
| **B2-ownership-linear** | 二次 move | `linear value used after move` | ✅ |
| **B3-lifetime-region** | 域逃逸 / 冲突 | `slice region escape` / `slice region mismatch` | ✅ |
| **B4-diag-priority** | region 检查先于泛化 assign mismatch | `typeck_check_slice_region_assign` 在 assign 路径前置 | ✅ |
| **B5-false-positive** | 合法重赋值 / 多绑定须通过 | `type-borrow-conflict-cases.tsv` **pos** 行 | ✅ |
| **B6-unified-cli** | `typeck error: … at line:col` | `lsp_diag_report_typeck` | ✅ |

**conflict 定义（v1）**：无独立 `&mut` 借用检查器；**borrow conflict** 指编译期拒绝的「所有权或域」冲突，而非 C 指针别名。

**false positive（误报）治理**：

- 同域 `T[]<label>` 重赋值、region 块内 stamp 后赋值 → **须通过**
- 多个独立 `Linear(T)` 绑定分别消费 → **须通过**
- 负例须给出 **专用** 文案（非笼统 `assignment type mismatch` 掩盖 region）

---

## 3. 用例矩阵

`tests/baseline/type-borrow-conflict-cases.tsv`：**6** 条（**3 pos** + **3 neg**）。

| case_id | 文件 | policy | 期望 |
|---------|------|--------|------|
| `fp_region_same` | `region_same_ok.x` | pos | product `-o` typeck-ok（UNDEF `slice_src` OK） |
| `fp_region_block` | `fp_region_block_reassign_ok.x` | pos | product `-o` typeck-ok |
| `fp_linear_two` | `fp_linear_two_bindings_ok.x` | pos | product `-o` typeck-ok／run |
| `conflict_region_escape` | `region_assign_escape.x` | neg | `slice region escape` @12 |
| `conflict_region_mismatch` | `region_mismatch.x` | neg | `slice region mismatch` @10 |
| `conflict_linear_move` | `double_move.x` | neg | `linear value used after move` |

全量回归：`run-typeck-region.sh` + `run-typeck-linear.sh`。

---

## 4. 非目标（v1）

- Rust 式 `&` / `&mut` 借用图
- 跨函数别名分析
- 自动 suggest fix 文案

---

## Gate

```bash
./tests/run-type-borrow-conflict-gate.sh   # runnable：manifest + borrow hooks
./tests/run-type-borrow-conflict.sh        # 误报/冲突烟测（product -o 硬绿）
```

**Honesty (2026-08-28)**：prefer asm + `XLANG_LINK_XLANG`；显式坏 XLANG／缺 native 硬 die；拒 soft SKIP→OK／soft auto-make／prefer-c；pos／neg 产品 `-o` 硬绿；`xlang check`＝obs（暂停闸）；报告 `run=`／`obs=`／`skip=`。

**gate report**：stdout 须含 `type-borrow-conflict gate OK`；失败打印 `type-borrow-conflict FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/archive/type/type-borrow-conflict-v1.md` |
| manifest | `tests/baseline/type-borrow-conflict.tsv` |
| 矩阵 | `tests/baseline/type-borrow-conflict-cases.tsv` |

**TYPE-003 状态：定版 ✅（honesty soft→硬绿）**
