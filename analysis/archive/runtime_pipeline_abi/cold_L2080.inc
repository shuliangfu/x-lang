/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
void xlang_fputs_stdout(const char *s) {
    /* Cap residual 9.7.1: fputs(stdout) → raw fd-1 write (twin of runtime_driver_abi
     * fputs_opaque semantics). PLATFORM: SHARED. */
    if (s)
        (void)xlang_io_write(1, s, strlen(s));
}
