/* seeds/runtime_kv_mmap_glue.from_x.c — G-02f-21 product TU
 * Logic still C until full .x port.
 */
/**
 * runtime_kv_mmap_glue.c — F-ZC：自 std/db 胶层迁入
 *
 * 从 kv.c 迁出 kv_mmap_file 与 munmap/msync；LSM/WAL 逻辑见 std/db/kv/kv.x。
 * 仅 Linux / macOS hosted 路径编译链接。
 */

#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>
#ifndef _WIN32
#include <sys/mman.h>
#endif
#include <sys/stat.h>
#ifndef _WIN32
#include <unistd.h>
#endif

/**
 * mmap 映射文件（O_RDWR|O_CREAT；不足 min_size 则 ftruncate）。
 * 成功返回映射地址（intptr），失败返回 0；out_size 写入映射长度。
 */
int64_t shu_kv_mmap_file_c(const uint8_t *path, size_t min_size, size_t *out_size) {
    int fd;
    struct stat st;
    void *p;
    size_t len;

    if (!path || !out_size) {
        return 0;
    }
    fd = open((const char *)path, O_RDWR | O_CREAT, (mode_t)0644);
    if (fd < 0) {
        return 0;
    }
    if (fstat(fd, &st) != 0) {
        close(fd);
        return 0;
    }
    len = (size_t)st.st_size;
    if (len < min_size) {
        if (ftruncate(fd, (off_t)min_size) != 0) {
            close(fd);
            return 0;
        }
        len = min_size;
    }
    p = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);
    if (p == MAP_FAILED) {
        return 0;
    }
    *out_size = len;
    return (int64_t)(intptr_t)p;
}

/** munmap(addr, len)；成功 0，失败 -1。 */
int32_t shu_kv_munmap_c(int64_t addr, size_t len) {
    if (addr == 0) {
        return -1;
    }
    return munmap((void *)(intptr_t)addr, len) == 0 ? 0 : -1;
}

/** msync MS_SYNC；成功 0，失败 -1。 */
int32_t shu_kv_msync_c(int64_t addr, size_t len) {
    if (addr == 0) {
        return -1;
    }
    return msync((void *)(intptr_t)addr, len, MS_SYNC) == 0 ? 0 : -1;
}
