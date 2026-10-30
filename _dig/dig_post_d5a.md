# DIG Capless SoftCap lit post_alt → @576d5a Cap@0024e6-class (native)

- Base: h3_jesk `cfb0fae4f5d9`
- SoftCap lit after Capless h5 / `@200ff7` jle → `@576b7b` post_alt
- `@576b7b` cmp `[rbp+0x444],0x2c`；SoftCap lit **jne HIT** → `@576d5a`（skip std_fmt `@56d014`）
- `@576d5a` Cap@0024e6-class：**HIT**
  - `[rbp+0x460]≠0`；`[rbp+0x45c]==0x2c`（≠ field `@+0x444`）
  - call `@201eeb`（kind0x2c→load `+0x14c`）HIT through ret
  - call `@20cd98`（kind==3 gate）HIT ok3
  - call `@20203f`（kind3→load `+0x120` size）HIT through ret
- Buffer clear `@576df3..`；first emit-ish call `@576f5e`→`@201f36` **AV**
- Prior falsified: h4_gate（skip `@2b49f3`→TIMEOUT ban）；exit_ret（`@578273` eax=1 still AV／epilogue INT3）；post_sz never built（ssh hung）
- Ban: letter-pile／LIVE SoftCap transplant／arg-loop／twin；PROD／pin untouched
