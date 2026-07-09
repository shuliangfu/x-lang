/**
 * build_runner_gen.c — pinned C for build_runner.x (G-05)
 *
 * Why pinned: shux -x -E currently drops entry(argc,argv) parameters into
 * invalid static init_globals. Semantics match build_runner.x; regenerate when
 * -x -E emits a correct entry() (or restore -E-extern C-frontend seed).
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t driver_get_argv_i(int32_t argc, uint8_t *argv, int32_t i, uint8_t *buf, int32_t max);
extern int32_t build_run_step(int32_t step_id, uint8_t *shu_path);
extern int32_t build_run_asm_build(uint8_t *shu_path);
extern int32_t build_get_step_count(void);
extern int32_t build_get_step_at(int32_t i);
extern int32_t build_use_asm_only(void);
extern int32_t build_copy_shux_asm(void);

int32_t build_run_legacy_steps(uint8_t *shu_path) {
  int32_t n = build_get_step_count();
  int32_t i = 0;
  while (i < n) {
    int32_t step_id = build_get_step_at(i);
    if (step_id < 0) {
      return 1;
    }
    if (build_run_step(step_id, shu_path) != 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

int32_t build_argv2_is_asm(uint8_t *arg2, int32_t l2) {
  if (l2 == 3 && arg2[0] == 97 && arg2[1] == 115 && arg2[2] == 109) {
    return 1;
  }
  return 0;
}

int32_t build_argv2_is_legacy(uint8_t *arg2, int32_t l2) {
  if (l2 == 6 && arg2[0] == 108 && arg2[1] == 101 && arg2[2] == 103 && arg2[3] == 97 &&
      arg2[4] == 99 && arg2[5] == 121) {
    return 1;
  }
  return 0;
}

int32_t entry(int32_t argc, uint8_t *argv) {
  uint8_t shu_buf[256];
  int32_t len = driver_get_argv_i(argc, argv, 1, shu_buf, 256);
  if (len < 0) {
    shu_buf[0] = 46;
    shu_buf[1] = 47;
    shu_buf[2] = 115;
    shu_buf[3] = 104;
    shu_buf[4] = 117;
    shu_buf[5] = 120;
    len = 6;
  }
  if (len < 256) {
    shu_buf[len] = 0;
  }
  {
    uint8_t arg2[8];
    int32_t l2 = driver_get_argv_i(argc, argv, 2, arg2, 8);
    if (build_argv2_is_asm(arg2, l2) != 0) {
      if (build_run_asm_build(shu_buf) != 0) {
        return 1;
      }
      return 0;
    }
    if (build_argv2_is_legacy(arg2, l2) != 0) {
      if (build_run_legacy_steps(shu_buf) != 0) {
        return 1;
      }
      return 0;
    }
  }
  if (build_use_asm_only() != 0) {
    if (build_run_asm_build(shu_buf) == 0) {
      if (build_copy_shux_asm() != 0) {
        return 1;
      }
      return 0;
    }
  }
  if (build_run_legacy_steps(shu_buf) != 0) {
    return 1;
  }
  return 0;
}
