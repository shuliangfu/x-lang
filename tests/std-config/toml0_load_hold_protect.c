/* Knife 11.36: host-cc protect for toml0 load residual (11.31 HOLD).
 *
 * PASS when residual still locked on product std/config/config.o:
 *   set_string round-trips AND load_toml_buf → CFG_OK AND get → CFG_ERR_NOT_FOUND (-2).
 * FAIL if set_string breaks, or residual clears without a Soft Cap tiphead knife
 * (do not silent-ACCEPT runtime load green).
 *
 * Honesty: this gate going green does NOT mean load is product-ready.
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern int64_t config_create_c(void);
extern void config_free_c(int64_t);
extern int32_t config_set_string_c(int64_t, const char *, int32_t, const char *, int32_t);
extern int32_t config_get_string_c(int64_t, const char *, int32_t, char *, int32_t);
extern int32_t config_load_toml_buf_c(int64_t, const char *, int32_t, int32_t);

enum {
  CFG_OK = 0,
  CFG_ERR_NOT_FOUND = -2
};

int main(void) {
  int64_t h;
  char buf[64];
  int32_t rc;
  const char *toml = "port = 8080\n";

  h = config_create_c();
  if (!h) {
    fprintf(stderr, "toml0-hold-protect FAIL: config_create_c\n");
    return 10;
  }
  rc = config_set_string_c(h, "k", 1, "v", 1);
  if (rc != CFG_OK) {
    fprintf(stderr, "toml0-hold-protect FAIL: set_string rc=%d\n", rc);
    return 11;
  }
  memset(buf, 0, sizeof buf);
  rc = config_get_string_c(h, "k", 1, buf, 64);
  if (rc < 0 || strcmp(buf, "v") != 0) {
    fprintf(stderr, "toml0-hold-protect FAIL: get after set rc=%d buf=%s\n", rc, buf);
    return 12;
  }
  config_free_c(h);

  h = config_create_c();
  if (!h) {
    fprintf(stderr, "toml0-hold-protect FAIL: create2\n");
    return 13;
  }
  rc = config_load_toml_buf_c(h, toml, (int32_t)strlen(toml), 1);
  if (rc != CFG_OK) {
    fprintf(stderr, "toml0-hold-protect FAIL: load rc=%d (want OK; residual shape)\n", rc);
    return 14;
  }
  memset(buf, 0, sizeof buf);
  rc = config_get_string_c(h, "port", 4, buf, 64);
  if (rc == CFG_OK || rc > 0) {
    fprintf(stderr,
            "toml0-hold-protect FAIL: residual CLEARED get rc=%d — reopen Soft Cap tiphead "
            "knife; do not claim silent runtime green\n",
            rc);
    return 15;
  }
  if (rc != CFG_ERR_NOT_FOUND) {
    fprintf(stderr, "toml0-hold-protect FAIL: get after load rc=%d want NOT_FOUND=-2\n", rc);
    return 16;
  }
  config_free_c(h);

  printf("xlang: [TOML0_LOAD_HOLD_PROTECT] residual_locked=1 set_ok=1 "
         "load_ok_get_not_found=1 runtime_load=deferred\n");
  return 0;
}
