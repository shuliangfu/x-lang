/* seeds/labi_diag_pure.from_x.c — G-02f-268 P2 link_abi L1 diag pure
 * Logic source: src/runtime/labi_diag_pure.x
 * Hybrid: SHUX_LABI_DIAG_PURE_FROM_X + ld -r into runtime_link_abi.o
 * No wait/errno/stat; only diag_report* + code mapping.
 */
#include <stddef.h>
#include <string.h>
#include "diag.h"
#include "runtime_diag_codes.h"

const char * link_diag_code_for_kind(const char *kind) {
    if (!kind)
        return SHUX_DIAG_CODE_PROCESS_PRC001;
    if (strcmp(kind, "build error") == 0)
        return SHUX_DIAG_CODE_BUILD_BLD001;
    if (strcmp(kind, "process error") == 0)
        return SHUX_DIAG_CODE_PROCESS_PRC001;
    return NULL;
}



void link_diag_runtime_obj_resolve_fail(const char *obj_name, const char *hint) {
    if (!obj_name)
        obj_name = "runtime object";
    if (hint && hint[0] != '\0') {
        diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                               "cannot resolve compiler directory to build %s (%s)",
                               obj_name, hint);
    } else {
        diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                               "cannot resolve compiler directory to build %s",
                               obj_name);
    }
}





void link_diag_runtime_source_missing(const char *obj_name, const char *source_path) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s source not found at %s",
                           obj_name, source_path ? source_path : "?");
}



void link_diag_runtime_source_missing_under(const char *obj_name, const char *base_dir,
                                                   const char *suffix) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s source not found under %s%s",
                           obj_name, base_dir ? base_dir : "?", suffix ? suffix : "");
}





void link_diag_runtime_obj_missing(const char *obj_name, const char *out_o) {
    if (!obj_name)
        obj_name = "runtime object";
    diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                           "%s missing after cc -c (expected near %s)",
                           obj_name, out_o ? out_o : "?");
}

void link_diag_freestanding_missing(const char *obj_name, const char *symbol_name) {
    if (symbol_name && symbol_name[0]) {
        diag_reportf_with_code(NULL, 0, 0, "link error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                     "freestanding link missing %s (user references %s)",
                     obj_name ? obj_name : "runtime object",
                     symbol_name);
        return;
    }
    diag_reportf_with_code(NULL, 0, 0, "link error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                 "freestanding link missing %s",
                 obj_name ? obj_name : "runtime object");
}



void link_diag_freestanding_unsupported(void) {
    diag_report_with_code(NULL, 0, 0, "link error", SHUX_DIAG_CODE_BUILD_BLD001,
                "-freestanding / SHUX_FREESTANDING is only supported for Linux ELF x86_64 (-o prog, not .o/.obj on macOS/COFF)",
                NULL);
}





void link_diag_ld_debug_push(const char *rel, const char *stage, const char *path) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "ld debug: push %s %s=%s",
                 rel ? rel : "(null)",
                 stage ? stage : "path",
                 path ? path : "(null)");
}



void link_diag_ld_debug_argv(const char *label, const char *const *argv) {
    int di;
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "ld debug: %s",
                 label ? label : "argv");
    if (!argv)
        return;
    for (di = 0; argv[di] != NULL; di++) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "ld debug argv[%d]=%s",
                     di,
                     argv[di]);
    }
}
