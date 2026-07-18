# B-21 FreeBSD 平台兼容 v1

> 更新时间：2026-06-25  
> 状态：**v1 落地（hosted POSIX + #[cfg]）**  
> 关联：`std/sys/freebsd.x`、`tests/run-freebsd-platform-gate.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **#[cfg(target_os = "freebsd")]** | lexer / cfg_eval / `-target x86_64-unknown-freebsd*` 剪枝正确 |
| **std.sys 门面** | `os_write` / `os_read` / `os_mmap_rw` 走 libc POSIX（同 macOS 模型） |
| **冷启动种子** | `seeds/bootstrap_shuxc.freebsd.<arch>` 须在 **FreeBSD 宿主**上 `capture_bootstrap_seeds.sh` 生成并入库 |
| **CI** | 矩阵占位 `freebsd-amd64-lite`；GitHub 默认无 FreeBSD runner，靠 self-hosted 或本地 |

**不在 v1 范围**：Linux 式 freestanding `shux_sys_*`、Stage2 SHA256 金标准、W3 全链。

---

## 2. 与 Linux / macOS 差异

| 项 | Linux | macOS | FreeBSD v1 |
|----|-------|-------|------------|
| 默认 write 路径 | freestanding `shux_sys_write` | libSystem `write` | **libc `write`** |
| `target_os` 字面量 | `linux` | `macos` | `freebsd` |
| x86_64 write syscall # | 1 | N/A (libc) | **4**（文档常量） |
| `*_gen.c` seed | 共用 `*.linux.x86_64.c` | 同左 | **同左（一份 C）** |
| 二进制 seed | `bootstrap_shuxc.linux.x86_64` | `darwin.arm64` | **`bootstrap_shuxc.freebsd.x86_64`**（待 capture） |

---

## 3. 种子纪律

1. **C 源码 seed**（`parser_gen` 等 18 个）：全平台共用，Git pin。  
2. **二进制 seed**：仅在 FreeBSD 上执行：
   ```bash
   cd compiler
   SHUX_LEGACY_C_FRONTEND=1 ./scripts/capture_bootstrap_seeds.sh
   # → seeds/bootstrap_shuxc.freebsd.x86_64
   # → seeds/asm_backend_partial.freebsd.x86_64.o
   ```
3. **勿**用 Linux ELF `bootstrap_shuxc` 冒充 FreeBSD 可执行文件。  
4. Stage2 hash：**gen1==gen2 在同一 FreeBSD 宿主**；不与 Linux Docker 金 hash 混比。

---

## 4. 验收

```bash
# 任意宿主：manifest + cross -target
chmod +x tests/run-freebsd-platform-gate.sh
./tests/run-freebsd-platform-gate.sh

# FreeBSD 宿主：再加 posix write 运行烟测
SHUX_FREEBSD_PLATFORM_FAIL=1 ./tests/run-freebsd-platform-gate.sh

# 刷新种子（仅 FreeBSD）
cd compiler && SHUX_LEGACY_C_FRONTEND=1 ./scripts/capture_bootstrap_seeds.sh
```

---

## 5. 索引

| 资源 | 路径 |
|------|------|
| std 子模块 | `std/sys/freebsd.x` |
| mod 门面 | `std/sys/mod.x` |
| cfg | `compiler/src/lexer/cfg_eval.x`、`lexer.c` |
| 种子选择 | `compiler/scripts/select_bootstrap_shuxc.sh` |
| 矩阵 | `tests/baseline/ci-platform-matrix.tsv` |

**B-21 v1 状态：代码 ✅ / 二进制 seed 待 FreeBSD 宿主 capture**

---

## 6. 没有 FreeBSD 真机怎么办？

**可以做。** GitHub 不提供 FreeBSD runner，但有三种等价路径：

| 方式 | 成本 | 产出 |
|------|------|------|
| **GitHub Actions + vmactions/freebsd-vm**（推荐） | 开源仓库免费 QEMU VM | `bootstrap-seeds-capture.yml` → `capture-freebsd-amd64` → Artifacts |
| **GitHub Actions** | 已有 workflow | linux/darwin/Alpine 同 workflow 其他 job |
| ~~Cirrus CI~~ | **已关停（2026-06-01）** | 勿再使用 |

### 6.1 推荐流程（零 FreeBSD 硬件）

1. **Linux / macOS 种子**（无需真机收藏）  
   - GitHub → Actions → **Bootstrap Seeds Capture** → Run workflow  
   - 完成后 **Artifacts** 下载 `bootstrap-seeds-linux-x86_64` 等 zip  
   - 或：`gh run download <run-id> -D /tmp/shux-seeds`

2. **FreeBSD 种子**（无需 FreeBSD 电脑）  
   - GitHub → Actions → **Bootstrap Seeds Capture** → Run workflow  
   - 完成后下载 artifact **`bootstrap-seeds-freebsd-x86_64`**  
   - 内含 `bootstrap_shuxc.freebsd.x86_64` 与 `.sha256` 清单

3. **入库纪律**（防自举坍塌）  
   - 对比 artifact 内 `.sha256` 与仓库现有种子  
   - **每个文件单独 commit** 到 `compiler/seeds/`（勿整包乱 commit）  
   - Git 为权威备份；Actions/Cirrus artifact 默认 **90 天**过期

### 6.2 不能做的事

- 在 Linux runner 上 **交叉编译** 出可执行的 FreeBSD `bootstrap_shuxc`（动态链接/解释器不同）  
- 用 Linux ELF 种子 **冒充** FreeBSD 冷启动

