/* Source-faithful rt_ab_dep_waits_unvisited twin (rt_run_asm_backend.x).
 * s136 hung after thin prerun zeroing: next_slot entered once
 * (ret should be 0x1400019cb) and called typool
 * rt_run_asm_backend_rt_ab_dep_waits_unvisited at 0x140228830.
 * Live RIP for 15s stayed in 0x140228cbe..0x140228d84.
 * Mechanism (two typool bugs in the ws-skip loop after import kw):
 * 1) break compiled as jmp to loop head 0x140228cbe
 *    (0x140228cf2 when p>=n, 0x140228d84 when c is not whitespace)
 *    without incrementing ws. ws stays 0 so the <16 bound never trips.
 * 2) c = src[p] compiled as lea -0x48(%rbp); lea (%rax,%rbx,8)
 *    (shallow lea of local src slot, scale-8) so the loaded qword
 *    was not a source byte (final rax/rbx=0x309), taking the
 *    break-as-jmp path forever.
 * PARSE_ONLY / ONE_CTX never entered. Fold only this proven function.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

extern uint8_t *driver_ptr_table_get(uint8_t *t, int32_t i);
extern size_t driver_size_table_get(uint8_t *t, int32_t i);
extern int32_t rt_run_asm_backend_rt_ab_at_import_kw(uint8_t *src, int32_t n, int32_t i);
extern int32_t xlang_find_loaded_import_index(uint8_t *import_path, uint8_t *all_paths, int32_t n_all);

int32_t rt_run_asm_backend_rt_ab_dep_waits_unvisited(uint8_t *ds, uint8_t *dl, uint8_t *dp, int32_t n_deps, int32_t slot, uint8_t *seen) {
  uint8_t *src = 0;
  size_t len_z = 0;
  int32_t n = 0;
  int32_t i = 0;
  int32_t p = 0;
  int32_t ws = 0;
  uint8_t c = 0;
  uint8_t open_b = 0;
  uint8_t q = 0;
  uint8_t path_buf[65] = {0};
  uint8_t *path_buf_p = 0;
  int32_t k = 0;
  int32_t g = 0;
  uint8_t sv = 0;
  if (ds == 0) {
    return 0;
  }
  if (dl == 0) {
    return 0;
  }
  if (dp == 0) {
    return 0;
  }
  if (seen == 0) {
    return 0;
  }
  if (slot < 0) {
    return 0;
  }
  if (n_deps <= 0) {
    return 0;
  }
  if (n_deps > 32) {
    return 0;
  }
  src = driver_ptr_table_get(ds, slot);
  len_z = driver_size_table_get(dl, slot);
  if (src == 0) {
    return 0;
  }
  if (len_z > 2147483647) {
    return 0;
  }
  n = (int32_t)len_z;
  while (i + 6 <= n) {
    if (rt_run_asm_backend_rt_ab_at_import_kw(src, n, i) != 0) {
      p = i + 6;
      ws = 0;
      while (ws < 16) {
        if (p >= n) {
          break;
        }
        c = src[p];
        if (c != 32) {
          if (c != 9) {
            if (c != 10) {
              if (c != 13) {
                break;
              }
            }
          }
        }
        p = p + 1;
        ws = ws + 1;
      }
      open_b = 0;
      if (p < n) {
        open_b = src[p];
      }
      if (open_b == 40) {
        p = p + 1;
        ws = 0;
        while (ws < 16) {
          if (p >= n) {
            break;
          }
          c = src[p];
          if (c != 32) {
            if (c != 9) {
              if (c != 10) {
                if (c != 13) {
                  break;
                }
              }
            }
          }
          p = p + 1;
          ws = ws + 1;
        }
        q = 0;
        if (p < n) {
          q = src[p];
        }
        if (q == 34) {
          p = p + 1;
          path_buf_p = &path_buf[0];
          memset(path_buf_p, 0, 65);
          k = 0;
          while (k < 64) {
            if (p >= n) {
              break;
            }
            c = src[p];
            if (c == 34) {
              break;
            }
            if (c == 0) {
              break;
            }
            path_buf_p[k] = c;
            k = k + 1;
            p = p + 1;
          }
          if (k > 0) {
            if (k < 65) {
              path_buf_p[k] = 0;
              g = xlang_find_loaded_import_index(path_buf_p, dp, n_deps);
              if (g >= 0) {
                if (g < 32) {
                  if (g != slot) {
                    sv = seen[g];
                    if (sv == 0) {
                      return 1;
                    }
                  }
                }
              }
            }
          }
          if (p < n) {
            i = p + 1;
            continue;
          }
          return 0;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}
