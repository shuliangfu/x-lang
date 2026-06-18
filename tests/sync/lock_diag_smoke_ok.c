/**
 * STD-111：lock_diag C 烟测入口（链接 sync.o）。
 */
#include <stdint.h>
#include <stdio.h>

extern int32_t sync_lock_diag_smoke_c(void);

int main(void) {
    int32_t r = sync_lock_diag_smoke_c();
    if (r != 0) {
        fprintf(stderr, "lock_diag smoke fail: %d\n", (int)r);
        return 1;
    }
    return 0;
}
