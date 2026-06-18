/**
 * core/mem/mem.c — volatile 读写与内存栅栏（CORE-017）
 *
 * 【文件职责】MMIO/共享内存场景的 volatile load/store；compiler_fence 与 acquire/release/seq_cst 线程栅栏。
 * 【所属模块】core.mem；与 core/mem/mod.su 同属一模块。依赖 C11 stdatomic.h（或 GCC __atomic_*）。
 * 【约定】u16/u32/u64 要求 ptr 自然对齐；不对齐行为未定义。
 */

#include <stdint.h>

#if defined(__GNUC__) || defined(__clang__)
#define SHU_MEM_COMPILER_FENCE() __asm__ __volatile__("" ::: "memory")
#elif defined(_MSC_VER)
#include <intrin.h>
#define SHU_MEM_COMPILER_FENCE() _ReadWriteBarrier()
#else
#define SHU_MEM_COMPILER_FENCE() ((void)0)
#endif

#if defined(__STDC_NO_ATOMICS__) || (defined(__GNUC__) && !defined(__clang__) && __GNUC__ < 4)
/* 极旧工具链回退：仅 compiler fence，线程栅栏为空操作 */
#define SHU_MEM_THREAD_FENCE_ACQ() SHU_MEM_COMPILER_FENCE()
#define SHU_MEM_THREAD_FENCE_REL() SHU_MEM_COMPILER_FENCE()
#define SHU_MEM_THREAD_FENCE_SEQ() SHU_MEM_COMPILER_FENCE()
#else
#include <stdatomic.h>
#define SHU_MEM_THREAD_FENCE_ACQ() atomic_thread_fence(memory_order_acquire)
#define SHU_MEM_THREAD_FENCE_REL() atomic_thread_fence(memory_order_release)
#define SHU_MEM_THREAD_FENCE_SEQ() atomic_thread_fence(memory_order_seq_cst)
#endif

/** volatile 读 u8；ptr 可为任意字节地址。 */
uint8_t mem_volatile_load_u8_c(const volatile uint8_t *ptr) {
  if (!ptr) return 0;
  return *ptr;
}

/** volatile 写 u8。 */
void mem_volatile_store_u8_c(volatile uint8_t *ptr, uint8_t val) {
  if (!ptr) return;
  *ptr = val;
}

/** volatile 读 u16；ptr 须 2 字节对齐。 */
uint16_t mem_volatile_load_u16_c(const volatile uint16_t *ptr) {
  if (!ptr) return 0;
  return *ptr;
}

/** volatile 写 u16。 */
void mem_volatile_store_u16_c(volatile uint16_t *ptr, uint16_t val) {
  if (!ptr) return;
  *ptr = val;
}

/** volatile 读 u32。 */
uint32_t mem_volatile_load_u32_c(const volatile uint32_t *ptr) {
  if (!ptr) return 0;
  return *ptr;
}

/** volatile 写 u32。 */
void mem_volatile_store_u32_c(volatile uint32_t *ptr, uint32_t val) {
  if (!ptr) return;
  *ptr = val;
}

/** volatile 读 u64。 */
uint64_t mem_volatile_load_u64_c(const volatile uint64_t *ptr) {
  if (!ptr) return 0;
  return *ptr;
}

/** volatile 写 u64。 */
void mem_volatile_store_u64_c(volatile uint64_t *ptr, uint64_t val) {
  if (!ptr) return;
  *ptr = val;
}

/** 编译器级栅栏：禁止编译器重排，不保证跨核可见性。 */
void mem_compiler_fence_c(void) {
  SHU_MEM_COMPILER_FENCE();
}

/** 线程 acquire 栅栏：后续读写不可重排到此栅栏之前。 */
void mem_fence_acquire_c(void) {
  SHU_MEM_THREAD_FENCE_ACQ();
}

/** 线程 release 栅栏：此前读写不可重排到此栅栏之后。 */
void mem_fence_release_c(void) {
  SHU_MEM_THREAD_FENCE_REL();
}

/** 线程 seq_cst 全序栅栏。 */
void mem_fence_seq_cst_c(void) {
  SHU_MEM_THREAD_FENCE_SEQ();
}

/** C 烟测：volatile 往返 + fence 可调用；失败返回非 0。 */
int32_t mem_volatile_fence_smoke_c(void) {
  volatile uint32_t cell = 0u;
  mem_volatile_store_u32_c(&cell, 0xA5A5A5A5u);
  if (mem_volatile_load_u32_c(&cell) != 0xA5A5A5A5u)
    return 1;
  {
    volatile uint16_t cell16 = 0u;
    mem_volatile_store_u16_c(&cell16, 0xBEEFu);
    if (mem_volatile_load_u16_c(&cell16) != 0xBEEFu)
      return 2;
  }
  mem_compiler_fence_c();
  mem_fence_release_c();
  mem_fence_acquire_c();
  mem_fence_seq_cst_c();
  return 0;
}
