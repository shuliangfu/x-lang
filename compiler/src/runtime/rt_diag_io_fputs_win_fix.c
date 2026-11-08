/* Win tip-cold: tip diag_io_fputs is a huge miscompile that SEGV on s[i]
 * when s is stale. Replace with libc fputs + null/readable guards.
 * o is opaque FILE* (stderr/stdout). PLATFORM: WINDOWS. */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#ifdef _WIN32
#include <windows.h>
#endif

static int win_readable_cstr(const char *s) {
  MEMORY_BASIC_INFORMATION mbi;
  const char *p;
  if (!s)
    return 0;
  if ((uintptr_t)s < 0x10000ull)
    return 0;
  p = s;
  /* Walk pages until NUL or 1MiB cap. */
  for (size_t n = 0; n < 1048576u; n++) {
    if ((n % 4096u) == 0) {
      if (VirtualQuery(p, &mbi, sizeof mbi) == 0)
        return 0;
      if (mbi.State != MEM_COMMIT)
        return 0;
      if (!(mbi.Protect & (PAGE_READONLY | PAGE_READWRITE | PAGE_EXECUTE_READ |
                           PAGE_EXECUTE_READWRITE | PAGE_WRITECOPY |
                           PAGE_EXECUTE_WRITECOPY)))
        return 0;
      if (mbi.Protect & (PAGE_NOACCESS | PAGE_GUARD))
        return 0;
    }
    if (*p == 0)
      return 1;
    p++;
  }
  return 0;
}

int diag_io_fputs(const char *s, uint8_t *o) {
  FILE *fp;
  if (!s)
    s = "";
  if (!win_readable_cstr(s))
    return EOF;
  fp = o ? (FILE *)o : stderr;
  return fputs(s, fp);
}
