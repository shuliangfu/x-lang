## Summary

<!-- 本 PR 做了什么、为什么 -->

## Test plan

- [ ] 本地 gate（改编译器时 **必勾**）见 [tests/docs/compiler-x-security-checklist.md](../tests/docs/compiler-x-security-checklist.md)
- [ ] `./tests/run-scope-borrow-gate.sh` `./tests/run-al06-gate.sh` `./tests/run-ub.sh`
- [ ] （若改 typeck/unsafe）`./tests/run-type-borrow-conflict-gate.sh` `./tests/run-safe-unsafe-audit-gate.sh`
- [ ] （若改 CTFE/lexer/i64）`./tests/run-i64-ctfe-gate.sh`
