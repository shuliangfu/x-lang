# DIG SoftCap lit post-@201f36 AV (Capless → call-mk → @5752bc)

Base: h3_jesk `cfb0fae4f5d9`. Short timeout INT3. Ban letter-pile / LIVE SoftCap transplant / arg-loop / twin.

## Capless after SoftCap lit emit @201f36

| site | role | SoftCap lit |
|---|---|---|
| @201f36 | memcpy node+0x20 / size+0x120 | entry→ret **HIT** (prior) |
| @576f73 call @201ea0 | size getter (+0x250) | entry→ret **HIT** |
| @577115 call @201ddf | memcpy node+0x150 / size+0x250 | entry→memcpy→ret **HIT** |
| @577681 jne kind≠0x2c | Cap join | **HIT** |
| @577c37 kind==3 body | Cap exit kind3 | **HIT** |
| @577c47 call @1ff2ef | load +0x274 | entry→ret **HIT** |
| @578273 call @57b98c | call-mk | enters (**@57bb30 HIT**) |

## Nail 1: AV root ≠ @201ddf / +0x150

SoftCap lit **completes** `@201ea0` and `@201ddf`. Hypothesis "AV at @201ddf +0x150" **falsified**.
skip_ddf→T001; kind_ft→still AV.

## Nail 2: AV moves into call-mk @57b98c → @5752bc

| site | result |
|---|---|
| @57bb30 call @5752bc | **HIT** |
| @5752bc deep | size / @1ff2a3 complete / @563e0c HIT / @575645/@575648 HIT |
| @5aaf18 (eax==2 path) | **HIT** (fallthrough taken) |
| loop @5755a9 / join @575778 | **HIT** |
| @575793 jne @575fa3 | **HIT** (loop exit; [rbp+0x990]≠1) |
| @575fa3 clear path | body HIT (@575fb7/@575fcc/@575fe3/@575fef…) — `[rbp+0x990]==0` fallthrough |
| post-clear / @57605c→@5762a2 | **frontier** (not fully densed) |

## Baseline gates (unchanged)

| Isol | lit / fwd / local |
|---|---|
| h3_jesk | AV / GS / AV |

## Ban / PROD

PROD SoftCap `7a2cf5da581a` untouched. Pin ecdb5cc1e not raised. Not green.
Logs: post_f36 / post_ddf / post_kind / k3_epi / callmk* / 5752bc / 5754c1 / 1ff2a3 / post_1ff / post_jmp / post_loop / fa3.
