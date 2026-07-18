# std.env 性能分析与优化

> 目标：极致压榨 std.env 热点路径，与 Zig/Rust 同量级并争取超越；无堆分配、栈与拷贝最小化。

---

## 一、热点路径识别

| 接口 | 热/冷 | 说明 |
|------|--------|------|
| **getenv** | 热 | 取单条环境变量，调用最频繁；key 拷贝 + 系统 getenv + value 拷贝。 |
| **getenv_exists** | 热 | 仅判存在，不拷贝 value；key 拷贝 + 一次 getenv。 |
| setenv / unsetenv | 冷 | 修改环境，调用少。 |
| temp_dir | 中 | 可能被多次调用（如每次写临时文件前取一次）；POSIX 需多次 getenv。 |

---

## 二、现状与瓶颈

### 2.1 getenv / getenv_exists

- **key 缓冲**：原 `ENV_KEY_MAX 4096`，每次调用在栈上分配 4KB。环境变量名 POSIX 通常 ≤255 字节，4096 过大，导致：
  - 栈占用大，不利于缓存与递归深度；
  - 无实际收益（名长几乎不会接近 4KB）。
- **系统调用**：POSIX 为 libc `getenv()`，Windows 为 `GetEnvironmentVariableA`，无法省去。
- **value 拷贝**：API 约定写入用户 buffer，必须一次 memcpy，无法省略。
- **strlen**：POSIX 上需对 getenv 返回值做 strlen 再 memcpy，已为常规最优做法。

### 2.2 setenv（Windows）

- 原实现用逐字节循环拼 `name=value`，可改为 `strlen` + 两次 `memcpy`，减少分支与循环。

### 2.3 temp_dir（POSIX）

- 每次调用依次 `getenv("TMPDIR")`、`getenv("TEMP")`、`getenv("TMP")`，最多 3 次 getenv + strlen + memcpy。
- 同一进程内临时目录通常不变，重复调用可做**线程局部缓存**，第二次起只做一次 memcpy，无额外 getenv。

---

## 三、已实施的优化

### 3.1 key 缓冲区：上限 256 + VLA 按 key 动态长度

- **改动**：`ENV_KEY_MAX` 由 4096 改为 256；key 缓冲改为 **VLA** `key_buf[key_len + 1]`（C99 可变长数组），按实际 key 长度分配栈。
- **依据**：POSIX 环境变量名通常 ≤255；调用方已传入 `key_len`，等价于「切片动态长度」。
- **效果**：短 key（如 "PATH" 4 字节）仅占 5 字节栈，长 key 最多 256 字节；不支持 VLA 时（`__STDC_NO_VLA__`）回退为固定 `key_buf[256]`。

### 3.2 Windows setenv 用 strlen + memcpy

- **改动**：不再用 while 逐字节拷贝，改为对 name/value 各一次 strlen，再两次 memcpy 拼成 `name=value`。
- **效果**：减少分支与循环，利于编译器优化与 CPU 流水线。

### 3.3 temp_dir（POSIX/Windows）线程局部缓存

- **改动**：POSIX 下使用 `__thread` 缓存首次计算出的临时目录路径；Windows 下同样用线程局部缓存（`__declspec(thread)` / `__thread`）缓存 GetTempPathA 结果。
- **效果**：重复调用 temp_dir 时，第二次起仅 memcpy，无 getenv/GetTempPathA。
- **语义**：进程内首次调用之后若外部修改 TMPDIR/TEMP/TMP（或 Windows 临时目录），同一线程内可能仍看到旧值；与「进程启动后临时目录通常不变」的用法一致，可接受。

### 3.4 热/冷与分支提示（GCC/Clang）

- **改动**：`getenv_c` / `getenv_exists_c` 标记为 `__attribute__((hot))`，`setenv_c` / `unsetenv_c` 标记为 `__attribute__((cold))`；POSIX getenv 中「value 能放入 buffer」用 `__builtin_expect` 标为 likely，「v == NULL」标为 unlikely。
- **效果**：热路径更易被内联与代码布局优化，冷路径可被排到后部减少 I-cache 压力；分支预测更偏向常见路径。

### 3.5 restrict 与指针别名

- **改动**：`env_getenv_c` 的 `key`、`out` 参数使用 `restrict`。
- **效果**：编译器可假定 key 与 out 不重叠，memcpy 等可做更激进的优化（向量化、重排等）。

### 3.6 零拷贝路径（getenv_ptr / getenv_z）

- **改动**：新增 `getenv_ptr(key, key_len, out_len)`、`getenv_z(key_z, out_len)`，返回 libc getenv() 的 value 指针（或 0）。不向用户 buffer 拷贝 value；`getenv_z` 在 key 已 NUL 结尾时直接传 getenv，无 key 拷贝。
- **效果**：读后即用、不长期持有时可完全避免 value 拷贝（及 getenv_z 下 key 拷贝）；POSIX/Windows 均使用 CRT getenv 返回的指针。
- **约束**：返回指针在 setenv/unsetenv 或下次 getenv_ptr/getenv_z 前有效，文档明确「勿长期持有」；需稳定拷贝时仍用 `getenv(key, len, out, cap)`。

### 3.7 热路径共用 key 构建（env_build_key）

- **改动**：抽出 `static inline env_build_key(key, key_len, key_buf)`，统一做 key 校验与 memcpy+NUL；getenv_c、getenv_ptr_c、getenv_exists_c 均调用它后再用 key_buf。
- **效果**：消除三处重复的校验与拷贝逻辑，减小 .text、利于 I-cache；内联后无额外调用开销。getenv_ptr_c/getenv_z_c 仅在 out_len 非 NULL 时调用 strlen，避免热路径多余扫描。

---

## 四、未做或可选优化

| 项 | 说明 |
|----|------|
| **getenv 返回只读指针** | **已提供**：`getenv_ptr` / `getenv_z` 返回 value 指针（零拷贝），文档明确指针在 setenv/unsetenv 或下次同类调用前有效、勿长期持有；需要稳定拷贝时仍用 `getenv(key, len, out, cap)`。 |
| **短 key 专用小缓冲** | 已用 **VLA（可变长数组）** 实现「按 key 动态长度」：栈上 `key_buf[key_len+1]`，短 key（如 "PATH"）仅占 5 字节；不支持 VLA 的编译器（`__STDC_NO_VLA__`）回退为固定 256 字节。 |
| **内联 / LTO** | 由编译器与链接时优化（-O2/-flto）处理；模块为独立 .c，用户链接时已可内联。hot/cold 与 restrict 已加，进一步配合 LTO。 |
| **Linux 直接读 /proc/self/environ** | 需解析整块、处理 NUL、且多线程下语义复杂，不如 libc getenv 简单可维护，不采用。 |

---

## 五、性能目标与验证

- **getenv / getenv_exists**：单次调用开销以「一次 key 拷贝 + 系统 getenv + 必要时 value 拷贝」为主，与 Zig/Rust 同量级；栈与拷贝已最小化。
- **temp_dir**：首次与当前实现相当；重复调用依赖缓存，明显快于多次 getenv 链。
- 建议：在 `tests/` 或单独 benchmark 中增加「大量 getenv 同 key」「大量 getenv_exists」「多次 temp_dir」的微基准，用脚本或 CI 做回归对比。

---

## 六、与项目宗旨的一致性

- **性能比肩 C**：无堆分配、无多余系统调用、栈与拷贝最小化，符合「极致压榨性能」。
- **轻量**：无新依赖，仅 C 标准库与平台 API；缓存仅在 temp_dir 且为线程局部。
- **内存安全**：未暴露悬垂指针，API 不变，行为可预期。
