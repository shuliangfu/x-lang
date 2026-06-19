/**
 * async_switch.c — B-ASYNC C 对照：scheduler jmp ping-pong 1M rounds
 */
#include <stdint.h>

extern int64_t shux_async_coop_pingpong_jmp(int64_t rounds);

int main(void) {
    int64_t r = shux_async_coop_pingpong_jmp(1000000);
    return (int)(r & 255);
}
