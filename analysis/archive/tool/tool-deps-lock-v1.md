# TOOL-008 依赖锁定与可重复构建 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`TOOL-007`（pkgmgr）、`shux.pkg.tsv`、`shux-deps-resolve.sh`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 锁定契约 L1–L6 |
| 2 | 打开 `tests/baseline/tool-deps-lock.tsv` |
| 3 | `./tests/run-tool-deps-lock-gate.sh` |
| 4 | `shux-deps-lock.sh` / `shux-deps-verify.sh` |

---

## 2. 锁定契约 L1–L6

权威：`tests/baseline/tool-deps-lock.tsv`（**6** 条 `rule_*`）。

| 规则 | 说明 | 实现 |
|------|------|------|
| **L1-lock-file** | 锁文件 `shux.pkg.lock.tsv` 与 manifest 同目录 | v1 TSV |
| **L2-content-digest** | 每条 `locked` 含 `sha256` 内容摘要 | `shasum -a 256` |
| **L3-relpath** | 记录仓库相对路径（可重复解析） | `core/mem/mod.x` |
| **L4-gen-lock** | `shux-deps-lock.sh` 由 manifest 生成锁 | `scripts/shux-deps-lock.sh` |
| **L5-verify-lock** | `shux-deps-verify.sh` 校验锁与磁盘一致 | `scripts/shux-deps-verify.sh` |
| **L6-replay** | 同锁文件重复 verify → 相同 report | CI gate |

**工作流**：

```bash
./scripts/shux-deps-resolve.sh tests/fixtures/pkgmgr/shux.pkg.tsv   # 解析
./scripts/shux-deps-lock.sh tests/fixtures/pkgmgr/shux.pkg.tsv     # 生成/更新锁
./scripts/shux-deps-verify.sh tests/fixtures/pkgmgr/shux.pkg.tsv \
  tests/fixtures/pkgmgr/shux.pkg.lock.tsv                          # 可重复构建校验
```

---

## 3. `shux.pkg.lock.tsv` 格式

```tsv
# 列：kind	package_id	tier	relpath	sha256
meta	lock_version	1	-	-
meta	name	demo-app	-	-
lib_root	.	../../..	-	-
locked	core.mem	bundled	core/mem/mod.x	<64-hex>
locked	core.types	bundled	core/types/mod.x	<64-hex>
```

`sha256` 为文件**内容**哈希（不含路径）；变更依赖须重新 `shux-deps-lock.sh` 并评审锁 diff。

---

## 4. report 与烟测

```
tool-deps-lock report locked=2/2 verify=OK reproducible=OK
```

金样：`tests/fixtures/pkgmgr/shux.pkg.lock.tsv`（与 `shux.pkg.tsv` 配对）。

---

## 5. 非目标（v1）

- 不锁编译器版本 / `shux` 二进制哈希（见 ENG 发布流程）。
- 不锁 std 全量传递闭包（仅 manifest 声明的 require）。
- 无网络镜像 pin（本地 bundled 路径）。

---

## 6. 验证与门禁

```bash
./tests/run-tool-deps-lock-gate.sh   # runnable：manifest + lock verify
./tests/run-deps-lock.sh             # 金样 replay 烟测
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/tool-deps-lock-v1.md` |
| manifest | `tests/baseline/tool-deps-lock.tsv` |
| 金样锁 | `tests/fixtures/pkgmgr/shux.pkg.lock.tsv` |
| 库 | `tests/lib/tool-deps-lock.sh` |

**TOOL-008 状态：定版 ✅**
