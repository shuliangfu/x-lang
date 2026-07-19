/* unistd.h — Windows MinGW compatibility shim for <unistd.h>.
 * Why: MinGW provides <unistd.h> but the deprecated POSIX aliases it
 *      declares via <io.h> (open/read/write/close/lseek/access/etc.) have
 *      `const char *` signatures that conflict with SHUX-generated
 *      `extern int32_t open(uint8_t *, int32_t, int32_t)` in typeck_gen.c
 *      L84 (C11 6.7.6.3p15 type incompatibility: uint8_t* vs const char*).
 *      Apple clang is lenient; MinGW gcc strictly enforces this and aborts
 *      with "conflicting types for 'open'".
 *
 *      The fix: pull in MinGW's <unistd.h> with NO_OLDNAMES defined, which
 *      suppresses io.h's deprecated alias block (L328 #ifndef NO_OLDNAMES
 *      ... #endif L347). Then re-declare SHUX's expected signatures (uint8_t*
 *      / int32_t) as inline wrappers delegating to MinGW _-prefixed
 *      functions (_open/_read/_write/_close/_lseek). pread/pwrite (which
 *      MinGW lacks entirely) are emulated via _lseek + _read/_write.
 *
 * On macOS/Linux the system <unistd.h> (which already declares
 * pread/pwrite and does NOT declare `open` — POSIX puts `open` in
 * <fcntl.h>) is used via #include_next, so this shim is a no-op there.
 *
 * Invariant: pread/pwrite are non-atomic (save cur → seek → I/O →
 *            restore cur). For SHUX, the shux_sys_pread/pwrite helpers
 *            are currently defined-but-unused static inline helpers
 *            (verified via grep), so non-atomicity is acceptable.
 * PLATFORM: WINDOWS | MSYS | MINGW (provides NO_OLDNAMES + wrappers);
 *           POSIX (delegates to system header via #include_next). */
#ifndef SHUX_UNISTD_H
#define SHUX_UNISTD_H

#if defined(_WIN32) || defined(_WIN64)

/* NO_OLDNAMES suppresses io.h's deprecated POSIX alias block (open/read/
 * write/close/lseek/access/etc. with const char* signatures) that conflicts
 * with SHUX's own uint8_t* extern declarations. Temporarily defined only
 * for the duration of <unistd.h> inclusion. */
#define NO_OLDNAMES
#include_next <unistd.h>
#undef NO_OLDNAMES

/* ssize_t / off_t fallbacks — MinGW <unistd.h> should provide these via
 * <sys/types.h>, but guard for safety. */
#ifndef _SSIZE_T_DEFINED
#define _SSIZE_T_DEFINED
typedef intptr_t ssize_t;
#endif

#ifndef _OFF_T_DEFINED
#define _OFF_T_DEFINED
typedef long off_t;
#endif

#include <io.h>  /* _read / _write / _close / _lseek / _open */

/* SHUX-expected POSIX wrappers — call MinGW _-prefixed functions.
 * Why: NO_OLDNAMES removed io.h's deprecated `open`/`read`/`write`/`close`/
 *      `lseek` aliases, so SHUX-generated code calling these would have no
 *      declaration. We provide SHUX's expected signatures (uint8_t* /
 *      int32_t) as inline wrappers delegating to MinGW _-prefixed functions.
 *
 *      The `open` wrapper matches SHUX's L84 `extern int32_t open(uint8_t *,
 *      int32_t, int32_t)` declaration exactly. Per C99 6.2.2p4, the prior
 *      static inline definition establishes internal linkage, and the
 *      subsequent `extern` declaration in typeck_gen.c L84 preserves that
 *      internal linkage (no conflict). */
static inline int32_t open(uint8_t *path, int32_t flags, int32_t mode) {
    return (int32_t)_open((const char *)path, (int)flags, (int)mode);
}

static inline ssize_t read(int fd, void *buf, size_t count) {
    return (ssize_t)_read(fd, buf, (unsigned int)count);
}

static inline ssize_t write(int fd, const void *buf, size_t count) {
    return (ssize_t)_write(fd, buf, (unsigned int)count);
}

static inline int close(int fd) {
    return _close(fd);
}

static inline long lseek(int fd, long offset, int origin) {
    return _lseek(fd, offset, origin);
}

/* pread — POSIX positional read; MinGW lacks it entirely.
 *         Non-atomic emulation: save cur → seek → read → restore cur.
 *         Returns bytes read, or -1 on error. */
static inline ssize_t pread(int fd, void *buf, size_t count, off_t offset) {
    off_t cur = _lseek(fd, 0, SEEK_CUR);
    if (cur < 0) return -1;
    if (_lseek(fd, offset, SEEK_SET) < 0) return -1;
    ssize_t n = (ssize_t)_read(fd, buf, (unsigned int)count);
    off_t restore = _lseek(fd, cur, SEEK_SET);
    (void)restore;  /* Best-effort restore; if it fails, fd offset is lost. */
    return n;
}

/* pwrite — POSIX positional write; MinGW lacks it entirely.
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
