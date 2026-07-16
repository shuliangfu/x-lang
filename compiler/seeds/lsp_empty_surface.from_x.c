#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void shux_panic_(int has_msg, int msg_val);
struct std_heap_HeapTraceStats {
  uint64_t alloc_count;
  uint64_t free_count;
  uint64_t realloc_count;
  uint64_t bytes_allocated;
};

struct std_heap_page_mmap_PageMmapHeap {
  uint8_t * base;
  size_t cap;
  size_t off;
};

struct std_heap_page_mmap_LibcArena64 {
  uint8_t * chunk;
  size_t cap;
  size_t off;
};

struct std_heap_libc_LibcArena64 {
  uint8_t * chunk;
  size_t cap;
  size_t off;
};

struct std_io_ReadOnlySlice {
  struct shux_slice_uint8_t data;
};

struct std_io_WriteOnlySlice {
  struct shux_slice_uint8_t data;
};

struct std_io_ReadPtrView {
  uint8_t * ptr;
  int32_t len;
  uint64_t gen;
};

struct std_context_Context {
  int64_t handle;
};

struct std_io_read_ptr_ShuxSliceU8 {
  uint8_t * data;
  size_t length;
};

struct std_io_sync_PollFd {
  int32_t fd;
  int16_t events;
  int16_t revents;
};

struct std_io_sync_IoBatchBuf {
  uint8_t * ptr;
  size_t len;
  size_t handle;
};

enum std_io_driver_IO_Result { std_io_driver_IO_Result_Ok, std_io_driver_IO_Result_Err, std_io_driver_IO_Result_Timeout, std_io_driver_IO_Result_Cancelled };
struct std_heap_Arena64;
struct std_heap_HeapTraceStats;
struct std_heap_Allocator;
struct std_heap_page_mmap_PageMmapHeap;
struct std_heap_page_mmap_LibcArena64;
struct std_heap_libc_LibcArena64;
struct std_io_ReadOnlySlice;
struct std_io_WriteOnlySlice;
struct std_io_ReadPtrView;
struct std_io_Buffer;
struct std_error_Error;
struct std_error_ErrorChain;
struct core_result_Result_i32;
struct core_result_Result_u8;
struct std_context_Context;
struct std_io_read_ptr_ShuxSliceU8;
struct std_io_sync_Iovec;
struct std_io_sync_PollFd;
struct std_io_sync_IoBatchBuf;
struct std_io_driver_Buffer;
struct std_io_driver_Completion;
struct std_io_driver_AsyncContext;
extern int32_t core_mem_placeholder(void);
extern int32_t core_mem_align_of_i32(void);
extern int32_t core_mem_align_of_bool(void);
extern int32_t core_mem_align_of_u8(void);
extern int32_t core_mem_align_of_u32(void);
extern int32_t core_mem_align_of_u64(void);
extern int32_t core_mem_align_of_i64(void);
extern int32_t core_mem_align_of_usize(void);
extern int32_t core_mem_align_of_isize(void);
extern int32_t core_mem_align_of_f32(void);
extern int32_t core_mem_align_of_f64(void);
extern int32_t core_mem_align_of_pointer(void);
extern void core_mem_mem_copy(uint8_t * dst, uint8_t * src, size_t n);
extern void core_mem_mem_set(uint8_t * dst, uint8_t byte, size_t n);
extern void core_mem_mem_move(uint8_t * dst, uint8_t * src, size_t n);
extern int32_t core_mem_mem_compare(uint8_t * a, uint8_t * b, size_t n);
extern void core_mem_mem_zero(uint8_t * dst, size_t n);
extern void core_mem_mem_swap(uint8_t * a, uint8_t * b, size_t n);
extern int core_mem_is_alignment_power_of_two(size_t x);
extern size_t core_mem_align_up(size_t addr, size_t alignment);
extern size_t core_mem_align_down(size_t addr, size_t alignment);
extern uint8_t core_mem_volatile_load_u8(uint8_t * ptr);
extern void core_mem_volatile_store_u8(uint8_t * ptr, uint8_t val);
extern uint16_t core_mem_volatile_load_u16(uint8_t * ptr);
extern void core_mem_volatile_store_u16(uint8_t * ptr, uint16_t val);
extern uint32_t core_mem_volatile_load_u32(uint8_t * ptr);
extern void core_mem_volatile_store_u32(uint8_t * ptr, uint32_t val);
extern void core_mem_compiler_fence(void);
extern void core_mem_fence_acquire(void);
extern void core_mem_fence_release(void);
extern void core_mem_fence_seq_cst(void);
int32_t core_mem_placeholder(void) {
  return 0;
}
int32_t core_mem_align_of_i32(void) {
  return 4;
}
int32_t core_mem_align_of_bool(void) {
  return 1;
}
int32_t core_mem_align_of_u8(void) {
  return 1;
}
int32_t core_mem_align_of_u32(void) {
  return 4;
}
int32_t core_mem_align_of_u64(void) {
  return 8;
}
int32_t core_mem_align_of_i64(void) {
  return 8;
}
int32_t core_mem_align_of_usize(void) {
  return 8;
}
int32_t core_mem_align_of_isize(void) {
  return 8;
}
int32_t core_mem_align_of_f32(void) {
  return 4;
}
int32_t core_mem_align_of_f64(void) {
  return 8;
}
int32_t core_mem_align_of_pointer(void) {
  return 8;
}
void core_mem_mem_copy(uint8_t * dst, uint8_t * src, size_t n) {
  size_t i = 0;
  while ((i < n)) {
    (void)(((dst)[i] = (src)[i]));
    (void)((i = (i + 1)));
  }
  (void)(0);
  return;
}
void core_mem_mem_set(uint8_t * dst, uint8_t byte, size_t n) {
  size_t i = 0;
  while ((i < n)) {
    (void)(((dst)[i] = byte));
    (void)((i = (i + 1)));
  }
  (void)(0);
  return;
}
void core_mem_mem_move(uint8_t * dst, uint8_t * src, size_t n) {
  size_t i = n;
  while ((i > 0)) {
    (void)((i = (i - 1)));
    (void)(((dst)[i] = (src)[i]));
  }
  (void)(0);
  return;
}
int32_t core_mem_mem_compare(uint8_t * a, uint8_t * b, size_t n) {
  size_t i = 0;
  while ((i < n)) {
    if (((a)[i] < (b)[i])) {
      return -(1);
    }
    if (((a)[i] > (b)[i])) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
void core_mem_mem_zero(uint8_t * dst, size_t n) {
  (void)(core_mem_mem_set(dst, 0, n));
}
void core_mem_mem_swap(uint8_t * a, uint8_t * b, size_t n) {
  size_t i = 0;
  while ((i < n)) {
    uint8_t t = (a)[i];
    (void)(((a)[i] = (b)[i]));
    (void)(((b)[i] = t));
    (void)((i = (i + 1)));
  }
  (void)(0);
  return;
}
int core_mem_is_alignment_power_of_two(size_t x) {
  if ((x ==0)) {
    return 0;
  }
  size_t m = (x - 1);
  size_t and_val = (x & m);
  return (and_val ==0);
}
size_t core_mem_align_up(size_t addr, size_t alignment) {
  if ((alignment ==0)) {
    return addr;
  }
  return ((((addr + alignment) - 1) / alignment) * alignment);
}
size_t core_mem_align_down(size_t addr, size_t alignment) {
  if ((alignment ==0)) {
    return addr;
  }
  return ((addr / alignment) * alignment);
}
uint8_t core_mem_volatile_load_u8(uint8_t * ptr) {
  if ((ptr ==0)) {
    return ((uint8_t)(0));
  }
  return (ptr)[0];
}
void core_mem_volatile_store_u8(uint8_t * ptr, uint8_t val) {
  if ((ptr ==0)) {
    return;
  }
  (void)(((ptr)[0] = val));
}
uint16_t core_mem_volatile_load_u16(uint8_t * ptr) {
  if ((ptr ==0)) {
    return ((uint16_t)(0));
  }
  uint16_t * p = ((uint16_t *)(ptr));
  return (p)[0];
}
void core_mem_volatile_store_u16(uint8_t * ptr, uint16_t val) {
  if ((ptr ==0)) {
    return;
  }
  uint16_t * p = ((uint16_t *)(ptr));
  (void)(((p)[0] = val));
}
uint32_t core_mem_volatile_load_u32(uint8_t * ptr) {
  if ((ptr ==0)) {
    return ((uint32_t)(0));
  }
  uint32_t * p = ((uint32_t *)(ptr));
  return (p)[0];
}
void core_mem_volatile_store_u32(uint8_t * ptr, uint32_t val) {
  if ((ptr ==0)) {
    return;
  }
  uint32_t * p = ((uint32_t *)(ptr));
  (void)(((p)[0] = val));
}
void core_mem_compiler_fence(void) {
  (void)(0);
}
void core_mem_fence_acquire(void) {
  (void)(core_mem_compiler_fence());
}
void core_mem_fence_release(void) {
  (void)(core_mem_compiler_fence());
}
void core_mem_fence_seq_cst(void) {
  (void)(core_mem_compiler_fence());
}
extern int32_t std_io_driver_register(ptrdiff_t  buf);
extern int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_Buffer * bufs, uint32_t  nr);
extern int32_t std_io_driver_submit_read(ptrdiff_t  buf, uint32_t  timeout_ms);
extern uint8_t * std_io_driver_driver_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_driver_driver_read_ptr_len(void);
extern uint64_t std_io_driver_driver_read_ptr_gen(void);
extern int32_t std_io_driver_driver_read_ptr_gen_valid(uint64_t saved);
extern int32_t std_io_driver_driver_read_ptr_backend(void);
extern struct shux_slice_uint8_t std_io_driver_driver_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_write(ptrdiff_t  buf, uint32_t  timeout_ms);
extern int32_t std_io_driver_submit_read_batch(struct std_io_Buffer * buffers, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_write_batch(struct std_io_Buffer * buffers, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_read_batch_buf(size_t  handle, struct std_io_Buffer * bufs, int32_t n, uint32_t  timeout_ms);
extern int32_t std_io_driver_submit_write_batch_buf(size_t  handle, struct std_io_Buffer * bufs, int32_t n, uint32_t  timeout_ms);
extern int32_t shux_io_register(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_register_buffers(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern void shux_io_unregister_buffers(void);
extern int32_t shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t shux_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern uint8_t * shux_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_read_ptr_len(void);
extern uint64_t shux_io_read_ptr_gen(void);
extern int32_t shux_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t shux_io_read_ptr_backend(void);
extern struct shux_slice_uint8_t shux_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_submit_read_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_submit_write_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_register_buffers_buf(uint8_t * bufs, int32_t nr);
extern ssize_t shux_io_read_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern ssize_t shux_io_write_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void shux_io_unregister_provided_buffers(void);
extern uint8_t * shux_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t shux_io_provided_buffer_size(void);
extern int32_t shux_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern int32_t shux_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_read_async(void);
extern int32_t shux_io_complete_read_async_slot(int32_t slot);
extern int32_t shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_write_async(void);
extern int32_t shux_io_complete_write_async_slot(int32_t slot);
extern uint32_t shux_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t shux_io_uring_is_available_c(void);
extern int64_t ctx_background_c(void);
extern int64_t ctx_with_cancel_c(int64_t parent);
extern int64_t ctx_with_deadline_c(int64_t parent, int64_t deadline_ns);
extern int64_t ctx_with_timeout_c(int64_t parent, int64_t timeout_ns);
extern void ctx_cancel_c(int64_t handle);
extern int32_t ctx_is_cancelled_c(int64_t handle);
extern int64_t ctx_deadline_ns_c(int64_t handle);
extern int64_t ctx_remaining_ns_c(int64_t handle);
extern int32_t ctx_set_value_c(int64_t handle, uint8_t * key, int64_t value);
extern int32_t ctx_get_value_c(int64_t handle, uint8_t * key, int64_t * out);
extern void ctx_free_c(int64_t handle);
extern int32_t ctx_smoke_c(void);
extern struct std_context_Context std_context_background(void);
extern struct std_context_Context std_context_with_cancel(struct std_context_Context parent);
extern struct std_context_Context std_context_with_deadline(struct std_context_Context parent, int64_t deadline_ns);
extern struct std_context_Context std_context_with_timeout(struct std_context_Context parent, int64_t timeout_ns);
extern void std_context_cancel(struct std_context_Context ctx);
extern int32_t std_context_is_cancelled(struct std_context_Context ctx);
extern int64_t std_context_deadline_ns(struct std_context_Context ctx);
extern int64_t std_context_remaining_ns(struct std_context_Context ctx);
extern int32_t std_context_set_value(struct std_context_Context ctx, uint8_t * key, int64_t value);
extern int32_t std_context_get_value(struct std_context_Context ctx, uint8_t * key, int64_t * out);
extern void std_context_free(struct std_context_Context ctx);
extern int32_t std_error_ok(void);
extern int32_t std_error_code_alloc_fail(void);
extern int32_t std_error_code_invalid(void);
extern int32_t std_error_code_not_found(void);
extern struct std_error_Error std_error_ok_value(void);
extern struct std_error_Error std_error_from_code(int32_t code);
extern int32_t std_error_code(struct std_error_Error e);
extern int32_t std_error_is_ok(struct std_error_Error e);
extern int32_t std_error_is_err(struct std_error_Error e);
extern int32_t std_error_base_io(void);
extern int32_t std_error_io_err_timeout(void);
extern int32_t std_error_io_err_cancelled(void);
extern int32_t std_error_io_err_generic(void);
extern int32_t std_error_base_net(void);
extern int32_t std_error_net_err_timeout(void);
extern int32_t std_error_net_err_cancelled(void);
extern int32_t std_error_net_err_generic(void);
extern int32_t std_error_base_async(void);
extern int32_t std_error_async_err_generic(void);
extern int32_t std_error_base_coll(void);
extern int32_t std_error_coll_err_generic(void);
extern int32_t std_error_base_fs(void);
extern int32_t std_error_fs_err_not_found(void);
extern int32_t std_error_mod_tag_io(void);
extern int32_t std_error_mod_tag_fs(void);
extern int32_t std_error_mod_tag_db(void);
extern int32_t std_error_sidecar_none(void);
extern int32_t std_error_sidecar_errno(void);
extern int32_t std_error_sidecar_db_struct(void);
extern int32_t std_error_code_to_module_base(int32_t code);
extern int32_t std_error_code_in_global_range(int32_t code);
extern int32_t std_error_code_in_module_span(int32_t code, int32_t base);
extern int32_t std_error_code_is_platform_errno(int32_t code);
extern int32_t std_error_mod_tag_from_base(int32_t base);
extern int32_t std_error_mod_base_from_tag(int32_t tag);
extern int32_t std_error_module_sidecar_kind(int32_t tag);
extern int32_t std_error_sem_none(void);
extern int32_t std_error_sem_timeout(void);
extern int32_t std_error_sem_cancelled(void);
extern int32_t std_error_sem_not_found(void);
extern int32_t std_error_http_err_timeout(void);
extern int32_t std_error_http_err_cancelled(void);
extern int32_t std_error_semantic_class(int32_t code);
extern int32_t std_error_is_timeout(int32_t code);
extern int32_t std_error_is_cancelled(int32_t code);
extern int32_t std_error_is_not_found(int32_t code);
extern int32_t std_error_recommend_retry(int32_t code);
extern int32_t std_error_chain_max_depth(void);
extern struct std_error_ErrorChain std_error_chain_empty(void);
extern struct std_error_ErrorChain std_error_chain_from_code(int32_t code);
extern struct std_error_ErrorChain std_error_chain_from_result(struct core_result_Result_i32 r);
extern int32_t std_error_chain_depth(struct std_error_ErrorChain chain);
extern int32_t std_error_chain_root(struct std_error_ErrorChain chain);
extern int32_t std_error_chain_code_at(struct std_error_ErrorChain chain, int32_t idx);
extern int32_t std_error_chain_leaf(struct std_error_ErrorChain chain);
extern struct std_error_ErrorChain std_error_chain_wrap(struct std_error_ErrorChain chain, int32_t wrapper);
extern int32_t std_error_error_module_anchor(void);
extern size_t std_io_stdin(void);
extern size_t std_io_stdout(void);
extern size_t std_io_stderr(void);
extern size_t std_io_from_fd(int32_t fd, int32_t _unused);
extern int32_t std_io_read_usize_u8_ptr_usize_u32(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms);
extern int32_t std_io_write_usize_u8_ptr_usize_u32(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms);
extern int32_t std_io_timeout_from_ctx(struct std_context_Context ctx);
extern int32_t std_io_read_ctx(size_t handle, uint8_t * ptr, size_t len, struct std_context_Context ctx);
extern int32_t std_io_write_ctx(size_t handle, uint8_t * ptr, size_t len, struct std_context_Context ctx);
extern int32_t std_io_read_stdin(uint8_t * ptr, size_t len);
extern uint8_t * std_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_ptr_len(void);
extern uint64_t std_io_ptr_gen(void);
extern int32_t std_io_ptr_valid(uint64_t saved);
extern int32_t std_io_ptr_backend(void);
extern struct std_io_ReadPtrView std_io_ptr_view(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_ptr_view_valid(struct std_io_ReadPtrView v);
extern struct std_io_ReadPtrView std_io_stdin_ptr_view(void);
extern struct shux_slice_uint8_t std_io_ptr_slice(size_t handle, uint32_t timeout_ms);
extern struct shux_slice_uint8_t std_io_stdin_slice(void);
extern uint8_t * std_io_read_stdin_ptr(void);
extern int32_t std_io_write_stdout(uint8_t * ptr, size_t len);
extern int32_t std_io_write_stderr_u8_ptr_usize(uint8_t * ptr, size_t len);
extern int32_t std_io_read_u8_ptr_usize_u32(uint8_t * ptr, size_t len, uint32_t timeout_ms);
extern int32_t std_io_write_u8_ptr_usize_u32(uint8_t * ptr, size_t len, uint32_t timeout_ms);
extern int32_t std_io_write_stderr_u8_ptr_usize_u32(uint8_t * ptr, size_t len, uint32_t timeout_ms);
extern int32_t std_io_read_fd(int32_t fd, uint8_t * ptr, size_t len);
extern int32_t std_io_write_fd(int32_t fd, uint8_t * ptr, size_t len);
extern int32_t std_io_read_batch_fd(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n);
extern int32_t std_io_write_batch_fd(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n);
extern int32_t std_io_readv(int32_t fd, struct std_io_Buffer * buffers, int32_t n);
extern int32_t std_io_writev(int32_t fd, struct std_io_Buffer * buffers, int32_t n);
extern int32_t std_io_print_u8_ptr_usize(uint8_t * ptr, size_t  len);
extern int32_t std_io_register_buffers_u8_ptr_usize_u8_ptr_usize_u8_ptr_usize_u8_ptr_usize_u32(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern int32_t std_io_register_buffers_Buffer_ptr_u32(struct std_io_Buffer * bufs, uint32_t nr);
extern int32_t std_io_read_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_write_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_register_provided(uint32_t nr, uint32_t bufsz);
extern void std_io_unregister_provided(void);
extern uint8_t * std_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t std_io_provided_buffer_size(void);
extern int32_t std_io_read_provided_fd(int32_t fd, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern int32_t std_io_read_batch_provided_fd(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t std_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_read_async(size_t handle, uint8_t * ptr, size_t len);
extern int32_t std_io_complete_read(void);
extern int32_t std_io_complete_read_i32(int32_t slot);
extern int32_t std_io_write_async(size_t handle, uint8_t * ptr, size_t len);
extern int32_t std_io_complete_write(void);
extern int32_t std_io_complete_write_i32(int32_t slot);
extern uint32_t std_io_poll_completions(uint32_t timeout_ms);
extern int32_t std_io_uring_ok(void);
extern int32_t std_io_read_slice(struct shux_slice_uint8_t buf, uint32_t timeout_ms);
extern int32_t std_io_write_slice(struct shux_slice_uint8_t buf, uint32_t timeout_ms);
extern int32_t std_io_print_i64_nl(int64_t v);
extern int32_t std_io_print_i32(int32_t x);
extern int32_t std_io_print_u32(uint32_t x);
extern int32_t std_io_print_i64(int64_t x);
extern int32_t std_io_io_module_anchor(void);
static const int32_t IO_CTX_MS_CANCELLED = -(1);
static const int32_t IO_CTX_MS_EXPIRED = -(2);
static const int32_t IO_ASYNC_NOT_READY = -(2);
size_t std_io_stdin(void) {
  return ((size_t)(0));
}
size_t std_io_stdout(void) {
  return 1;
}
size_t std_io_stderr(void) {
  return 2;
}
size_t std_io_from_fd(int32_t fd, int32_t _unused) {
  return ((size_t)(fd));
}
int32_t std_io_read_usize_u8_ptr_usize_u32(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  struct std_io_Buffer buf = (struct std_io_driver_Buffer){ .ptr = ptr, .len = len, .handle = handle };
  return shux_io_submit_read_buf((intptr_t)(void*)&buf, timeout_ms);
}
int32_t std_io_write_usize_u8_ptr_usize_u32(size_t handle, uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  struct std_io_Buffer buf = (struct std_io_driver_Buffer){ .ptr = ptr, .len = len, .handle = handle };
  return shux_io_submit_write_buf((intptr_t)(void*)&buf, timeout_ms);
}
int32_t std_io_timeout_from_ctx(struct std_context_Context ctx) {
  if ((std_context_is_cancelled(ctx) !=0)) {
    return IO_CTX_MS_CANCELLED;
  }
  int64_t rem = std_context_remaining_ns(ctx);
  int64_t dl = std_context_deadline_ns(ctx);
  if (((dl > 0) && (rem <=0))) {
    return IO_CTX_MS_EXPIRED;
  }
  if ((rem <=0)) {
    return 0;
  }
  int64_t ms = (rem / 1000000);
  if ((ms <=0)) {
    return 1;
  }
  if ((ms > 2147483647)) {
    return 2147483647;
  }
  return ((int32_t)(ms));
}
int32_t std_io_read_ctx(size_t handle, uint8_t * ptr, size_t len, struct std_context_Context ctx) {
  int32_t tm = std_io_timeout_from_ctx(ctx);
  if ((tm ==IO_CTX_MS_CANCELLED)) {
    return std_error_io_err_cancelled();
  }
  if ((tm ==IO_CTX_MS_EXPIRED)) {
    return std_error_io_err_timeout();
  }
  return std_io_read_usize_u8_ptr_usize_u32(handle, ptr, len, ((uint32_t)(tm)));
}
int32_t std_io_write_ctx(size_t handle, uint8_t * ptr, size_t len, struct std_context_Context ctx) {
  int32_t tm = std_io_timeout_from_ctx(ctx);
  if ((tm ==IO_CTX_MS_CANCELLED)) {
    return std_error_io_err_cancelled();
  }
  if ((tm ==IO_CTX_MS_EXPIRED)) {
    return std_error_io_err_timeout();
  }
  return std_io_write_usize_u8_ptr_usize_u32(handle, ptr, len, ((uint32_t)(tm)));
}
int32_t std_io_read_stdin(uint8_t * ptr, size_t len) {
  return std_io_read_usize_u8_ptr_usize_u32(std_io_stdin(), ptr, len, ((uint32_t)(0)));
}
uint8_t * std_io_read_ptr(size_t handle, uint32_t timeout_ms) {
  return std_io_driver_driver_read_ptr(handle, timeout_ms);
}
int32_t std_io_ptr_len(void) {
  return std_io_driver_driver_read_ptr_len();
}
uint64_t std_io_ptr_gen(void) {
  return std_io_driver_driver_read_ptr_gen();
}
int32_t std_io_ptr_valid(uint64_t saved) {
  return std_io_driver_driver_read_ptr_gen_valid(saved);
}
int32_t std_io_ptr_backend(void) {
  return std_io_driver_driver_read_ptr_backend();
}
struct std_io_ReadPtrView std_io_ptr_view(size_t handle, uint32_t timeout_ms) {
  uint8_t * p = std_io_read_ptr(handle, timeout_ms);
  int32_t n = std_io_ptr_len();
  uint64_t g = std_io_ptr_gen();
  return (struct std_io_ReadPtrView){ .ptr = p, .len = n, .gen = g };
}
int32_t std_io_ptr_view_valid(struct std_io_ReadPtrView v) {
  if (((v.ptr) ==0)) {
    return 0;
  }
  return std_io_ptr_valid((v.gen));
}
struct std_io_ReadPtrView std_io_stdin_ptr_view(void) {
  return std_io_ptr_view(std_io_stdin(), ((uint32_t)(0)));
}
struct shux_slice_uint8_t std_io_ptr_slice(size_t handle, uint32_t timeout_ms) {
  return std_io_driver_driver_read_ptr_slice(handle, timeout_ms);
}
struct shux_slice_uint8_t std_io_stdin_slice(void) {
  return std_io_driver_driver_read_ptr_slice(std_io_stdin(), ((uint32_t)(0)));
}
uint8_t * std_io_read_stdin_ptr(void) {
  return std_io_read_ptr(std_io_stdin(), ((uint32_t)(0)));
}
int32_t std_io_write_stdout(uint8_t * ptr, size_t len) {
  return std_io_write_usize_u8_ptr_usize_u32(std_io_stdout(), ptr, len, ((uint32_t)(0)));
}
int32_t std_io_write_stderr_u8_ptr_usize(uint8_t * ptr, size_t len) {
  return std_io_write_usize_u8_ptr_usize_u32(std_io_stderr(), ptr, len, ((uint32_t)(0)));
}
int32_t std_io_read_u8_ptr_usize_u32(uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  return std_io_read_usize_u8_ptr_usize_u32(std_io_stdin(), ptr, len, timeout_ms);
}
int32_t std_io_write_u8_ptr_usize_u32(uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  return std_io_write_usize_u8_ptr_usize_u32(std_io_stdout(), ptr, len, timeout_ms);
}
int32_t std_io_write_stderr_u8_ptr_usize_u32(uint8_t * ptr, size_t len, uint32_t timeout_ms) {
  return std_io_write_usize_u8_ptr_usize_u32(std_io_stderr(), ptr, len, timeout_ms);
}
int32_t std_io_read_fd(int32_t fd, uint8_t * ptr, size_t len) {
  return std_io_read_usize_u8_ptr_usize_u32(std_io_from_fd(fd, 0), ptr, len, ((uint32_t)(0)));
}
int32_t std_io_write_fd(int32_t fd, uint8_t * ptr, size_t len) {
  return std_io_write_usize_u8_ptr_usize_u32(std_io_from_fd(fd, 0), ptr, len, ((uint32_t)(0)));
}
int32_t std_io_read_batch_fd(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n) {
  size_t h = std_io_from_fd(fd, 0);
  struct std_io_Buffer bufs[4] = {(struct std_io_driver_Buffer){ .ptr = p0, .len = l0, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p1, .len = l1, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p2, .len = l2, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p3, .len = l3, .handle = h }};
  return std_io_driver_submit_read_batch(bufs, n, ((uint32_t)(0)));
}
int32_t std_io_write_batch_fd(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n) {
  size_t h = std_io_from_fd(fd, 0);
  struct std_io_Buffer bufs[4] = {(struct std_io_driver_Buffer){ .ptr = p0, .len = l0, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p1, .len = l1, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p2, .len = l2, .handle = h }, (struct std_io_driver_Buffer){ .ptr = p3, .len = l3, .handle = h }};
  return std_io_driver_submit_write_batch(bufs, n, ((uint32_t)(0)));
}
int32_t std_io_readv(int32_t fd, struct std_io_Buffer * buffers, int32_t n) {
  size_t h = std_io_from_fd(fd, 0);
  return std_io_driver_submit_read_batch_buf(h, buffers, n, ((uint32_t)(0)));
}
int32_t std_io_writev(int32_t fd, struct std_io_Buffer * buffers, int32_t n) {
  size_t h = std_io_from_fd(fd, 0);
  return std_io_driver_submit_write_batch_buf(h, buffers, n, ((uint32_t)(0)));
}
int32_t std_io_print_u8_ptr_usize(uint8_t * ptr, size_t  len) {
  return std_io_write_stdout(ptr, len);
}
int32_t std_io_register_buffers_u8_ptr_usize_u8_ptr_usize_u8_ptr_usize_u8_ptr_usize_u32(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr) {
  return std_io_core_shux_io_register_buffers(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}
int32_t std_io_register_buffers_Buffer_ptr_u32(struct std_io_Buffer * bufs, uint32_t nr) {
  return std_io_driver_submit_register_fixed_buffers_buf(bufs, nr);
}
int32_t std_io_read_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  return std_io_core_shux_io_read_fixed(std_io_from_fd(fd, 0), buf_index, offset, len, timeout_ms);
}
int32_t std_io_write_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  return std_io_core_shux_io_write_fixed(std_io_from_fd(fd, 0), buf_index, offset, len, timeout_ms);
}
int32_t std_io_register_provided(uint32_t nr, uint32_t bufsz) {
  return std_io_core_shux_io_register_provided_buffers(nr, bufsz);
}
uint32_t std_io_provided_buffer_size(void) {
  return std_io_core_shux_io_provided_buffer_size();
}
int32_t std_io_read_provided_fd(int32_t fd, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len) {
  return std_io_core_shux_io_read_provided(std_io_from_fd(fd, 0), timeout_ms, out_bid, out_len);
}
int32_t std_io_read_batch_provided_fd(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens) {
  return std_io_core_shux_io_read_batch_provided(std_io_from_fd(fd, 0), n, timeout_ms, out_bids, out_lens);
}
int32_t std_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms) {
  return std_io_core_shux_io_wait_readable(fds, n, timeout_ms);
}
int32_t std_io_read_async(size_t handle, uint8_t * ptr, size_t len) {
  return std_io_core_shux_io_submit_read_async(ptr, len, handle);
}
int32_t std_io_complete_read(void) {
  return std_io_core_shux_io_complete_read_async();
}
int32_t std_io_complete_read_i32(int32_t slot) {
  return std_io_core_shux_io_complete_read_async_slot(slot);
}
int32_t std_io_write_async(size_t handle, uint8_t * ptr, size_t len) {
  return std_io_core_shux_io_submit_write_async(ptr, len, handle);
}
int32_t std_io_complete_write(void) {
  return std_io_core_shux_io_complete_write_async();
}
int32_t std_io_complete_write_i32(int32_t slot) {
  return std_io_core_shux_io_complete_write_async_slot(slot);
}
uint32_t std_io_poll_completions(uint32_t timeout_ms) {
  return std_io_core_shux_io_poll_async_completions(timeout_ms);
}
int32_t std_io_uring_ok(void) {
  return std_io_core_shux_io_uring_is_available_c();
}
int32_t std_io_read_slice(struct shux_slice_uint8_t buf, uint32_t timeout_ms) {
  return std_io_read_usize_u8_ptr_usize_u32(std_io_stdin(), (buf.data), (buf.length), timeout_ms);
}
int32_t std_io_write_slice(struct shux_slice_uint8_t buf, uint32_t timeout_ms) {
  return std_io_write_usize_u8_ptr_usize_u32(std_io_stdout(), (buf.data), (buf.length), timeout_ms);
}
int32_t std_io_print_i64_nl(int64_t v) {
  uint8_t buf[24] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  uint8_t tmp[24] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  int32_t n = 0;
  int32_t pos = 0;
  int64_t x = v;
  if ((x ==0)) {
    int32_t _w0 = std_io_write_stdout(&((buf)[0]), ((size_t)(2)));
    (void)(((buf)[0] = ((uint8_t)(48))));
    (void)(((buf)[1] = ((uint8_t)(10))));
    return 0;
  }
  if ((x < 0)) {
    (void)(((buf)[0] = ((uint8_t)(45))));
    (void)((pos = 1));
    (void)((x = (((int64_t)(0)) - x)));
  }
  while ((x > 0)) {
    (void)(((tmp)[n] = ((uint8_t)((48 + (x % ((int64_t)(10))))))));
    (void)((n = (n + 1)));
    (void)((x = (x / ((int64_t)(10)))));
  }
  while ((n > 0)) {
    (void)((n = (n - 1)));
    (void)(((buf)[pos] = (tmp)[n]));
    (void)((pos = (pos + 1)));
  }
  (void)(((buf)[pos] = ((uint8_t)(10))));
  (void)((pos = (pos + 1)));
  int32_t _w = std_io_write_stdout(&((buf)[0]), ((size_t)(pos)));
  return 0;
}
int32_t std_io_print_i32(int32_t x) {
  return std_io_print_i64_nl(((int64_t)(x)));
}
int32_t std_io_print_u32(uint32_t x) {
  return std_io_print_i64_nl(((int64_t)(x)));
}
int32_t std_io_print_i64(int64_t x) {
  return std_io_print_i64_nl(x);
}
int32_t std_io_io_module_anchor(void) {
  return 0;
}
extern struct core_result_Result_i32 core_result_ok(int32_t x);
extern struct core_result_Result_i32 core_result_err(int32_t e);
extern int32_t core_result_unwrap_or(struct core_result_Result_i32 r, int32_t default_val);
extern int core_result_is_ok(struct core_result_Result_i32 r);
extern int core_result_is_ok_gen(struct core_result_Result_i32 r);
extern int32_t core_result_unwrap_or_gen(struct core_result_Result_i32 r, int32_t default_val);
extern int core_result_is_err(struct core_result_Result_i32 r);
extern int32_t core_result_expect(struct core_result_Result_i32 r, int32_t default_val);
extern int32_t core_result_expect_or_panic(struct core_result_Result_i32 r);
extern struct core_result_Result_i32 core_result_or(struct core_result_Result_i32 r, struct core_result_Result_i32 other);
extern struct core_result_Result_i32 core_result_and(struct core_result_Result_i32 r, struct core_result_Result_i32 other);
extern struct core_result_Result_i32 core_result_map(struct core_result_Result_i32 r, int32_t mapped);
extern struct core_result_Result_i32 core_result_and_then(struct core_result_Result_i32 r, struct core_result_Result_i32 next);
extern struct core_result_Result_i32 core_result_or_else(struct core_result_Result_i32 r, struct core_result_Result_i32 other);
extern struct core_result_Result_u8 core_result_ok_u8(uint8_t x);
extern struct core_result_Result_u8 core_result_err_u8(int32_t e);
extern uint8_t core_result_unwrap_or_u8(struct core_result_Result_u8 r, uint8_t default_val);
extern int core_result_is_ok_u8(struct core_result_Result_u8 r);
extern int core_result_is_err_u8(struct core_result_Result_u8 r);
extern uint8_t core_result_expect_u8_or_panic(struct core_result_Result_u8 r);
extern struct core_result_Result_u8 core_result_map_u8(struct core_result_Result_u8 r, uint8_t mapped);
extern struct core_result_Result_u8 core_result_or_else_u8(struct core_result_Result_u8 r, struct core_result_Result_u8 other);
extern struct core_result_Result_i32 core_result_ok_i32(int32_t x);
extern struct core_result_Result_i32 core_result_err_i32(int32_t e);
extern int32_t core_result_unwrap_or_i32(struct core_result_Result_i32 r, int32_t default_val);
extern int core_result_is_ok_i32(struct core_result_Result_i32 r);
extern int core_result_is_err_i32(struct core_result_Result_i32 r);
extern int32_t core_result_expect_i32(struct core_result_Result_i32 r, int32_t default_val);
extern int32_t core_result_expect_i32_or_panic(struct core_result_Result_i32 r);
extern struct core_result_Result_i32 core_result_or_i32(struct core_result_Result_i32 r, struct core_result_Result_i32 other);
extern struct core_result_Result_i32 core_result_and_i32(struct core_result_Result_i32 r, struct core_result_Result_i32 other);
extern struct core_result_Result_i32 core_result_map_i32(struct core_result_Result_i32 r, int32_t mapped);
extern struct core_result_Result_i32 core_result_and_then_i32(struct core_result_Result_i32 r, struct core_result_Result_i32 next);
extern struct core_result_Result_i32 core_result_or_else_i32(struct core_result_Result_i32 r, struct core_result_Result_i32 other);
extern int32_t core_result_result_module_anchor(void);
struct core_result_Result_i32 core_result_ok(int32_t x) {
  return (struct core_result_Result_i32){ .value = x, ._pad1 = 0, .err = 0, ._pad2 = 0 };
}
struct core_result_Result_i32 core_result_err(int32_t e) {
  return (struct core_result_Result_i32){ .value = 0, ._pad1 = 0, .err = e, ._pad2 = 0 };
}
int32_t core_result_unwrap_or(struct core_result_Result_i32 r, int32_t default_val) {
  if (((r.err) ==0)) {
    return (r.value);
  }
  return default_val;
}
int core_result_is_ok(struct core_result_Result_i32 r) {
  return ((r.err) ==0);
}
int core_result_is_ok_gen(struct core_result_Result_i32 r) {
  return core_result_is_ok(r);
}
int32_t core_result_unwrap_or_gen(struct core_result_Result_i32 r, int32_t default_val) {
  return core_result_unwrap_or(r, default_val);
}
int core_result_is_err(struct core_result_Result_i32 r) {
  return ((r.err) !=0);
}
int32_t core_result_expect(struct core_result_Result_i32 r, int32_t default_val) {
  if (((r.err) ==0)) {
    return (r.value);
  }
  return default_val;
}
int32_t core_result_expect_or_panic(struct core_result_Result_i32 r) {
  if (((r.err) ==0)) {
    return (r.value);
  }
  shux_panic_(0,0);
}
struct core_result_Result_i32 core_result_or(struct core_result_Result_i32 r, struct core_result_Result_i32 other) {
  if (((r.err) ==0)) {
    return r;
  }
  return other;
}
struct core_result_Result_i32 core_result_and(struct core_result_Result_i32 r, struct core_result_Result_i32 other) {
  if (((r.err) !=0)) {
    return r;
  }
  return other;
}
struct core_result_Result_i32 core_result_map(struct core_result_Result_i32 r, int32_t mapped) {
  if (core_result_is_ok(r)) {
    return core_result_ok(mapped);
  }
  return r;
}
struct core_result_Result_i32 core_result_and_then(struct core_result_Result_i32 r, struct core_result_Result_i32 next) {
  if (core_result_is_ok(r)) {
    return next;
  }
  return r;
}
struct core_result_Result_i32 core_result_or_else(struct core_result_Result_i32 r, struct core_result_Result_i32 other) {
  if (core_result_is_err(r)) {
    return other;
  }
  return r;
}
struct core_result_Result_u8 core_result_ok_u8(uint8_t x) {
  return (struct core_result_Result_u8){ .value = x, ._pad1 = 0, ._pad2 = 0, ._pad3 = 0, .err = 0, ._pad4 = 0 };
}
struct core_result_Result_u8 core_result_err_u8(int32_t e) {
  return (struct core_result_Result_u8){ .value = 0, ._pad1 = 0, ._pad2 = 0, ._pad3 = 0, .err = e, ._pad4 = 0 };
}
uint8_t core_result_unwrap_or_u8(struct core_result_Result_u8 r, uint8_t default_val) {
  if (((r.err) ==0)) {
    return (r.value);
  }
  return default_val;
}
int core_result_is_ok_u8(struct core_result_Result_u8 r) {
  return ((r.err) ==0);
}
int core_result_is_err_u8(struct core_result_Result_u8 r) {
  return ((r.err) !=0);
}
uint8_t core_result_expect_u8_or_panic(struct core_result_Result_u8 r) {
  if (((r.err) ==0)) {
    return (r.value);
  }
  shux_panic_(0,0);
}
struct core_result_Result_u8 core_result_map_u8(struct core_result_Result_u8 r, uint8_t mapped) {
  if (core_result_is_ok_u8(r)) {
    return core_result_ok_u8(mapped);
  }
  return r;
}
struct core_result_Result_u8 core_result_or_else_u8(struct core_result_Result_u8 r, struct core_result_Result_u8 other) {
  if (core_result_is_err_u8(r)) {
    return other;
  }
  return r;
}
struct core_result_Result_i32 core_result_ok_i32(int32_t x) {
  return core_result_ok(x);
}
struct core_result_Result_i32 core_result_err_i32(int32_t e) {
  return core_result_err(e);
}
int32_t core_result_unwrap_or_i32(struct core_result_Result_i32 r, int32_t default_val) {
  return core_result_unwrap_or(r, default_val);
}
int core_result_is_ok_i32(struct core_result_Result_i32 r) {
  return core_result_is_ok(r);
}
int core_result_is_err_i32(struct core_result_Result_i32 r) {
  return core_result_is_err(r);
}
int32_t core_result_expect_i32(struct core_result_Result_i32 r, int32_t default_val) {
  return core_result_expect(r, default_val);
}
int32_t core_result_expect_i32_or_panic(struct core_result_Result_i32 r) {
  return core_result_expect_or_panic(r);
}
struct core_result_Result_i32 core_result_or_i32(struct core_result_Result_i32 r, struct core_result_Result_i32 other) {
  return core_result_or(r, other);
}
struct core_result_Result_i32 core_result_and_i32(struct core_result_Result_i32 r, struct core_result_Result_i32 other) {
  return core_result_and(r, other);
}
struct core_result_Result_i32 core_result_map_i32(struct core_result_Result_i32 r, int32_t mapped) {
  return core_result_map(r, mapped);
}
struct core_result_Result_i32 core_result_and_then_i32(struct core_result_Result_i32 r, struct core_result_Result_i32 next) {
  return core_result_and_then(r, next);
}
struct core_result_Result_i32 core_result_or_else_i32(struct core_result_Result_i32 r, struct core_result_Result_i32 other) {
  return core_result_or_else(r, other);
}
int32_t core_result_result_module_anchor(void) {
  return 0;
}
extern struct std_context_Context std_context_background(void);
extern struct std_context_Context std_context_with_cancel(struct std_context_Context parent);
extern struct std_context_Context std_context_with_deadline(struct std_context_Context parent, int64_t deadline_ns);
extern struct std_context_Context std_context_with_timeout(struct std_context_Context parent, int64_t timeout_ns);
extern void std_context_cancel(struct std_context_Context ctx);
extern int32_t std_context_is_cancelled(struct std_context_Context ctx);
extern int64_t std_context_deadline_ns(struct std_context_Context ctx);
extern int64_t std_context_remaining_ns(struct std_context_Context ctx);
extern int32_t std_context_set_value(struct std_context_Context ctx, uint8_t * key, int64_t value);
extern int32_t std_context_get_value(struct std_context_Context ctx, uint8_t * key, int64_t * out);
extern void std_context_free(struct std_context_Context ctx);
static const int32_t CTX_OK = 0;
static const int32_t CTX_ERR_NULL = -(1);
static const int32_t CTX_CANCELLED = -(2);
static const int32_t CTX_DEADLINE = -(3);
extern int64_t ctx_background_c(void);
extern int64_t ctx_with_cancel_c(int64_t parent);
extern int64_t ctx_with_deadline_c(int64_t parent, int64_t deadline_ns);
extern int64_t ctx_with_timeout_c(int64_t parent, int64_t timeout_ns);
extern void ctx_cancel_c(int64_t handle);
extern int32_t ctx_is_cancelled_c(int64_t handle);
extern int64_t ctx_deadline_ns_c(int64_t handle);
extern int64_t ctx_remaining_ns_c(int64_t handle);
extern int32_t ctx_set_value_c(int64_t handle, uint8_t * key, int64_t value);
extern int32_t ctx_get_value_c(int64_t handle, uint8_t * key, int64_t * out);
extern void ctx_free_c(int64_t handle);
extern int32_t ctx_smoke_c(void);
extern ssize_t std_io_backend_io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_read_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_write_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_read_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_write_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_io_register_buffer(uint8_t * ptr, size_t len);
extern int32_t std_io_backend_io_register_buffers_4(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern int32_t std_io_backend_io_register_buffers_buf(uint8_t * bufs, int32_t nr);
extern void std_io_backend_io_unregister_buffers(void);
extern ssize_t std_io_backend_io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_backend_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern uint8_t * std_io_backend_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_backend_io_read_ptr_len(void);
extern uint64_t std_io_backend_io_read_ptr_gen(void);
extern int32_t std_io_backend_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t std_io_backend_io_read_ptr_backend(void);
extern struct shux_slice_uint8_t std_io_backend_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_backend_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void std_io_backend_io_unregister_provided_buffers(void);
extern uint8_t * std_io_backend_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t std_io_backend_io_provided_buffer_size(void);
extern ssize_t std_io_backend_io_read_provided(int32_t fd, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern ssize_t std_io_backend_io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t std_io_backend_shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_backend_shux_io_complete_read_async(void);
extern int32_t std_io_backend_shux_io_complete_read_async_slot(int32_t slot);
extern int32_t std_io_backend_shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_backend_shux_io_complete_write_async(void);
extern int32_t std_io_backend_shux_io_complete_write_async_slot(int32_t slot);
extern uint32_t std_io_backend_shux_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_uring_is_available_c(void);
extern int32_t std_io_backend_shux_io_register(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_backend_shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern uint8_t * std_io_backend_shux_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_read_ptr_len(void);
extern uint64_t std_io_backend_shux_io_read_ptr_gen(void);
extern int32_t std_io_backend_shux_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t std_io_backend_shux_io_read_ptr_backend(void);
extern struct std_io_read_ptr_ShuxSliceU8 std_io_backend_shux_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern size_t std_io_backend_handle_from_fd(int32_t fd, int32_t _unused);
extern int32_t std_io_backend_shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_submit_read_batch(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_submit_write_batch(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_submit_read_batch_buf(size_t handle, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_submit_write_batch_buf(size_t handle, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_submit_register_fixed_buffers_buf(uint8_t * bufs, uint32_t nr);
extern int32_t std_io_backend_shux_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void std_io_backend_shux_io_unregister_provided_buffers(void);
extern uint8_t * std_io_backend_shux_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t std_io_backend_shux_io_provided_buffer_size(void);
extern int32_t std_io_backend_shux_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t std_io_backend_shux_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern int32_t std_io_backend_io_backend_anchor(void);
extern int32_t shux_io_register(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_register_buffers(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern void shux_io_unregister_buffers(void);
extern int32_t shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t shux_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern uint8_t * shux_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_read_ptr_len(void);
extern uint64_t shux_io_read_ptr_gen(void);
extern int32_t shux_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t shux_io_read_ptr_backend(void);
extern struct shux_slice_uint8_t shux_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_submit_read_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_submit_write_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_register_buffers_buf(uint8_t * bufs, int32_t nr);
extern ssize_t shux_io_read_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern ssize_t shux_io_write_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void shux_io_unregister_provided_buffers(void);
extern uint8_t * shux_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t shux_io_provided_buffer_size(void);
extern int32_t shux_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern int32_t shux_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_read_async(void);
extern int32_t shux_io_complete_read_async_slot(int32_t slot);
extern int32_t shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_write_async(void);
extern int32_t shux_io_complete_write_async_slot(int32_t slot);
extern uint32_t shux_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t shux_io_uring_is_available_c(void);
int32_t shux_io_register(uint8_t * ptr, size_t len, size_t handle) {
  if ((handle >=0)) {
  }
  return std_io_backend_io_register_buffer(ptr, len);
}
void shux_io_unregister_buffers(void) {
  (void)(std_io_backend_io_unregister_buffers());
}
int32_t shux_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms) {
  return std_io_backend_io_wait_readable(fds, n, timeout_ms);
}
uint8_t * shux_io_read_ptr(size_t handle, uint32_t timeout_ms) {
  return std_io_backend_io_read_ptr(handle, timeout_ms);
}
int32_t shux_io_read_ptr_len(void) {
  return std_io_backend_io_read_ptr_len();
}
uint64_t shux_io_read_ptr_gen(void) {
  return std_io_backend_io_read_ptr_gen();
}
int32_t shux_io_read_ptr_gen_valid(uint64_t saved) {
  return std_io_backend_io_read_ptr_gen_valid(saved);
}
struct shux_slice_uint8_t shux_io_read_ptr_slice(size_t handle, uint32_t timeout_ms) {
  return std_io_backend_io_read_ptr_slice(handle, timeout_ms);
}
int32_t shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms) {
  int32_t fd = ((int32_t)(handle));
  if ((handle >=1)) {
    ssize_t r = std_io_backend_io_write(fd, ptr, len, timeout_ms);
    if ((r < 0)) {
      return -(1);
    }
    return ((int32_t)(r));
  }
  return -(1);
}
int32_t shux_io_submit_write_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms) {
  int32_t fd = ((int32_t)(handle));
  if ((handle >=1)) {
    ssize_t r = std_io_backend_io_write_batch(fd, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, n, timeout_ms);
    if ((r < 0)) {
      return -(1);
    }
    return ((int32_t)(r));
  }
  return -(1);
}
int32_t shux_io_register_buffers_buf(uint8_t * bufs, int32_t nr) {
  return std_io_backend_io_register_buffers_buf(bufs, nr);
}
ssize_t shux_io_read_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms) {
  return std_io_backend_io_read_batch_buf(fd, bufs, n, timeout_ms);
}
ssize_t shux_io_write_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms) {
  return std_io_backend_io_write_batch_buf(fd, bufs, n, timeout_ms);
}
int32_t shux_io_register_provided_buffers(uint32_t nr, uint32_t bufsz) {
  return std_io_backend_io_register_provided_buffers(nr, bufsz);
}
void shux_io_unregister_provided_buffers(void) {
  (void)(std_io_backend_io_unregister_provided_buffers());
}
uint8_t * shux_io_provided_buffer_ptr(uint32_t bid) {
  return std_io_backend_io_provided_buffer_ptr(bid);
}
uint32_t shux_io_provided_buffer_size(void) {
  return std_io_backend_io_provided_buffer_size();
}
int32_t shux_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len) {
  int32_t fd = ((int32_t)(handle));
  if (((handle ==0) || (handle >=2))) {
    ssize_t r = std_io_backend_io_read_provided(fd, timeout_ms, out_bid, out_len);
    if ((r < 0)) {
      return -(1);
    }
    return ((int32_t)(r));
  }
  return -(1);
}
int32_t shux_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens) {
  int32_t fd = ((int32_t)(handle));
  if (((handle ==0) || (handle >=2))) {
    ssize_t r = std_io_backend_io_read_batch_provided(fd, n, timeout_ms, out_bids, out_lens);
    if ((r < 0)) {
      return -(1);
    }
    return ((int32_t)(r));
  }
  return -(1);
}
int32_t shux_io_complete_read_async(void) {
  return std_io_backend_shux_io_complete_read_async();
}
int32_t shux_io_complete_read_async_slot(int32_t slot) {
  return std_io_backend_shux_io_complete_read_async_slot(slot);
}
int32_t shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle) {
  return std_io_backend_shux_io_submit_write_async(ptr, len, handle);
}
int32_t shux_io_complete_write_async(void) {
  return std_io_backend_shux_io_complete_write_async();
}
int32_t shux_io_complete_write_async_slot(int32_t slot) {
  return std_io_backend_shux_io_complete_write_async_slot(slot);
}
uint32_t shux_io_poll_async_completions(uint32_t timeout_ms) {
  return std_io_backend_shux_io_poll_async_completions(timeout_ms);
}
int32_t shux_io_uring_is_available_c(void) {
  return std_io_backend_shux_io_uring_is_available_c();
}
extern ssize_t shux_sys_read(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t shux_sys_write(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t shux_sys_readv(int32_t fd, uint8_t * iov, int32_t iovcnt);
extern ssize_t shux_sys_writev(int32_t fd, uint8_t * iov, int32_t iovcnt);
extern int32_t shux_sys_poll(uint8_t * fds, int32_t nfds, int32_t timeout);
extern ssize_t std_io_sync_io_libc_read(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t std_io_sync_io_libc_write(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t std_io_sync_io_libc_readv(int32_t fd, struct std_io_sync_Iovec * iov, int32_t iovcnt);
extern ssize_t std_io_sync_io_libc_writev(int32_t fd, struct std_io_sync_Iovec * iov, int32_t iovcnt);
extern int32_t std_io_sync_io_libc_poll(struct std_io_sync_PollFd * fds, int32_t nfds, int32_t timeout);
extern ssize_t std_io_sync_io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_read_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_read_batch_buf(int32_t fd, struct std_io_sync_IoBatchBuf * bufs, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_batch_buf(int32_t fd, struct std_io_sync_IoBatchBuf * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_sync_io_register_buffer(uint8_t * ptr, size_t len);
extern int32_t std_io_sync_io_register_buffers_4(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern int32_t std_io_sync_io_register_buffers_buf(struct std_io_sync_IoBatchBuf * bufs, int32_t nr);
extern void std_io_sync_io_unregister_buffers(void);
extern ssize_t std_io_sync_io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_sync_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern uint8_t * std_io_read_ptr_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_read_ptr_io_read_ptr_len(void);
extern uint64_t std_io_read_ptr_io_read_ptr_gen(void);
extern int32_t std_io_read_ptr_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t std_io_read_ptr_io_read_ptr_backend(void);
extern struct std_io_read_ptr_ShuxSliceU8 std_io_read_ptr_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_stubs_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void std_io_stubs_io_unregister_provided_buffers(void);
extern uint8_t * std_io_stubs_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t std_io_stubs_io_provided_buffer_size(void);
extern ssize_t std_io_stubs_io_read_provided(int32_t fd, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern ssize_t std_io_stubs_io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t std_io_stubs_shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_stubs_shux_io_complete_read_async(void);
extern int32_t std_io_stubs_shux_io_complete_read_async_slot(int32_t slot);
extern int32_t std_io_stubs_shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_stubs_shux_io_complete_write_async(void);
extern int32_t std_io_stubs_shux_io_complete_write_async_slot(int32_t slot);
extern uint32_t std_io_stubs_shux_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t std_io_stubs_shux_io_uring_is_available_c(void);
extern ssize_t std_io_backend_io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_read_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_write_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_read_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_write_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_io_register_buffer(uint8_t * ptr, size_t len);
extern int32_t std_io_backend_io_register_buffers_4(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern int32_t std_io_backend_io_register_buffers_buf(uint8_t * bufs, int32_t nr);
extern void std_io_backend_io_unregister_buffers(void);
extern ssize_t std_io_backend_io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern ssize_t std_io_backend_io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_backend_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern uint8_t * std_io_backend_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_backend_io_read_ptr_len(void);
extern uint64_t std_io_backend_io_read_ptr_gen(void);
extern int32_t std_io_backend_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t std_io_backend_io_read_ptr_backend(void);
extern struct shux_slice_uint8_t std_io_backend_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_backend_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void std_io_backend_io_unregister_provided_buffers(void);
extern uint8_t * std_io_backend_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t std_io_backend_io_provided_buffer_size(void);
extern ssize_t std_io_backend_io_read_provided(int32_t fd, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern ssize_t std_io_backend_io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t std_io_backend_shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_backend_shux_io_complete_read_async(void);
extern int32_t std_io_backend_shux_io_complete_read_async_slot(int32_t slot);
extern int32_t std_io_backend_shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_backend_shux_io_complete_write_async(void);
extern int32_t std_io_backend_shux_io_complete_write_async_slot(int32_t slot);
extern uint32_t std_io_backend_shux_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_uring_is_available_c(void);
extern int32_t std_io_backend_shux_io_register(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_backend_shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern uint8_t * std_io_backend_shux_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_read_ptr_len(void);
extern uint64_t std_io_backend_shux_io_read_ptr_gen(void);
extern int32_t std_io_backend_shux_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t std_io_backend_shux_io_read_ptr_backend(void);
extern struct std_io_read_ptr_ShuxSliceU8 std_io_backend_shux_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern size_t std_io_backend_handle_from_fd(int32_t fd, int32_t _unused);
extern int32_t std_io_backend_shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_submit_read_batch(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_shux_io_submit_write_batch(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_submit_read_batch_buf(size_t handle, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_submit_write_batch_buf(size_t handle, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_backend_submit_register_fixed_buffers_buf(uint8_t * bufs, uint32_t nr);
extern int32_t std_io_backend_shux_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void std_io_backend_shux_io_unregister_provided_buffers(void);
extern uint8_t * std_io_backend_shux_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t std_io_backend_shux_io_provided_buffer_size(void);
extern int32_t std_io_backend_shux_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t std_io_backend_shux_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern int32_t std_io_backend_io_backend_anchor(void);
ssize_t std_io_backend_io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms) {
  return std_io_sync_io_read(fd, buf, count, timeout_ms);
}
ssize_t std_io_backend_io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms) {
  return std_io_sync_io_write(fd, buf, count, timeout_ms);
}
ssize_t std_io_backend_io_read_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms) {
  return std_io_sync_io_read_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}
ssize_t std_io_backend_io_write_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms) {
  return std_io_sync_io_write_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}
ssize_t std_io_backend_io_read_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms) {
  struct std_io_sync_IoBatchBuf * batch = ((struct std_io_sync_IoBatchBuf *)(bufs));
  return std_io_sync_io_read_batch_buf(fd, batch, n, timeout_ms);
}
ssize_t std_io_backend_io_write_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms) {
  struct std_io_sync_IoBatchBuf * batch = ((struct std_io_sync_IoBatchBuf *)(bufs));
  return std_io_sync_io_write_batch_buf(fd, batch, n, timeout_ms);
}
int32_t std_io_backend_io_register_buffer(uint8_t * ptr, size_t len) {
  return std_io_sync_io_register_buffer(ptr, len);
}
int32_t std_io_backend_io_register_buffers_4(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr) {
  return std_io_sync_io_register_buffers_4(p0, l0, p1, l1, p2, l2, p3, l3, nr);
}
int32_t std_io_backend_io_register_buffers_buf(uint8_t * bufs, int32_t nr) {
  struct std_io_sync_IoBatchBuf * batch = ((struct std_io_sync_IoBatchBuf *)(bufs));
  return std_io_sync_io_register_buffers_buf(batch, nr);
}
void std_io_backend_io_unregister_buffers(void) {
  (void)(std_io_sync_io_unregister_buffers());
}
ssize_t std_io_backend_io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  return std_io_sync_io_read_fixed(fd, buf_index, offset, len, timeout_ms);
}
ssize_t std_io_backend_io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  return std_io_sync_io_write_fixed(fd, buf_index, offset, len, timeout_ms);
}
int32_t std_io_backend_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms) {
  return std_io_sync_io_wait_readable(fds, n, timeout_ms);
}
uint8_t * std_io_backend_io_read_ptr(size_t handle, uint32_t timeout_ms) {
  return std_io_read_ptr_io_read_ptr(handle, timeout_ms);
}
int32_t std_io_backend_io_read_ptr_len(void) {
  return std_io_read_ptr_io_read_ptr_len();
}
uint64_t std_io_backend_io_read_ptr_gen(void) {
  return std_io_read_ptr_io_read_ptr_gen();
}
int32_t std_io_backend_io_read_ptr_gen_valid(uint64_t saved) {
  return std_io_read_ptr_io_read_ptr_gen_valid(saved);
}
int32_t std_io_backend_io_read_ptr_backend(void) {
  return std_io_read_ptr_io_read_ptr_backend();
}
struct shux_slice_uint8_t std_io_backend_io_read_ptr_slice(size_t handle, uint32_t timeout_ms) {
  struct std_io_read_ptr_ShuxSliceU8 s = std_io_read_ptr_io_read_ptr_slice(handle, timeout_ms);
  struct shux_slice_uint8_t out = { 0 };
  (void)(((out.data) = (s.data)));
  (void)(((out.length) = (s.length)));
  return out;
}
int32_t std_io_backend_io_register_provided_buffers(uint32_t nr, uint32_t bufsz) {
  return std_io_stubs_io_register_provided_buffers(nr, bufsz);
}
void std_io_backend_io_unregister_provided_buffers(void) {
  (void)(std_io_stubs_io_unregister_provided_buffers());
}
uint8_t * std_io_backend_io_provided_buffer_ptr(uint32_t bid) {
  return std_io_stubs_io_provided_buffer_ptr(bid);
}
uint32_t std_io_backend_io_provided_buffer_size(void) {
  return std_io_stubs_io_provided_buffer_size();
}
ssize_t std_io_backend_io_read_provided(int32_t fd, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len) {
  return std_io_stubs_io_read_provided(fd, timeout_ms, out_bid, out_len);
}
ssize_t std_io_backend_io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens) {
  return std_io_stubs_io_read_batch_provided(fd, n, timeout_ms, out_bids, out_lens);
}
int32_t std_io_backend_shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle) {
  return std_io_stubs_shux_io_submit_read_async(ptr, len, handle);
}
int32_t std_io_backend_shux_io_complete_read_async(void) {
  return std_io_stubs_shux_io_complete_read_async();
}
int32_t std_io_backend_shux_io_complete_read_async_slot(int32_t slot) {
  return std_io_stubs_shux_io_complete_read_async_slot(slot);
}
int32_t std_io_backend_shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle) {
  return std_io_stubs_shux_io_submit_write_async(ptr, len, handle);
}
int32_t std_io_backend_shux_io_complete_write_async(void) {
  return std_io_stubs_shux_io_complete_write_async();
}
int32_t std_io_backend_shux_io_complete_write_async_slot(int32_t slot) {
  return std_io_stubs_shux_io_complete_write_async_slot(slot);
}
uint32_t std_io_backend_shux_io_poll_async_completions(uint32_t timeout_ms) {
  return std_io_stubs_shux_io_poll_async_completions(timeout_ms);
}
int32_t std_io_backend_shux_io_uring_is_available_c(void) {
  return std_io_stubs_shux_io_uring_is_available_c();
}
int32_t std_io_backend_shux_io_register(uint8_t * ptr, size_t len, size_t handle) {
  if ((handle >=0)) {
  }
  return std_io_backend_io_register_buffer(ptr, len);
}
int32_t std_io_backend_shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms) {
  ssize_t r = std_io_backend_io_read(((int32_t)(handle)), ptr, len, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms) {
  ssize_t r = std_io_backend_io_write(((int32_t)(handle)), ptr, len, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
uint8_t * std_io_backend_shux_io_read_ptr(size_t handle, uint32_t timeout_ms) {
  return std_io_backend_io_read_ptr(handle, timeout_ms);
}
int32_t std_io_backend_shux_io_read_ptr_len(void) {
  return std_io_backend_io_read_ptr_len();
}
uint64_t std_io_backend_shux_io_read_ptr_gen(void) {
  return std_io_backend_io_read_ptr_gen();
}
int32_t std_io_backend_shux_io_read_ptr_gen_valid(uint64_t saved) {
  return std_io_backend_io_read_ptr_gen_valid(saved);
}
int32_t std_io_backend_shux_io_read_ptr_backend(void) {
  return std_io_backend_io_read_ptr_backend();
}
struct std_io_read_ptr_ShuxSliceU8 std_io_backend_shux_io_read_ptr_slice(size_t handle, uint32_t timeout_ms) {
  return std_io_read_ptr_io_read_ptr_slice(handle, timeout_ms);
}
size_t std_io_backend_handle_from_fd(int32_t fd, int32_t _unused) {
  return ((size_t)(fd));
}
int32_t std_io_backend_shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  ssize_t r = std_io_backend_io_read_fixed(((int32_t)(handle)), buf_index, offset, len, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  ssize_t r = std_io_backend_io_write_fixed(((int32_t)(handle)), buf_index, offset, len, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_shux_io_submit_read_batch(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, size_t handle, int32_t n, uint32_t timeout_ms) {
  if (!(((handle ==0) || (handle >=2)))) {
    return -(1);
  }
  ssize_t r = std_io_backend_io_read_batch(((int32_t)(handle)), p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_shux_io_submit_write_batch(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, size_t handle, int32_t n, uint32_t timeout_ms) {
  if ((handle < 1)) {
    return -(1);
  }
  ssize_t r = std_io_backend_io_write_batch(((int32_t)(handle)), p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_submit_read_batch_buf(size_t handle, uint8_t * bufs, int32_t n, uint32_t timeout_ms) {
  ssize_t r = std_io_backend_io_read_batch_buf(((int32_t)(handle)), bufs, n, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_submit_write_batch_buf(size_t handle, uint8_t * bufs, int32_t n, uint32_t timeout_ms) {
  ssize_t r = std_io_backend_io_write_batch_buf(((int32_t)(handle)), bufs, n, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_submit_register_fixed_buffers_buf(uint8_t * bufs, uint32_t nr) {
  int32_t ok = std_io_backend_io_register_buffers_buf(bufs, ((int32_t)(nr)));
  if ((ok !=0)) {
    return ok;
  }
  return 0;
}
int32_t std_io_backend_shux_io_register_provided_buffers(uint32_t nr, uint32_t bufsz) {
  return std_io_backend_io_register_provided_buffers(nr, bufsz);
}
void std_io_backend_shux_io_unregister_provided_buffers(void) {
  (void)(std_io_backend_io_unregister_provided_buffers());
}
uint8_t * std_io_backend_shux_io_provided_buffer_ptr(uint32_t bid) {
  return std_io_backend_io_provided_buffer_ptr(bid);
}
uint32_t std_io_backend_shux_io_provided_buffer_size(void) {
  return std_io_backend_io_provided_buffer_size();
}
int32_t std_io_backend_shux_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens) {
  if (!(((handle ==0) || (handle >=2)))) {
    return -(1);
  }
  ssize_t r = std_io_backend_io_read_batch_provided(((int32_t)(handle)), n, timeout_ms, out_bids, out_lens);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_shux_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len) {
  if (!(((handle ==0) || (handle >=2)))) {
    return -(1);
  }
  ssize_t r = std_io_backend_io_read_provided(((int32_t)(handle)), timeout_ms, out_bid, out_len);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_backend_io_backend_anchor(void) {
  return 0;
}
extern int32_t std_io_stubs_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void std_io_stubs_io_unregister_provided_buffers(void);
extern uint8_t * std_io_stubs_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t std_io_stubs_io_provided_buffer_size(void);
extern ssize_t std_io_stubs_io_read_provided(int32_t fd, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern ssize_t std_io_stubs_io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t std_io_stubs_shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_stubs_shux_io_complete_read_async(void);
extern int32_t std_io_stubs_shux_io_complete_read_async_slot(int32_t slot);
extern int32_t std_io_stubs_shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t std_io_stubs_shux_io_complete_write_async(void);
extern int32_t std_io_stubs_shux_io_complete_write_async_slot(int32_t slot);
extern uint32_t std_io_stubs_shux_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t std_io_stubs_shux_io_uring_is_available_c(void);
int32_t std_io_stubs_io_register_provided_buffers(uint32_t nr, uint32_t bufsz) {
  if (((nr > 0) || (bufsz > 0))) {
  }
  return 0;
}
void std_io_stubs_io_unregister_provided_buffers(void) {
  (void)(0);
}
uint8_t * std_io_stubs_io_provided_buffer_ptr(uint32_t bid) {
  if ((bid > 0)) {
    return ((uint8_t *)(0));
  }
  return ((uint8_t *)(0));
}
uint32_t std_io_stubs_io_provided_buffer_size(void) {
  return ((uint32_t)(0));
}
ssize_t std_io_stubs_io_read_provided(int32_t fd, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len) {
  if (((((fd >=0) || (timeout_ms >=0)) || (out_bid !=0)) || (out_len !=0))) {
  }
  return ((ssize_t)(-(1)));
}
ssize_t std_io_stubs_io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens) {
  if ((((((fd >=0) || (n > 0)) || (timeout_ms >=0)) || (out_bids !=0)) || (out_lens !=0))) {
  }
  return ((ssize_t)(-(1)));
}
int32_t std_io_stubs_shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle) {
  if ((((ptr !=0) && (len > 0)) && (handle >=0))) {
    return -(1);
  }
  return -(1);
}
int32_t std_io_stubs_shux_io_complete_read_async(void) {
  return -(1);
}
int32_t std_io_stubs_shux_io_complete_read_async_slot(int32_t slot) {
  if ((slot >=0)) {
    return -(1);
  }
  return -(1);
}
int32_t std_io_stubs_shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle) {
  if ((((ptr !=0) && (len > 0)) && (handle >=0))) {
    return -(1);
  }
  return -(1);
}
int32_t std_io_stubs_shux_io_complete_write_async(void) {
  return -(1);
}
int32_t std_io_stubs_shux_io_complete_write_async_slot(int32_t slot) {
  if ((slot >=0)) {
    return -(1);
  }
  return -(1);
}
uint32_t std_io_stubs_shux_io_poll_async_completions(uint32_t timeout_ms) {
  if ((timeout_ms >=0)) {
  }
  return ((uint32_t)(0));
}
int32_t std_io_stubs_shux_io_uring_is_available_c(void) {
  return 0;
}
extern ssize_t shux_sys_read(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t shux_sys_write(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t shux_sys_readv(int32_t fd, uint8_t * iov, int32_t iovcnt);
extern ssize_t shux_sys_writev(int32_t fd, uint8_t * iov, int32_t iovcnt);
extern int32_t shux_sys_poll(uint8_t * fds, int32_t nfds, int32_t timeout);
extern ssize_t std_io_sync_io_libc_read(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t std_io_sync_io_libc_write(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t std_io_sync_io_libc_readv(int32_t fd, struct std_io_sync_Iovec * iov, int32_t iovcnt);
extern ssize_t std_io_sync_io_libc_writev(int32_t fd, struct std_io_sync_Iovec * iov, int32_t iovcnt);
extern int32_t std_io_sync_io_libc_poll(struct std_io_sync_PollFd * fds, int32_t nfds, int32_t timeout);
extern ssize_t std_io_sync_io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_read_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_read_batch_buf(int32_t fd, struct std_io_sync_IoBatchBuf * bufs, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_batch_buf(int32_t fd, struct std_io_sync_IoBatchBuf * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_sync_io_register_buffer(uint8_t * ptr, size_t len);
extern int32_t std_io_sync_io_register_buffers_4(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern int32_t std_io_sync_io_register_buffers_buf(struct std_io_sync_IoBatchBuf * bufs, int32_t nr);
extern void std_io_sync_io_unregister_buffers(void);
extern ssize_t std_io_sync_io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_sync_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern uint8_t * std_io_read_ptr_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_read_ptr_io_read_ptr_len(void);
extern uint64_t std_io_read_ptr_io_read_ptr_gen(void);
extern int32_t std_io_read_ptr_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t std_io_read_ptr_io_read_ptr_backend(void);
extern struct std_io_read_ptr_ShuxSliceU8 std_io_read_ptr_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
static const size_t IO_READ_PTR_BUF_SIZE = 65536;
static uint8_t g_io_read_ptr_buf[65536];
static int32_t g_io_read_ptr_len;
static uint64_t g_io_read_ptr_gen;
static int32_t g_io_read_ptr_backend;
uint8_t * std_io_read_ptr_io_read_ptr(size_t handle, uint32_t timeout_ms) {
  (void)((g_io_read_ptr_gen = (g_io_read_ptr_gen + 1)));
  (void)((g_io_read_ptr_backend = 0));
  int32_t fd = ((int32_t)(handle));
  ssize_t r = std_io_sync_io_read(fd, &((g_io_read_ptr_buf)[0]), IO_READ_PTR_BUF_SIZE, timeout_ms);
  if ((r < 0)) {
    (void)((g_io_read_ptr_len = 0));
    return ((uint8_t *)(0));
  }
  (void)((g_io_read_ptr_len = ((int32_t)(r))));
  return &((g_io_read_ptr_buf)[0]);
}
int32_t std_io_read_ptr_io_read_ptr_len(void) {
  return g_io_read_ptr_len;
}
uint64_t std_io_read_ptr_io_read_ptr_gen(void) {
  return g_io_read_ptr_gen;
}
int32_t std_io_read_ptr_io_read_ptr_gen_valid(uint64_t saved) {
  if ((saved ==g_io_read_ptr_gen)) {
    return 1;
  }
  return 0;
}
int32_t std_io_read_ptr_io_read_ptr_backend(void) {
  return g_io_read_ptr_backend;
}
struct std_io_read_ptr_ShuxSliceU8 std_io_read_ptr_io_read_ptr_slice(size_t handle, uint32_t timeout_ms) {
  uint8_t * p = std_io_read_ptr_io_read_ptr(handle, timeout_ms);
  struct std_io_read_ptr_ShuxSliceU8 s = { 0 };
  (void)(((s.data) = p));
  if ((p !=0)) {
    (void)(((s.length) = ((size_t)(g_io_read_ptr_len))));
  } else {
    (void)(((s.length) = 0));
  }
  return s;
}
extern ssize_t std_io_sync_io_libc_read(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t std_io_sync_io_libc_write(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t std_io_sync_io_libc_readv(int32_t fd, struct std_io_sync_Iovec * iov, int32_t iovcnt);
extern ssize_t std_io_sync_io_libc_writev(int32_t fd, struct std_io_sync_Iovec * iov, int32_t iovcnt);
extern int32_t std_io_sync_io_libc_poll(struct std_io_sync_PollFd * fds, int32_t nfds, int32_t timeout);
extern ssize_t std_io_sync_io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_read_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_read_batch_buf(int32_t fd, struct std_io_sync_IoBatchBuf * bufs, int32_t n, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_batch_buf(int32_t fd, struct std_io_sync_IoBatchBuf * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_sync_io_register_buffer(uint8_t * ptr, size_t len);
extern int32_t std_io_sync_io_register_buffers_4(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern int32_t std_io_sync_io_register_buffers_buf(struct std_io_sync_IoBatchBuf * bufs, int32_t nr);
extern void std_io_sync_io_unregister_buffers(void);
extern ssize_t std_io_sync_io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern ssize_t std_io_sync_io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t std_io_sync_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
static const uint32_t IO_FIXED_MAX = 8;
static const int32_t IO_READV_BUF_MAX = 16;
static uint8_t * io_fixed_ptr[8] = {((uint8_t *)(0)), ((uint8_t *)(0)), ((uint8_t *)(0)), ((uint8_t *)(0)), ((uint8_t *)(0)), ((uint8_t *)(0)), ((uint8_t *)(0)), ((uint8_t *)(0))};
static size_t io_fixed_len[8] = {0, 0, 0, 0, 0, 0, 0, 0};
static uint32_t io_fixed_nr;
extern ssize_t shux_sys_read(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t shux_sys_write(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t shux_sys_readv(int32_t fd, uint8_t * iov, int32_t iovcnt);
extern ssize_t shux_sys_writev(int32_t fd, uint8_t * iov, int32_t iovcnt);
extern int32_t shux_sys_poll(uint8_t * fds, int32_t nfds, int32_t timeout);
ssize_t std_io_sync_io_libc_read(int32_t fd, uint8_t * buf, size_t count) {
  return shux_sys_read(fd, buf, count);
  return ((ssize_t)(0));
}
ssize_t std_io_sync_io_libc_write(int32_t fd, uint8_t * buf, size_t count) {
  return shux_sys_write(fd, buf, count);
  return ((ssize_t)(0));
}
ssize_t std_io_sync_io_libc_readv(int32_t fd, struct std_io_sync_Iovec * iov, int32_t iovcnt) {
  return shux_sys_readv(fd, ((uint8_t *)(iov)), iovcnt);
  return ((ssize_t)(0));
}
ssize_t std_io_sync_io_libc_writev(int32_t fd, struct std_io_sync_Iovec * iov, int32_t iovcnt) {
  return shux_sys_writev(fd, ((uint8_t *)(iov)), iovcnt);
  return ((ssize_t)(0));
}
int32_t std_io_sync_io_libc_poll(struct std_io_sync_PollFd * fds, int32_t nfds, int32_t timeout) {
  return shux_sys_poll(((uint8_t *)(fds)), nfds, timeout);
  return 0;
}
ssize_t std_io_sync_io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms) {
  if ((timeout_ms > 0)) {
  }
  return std_io_sync_io_libc_read(fd, buf, count);
}
ssize_t std_io_sync_io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms) {
  if ((timeout_ms > 0)) {
  }
  return std_io_sync_io_libc_write(fd, buf, count);
}
ssize_t std_io_sync_io_read_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms) {
  if (((n <=0) || (n > 4))) {
    return ((ssize_t)(-(1)));
  }
  if ((n ==1)) {
    return std_io_sync_io_read(fd, p0, l0, timeout_ms);
  }
  if ((timeout_ms ==0)) {
    struct std_io_sync_Iovec iov[4] = { 0 };
    (void)((((iov)[0].base) = p0));
    (void)((((iov)[0].len) = l0));
    (void)((((iov)[1].base) = p1));
    (void)((((iov)[1].len) = l1));
    if ((n >=3)) {
      (void)((((iov)[2].base) = p2));
      (void)((((iov)[2].len) = l2));
    }
    if ((n >=4)) {
      (void)((((iov)[3].base) = p3));
      (void)((((iov)[3].len) = l3));
    }
    return std_io_sync_io_libc_readv(fd, &((iov)[0]), n);
  }
  ssize_t total = 0;
  ssize_t r0 = std_io_sync_io_read(fd, p0, l0, timeout_ms);
  if ((r0 < 0)) {
    return ((ssize_t)(-(1)));
  }
  (void)((total = (total + r0)));
  if ((n ==1)) {
    return total;
  }
  ssize_t r1 = std_io_sync_io_read(fd, p1, l1, timeout_ms);
  if ((r1 < 0)) {
    return ((ssize_t)(-(1)));
  }
  (void)((total = (total + r1)));
  if ((n ==2)) {
    return total;
  }
  ssize_t r2 = std_io_sync_io_read(fd, p2, l2, timeout_ms);
  if ((r2 < 0)) {
    return ((ssize_t)(-(1)));
  }
  (void)((total = (total + r2)));
  if ((n ==3)) {
    return total;
  }
  ssize_t r3 = std_io_sync_io_read(fd, p3, l3, timeout_ms);
  if ((r3 < 0)) {
    return ((ssize_t)(-(1)));
  }
  return (total + r3);
}
ssize_t std_io_sync_io_write_batch(int32_t fd, uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, int32_t n, uint32_t timeout_ms) {
  if (((n <=0) || (n > 4))) {
    return ((ssize_t)(-(1)));
  }
  if ((n ==1)) {
    return std_io_sync_io_write(fd, p0, l0, timeout_ms);
  }
  if ((timeout_ms ==0)) {
    struct std_io_sync_Iovec iov[4] = { 0 };
    (void)((((iov)[0].base) = p0));
    (void)((((iov)[0].len) = l0));
    (void)((((iov)[1].base) = p1));
    (void)((((iov)[1].len) = l1));
    if ((n >=3)) {
      (void)((((iov)[2].base) = p2));
      (void)((((iov)[2].len) = l2));
    }
    if ((n >=4)) {
      (void)((((iov)[3].base) = p3));
      (void)((((iov)[3].len) = l3));
    }
    return std_io_sync_io_libc_writev(fd, &((iov)[0]), n);
  }
  ssize_t total = 0;
  ssize_t r0 = std_io_sync_io_write(fd, p0, l0, timeout_ms);
  if ((r0 < 0)) {
    return ((ssize_t)(-(1)));
  }
  (void)((total = (total + r0)));
  if ((n ==1)) {
    return total;
  }
  ssize_t r1 = std_io_sync_io_write(fd, p1, l1, timeout_ms);
  if ((r1 < 0)) {
    return ((ssize_t)(-(1)));
  }
  (void)((total = (total + r1)));
  if ((n ==2)) {
    return total;
  }
  ssize_t r2 = std_io_sync_io_write(fd, p2, l2, timeout_ms);
  if ((r2 < 0)) {
    return ((ssize_t)(-(1)));
  }
  (void)((total = (total + r2)));
  if ((n ==3)) {
    return total;
  }
  ssize_t r3 = std_io_sync_io_write(fd, p3, l3, timeout_ms);
  if ((r3 < 0)) {
    return ((ssize_t)(-(1)));
  }
  return (total + r3);
}
ssize_t std_io_sync_io_read_batch_buf(int32_t fd, struct std_io_sync_IoBatchBuf * bufs, int32_t n, uint32_t timeout_ms) {
  if ((((n <=0) || (n > IO_READV_BUF_MAX)) || (bufs ==0))) {
    return ((ssize_t)(-(1)));
  }
  if ((n ==1)) {
    return std_io_sync_io_read(fd, ((bufs)[0].ptr), ((bufs)[0].len), timeout_ms);
  }
  if ((timeout_ms ==0)) {
    struct std_io_sync_Iovec iov[16] = { 0 };
    int32_t i = 0;
    while ((i < n)) {
      (void)((((iov)[i].base) = ((bufs)[i].ptr)));
      (void)((((iov)[i].len) = ((bufs)[i].len)));
      (void)((i = (i + 1)));
    }
    return std_io_sync_io_libc_readv(fd, &((iov)[0]), n);
  }
  ssize_t total = 0;
  int32_t i2 = 0;
  while ((i2 < n)) {
    ssize_t r = std_io_sync_io_read(fd, ((bufs)[i2].ptr), ((bufs)[i2].len), timeout_ms);
    if ((r < 0)) {
      return ((ssize_t)(-(1)));
    }
    (void)((total = (total + r)));
    (void)((i2 = (i2 + 1)));
  }
  return total;
}
ssize_t std_io_sync_io_write_batch_buf(int32_t fd, struct std_io_sync_IoBatchBuf * bufs, int32_t n, uint32_t timeout_ms) {
  if ((((n <=0) || (n > IO_READV_BUF_MAX)) || (bufs ==0))) {
    return ((ssize_t)(-(1)));
  }
  if ((n ==1)) {
    return std_io_sync_io_write(fd, ((bufs)[0].ptr), ((bufs)[0].len), timeout_ms);
  }
  if ((timeout_ms ==0)) {
    struct std_io_sync_Iovec iov[16] = { 0 };
    int32_t i = 0;
    while ((i < n)) {
      (void)((((iov)[i].base) = ((bufs)[i].ptr)));
      (void)((((iov)[i].len) = ((bufs)[i].len)));
      (void)((i = (i + 1)));
    }
    return std_io_sync_io_libc_writev(fd, &((iov)[0]), n);
  }
  ssize_t total = 0;
  int32_t i2 = 0;
  while ((i2 < n)) {
    ssize_t r = std_io_sync_io_write(fd, ((bufs)[i2].ptr), ((bufs)[i2].len), timeout_ms);
    if ((r < 0)) {
      return ((ssize_t)(-(1)));
    }
    (void)((total = (total + r)));
    (void)((i2 = (i2 + 1)));
  }
  return total;
}
int32_t std_io_sync_io_register_buffer(uint8_t * ptr, size_t len) {
  return std_io_sync_io_register_buffers_4(ptr, len, 0, 0, 0, 0, 0, 0, 1);
}
int32_t std_io_sync_io_register_buffers_4(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr) {
  uint32_t i = 0;
  if (((nr ==0) || (nr > 4))) {
    return 0;
  }
  (void)((io_fixed_nr = 0));
  if ((nr >=1)) {
    if ((p0 ==0)) {
      return 0;
    }
    (void)(((io_fixed_ptr)[0] = p0));
    (void)(((io_fixed_len)[0] = l0));
    (void)((i = 1));
  }
  if ((nr >=2)) {
    if ((p1 ==0)) {
      return 0;
    }
    (void)(((io_fixed_ptr)[1] = p1));
    (void)(((io_fixed_len)[1] = l1));
    (void)((i = 2));
  }
  if ((nr >=3)) {
    if ((p2 ==0)) {
      return 0;
    }
    (void)(((io_fixed_ptr)[2] = p2));
    (void)(((io_fixed_len)[2] = l2));
    (void)((i = 3));
  }
  if ((nr >=4)) {
    if ((p3 ==0)) {
      return 0;
    }
    (void)(((io_fixed_ptr)[3] = p3));
    (void)(((io_fixed_len)[3] = l3));
    (void)((i = 4));
  }
  (void)((io_fixed_nr = i));
  return 1;
}
int32_t std_io_sync_io_register_buffers_buf(struct std_io_sync_IoBatchBuf * bufs, int32_t nr) {
  int32_t max_n = 8;
  if ((((nr <=0) || (nr > max_n)) || (bufs ==0))) {
    return 0;
  }
  int32_t i = 0;
  while ((i < nr)) {
    uint8_t * p = ((bufs)[i].ptr);
    size_t l = ((bufs)[i].len);
    if ((p ==((uint8_t *)(0)))) {
      return 0;
    }
    if ((i ==0)) {
      (void)(((io_fixed_ptr)[0] = p));
      (void)(((io_fixed_len)[0] = l));
    }
    if ((i ==1)) {
      (void)(((io_fixed_ptr)[1] = p));
      (void)(((io_fixed_len)[1] = l));
    }
    if ((i ==2)) {
      (void)(((io_fixed_ptr)[2] = p));
      (void)(((io_fixed_len)[2] = l));
    }
    if ((i ==3)) {
      (void)(((io_fixed_ptr)[3] = p));
      (void)(((io_fixed_len)[3] = l));
    }
    if ((i ==4)) {
      (void)(((io_fixed_ptr)[4] = p));
      (void)(((io_fixed_len)[4] = l));
    }
    if ((i ==5)) {
      (void)(((io_fixed_ptr)[5] = p));
      (void)(((io_fixed_len)[5] = l));
    }
    if ((i ==6)) {
      (void)(((io_fixed_ptr)[6] = p));
      (void)(((io_fixed_len)[6] = l));
    }
    if ((i ==7)) {
      (void)(((io_fixed_ptr)[7] = p));
      (void)(((io_fixed_len)[7] = l));
    }
    (void)((i = (i + 1)));
  }
  (void)((io_fixed_nr = ((uint32_t)(i))));
  return 1;
}
void std_io_sync_io_unregister_buffers(void) {
  (void)((io_fixed_nr = 0));
}
ssize_t std_io_sync_io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  if ((buf_index >=io_fixed_nr)) {
    return ((ssize_t)(-(1)));
  }
  uint8_t * base = (io_fixed_ptr)[buf_index];
  size_t cap = (io_fixed_len)[buf_index];
  if ((((base ==0) || (offset > cap)) || (len > (cap - offset)))) {
    return ((ssize_t)(-(1)));
  }
  uint8_t * addr = (base + offset);
  return std_io_sync_io_read(fd, addr, len, timeout_ms);
}
ssize_t std_io_sync_io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
  if ((buf_index >=io_fixed_nr)) {
    return ((ssize_t)(-(1)));
  }
  uint8_t * base = (io_fixed_ptr)[buf_index];
  size_t cap = (io_fixed_len)[buf_index];
  if ((((base ==0) || (offset > cap)) || (len > (cap - offset)))) {
    return ((ssize_t)(-(1)));
  }
  uint8_t * addr = (base + offset);
  return std_io_sync_io_write(fd, addr, len, timeout_ms);
}
int32_t std_io_sync_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms) {
  if ((((fds ==0) || (n <=0)) || (n > 8))) {
    return -(1);
  }
  struct std_io_sync_PollFd pfd[8] = { 0 };
  int32_t i = 0;
  while ((i < n)) {
    (void)((((pfd)[i].fd) = (fds)[i]));
    (void)((((pfd)[i].events) = ((int16_t)(1))));
    (void)((((pfd)[i].revents) = ((int16_t)(0))));
    (void)((i = (i + 1)));
  }
  int32_t to = -(1);
  if ((timeout_ms > 0)) {
    (void)((to = ((int32_t)(timeout_ms))));
  }
  int32_t r = std_io_sync_io_libc_poll(&((pfd)[0]), n, to);
  if ((r <=0)) {
    return -(1);
  }
  (void)((i = 0));
  while ((i < n)) {
    if ((((((pfd)[i].revents) & 1) !=0) || ((((pfd)[i].revents) & 16) !=0))) {
      return i;
    }
    (void)((i = (i + 1)));
  }
  return -(1);
}
extern int32_t shux_io_register(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_register_buffers(uint8_t * p0, size_t l0, uint8_t * p1, size_t l1, uint8_t * p2, size_t l2, uint8_t * p3, size_t l3, uint32_t nr);
extern void shux_io_unregister_buffers(void);
extern int32_t shux_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t shux_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms);
extern int32_t shux_io_wait_readable(int32_t * fds, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_submit_read(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern uint8_t * shux_io_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_read_ptr_len(void);
extern uint64_t shux_io_read_ptr_gen(void);
extern int32_t shux_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t shux_io_read_ptr_backend(void);
extern struct shux_slice_uint8_t shux_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_submit_write(uint8_t * ptr, size_t len, size_t handle, uint32_t timeout_ms);
extern int32_t shux_io_submit_read_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_submit_write_batch(uint8_t * ptr0, size_t len0, uint8_t * ptr1, size_t len1, uint8_t * ptr2, size_t len2, uint8_t * ptr3, size_t len3, size_t handle, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_register_buffers_buf(uint8_t * bufs, int32_t nr);
extern ssize_t shux_io_read_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern ssize_t shux_io_write_batch_buf(int32_t fd, uint8_t * bufs, int32_t n, uint32_t timeout_ms);
extern int32_t shux_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void shux_io_unregister_provided_buffers(void);
extern uint8_t * shux_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t shux_io_provided_buffer_size(void);
extern int32_t shux_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t * out_bid, uint32_t * out_len);
extern int32_t shux_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t * out_bids, uint32_t * out_lens);
extern int32_t shux_io_submit_read_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_read_async(void);
extern int32_t shux_io_complete_read_async_slot(int32_t slot);
extern int32_t shux_io_submit_write_async(uint8_t * ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_write_async(void);
extern int32_t shux_io_complete_write_async_slot(int32_t slot);
extern uint32_t shux_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t shux_io_uring_is_available_c(void);
extern int32_t std_io_driver_register(ptrdiff_t  buf);
extern int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_Buffer * bufs, uint32_t  nr);
extern int32_t std_io_driver_submit_read(ptrdiff_t  buf, uint32_t  timeout_ms);
extern uint8_t * std_io_driver_driver_read_ptr(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_driver_driver_read_ptr_len(void);
extern uint64_t std_io_driver_driver_read_ptr_gen(void);
extern int32_t std_io_driver_driver_read_ptr_gen_valid(uint64_t saved);
extern int32_t std_io_driver_driver_read_ptr_backend(void);
extern struct shux_slice_uint8_t std_io_driver_driver_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_write(ptrdiff_t  buf, uint32_t  timeout_ms);
extern int32_t std_io_driver_submit_read_batch(struct std_io_Buffer * buffers, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_write_batch(struct std_io_Buffer * buffers, int32_t n, uint32_t timeout_ms);
extern int32_t std_io_driver_submit_read_batch_buf(size_t  handle, struct std_io_Buffer * bufs, int32_t n, uint32_t  timeout_ms);
extern int32_t std_io_driver_submit_write_batch_buf(size_t  handle, struct std_io_Buffer * bufs, int32_t n, uint32_t  timeout_ms);
int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_Buffer * bufs, uint32_t  nr) {
  return std_io_core_shux_io_register_buffers_buf(((uint8_t *)(bufs)), ((int32_t)(nr)));
}
int32_t std_io_driver_driver_read_ptr_gen_valid(uint64_t saved) {
  return std_io_core_shux_io_read_ptr_gen_valid(saved);
}
int32_t std_io_driver_driver_read_ptr_backend(void) {
  return std_io_core_shux_io_read_ptr_backend();
}
struct shux_slice_uint8_t std_io_driver_driver_read_ptr_slice(size_t handle, uint32_t timeout_ms) {
  return std_io_core_shux_io_read_ptr_slice(handle, timeout_ms);
}
int32_t std_io_driver_submit_read_batch(struct std_io_Buffer * buffers, int32_t n, uint32_t timeout_ms) {
  size_t h = ((buffers)[0].handle);
  return std_io_core_shux_io_submit_read_batch(((buffers)[0].ptr), ((buffers)[0].len), ((buffers)[1].ptr), ((buffers)[1].len), ((buffers)[2].ptr), ((buffers)[2].len), ((buffers)[3].ptr), ((buffers)[3].len), h, n, timeout_ms);
}
int32_t std_io_driver_submit_write_batch(struct std_io_Buffer * buffers, int32_t n, uint32_t timeout_ms) {
  size_t h = ((buffers)[0].handle);
  return std_io_core_shux_io_submit_write_batch(((buffers)[0].ptr), ((buffers)[0].len), ((buffers)[1].ptr), ((buffers)[1].len), ((buffers)[2].ptr), ((buffers)[2].len), ((buffers)[3].ptr), ((buffers)[3].len), h, n, timeout_ms);
}
int32_t std_io_driver_submit_read_batch_buf(size_t  handle, struct std_io_Buffer * bufs, int32_t n, uint32_t  timeout_ms) {
  ssize_t r = std_io_core_shux_io_read_batch_buf(((int32_t)(handle)), ((uint8_t *)(bufs)), n, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
int32_t std_io_driver_submit_write_batch_buf(size_t  handle, struct std_io_Buffer * bufs, int32_t n, uint32_t  timeout_ms) {
  ssize_t r = std_io_core_shux_io_write_batch_buf(((int32_t)(handle)), ((uint8_t *)(bufs)), n, timeout_ms);
  if ((r < 0)) {
    return -(1);
  }
  return ((int32_t)(r));
}
extern void lsp_diag_invalidate_cache(void);
extern void lsp_debug_u32(uint32_t n);
extern void lsp_debug_ptr(uint8_t * p);
extern ssize_t lsp_io_read_message(int32_t fd, uint8_t * body_out, int32_t body_cap, uint8_t * state_buf);
extern int32_t lsp_io_parse_content_length_in_buf(uint8_t * state_buf, int32_t off, int32_t header_end);
extern ssize_t lsp_io_write_fd(int32_t fd, uint8_t * ptr, size_t count);
extern int32_t lsp_io_extract_document_text(uint8_t * body, int32_t body_len, uint8_t * out_buf, int32_t out_cap);
extern uint8_t * lsp_io_lsp_alloc(size_t size);
extern void lsp_io_lsp_free(uint8_t * ptr);
extern int32_t lsp_io_lsp_is_null(uint8_t * ptr);
extern int32_t lsp_body_contains_initialize(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_initialized(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_shutdown(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_did_open(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_did_change(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_did_save(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_diagnostic(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_completion(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_document_symbol(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_semantic_tokens(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_rename(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_did_close(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_cancel(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_did_change_config(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_definition(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_references(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_hover(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_formatting(uint8_t * body, int32_t len);
extern int32_t lsp_body_contains_exit(uint8_t * body, int32_t len);
extern int32_t lsp_parse_id(uint8_t * body, int32_t len, uint8_t * id_buf, int32_t id_buf_len);
extern int32_t lsp_send_response(int32_t fd, uint8_t * body, int32_t body_len);
extern int32_t lsp_main_impl(void);
static int32_t LSP_BODY_CAP;
static int32_t LSP_STATE_SIZE;
static int32_t LSP_DIAG_RESP_CAP;
static int32_t LSP_REF_RESP_CAP;
static int32_t LSP_FORMAT_RESP_CAP;
static void init_globals(void) {
  LSP_BODY_CAP = 1048576;
  LSP_STATE_SIZE = (4 + (8192 * 2));
  LSP_DIAG_RESP_CAP = 32768;
  LSP_REF_RESP_CAP = 8192;
  LSP_FORMAT_RESP_CAP = 262144;
  LSP_BODY_SAFETY_CAP = 1048576;
  LSP_STATE_LEFTOVER_OFF = 0;
  LSP_STATE_LEFTOVER_MAX = (8192 * 2);
  LSP_STATE_LEN_OFF = (8192 * 2);
  g_io_read_ptr_len = 0;
  g_io_read_ptr_gen = ((uint64_t)(0));
  g_io_read_ptr_backend = 0;
  io_fixed_nr = 0;
}
extern uint8_t * lsp_state_buf_ptr(void);
extern int32_t lsp_write_all(int32_t fd, uint8_t * ptr, int32_t len);
extern int32_t lsp_build_initialize_result(int32_t id_val, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_diagnostics_response(int32_t id_val, uint8_t * source, int32_t source_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_definition_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_references_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_hover_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_formatting_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_completion_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_document_symbol_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_semantic_tokens_response(int32_t id_val, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t lsp_build_rename_response(int32_t id_val, uint8_t * body, int32_t body_len, uint8_t * doc_buf, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern void lsp_diag_invalidate_cache(void);
extern int32_t lsp_build_response_with_result(int32_t id_val, uint8_t * result_ptr, int32_t result_len, uint8_t * out_buf, int32_t out_cap);
extern void lsp_set_document_from_body(uint8_t * body, int32_t body_len);
extern uint8_t * lsp_get_document_ptr(void);
extern int32_t lsp_get_document_len(void);
int32_t lsp_body_contains_initialize(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 10) <=len)) {
    if ((((((((((((body)[i] ==105) && ((body)[(i + 1)] ==110)) && ((body)[(i + 2)] ==105)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==105)) && ((body)[(i + 5)] ==97)) && ((body)[(i + 6)] ==108)) && ((body)[(i + 7)] ==105)) && ((body)[(i + 8)] ==122)) && ((body)[(i + 9)] ==101))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_initialized(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 11) <=len)) {
    if (((((((((((((body)[i] ==105) && ((body)[(i + 1)] ==110)) && ((body)[(i + 2)] ==105)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==105)) && ((body)[(i + 5)] ==97)) && ((body)[(i + 6)] ==108)) && ((body)[(i + 7)] ==105)) && ((body)[(i + 8)] ==122)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==100))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_shutdown(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 8) <=len)) {
    if ((((((((((body)[i] ==115) && ((body)[(i + 1)] ==104)) && ((body)[(i + 2)] ==117)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==100)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==119)) && ((body)[(i + 7)] ==110))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_did_open(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 19) <=len)) {
    if ((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==100)) && ((body)[(i + 14)] ==105)) && ((body)[(i + 15)] ==100)) && ((body)[(i + 16)] ==79)) && ((body)[(i + 17)] ==112)) && ((body)[(i + 18)] ==101)) && ((body)[(i + 19)] ==110))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_did_change(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 21) <=len)) {
    if ((((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==100)) && ((body)[(i + 14)] ==105)) && ((body)[(i + 15)] ==100)) && ((body)[(i + 16)] ==67)) && ((body)[(i + 17)] ==104)) && ((body)[(i + 18)] ==97)) && ((body)[(i + 19)] ==110)) && ((body)[(i + 20)] ==103)) && ((body)[(i + 21)] ==101))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_did_save(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 19) <=len)) {
    if ((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==100)) && ((body)[(i + 14)] ==105)) && ((body)[(i + 15)] ==100)) && ((body)[(i + 16)] ==83)) && ((body)[(i + 17)] ==97)) && ((body)[(i + 18)] ==118)) && ((body)[(i + 19)] ==101))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_diagnostic(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 23) <=len)) {
    if (((((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==100)) && ((body)[(i + 14)] ==105)) && ((body)[(i + 15)] ==97)) && ((body)[(i + 16)] ==103)) && ((body)[(i + 17)] ==110)) && ((body)[(i + 18)] ==111)) && ((body)[(i + 19)] ==115)) && ((body)[(i + 20)] ==116)) && ((body)[(i + 21)] ==105)) && ((body)[(i + 22)] ==99))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_completion(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 23) <=len)) {
    if (((((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==99)) && ((body)[(i + 14)] ==111)) && ((body)[(i + 15)] ==109)) && ((body)[(i + 16)] ==112)) && ((body)[(i + 17)] ==108)) && ((body)[(i + 18)] ==101)) && ((body)[(i + 19)] ==116)) && ((body)[(i + 20)] ==105)) && ((body)[(i + 21)] ==111)) && ((body)[(i + 22)] ==110))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_document_symbol(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 27) <=len)) {
    if (((((((((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==100)) && ((body)[(i + 14)] ==111)) && ((body)[(i + 15)] ==99)) && ((body)[(i + 16)] ==117)) && ((body)[(i + 17)] ==109)) && ((body)[(i + 18)] ==101)) && ((body)[(i + 19)] ==110)) && ((body)[(i + 20)] ==116)) && ((body)[(i + 21)] ==83)) && ((body)[(i + 22)] ==121)) && ((body)[(i + 23)] ==109)) && ((body)[(i + 24)] ==98)) && ((body)[(i + 25)] ==111)) && ((body)[(i + 26)] ==108))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_semantic_tokens(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 28) <=len)) {
    if (((((((((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==115)) && ((body)[(i + 14)] ==101)) && ((body)[(i + 15)] ==109)) && ((body)[(i + 16)] ==97)) && ((body)[(i + 17)] ==110)) && ((body)[(i + 18)] ==116)) && ((body)[(i + 19)] ==105)) && ((body)[(i + 20)] ==99)) && ((body)[(i + 21)] ==84)) && ((body)[(i + 22)] ==111)) && ((body)[(i + 23)] ==107)) && ((body)[(i + 24)] ==101)) && ((body)[(i + 25)] ==110)) && ((body)[(i + 26)] ==115))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_rename(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 20) <=len)) {
    if (((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==114)) && ((body)[(i + 14)] ==101)) && ((body)[(i + 15)] ==110)) && ((body)[(i + 16)] ==97)) && ((body)[(i + 17)] ==109)) && ((body)[(i + 18)] ==101))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_did_close(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 20) <=len)) {
    if (((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==100)) && ((body)[(i + 14)] ==105)) && ((body)[(i + 15)] ==100)) && ((body)[(i + 16)] ==67)) && ((body)[(i + 17)] ==108)) && ((body)[(i + 18)] ==111)) && ((body)[(i + 19)] ==115)) && ((body)[(i + 20)] ==101))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_cancel(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 14) <=len)) {
    if (((((((((((((((((body)[i] ==36) && ((body)[(i + 1)] ==47)) && ((body)[(i + 2)] ==99)) && ((body)[(i + 3)] ==97)) && ((body)[(i + 4)] ==110)) && ((body)[(i + 5)] ==99)) && ((body)[(i + 6)] ==101)) && ((body)[(i + 7)] ==108)) && ((body)[(i + 8)] ==82)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==113)) && ((body)[(i + 11)] ==117)) && ((body)[(i + 12)] ==101)) && ((body)[(i + 13)] ==115)) && ((body)[(i + 14)] ==116))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_did_change_config(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 35) <=len)) {
    if ((((((((((((((((((((((((((((((((((body)[i] ==119) && ((body)[(i + 1)] ==111)) && ((body)[(i + 2)] ==114)) && ((body)[(i + 3)] ==107)) && ((body)[(i + 4)] ==115)) && ((body)[(i + 5)] ==112)) && ((body)[(i + 6)] ==97)) && ((body)[(i + 7)] ==99)) && ((body)[(i + 8)] ==101)) && ((body)[(i + 9)] ==47)) && ((body)[(i + 10)] ==100)) && ((body)[(i + 11)] ==105)) && ((body)[(i + 12)] ==100)) && ((body)[(i + 13)] ==67)) && ((body)[(i + 14)] ==104)) && ((body)[(i + 15)] ==97)) && ((body)[(i + 16)] ==110)) && ((body)[(i + 17)] ==103)) && ((body)[(i + 18)] ==101)) && ((body)[(i + 19)] ==67)) && ((body)[(i + 20)] ==111)) && ((body)[(i + 21)] ==110)) && ((body)[(i + 22)] ==102)) && ((body)[(i + 23)] ==105)) && ((body)[(i + 24)] ==103)) && ((body)[(i + 25)] ==117)) && ((body)[(i + 26)] ==114)) && ((body)[(i + 27)] ==97)) && ((body)[(i + 28)] ==116)) && ((body)[(i + 29)] ==105)) && ((body)[(i + 30)] ==111)) && ((body)[(i + 31)] ==110))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_definition(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 22) < len)) {
    if (((((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==100)) && ((body)[(i + 14)] ==101)) && ((body)[(i + 15)] ==102)) && ((body)[(i + 16)] ==105)) && ((body)[(i + 17)] ==110)) && ((body)[(i + 18)] ==105)) && ((body)[(i + 19)] ==116)) && ((body)[(i + 20)] ==105)) && ((body)[(i + 21)] ==111)) && ((body)[(i + 22)] ==110))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_references(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 23) < len)) {
    if ((((((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==114)) && ((body)[(i + 14)] ==101)) && ((body)[(i + 15)] ==102)) && ((body)[(i + 16)] ==101)) && ((body)[(i + 17)] ==114)) && ((body)[(i + 18)] ==101)) && ((body)[(i + 19)] ==110)) && ((body)[(i + 20)] ==99)) && ((body)[(i + 21)] ==101)) && ((body)[(i + 22)] ==115)) && ((body)[(i + 23)] ==115))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_hover(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 17) <=len)) {
    if ((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==104)) && ((body)[(i + 14)] ==111)) && ((body)[(i + 15)] ==118)) && ((body)[(i + 16)] ==101)) && ((body)[(i + 17)] ==114))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_formatting(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 23) <=len)) {
    if (((((((((((((((((((((((((body)[i] ==116) && ((body)[(i + 1)] ==101)) && ((body)[(i + 2)] ==120)) && ((body)[(i + 3)] ==116)) && ((body)[(i + 4)] ==68)) && ((body)[(i + 5)] ==111)) && ((body)[(i + 6)] ==99)) && ((body)[(i + 7)] ==117)) && ((body)[(i + 8)] ==109)) && ((body)[(i + 9)] ==101)) && ((body)[(i + 10)] ==110)) && ((body)[(i + 11)] ==116)) && ((body)[(i + 12)] ==47)) && ((body)[(i + 13)] ==102)) && ((body)[(i + 14)] ==111)) && ((body)[(i + 15)] ==114)) && ((body)[(i + 16)] ==109)) && ((body)[(i + 17)] ==97)) && ((body)[(i + 18)] ==116)) && ((body)[(i + 19)] ==116)) && ((body)[(i + 20)] ==105)) && ((body)[(i + 21)] ==110)) && ((body)[(i + 22)] ==103))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_body_contains_exit(uint8_t * body, int32_t len) {
  int32_t i = 0;
  while (((i + 4) <=len)) {
    if ((((((body)[i] ==101) && ((body)[(i + 1)] ==120)) && ((body)[(i + 2)] ==105)) && ((body)[(i + 3)] ==116))) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t lsp_parse_id(uint8_t * body, int32_t len, uint8_t * id_buf, int32_t id_buf_len) {
  int32_t i = 0;
  while (((i + 6) <=len)) {
    if (((((((body)[i] ==34) && ((body)[(i + 1)] ==105)) && ((body)[(i + 2)] ==100)) && ((body)[(i + 3)] ==34)) && ((body)[(i + 4)] ==58))) {
      int32_t val = 0;
      int32_t j = 0;
      (void)((i = (i + 5)));
      while (((i < len) && (((body)[i] ==32) || ((body)[i] ==9)))) {
        (void)((i = (i + 1)));
      }
      if ((i >=len)) {
        return -(1);
      }
      while (((i < len) && (j < (id_buf_len - 1)))) {
        uint8_t c = (body)[i];
        if (((c >=48) && (c <=57))) {
          (void)((val = (((val * 10) + ((int32_t)(c))) - 48)));
          (void)(((id_buf)[j] = c));
          (void)((j = (j + 1)));
          (void)((i = (i + 1)));
        } else {
          break;
        }
      }
      (void)(((id_buf)[j] = 0));
      return val;
    }
    (void)((i = (i + 1)));
  }
  return -(1);
}
int32_t lsp_send_response(int32_t fd, uint8_t * body, int32_t body_len) {
  {
    uint8_t header[64] = {};
    (void)(((header)[0] = 67));
    (void)(((header)[1] = 111));
    (void)(((header)[2] = 110));
    (void)(((header)[3] = 116));
    (void)(((header)[4] = 101));
    (void)(((header)[5] = 110));
    (void)(((header)[6] = 116));
    (void)(((header)[7] = 45));
    (void)(((header)[8] = 76));
    (void)(((header)[9] = 101));
    (void)(((header)[10] = 110));
    (void)(((header)[11] = 103));
    (void)(((header)[12] = 116));
    (void)(((header)[13] = 104));
    (void)(((header)[14] = 58));
    (void)(((header)[15] = 32));
    int32_t n = body_len;
    int32_t k = 16;
    if ((n ==0)) {
      (void)(((header)[k] = 48));
      (void)((k = (k + 1)));
    } else {
      int32_t digits[12] = {};
      int32_t d = 0;
      int32_t n2 = n;
      while ((n2 > 0)) {
        (void)(((digits)[d] = (n2 % 10)));
        (void)((n2 = (n2 / 10)));
        (void)((d = (d + 1)));
      }
      int32_t idx = (d - 1);
      while ((idx >=0)) {
        (void)(((header)[k] = ((uint8_t)(((digits)[idx] + 48)))));
        (void)((k = (k + 1)));
        (void)((idx = (idx - 1)));
      }
    }
    (void)(((header)[k] = 13));
    (void)((k = (k + 1)));
    (void)(((header)[k] = 10));
    (void)((k = (k + 1)));
    (void)(((header)[k] = 13));
    (void)((k = (k + 1)));
    (void)(((header)[k] = 10));
    (void)((k = (k + 1)));
    int32_t w = lsp_write_all(fd, header, k);
    if ((w !=0)) {
      return -(1);
    }
    if ((body_len > 0)) {
      int32_t w2 = lsp_write_all(fd, body, body_len);
      if ((w2 !=0)) {
        return -(1);
      }
    }
    return 0;
  }
  return 0;
}
int32_t lsp_main_impl(void) {
  {
    int32_t stdin_fd = 0;
    int32_t stdout_fd = 1;
    uint8_t line_buf[256] = {};
    uint8_t out_buf[4096] = {};
    int32_t shutdown_requested = 0;
    uint8_t id_buf[32] = {};
    uint8_t * state_ptr = lsp_state_buf_ptr();
    uint8_t * diag_ptr = lsp_io_lsp_alloc(((size_t)(LSP_DIAG_RESP_CAP)));
    uint8_t * ref_ptr = lsp_io_lsp_alloc(((size_t)(LSP_REF_RESP_CAP)));
    uint8_t * format_ptr = lsp_io_lsp_alloc(((size_t)(LSP_FORMAT_RESP_CAP)));
    if (((((lsp_io_lsp_is_null(state_ptr) !=0) || (lsp_io_lsp_is_null(diag_ptr) !=0)) || (lsp_io_lsp_is_null(ref_ptr) !=0)) || (lsp_io_lsp_is_null(format_ptr) !=0))) {
      if ((lsp_io_lsp_is_null(diag_ptr) ==0)) {
        (void)(lsp_io_lsp_free(diag_ptr));
      }
      if ((lsp_io_lsp_is_null(ref_ptr) ==0)) {
        (void)(lsp_io_lsp_free(ref_ptr));
      }
      if ((lsp_io_lsp_is_null(format_ptr) ==0)) {
        (void)(lsp_io_lsp_free(format_ptr));
      }
      return -(1);
    }
    while (1) {
      uint8_t * body_ptr = lsp_io_lsp_alloc(((size_t)(LSP_BODY_CAP)));
      if ((lsp_io_lsp_is_null(body_ptr) !=0)) {
        continue;
      }
      ssize_t msg_len = lsp_io_read_message(stdin_fd, body_ptr, LSP_BODY_CAP, state_ptr);
      if ((msg_len < 0)) {
        (void)(lsp_io_lsp_free(body_ptr));
        break;
      }
      if ((msg_len ==0)) {
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      int32_t content_len = ((int32_t)(msg_len));
      if ((content_len > LSP_BODY_CAP)) {
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if ((lsp_body_contains_did_open(body_ptr, content_len) !=0)) {
        (void)(lsp_set_document_from_body(body_ptr, content_len));
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if ((lsp_body_contains_did_change(body_ptr, content_len) !=0)) {
        (void)(lsp_set_document_from_body(body_ptr, content_len));
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if ((lsp_body_contains_did_save(body_ptr, content_len) !=0)) {
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if ((lsp_body_contains_did_close(body_ptr, content_len) !=0)) {
        (void)(lsp_diag_invalidate_cache());
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if ((lsp_body_contains_cancel(body_ptr, content_len) !=0)) {
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if ((lsp_body_contains_did_change_config(body_ptr, content_len) !=0)) {
        (void)(lsp_diag_invalidate_cache());
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if (((lsp_body_contains_exit(body_ptr, content_len) !=0) && (shutdown_requested !=0))) {
        (void)(lsp_io_lsp_free(body_ptr));
        break;
      }
      if ((lsp_body_contains_shutdown(body_ptr, content_len) !=0)) {
        int32_t sid = lsp_parse_id(body_ptr, content_len, id_buf, 32);
        uint8_t null_val[4] = {110, 117, 108, 108};
        int32_t resp_len = lsp_build_response_with_result(sid, null_val, 4, out_buf, 4096);
        (void)((shutdown_requested = 1));
        if ((sid < 0)) {
          (void)((sid = 1));
        }
        if ((resp_len > 0)) {
          (void)(lsp_send_response(stdout_fd, out_buf, resp_len));
        }
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if ((lsp_body_contains_initialized(body_ptr, content_len) !=0)) {
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      if ((lsp_body_contains_initialize(body_ptr, content_len) !=0)) {
        int32_t sid = lsp_parse_id(body_ptr, content_len, id_buf, 32);
        if ((sid < 0)) {
          (void)((sid = 1));
        }
        int32_t out_len = lsp_build_initialize_result(sid, diag_ptr, LSP_DIAG_RESP_CAP);
        if ((out_len > 0)) {
          (void)(lsp_send_response(stdout_fd, diag_ptr, out_len));
        }
        (void)(lsp_io_lsp_free(body_ptr));
        continue;
      }
      int32_t req_id = lsp_parse_id(body_ptr, content_len, id_buf, 32);
      uint8_t * doc_ptr = lsp_get_document_ptr();
      int32_t doc_len = lsp_get_document_len();
      if ((req_id >=0)) {
        uint8_t empty_arr[2] = {91, 93};
        uint8_t null_val[4] = {110, 117, 108, 108};
        if ((lsp_body_contains_diagnostic(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_diagnostics_response(req_id, doc_ptr, doc_len, diag_ptr, LSP_DIAG_RESP_CAP);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, diag_ptr, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
        if ((lsp_body_contains_definition(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_definition_response(req_id, body_ptr, content_len, doc_ptr, doc_len, out_buf, 4096);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, out_buf, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, null_val, 4, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
        if ((lsp_body_contains_references(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_references_response(req_id, body_ptr, content_len, doc_ptr, doc_len, ref_ptr, LSP_REF_RESP_CAP);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, ref_ptr, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
        if ((lsp_body_contains_hover(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_hover_response(req_id, body_ptr, content_len, doc_ptr, doc_len, out_buf, 4096);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, out_buf, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, null_val, 4, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
        if ((lsp_body_contains_formatting(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_formatting_response(req_id, body_ptr, content_len, doc_ptr, doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, format_ptr, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
        if ((lsp_body_contains_completion(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_completion_response(req_id, body_ptr, content_len, doc_ptr, doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, format_ptr, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
        if ((lsp_body_contains_document_symbol(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_document_symbol_response(req_id, body_ptr, content_len, doc_ptr, doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, format_ptr, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
        if ((lsp_body_contains_semantic_tokens(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_semantic_tokens_response(req_id, doc_ptr, doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, format_ptr, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, empty_arr, 2, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
        if ((lsp_body_contains_rename(body_ptr, content_len) !=0)) {
          int32_t resp_len = lsp_build_rename_response(req_id, body_ptr, content_len, doc_ptr, doc_len, format_ptr, LSP_FORMAT_RESP_CAP);
          if ((resp_len > 0)) {
            (void)(lsp_send_response(stdout_fd, format_ptr, resp_len));
          } else {
            int32_t fallback_len = lsp_build_response_with_result(req_id, null_val, 4, out_buf, 4096);
            if ((fallback_len > 0)) {
              (void)(lsp_send_response(stdout_fd, out_buf, fallback_len));
            }
          }
          (void)(lsp_io_lsp_free(body_ptr));
          continue;
        }
      }
      (void)(lsp_io_lsp_free(body_ptr));
    }
    (void)(lsp_io_lsp_free(diag_ptr));
    (void)(lsp_io_lsp_free(ref_ptr));
    (void)(lsp_io_lsp_free(format_ptr));
    return 0;
  }
  return 0;
}
