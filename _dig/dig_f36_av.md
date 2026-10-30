# DIG SoftCap lit emit call @201f36 AV root

Base: h3_jesk `cfb0fae4f5d9`. Short timeout INT3 (no long hang).

## Caller (@576f47)
- `lea rcx,[rbp+0x60]` buf
- `edx=[rbp+0x424]` idx
- `rcx=[rbp+0x490]` node; `r8=buf`
- `call @201f36`

## SoftCap lit INT3
| site | result |
|---|---|
| @201f36 entry / save rcx·edx·r8 / je buf / lookup / jne node / load+120 / memset / memcpy+20 / **ret** | **HIT** |
| @576f5e call site / @576f47 lea / @576f63 after | AV (call-site plant / post-return) |
| baseline h3_jesk lit | AV |

## Nail
SoftCap lit **enters and completes** `@201f36` (args+buf+idx OK; memcpy `node+0x20` size`+0x120`). **AV root ≠ inside @201f36** — AV is Capless **after return** (next `@201ea0` / `@201ddf` memcpy `node+0x150` size`+0x250`).

Ban: letter-pile / LIVE SoftCap transplant / arg-loop / twin. PROD/pin untouched. Not green.
