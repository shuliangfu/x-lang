# 阶段 F-NL-07 完成标准 v3（bootstrap nostdlib 链入烟测硬绿）

> **NL-07 v3**：在 v2 链尾统一之上，**Linux x86_64** 上验证 crt0 + freestanding_io + bootstrap 桩可 `-nostdlib -static` 链入并运行。

## v3 完成（✅ 烟测层）

| 项 | 标准 | 产物 |
|----|------|------|
| NL-07 v3 文档 | 本文件 | `analysis/phase-f-n07-v3.md` |
| 烟测入口 | `main_entry` 最小实现 | `tests/fixtures/nolibc-n07-bootstrap-smoke.c` |
| 链入 helper | 强制本机重编 .o + nostdlib 链 + readelf 审计 | `tests/lib/nolibc-n07-link-smoke.sh` |
| v3 link gate | manifest + Linux 烟测 | `tests/run-nolibc-n07-v3-link-gate.sh` |

## 烟测链（v3）

```
crt0_x86_64.o + freestanding_io_x86_64.o + bootstrap_nostdlib_stubs.o
+ runtime_panic.o（可选）+ smoke main_entry.o
→ cc -nostdlib -static -Wl,--gc-sections
→ 运行 exit 0；readelf 无 NEEDED libc
```

**注意**：须在本机 Linux x86_64 **重编** `.o`（勿复用 macOS 宿主产物）。

## 复现

```bash
# 任意平台 manifest
SHUX_NOLIBC_N07_V3_FAIL=1 ./tests/run-nolibc-n07-v3-link-gate.sh

# Linux x86_64 烟测硬绿
SHUX_NOLIBC_N07_V3_FAIL=1 SHUX_NOLIBC_N07_V3_MANIFEST_ONLY=0 ./tests/run-nolibc-n07-v3-link-gate.sh

# macOS 宿主 → Docker amd64
SHUX_DOCKER_PLATFORM=linux/amd64 docker run --rm --platform linux/amd64 \
  -v "$(pwd):/src" -w /src ubuntu:22.04 bash -lc \
  'apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gcc make binutils file >/dev/null && \
   SHUX_NOLIBC_N07_V3_FAIL=1 ./tests/run-nolibc-n07-v3-link-gate.sh'

# 全量 bootstrap nostdlib（需 shux + build_asm 就绪）
cd compiler && SHUX_BOOTSTRAP_NOSTDLIB=1 ./scripts/build_shux_asm.sh
```

## 延后（NL-07 v4+）

- ~~Linux x86_64 烟测硬绿~~ → 见 `analysis/phase-f-n07-v3.md` ✅
- **NL-07 v4 track**：全链 `SHUX_BOOTSTRAP_NOSTDLIB=1 build_shux_asm` → `run-nolibc-n07-v4-build-gate.sh`
