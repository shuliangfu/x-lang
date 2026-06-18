/**
 * tests/fs/dirmeta_smoke_ok.c — STD-123 C 烟测：mkdir → stat(is_dir) → rmdir
 */
#include <stdint.h>
#include <stdio.h>

typedef struct {
    int64_t size;
    uint32_t mode;
    int32_t is_dir;
    int32_t is_file;
    int64_t mtime_sec;
} fs_stat_out_t;

extern int32_t fs_mkdir_c(uint8_t *path, uint32_t mode);
extern int32_t fs_stat_c(uint8_t *path, fs_stat_out_t *out);
extern int32_t fs_rmdir_c(uint8_t *path);
extern int32_t fs_unlink_c(uint8_t *path);

int main(void) {
    const char *dir = "/tmp/shu_fs_dirmeta_smoke";
    fs_stat_out_t st;
    (void)fs_rmdir_c((uint8_t *)dir);
    (void)fs_unlink_c((uint8_t *)dir);
    if (fs_mkdir_c((uint8_t *)dir, 493u) != 0) {
        return 1;
    }
    if (fs_stat_c((uint8_t *)dir, &st) != 0) {
        return 2;
    }
    if (st.is_dir != 1) {
        return 3;
    }
    if (fs_rmdir_c((uint8_t *)dir) != 0) {
        return 4;
    }
    return 0;
}
