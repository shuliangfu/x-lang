# DIG tip_c21k / tip_c21b — Isol Cap@0024e6-class SoftCap dispatch

Date: 2026-10-30 ~14:45 CST Asia/Shanghai

## Plants (semantic short names; no letter-pile)
| name | sha12 | plant | SoftCap lit |
|---|---|---|---|
| tip_c21k | `81295b0d64f9` | tip SoftCap→`@28f496` Cap21 ABI + force kind`@28f6cc` + force size`@28f70d` | CG002 |
| tip_c21r | `9dda65be01c5` | tip_c21k + tip_after force eax=1 | CG002 |
| tip_c21z | — | tip_c21k + tip_after force eax=0 | crc=0x1 |
| tip_c21b | `7c8ca171e2bc` | tip_c21k + `@28f661` c0←r8 | TIMEOUT (ban) |

## LIVE vs Isol Cap21
- LIVE Cap`@0024e6`→Cap21c8 `@0021c8`: rcx/edx/r8/r9; stores f8=r9; emit via `@1d8cf4` etc.
- Isol `@28f496`: rcx/edx/r8 only; kind==3 gate; size 1..255; c0←`@24af8b`; **dead** (no native callers).

## tip_c21k INT3 SoftCap lit
Hits: c21_entry(TIMEOUT odd)/call_24af8b/call_20cd98/kind_ok/call_20203f/sz_ok/c21_fail/tip_after/tip_join;
mid: `@201f36`/`@24b171`/`@23030e`/`@204732`/path_alt/`@2087a9`/`@200ff7`/cc_ok;
skip: `@2a3d37`@28f7bc / `@1fc596`@28f823 → crc=0x1 (path_alt when c0==0).

## Falsify
Cap@0024e6-class via dead `@28f496` enters body but does not emit SoftCap lit frame (CG002). c0=r8 → TIMEOUT. Do not arg-loop / LIVE transplant.

## Next
Capless h3 SoftCap lit past `@46a71c` without AV (`je` equal skips `@46a741 call @1fb0ec`).
