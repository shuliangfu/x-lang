# [OPEN] hello-stage1-segv

## Summary
- Symptom: `./compiler/shux_asm -L .. ../examples/hello.x -o /tmp/shux_hello_stage1` on `ubuntu-server` terminates with `SIGSEGV`.
- Expected: stage1 compiler finishes hello build successfully.
- Scope: blocks `check-7.2-bstrict` and `bootstrap-verify-bstrict` on Ubuntu.

## Reproduction
- Host: `ubuntu-server`
- Working dir: `~/worker/shu/shux/compiler`
- Command:
  - `perl -e 'alarm shift; exec @ARGV' 120 ./shux_asm -L .. ../examples/hello.x -o /tmp/shux_hello_stage1`

## Hypotheses
1. Crash is in driver compile / final link path, not in typeck.
2. `std.io` import triggers a bad std/runtime object resolution branch.
3. `shux_asm` and `shux_asm.strict_glue` diverge in hello compile path.
4. Intermediate artifacts or stderr can narrow crash stage before final executable link.

## Evidence Plan
- Add minimal instrumentation around `shux_invoke_cc` / runtime link preparation path.
- Reproduce on Ubuntu with hard timeout and RSS capture.
- Compare `shux_asm` vs `shux_asm.strict_glue` behavior on the same hello compile command.

## Status
- Open
