# CI 与本地 Docker 测试

## CI 各平台一览

| Job | 环境 | 步骤 |
|-----|------|------|
| **linux** | ubuntu-22.04, ubuntu-latest | `make OPT=1 all` → test_c → test_su → **`./tests/run-bootstrap-bstrict-ci.sh`**（M3-c）→ `bootstrap-verify` |
| **linux-arm64** | ubuntu-24.04-arm | 同上 |
| **mac** | macos-14, macos-latest | 同上 |
| **windows** | windows-latest + MSYS2 | 装 make/gcc/zlib/brotli 等 → `make OPT=1 all`（**shu** + **shu-c**）→ test_c → test_su → bootstrap-verify |
| **docker-distro** | 容器内 | Alpine / Debian 下 **make clean** → all → test_c → test_su → bootstrap-verify |
| **linux-option-asan** | ubuntu-22.04 | 可选，ASan 构建复现 run-option 崩溃用，不阻塞主流程 |

触发：推送到 `dev` 或 PR 到 `dev`/`main`。

## 本地先用 Docker 全量测通再推 CI

**Mac 上可以测 Linux (Ubuntu)**：用 Docker 跑 Ubuntu 镜像即可复现 CI 的 **linux** job，无需真机 Ubuntu。

### 一键跑与 CI 相同的 Docker 测试

在**仓库根目录**执行：

```bash
chmod +x scripts/docker-ci-local.sh
./scripts/docker-ci-local.sh all
```

- `./scripts/docker-ci-local.sh ubuntu`：**只跑 Ubuntu 22.04**，与 CI 的 **linux (Ubuntu)** job 同环境，**Mac 上推荐先跑这个**。
- `./scripts/docker-ci-local.sh alpine`：只跑 Alpine（docker-distro）
- `./scripts/docker-ci-local.sh debian`：只跑 Debian（docker-distro）
- `./scripts/docker-ci-local.sh all` 或 `./scripts/docker-ci-local.sh`：Alpine + Debian + Ubuntu 都跑

流程与 CI 一致：容器内安装依赖 → `make clean` → `OPT=1 all` → test_c → test_su →（可选 `./tests/run-bootstrap-bstrict-ci.sh`）→ bootstrap-verify。

### Mac 上两种本地测法

| 方式 | 复现的 CI job | 命令 |
|------|----------------|------|
| **本机直接 make** | **mac** | 仓库根：`make -C compiler OPT=1 all && make -C compiler test`（`test_c` 即 `run-all-c.sh` 全量 + `test_su`）；或 `./tests/run-all-c.sh` + `./tests/run-all-su.sh` |
| **Docker 跑 Ubuntu** | **linux (Ubuntu)** | `./scripts/docker-ci-local.sh ubuntu` |

- **macOS / Windows / ARM64**：需对应系统或 CI 跑，无法在 x86 Docker 里复现。

建议顺序：**Mac 上先 `./scripts/docker-ci-local.sh ubuntu`（或 `all`）全过 → 再推分支/PR 跑完整 CI**。
