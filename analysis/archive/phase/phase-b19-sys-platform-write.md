# B-19：std.sys platform write unified (honesty)

> Archived archaeology DOC for `tests/run-sys-platform-write-gate.sh`.  
> Live roadmap: `analysis/自举进度.md`.  
> Related: BOOT-029 `analysis/archive/std/std-sys-v0.md` · B-19 facade `run-b19-sys-mod-facade-gate.sh`.

---

## 1. Goal

| ID | Delivery |
|----|----------|
| B-19 write | `import("std.sys")` + `write_stdout` unified smoke on Darwin hosted / Linux freestanding |

Smoke authority: `tests/sys/sys_platform_write_unified.x` (exit 0 + stdout `Hello Xlang!\n`).  
Facade authority: live `write`／`write_stdout`／`read`／`read_file_into`／`mmap`／`exit`／`close` in `std/sys/mod.x`（fossil `os_*` names retired）.

---

## Gate

```bash
./tests/run-sys-platform-write-gate.sh
```

Honesty（2026-08-27 soft→硬绿）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- Soft `XLANG_SYS_PLATFORM_WRITE_FAIL` **retired**（缺编译器／compile／run 失败曾 soft die→exit0＝portable 假绿）
- Live DOC = this archive path；refuse top-level `analysis/phase-b19-sys-platform-write.md` resurrect
- Refuse `compiler/Makefile` resurrect（use `./xbuild`）
- Hard-delegate：`run-b19-sys-mod-facade-gate.sh`（mod facade symbols）
- Hard runnable：`sys_platform_write_unified.x` exit 0
  - **LINUX|UBUNTU**：`-freestanding -backend asm`
  - **MACOS|DARWIN**：hosted `-o`（no freestanding）
- 无 native xlang → **FAIL**（禁止 soft SKIP→OK）
- Report：`doc=`／`facade=`／`run=`／`skip=`

```text
xlang: [XLANG_B19_SYS_PLATFORM_WRITE] status=ok doc=1 facade=1 run=1 skip=0
```

Changelog：

- **v1.1（2026-08-27）**：soft→硬绿 — archive DOC + `## Gate`；prefer asm + LINK pin；硬委托 facade；退役 soft FAIL；报告 counters。
- **v1.0**：初版 soft FAIL:-0 + 默认 `xlang-c`。
