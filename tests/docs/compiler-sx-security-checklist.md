# 改编译器 `.x` / 前端 C 时的安全自检（P0-6）

> 关联：[analysis/安全与性能.md](../../analysis/安全与性能.md) §十一 P0  
> 适用：`compiler/src/**/*.x`、`compiler/src/{lexer,parser,typeck,codegen}/**`

## 必跑（本地，改完即跑）

```bash
# 从仓库根目录
make -C compiler shux-c
./tests/run-scope-borrow-gate.sh
./tests/run-al06-gate.sh
./tests/run-ub.sh
./tests/run-i64-ctfe-gate.sh
```

## 改 typeck / unsafe / extern 时追加

```bash
./tests/run-type-borrow-conflict-gate.sh
./tests/run-safe-unsafe-audit-gate.sh
```

## 改 std.mem / fmt / 整数常量折叠时追加

```bash
./tests/run-i64-ctfe-gate.sh
./tests/run-fmt.sh          # 或 SHUX_LINK_SHUX=./compiler/shux-c ./tests/run-fmt.sh
```

## Docker 与自举门禁（合并验收）

```bash
./tests/run-linux-a09-a11-gate.sh
```

## PR 自检勾选

- [ ] 未扩大 `unsafe` / `extern` 面，或已更新 `safe-unsafe-api.tsv` + `safe-unsafe-audit.tsv`
- [ ] 布局/数组长度算术有溢出防护（C 侧 `__builtin_*_overflow` 或等价）
- [ ] 优化 pass 证不出时已回退（未强开 noalias/BCE）
- [ ] 上列 gate 已本地或 CI 全绿
