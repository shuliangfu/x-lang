# STD-149：std.math fenv 能力检测 v1

> 状态：**定版（v1）**  
> 关联：`STD-059` fenv API、`FENV_NOT_IMPL = -9`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-149 | `fenv_available()` + 平台能力表 + `SHUX_MATH_FENV_CAP` 报告 + gate |

调用方在 `test_exceptions` 前可先探测；stub 平台 API 返回 `FENV_NOT_IMPL`。

---

## 2. 平台能力表

| 平台 | `fenv_available()` | `test/clear/raise` |
|------|-------------------|-------------------|
| **Darwin** | 1 | `fenv.h` 全路径 |
| **Linux** (非 Android) | 1 | `fenv.h` 全路径 |
| **Windows** | 0 | 返回 `FENV_NOT_IMPL` |
| **Android / 其他** | 0 | stub |

---

## 3. 能力报告格式

```
shux: [SHUX_MATH_FENV_CAP] platform=Darwin available=1
```

---

## 4. 用法

```su
if (fenv_available() != 0) {
  clear_exceptions(31);
}
```

---

## 5. Gate

```bash
./tests/run-std-math-fenv-capability-gate.sh
```

报告：`shux: [SHUX_STD149_MATH_FENV_CAP]`
