/* Freestanding stubs for shux codegen runtime (shux_panic_, crash evidence).
 * These are never called in a correctly-functioning kernel but must exist
 * to satisfy the linker since shux-c always emits shux_panic_ references. */
typedef struct { int _dummy; } shux_FILE;
typedef unsigned long size_t;
shux_FILE _shux_stderr_obj;
shux_FILE *stderr = &_shux_stderr_obj;
void __stack_chk_fail(void) { for(;;); }
void abort(void) { for(;;); }
int fprintf(shux_FILE *f, const char *fmt, ...) { (void)f; (void)fmt; return 0; }
int snprintf(char *buf, unsigned long sz, const char *fmt, ...) { (void)buf; (void)sz; (void)fmt; return 0; }
char *getenv(const char *name) { (void)name; return (char*)0; }
int getpid(void) { return 0; }
shux_FILE *fopen(const char *p, const char *m) { (void)p; (void)m; return (shux_FILE*)0; }
int fclose(shux_FILE *f) { (void)f; return 0; }
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
