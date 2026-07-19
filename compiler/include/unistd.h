/* unistd.h — Windows MinGW compatibility shim for <unistd.h>.
 * Why: MinGW provides <unistd.h> but lacks pread/pwrite (POSIX positional
 *      I/O). Generated C files (parser_gen.c, codegen_gen.c, typeck_gen.c,
 *      seeds/runtime_*_thin.from_x.c, etc.) define shux_sys_pread /
 *      shux_sys_pwrite static inline helpers that call pread / pwrite.
 *      Without these declarations, Windows MSYS/MinGW compilation aborts
 *      with "implicit declaration of function 'pread'/'pwrite'" error.
 * On macOS/Linux the system <unistd.h> (which already declares pread/pwrite)
 * is used via #include_next, so this shim is effectively a no-op there.
 * Invariant: pread/pwrite are emulated via _lseek + _read/_write (MinGW
 *            <io.h>). This is NOT atomic: a concurrent thread sharing the
 *            same fd could race between _lseek and _read. For SHUX, the
 *            shux_sys_pread/pwrite helpers are currently defined-but-unused
 *            (verified via grep), so the non-atomicity is acceptable. If
 *            Windows code actually calls them on a shared fd, a real
 *            implementation (e.g. via ReadFile/WriteFile with OVERLAPPED)
 *            belongs here in a later wave.
 * PLATFORM: WINDOWS | MSYS | MINGW (provides pread/pwrite emulation);
 *           POSIX (delegates to system header via #include_next). */
#ifndef SHUX_UNISTD_H
#define SHUX_UNISTD_H

#if defined(_WIN32) || defined(_WIN64)

/* Pull in MinGW's own <unistd.h> first (skipping this shim), which
 * declares read/write/close/lseek/getopt/getpid/etc. and defines
 * off_t / ssize_t via <sys/types.h>. */
#include_next <unistd.h>

/* ssize_t / off_t should already be defined by MinGW <unistd.h>. If not,
 * fall back to a local definition. */
#ifndef _SSIZE_T_DEFINED
#define _SSIZE_T_DEFINED
typedef intptr_t ssize_t;
#endif

#ifndef _OFF_T_DEFINED
#define _OFF_T_DEFINED
typedef long off_t;
#endif

#include <io.h>  /* _read / _write / _lseek / _close */

/* pread — POSIX positional read; MinGW lacks it.
 *         Non-atomic emulation: save cur → seek → read → restore cur.
 *         Returns bytes read, or -1 on error (errno preserved by caller
 *         via _read semantics). */
static inline ssize_t pread(int fd, void *buf, size_t count, off_t offset) {
    off_t cur = _lseek(fd, 0, SEEK_CUR);
    if (cur < 0) return -1;
    if (_lseek(fd, offset, SEEK_SET) < 0) return -1;
    ssize_t n = (ssize_t)_read(fd, buf, (unsigned int)count);
    off_t restore = _lseek(fd, cur, SEEK_SET);
    (void)restore;  /* Best-effort restore; if it fails, fd offset is lost. */
    return n;
}

/* pwrite — POSIX positional write; MinGW lacks it.
 *          Non-atomic emulation: save cur → seek → write → restore cur. */
static inline ssize_t pwrite(int fd, const void *buf, size_t count, off_t offset) {
    off_t cur = _lseek(fd, 0, SEEK_CUR);
    if (cur < 0) return -1;
    if (_lseek(fd, offset, SEEK_SET) < 0) return -1;
    ssize_t n = (ssize_t)_write(fd, buf, (unsigned int)count);
    off_t restore = _lseek(fd, cur, SEEK_SET);
    (void)restore;
    return n;
}

#else
/* macOS / Linux: delegate to the system <unistd.h>. */
#include_next <unistd.h>
#endif

#endif /* SHUX_UNISTD_H */
