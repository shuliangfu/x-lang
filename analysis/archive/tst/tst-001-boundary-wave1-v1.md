# TST-001 P0 边界测试波次 1 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` Phase 2 P0、`tests/run-io.sh` / `run-fs.sh` / `run-net.sh`

---

## 1. 目标

| ID | 交付 |
|----|------|
| TST-001 | **io / fs / net / string** 四模块边界烟测波次 1 |
| 验收 | 每模块 **≥8** `// case N` 边界；`run-tst-001-boundary-gate.sh` 全绿 |

波次 2（TST-002）：heap / vec / map / process。

---

## 2. 用例矩阵

| 模块 | 文件 | case 数 | 覆盖要点 |
|------|------|---------|----------|
| `std.io` | `tests/io/boundary.x` | 9 | handle 常量、零长 write、print_str |
| `std.fs` | `tests/fs/boundary.x` | 10 | invalid handle、不存在路径、写读、pread |
| `std.net` | `tests/net/boundary.x` | 10 | addr 编解码、UDP/TCP bind 0、local_addr |
| `std.string` | `tests/string/boundary.x` | 10 | StrView 钳制、capacity、compare/find |

约定：每个 case 失败返回唯一 exit code；`main` 成功返回 0。

---

## 3. 与现有 run-*.sh 关系

| 脚本 | 角色 |
|------|------|
| `run-io.sh` / `run-fs.sh` / `run-net.sh` | 功能烟测（stdout/管道/UDP） |
| `run-tst-001-boundary-gate.sh` | **边界向量** manifest + case 计数 + 链接烟测 |

不替代 `run-all.sh` 全量；portable-suite 挂入门禁即可。

---

## 4. 门禁

```bash
./tests/run-tst-001-boundary-gate.sh
```

manifest：`tests/baseline/tst-001-boundary-wave1.tsv`

---

## 5. 变更流程

扩展边界时：

1. 在对应 `tests/<mod>/boundary.x` 追加 `// case N`  
2. 更新 manifest `min_cases` 列（若超过原值）  
3. 跑 gate 全绿  
