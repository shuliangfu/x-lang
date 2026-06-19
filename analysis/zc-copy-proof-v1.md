# ZC-007 零拷贝证明测试与 PR 拷贝声明 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`ZC-006`（语义白皮书）、`ENG-001`（PR checklist 模式）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **PR 可审计** | 触及 IO/FS/NET/String 热路径的 PR 须声明 userland 拷贝次数 |
| **可复现证明** | 关键路径提供可编译 `.sx` 烟测，exit 0 = 证明通过 |
| **模板一致** | 复制 `tests/templates/zc-copy-proof-test.sx`，填 metadata 头 |

验收（NEXT ZC-007）：**新 PR 必填拷贝声明** + 模板 + 示例 proof + gate。

---

## 2. 何时必填

| PR 变更 | 是否必填 ZC-007 |
|---------|----------------|
| `std/io` / `std/fs` / `std/net` / `std/string` 热路径 | **是** |
| 新增 `read`/`write`/`mmap`/`sendfile`/视图 API | **是** |
| 仅文档 / 测试 baseline 数字 / 编译器前端 | 否（建议仍填 N/A） |
| 纯 typeck/语法，无运行时数据路径 | 否 |

---

## 3. PR 拷贝声明（复制模板）

文件：`tests/templates/zc-pr-copy-declaration.txt`

必填字段：

| 字段 | 含义 |
|------|------|
| `userland_copies` | 热路径用户态 **冗余** 拷贝次数（见 ZC-006 §2） |
| `zc_tier` | `none` / `ZC-1`..`ZC-5` |
| `proof_id` | `tests/zc/<id>.sx` 或 `N/A` |
| `fallback` | 非 Linux 回退说明（若有） |

粘贴到 PR 描述 **或** 链到 proof 文件头 comment。

---

## 4. 证明测试模板

1. 复制 `tests/templates/zc-copy-proof-test.sx` → `tests/zc/<proof_id>.sx`
2. 填写文件头 metadata（`path_id`、`userland_copies`、`zc_tier`）
3. 实现 `main()`：触达声称的零拷贝/最小拷贝路径，**return 0** 表示证明成功
4. 登记 `tests/baseline/zc-copy-proof.tsv`
5. 本地：`./tests/run-zc-copy-proof-gate.sh`

### 4.1 metadata 头（须保留）

```su
// path_id: ...
// userland_copies: 0
// zc_tier: ZC-4
// hot_path: ...
// fallback: none
```

Gate 会 grep 这些键。

---

## 5. 示例

| proof_id | 路径 | copies | tier | 说明 |
|----------|------|--------|------|------|
| `copy_proof_smoke` | `tests/zc/copy_proof_smoke.sx` | 0 | ZC-4 | StrView subview 无堆拷贝 |

---

## 6. 门禁

`tests/run-zc-copy-proof-gate.sh`：

1. 本文 + 模板 + manifest  
2. 模板含必需 metadata 键  
3. matrix 中 `policy=run` 的 proof 编译运行 exit 0（有 native shux 时）  
4. `zc-semantics-v1.md` 引用 ZC-007  

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| PR 模板 | `tests/templates/zc-pr-copy-declaration.txt` |
| 测试模板 | `tests/templates/zc-copy-proof-test.sx` |
| 矩阵 | `tests/baseline/zc-copy-proof.tsv` |
| 语义 | `analysis/zc-semantics-v1.md` |

**ZC-007 状态：定版 ✅**
