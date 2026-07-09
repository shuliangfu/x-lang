# G-07：`vX.Y.Z-selfhost` 发布说明

> 版本号以仓库根 `VERSION` 为准（当前 **0.2.0** → 建议 tag **`v0.2.0-selfhost`**）。  
> 人工打 tag 前须绿：`SHUX_F11_SELFHOST_RELEASE_PREP_FAIL=1 ./tests/run-f11-selfhost-release-prep-gate.sh`

## 1. 发布物

| 项 | 说明 |
|----|------|
| 源码树 | 全 `.x` 主链 + G-04 永久语言限制 C 桥（STRICT 非永久=0） |
| 二进制 | `compiler/shux`（= relink / B-strict 定稿；与 `shux_asm` 同步） |
| 构建入口 | `./shux-build.sh build` 或 `cd compiler && ./build_tool ./shux` |
| 许可 | AGPL-3.0-or-later |

## 2. 发版前命令（Linux x86_64 金标准）

```bash
git checkout g-02a-remove-legacy-c   # 或 main 合并后
git pull

# 定稿二进制
./shux-build.sh build
# 或：make -C compiler shux_asm

# 发布 checklist（硬失败）
SHUX_F11_SELFHOST_RELEASE_PREP_FAIL=1 ./tests/run-f11-selfhost-release-prep-gate.sh

# 建议烟测
SHUX=./compiler/shux ./tests/run-hello.sh
./compiler/shux build -o /tmp/let42 - <<'EOF'  # 或已有 let 用例
# …
EOF
```

可选（耗时）：

```bash
make -C compiler bootstrap-verify
make -C compiler bootstrap-verify-stage2-bstrict   # Stage2 哈希
SHUX_NO_HANDWRITTEN_C_STRICT=1 SHUX_NO_HANDWRITTEN_C_FAIL=1 \
  SHUX_NO_HANDWRITTEN_C_MANIFEST_ONLY=1 ./tests/run-no-handwritten-c-gate.sh
```

## 3. 打 tag（人工）

```bash
VER=$(cat VERSION)   # 0.2.0
git tag -a "v${VER}-selfhost" -m "Release v${VER}-selfhost (D+E+F + G-04 STRICT + G-05 entry)"
git push origin "v${VER}-selfhost"
```

**不要**在无 F-11 绿 / 无维护者确认时自动推 tag。

## 4. Checklist 与 gate 映射（F-11 v2）

| 检查 | Gate / 判据 |
|------|-------------|
| 文档 D+E+F | `SELFHOST.md` + `phase-f-f11-v1.md` |
| 单 shux 发布 | `run-d05-single-shux-release-gate.sh` |
| 编译器 C 退役口径 | `run-e-soft-retire-gate.sh`（MANIFEST_ONLY；G-02a hard_retired） |
| 手写 C STRICT | `SHUX_NO_HANDWRITTEN_C_STRICT=1` manifest |
| Stage2 哈希 | `run-d03`（有 stage 产物时；Darwin N/A） |
| Stage2 行为 | `run-d04`（有 stage 产物时） |

历史 `run-f-std-de-c-batch-gate.sh`（65 项）默认**不**阻塞发版；需要时：

`SHUX_F11_RUN_F_STD_BATCH=1 ./tests/run-f11-selfhost-release-prep-gate.sh`

## 5. 已知非阻塞项

- macOS：`make shux_asm` 偶发 `parser_gen` seed 问题；开发机以 Linux 验收为准  
- al06-gate 诊断文案  
- Makefile 仍作冷启动 / CI 兜底（G-05 未物理删除）  
