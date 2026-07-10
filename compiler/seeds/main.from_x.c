/* E-04 v21 minimal main — LEGACY/shux-c cold start (G-02f-78 seed is truth). */
/* Generated from src/main_c_entry.x (G-02f-23 true .x).
 * Regen: ./shux-c -E -L .. src/main_c_entry.x > seeds/main.from_x.c
 * argv polished to char** for C ABI (shux-c emits *u8).
 */
#include <stdint.h>
#include <stddef.h>
extern int shux_forward_main_to_main_entry(int argc, char **argv);
int main(int argc, char **argv) {
  (void)(({   {
    int32_t r = shux_forward_main_to_main_entry(argc, argv);
    return r;
  }
 }));
  return 0;
}
