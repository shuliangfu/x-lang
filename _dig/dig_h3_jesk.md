# DIG h3_je / h3_jesk — Capless h3 SoftCap lit past @46a71c

Date: 2026-10-30 ~14:50 CST Asia/Shanghai

## Plants
| name | sha12 | plant | SoftCap lit |
|---|---|---|---|
| h3_je | `a4461bae5d62` | c36 + `@46a82b je→jmp @46a8a5` | AV (past @46a837) |
| h3_jesk | `cfb0fae4f5d9` | h3_je + `@46a90c jne→jmp` skip `@2a3d37` | AV at h4 |

## Path
c36 SoftCap-site miss → Capless h3. SoftCap lit already equal `@46a71c→@46a756`.
AV was `@46a837` fallthrough of `@46a82b je`. Force jmp → exit `@46a8a5` → kind gate → h3 ret.
Capless: h3_ok → call_h4 → **AV @493d31**.

## Next
DIG Capless h4 SoftCap lit AV root; single-site skip/fix without arg-loop.
