/* seeds/runtime_process_os_glue_surface.from_x.c
 * G-02f-21 runtime_process_os_glue R2 thin+rest surface - isomorphic with src/asm/runtime_process_os_glue.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_process_os_glue.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (22 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest - 22 public API forwards to _impl extern C bridges;
 *   rest keeps OS-specific logic (getenv/setenv/unsetenv/getpid/getppid/getcwd/chdir/
 *   self_exe_path/nop_sigchld/spawn/exec/waitpid/pipe (POSIX) +
 *   _wpgmptr/GetModuleFileName/CreateProcess (Windows))
 * Cap residual: 22 _impl - process_getenv/setenv/unsetenv/getpid/getppid/getcwd/getcwd_ptr/
 *   getcwd_cached_len/chdir/self_exe_path/self_exe_path_ptr/self_exe_path_cached_len/
 *   nop_sigchld/spawn/exec/waitpid/spawn_simple/exec_simple/dup_stdio_posix/spawn_io/pipe
 * Note: doc_anchor runtime_process_os_glue_x_doc_anchor (no ast_; process_ prefix not trigger).
 * Logic: 22 functions = 22 thin+rest forwards.
 * Regen: ./xlang-c -E ... runtime_process_os_glue.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern uint8_t *process_getenv_impl(uint8_t *name);
extern int32_t process_setenv_impl(uint8_t *name, uint8_t *value, int32_t overwrite);
extern int32_t process_unsetenv_impl(uint8_t *name);
extern int32_t process_getpid_impl(void);
extern int32_t process_getppid_impl(void);
extern int32_t process_getcwd_impl(uint8_t *buf, int32_t buf_size);
extern uint8_t *process_getcwd_ptr_impl(void);
extern int32_t process_getcwd_cached_len_impl(void);
extern int32_t process_chdir_impl(uint8_t *path);
extern int32_t process_self_exe_path_impl(uint8_t *buf, int32_t buf_size);
extern uint8_t *process_self_exe_path_ptr_impl(void);
extern int32_t process_self_exe_path_cached_len_impl(void);
extern void process_nop_sigchld_impl(int32_t sig);
extern int32_t process_spawn_impl(uint8_t *program, uint8_t *argv_ptr);
extern int32_t process_exec_impl(uint8_t *program, uint8_t *argv_ptr);
extern int32_t process_waitpid_impl(int32_t pid);
extern int32_t process_spawn_simple_impl(uint8_t *program);
extern int32_t process_exec_simple_impl(uint8_t *program);
extern int32_t process_dup_stdio_posix_impl(int32_t fd, int32_t slot);
extern int32_t process_spawn_io_impl(uint8_t *program, uint8_t *argv_ptr, uint8_t *io);
extern int32_t process_pipe_impl(int32_t *read_fd, int32_t *write_fd);

int32_t runtime_process_os_glue_x_doc_anchor(void) {
  return 0;
}

uint8_t *process_getenv_c(uint8_t *name) {
  return process_getenv_impl(name);
}

int32_t process_setenv_c(uint8_t *name, uint8_t *value, int32_t overwrite) {
  return process_setenv_impl(name, value, overwrite);
}

int32_t process_unsetenv_c(uint8_t *name) {
  return process_unsetenv_impl(name);
}

int32_t process_getpid_c(void) {
  return process_getpid_impl();
}

int32_t process_getppid_c(void) {
  return process_getppid_impl();
}

int32_t process_getcwd_c(uint8_t *buf, int32_t buf_size) {
  return process_getcwd_impl(buf, buf_size);
}

uint8_t *process_getcwd_ptr_c(void) {
  return process_getcwd_ptr_impl();
}

int32_t process_getcwd_cached_len_c(void) {
  return process_getcwd_cached_len_impl();
}

int32_t process_chdir_c(uint8_t *path) {
  return process_chdir_impl(path);
}

int32_t process_self_exe_path_c(uint8_t *buf, int32_t buf_size) {
  return process_self_exe_path_impl(buf, buf_size);
}

uint8_t *process_self_exe_path_ptr_c(void) {
  return process_self_exe_path_ptr_impl();
}

int32_t process_self_exe_path_cached_len_c(void) {
  return process_self_exe_path_cached_len_impl();
}

void process_nop_sigchld(int32_t sig) {
  process_nop_sigchld_impl(sig);
}

int32_t process_spawn_c(uint8_t *program, uint8_t *argv_ptr) {
  return process_spawn_impl(program, argv_ptr);
}

int32_t process_exec_c(uint8_t *program, uint8_t *argv_ptr) {
  return process_exec_impl(program, argv_ptr);
}

int32_t process_waitpid_c(int32_t pid) {
  return process_waitpid_impl(pid);
}

int32_t process_spawn_simple_c(uint8_t *program) {
  return process_spawn_simple_impl(program);
}

int32_t process_dup_stdio_posix(int32_t fd, int32_t slot) {
  return process_dup_stdio_posix_impl(fd, slot);
}

int32_t process_spawn_io_c(uint8_t *program, uint8_t *argv_ptr, uint8_t *io) {
  return process_spawn_io_impl(program, argv_ptr, io);
}

int32_t process_exec_simple_c(uint8_t *program) {
  return process_exec_simple_impl(program);
}

int32_t process_pipe_c(int32_t *read_fd, int32_t *write_fd) {
  return process_pipe_impl(read_fd, write_fd);
}
