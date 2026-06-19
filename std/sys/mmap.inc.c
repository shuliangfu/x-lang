/**
 * std/sys/mmap.inc.c — BOOT-029 v3：mmap 原语（MAP_SHARED 可写映射）
 *
 * 【职责】为 std.db.kv 等模块提供连续扇区 mmap；POSIX mmap + ftruncate。
 * 【平台】Linux / macOS；其他平台返回 NULL。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#if defined(__linux__) || defined(__APPLE__)
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

/** 可写 mmap：文件不足 min_size 时 ftruncate 扩展；*out_size 返回映射字节数。 */
void *shux_sys_mmap_rw_c(uint8_t *path, size_t min_size, size_t *out_size) {
#if defined(__linux__) || defined(__APPLE__)
    int fd;
    struct stat st;
    void *p;
    size_t len;
    if (!path || !out_size || min_size == 0) {
        return NULL;
    }
    fd = open((const char *)path, O_RDWR | O_CREAT, (mode_t)0644);
    if (fd < 0) {
        return NULL;
    }
    if (fstat(fd, &st) != 0) {
        close(fd);
        return NULL;
    }
    len = (size_t)st.st_size;
    if (len < min_size) {
        if (ftruncate(fd, (off_t)min_size) != 0) {
            close(fd);
            return NULL;
        }
        len = min_size;
    }
    p = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);
    if (p == MAP_FAILED) {
        return NULL;
    }
    *out_size = len;
    return p;
#else
    (void)path;
    (void)min_size;
    if (out_size) {
        *out_size = 0;
    }
    return NULL;
#endif
}

/** 解除 mmap；0 成功，-1 失败。 */
int32_t shux_sys_munmap_c(void *ptr, size_t size) {
#if defined(__linux__) || defined(__APPLE__)
    if (!ptr || size == 0) {
        return -1;
    }
    return munmap(ptr, size) == 0 ? 0 : -1;
#else
    (void)ptr;
    (void)size;
    return -1;
#endif
}

/** msync 刷盘；0 成功，-1 失败。 */
int32_t shux_sys_msync_c(void *ptr, size_t size) {
#if defined(__linux__) || defined(__APPLE__)
    if (!ptr || size == 0) {
        return -1;
    }
    return msync(ptr, size, MS_SYNC) == 0 ? 0 : -1;
#else
    (void)ptr;
    (void)size;
    return -1;
#endif
}

/** 烟测：mmap 读写 8 字节 magic。 */
int32_t shux_sys_mmap_smoke_c(uint8_t *path) {
#if defined(__linux__) || defined(__APPLE__)
    size_t sz = 0;
    uint8_t *p;
    if (!path) {
        return -1;
    }
    p = (uint8_t *)shux_sys_mmap_rw_c(path, 4096, &sz);
    if (!p || sz < 8) {
        return -2;
    }
    p[0] = (uint8_t)'M';
    p[1] = (uint8_t)'M';
    p[2] = (uint8_t)'A';
    p[3] = (uint8_t)'P';
    p[4] = (uint8_t)'O';
    p[5] = (uint8_t)'K';
    p[6] = 0;
    p[7] = 0;
    if (shux_sys_msync_c(p, sz) != 0) {
        shux_sys_munmap_c(p, sz);
        return -3;
    }
    shux_sys_munmap_c(p, sz);
    return 0;
#else
    (void)path;
    return -9;
#endif
}
