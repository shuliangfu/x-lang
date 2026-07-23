/* Freestanding stubs for xlang codegen runtime (xlang_panic_, crash evidence).
 * These are never called in a correctly-functioning kernel but must exist
 * to satisfy the linker since xlang-c always emits xlang_panic_ references. */
typedef struct { int _dummy; } xlang_FILE;
typedef unsigned long size_t;
xlang_FILE _xlang_stderr_obj;
xlang_FILE *stderr = &_xlang_stderr_obj;
void __stack_chk_fail(void) { for(;;); }
void abort(void) { for(;;); }
int fprintf(xlang_FILE *f, const char *fmt, ...) { (void)f; (void)fmt; return 0; }
int snprintf(char *buf, unsigned long sz, const char *fmt, ...) { (void)buf; (void)sz; (void)fmt; return 0; }
char *getenv(const char *name) { (void)name; return (char*)0; }
int getpid(void) { return 0; }
xlang_FILE *fopen(const char *p, const char *m) { (void)p; (void)m; return (xlang_FILE*)0; }
int fclose(xlang_FILE *f) { (void)f; return 0; }
/* memset/memcpy: C compiler may emit calls for struct literal init or large copies.
 * In freestanding kernel mode these are safe byte-level implementations. */
void *memset(void *dst, int c, size_t n) {
    unsigned char *d = (unsigned char *)dst;
    while (n--) *d++ = (unsigned char)c;
    return dst;
}
void *memcpy(void *dst, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    while (n--) *d++ = *s++;
    return dst;
}
