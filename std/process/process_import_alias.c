/**
 * process_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const process = import("std.process")` 生成 std_process_* 符号；
 * process.o 现仅作为 alias 容器；真实 process_*_c 由 runtime_process_argv.o 与
 * runtime_process_os_glue.o 提供。本 TU 负责 std_process_* -> process_*_c 转发。
 */
#include <stdint.h>

/** 与 mod.x SpawnIo 布局一致。 */
typedef struct ShuxSpawnIo {
  int32_t stdin_fd;
  int32_t stdout_fd;
  int32_t stderr_fd;
} ShuxSpawnIo;

extern int32_t process_args_count_c(void);
extern uint8_t *process_arg_c(int32_t i);
extern uint8_t *process_getenv_c(uint8_t *name);
extern int32_t process_setenv_c(uint8_t *name, uint8_t *value, int32_t overwrite);
extern int32_t process_unsetenv_c(uint8_t *name);
extern int32_t process_getpid_c(void);
extern int32_t process_getppid_c(void);
extern int32_t process_getcwd_c(uint8_t *buf, int32_t buf_size);
extern uint8_t *process_getcwd_ptr_c(void);
extern int32_t process_getcwd_cached_len_c(void);
extern int32_t process_chdir_c(uint8_t *path);
extern int32_t process_self_exe_path_c(uint8_t *buf, int32_t buf_size);
extern uint8_t *process_self_exe_path_ptr_c(void);
extern int32_t process_self_exe_path_cached_len_c(void);
extern int32_t process_spawn_c(uint8_t *program, uint8_t *argv);
extern int32_t process_spawn_io_c(uint8_t *program, uint8_t *argv, ShuxSpawnIo *io);
extern int32_t process_exec_c(uint8_t *program, uint8_t *argv);
extern int32_t process_waitpid_c(int32_t pid);
extern int32_t process_spawn_simple_c(uint8_t *program);
extern int32_t process_exec_simple_c(uint8_t *program);
extern int32_t process_pipe_c(int32_t *read_fd, int32_t *write_fd);

/** exit 由 codegen 特判；此处提供占位以满足 import 符号。 */
int32_t std_process_exit(int32_t code) {
  (void)code;
  return 0;
}

/** args_count；转发 process_args_count_c。 */
int32_t std_process_args_count(void) { return process_args_count_c(); }

/** arg；转发 process_arg_c。 */
uint8_t *std_process_arg(int32_t i) { return process_arg_c(i); }

/** getenv；转发 process_getenv_c。 */
uint8_t *std_process_getenv(uint8_t *name) { return process_getenv_c(name); }

/** setenv；转发 process_setenv_c。 */
int32_t std_process_setenv(uint8_t *name, uint8_t *value, int32_t overwrite) {
  return process_setenv_c(name, value, overwrite);
}

/** unsetenv；转发 process_unsetenv_c。 */
int32_t std_process_unsetenv(uint8_t *name) { return process_unsetenv_c(name); }

/** getpid；转发 process_getpid_c。 */
int32_t std_process_getpid(void) { return process_getpid_c(); }

/** getppid；转发 process_getppid_c。 */
int32_t std_process_getppid(void) { return process_getppid_c(); }

/** getcwd；转发 process_getcwd_c。 */
int32_t std_process_getcwd(uint8_t *buf, int32_t buf_size) { return process_getcwd_c(buf, buf_size); }

/** getcwd_ptr；转发 process_getcwd_ptr_c。 */
uint8_t *std_process_getcwd_ptr(void) { return process_getcwd_ptr_c(); }

/** getcwd_cached_len；转发 process_getcwd_cached_len_c。 */
int32_t std_process_getcwd_cached_len(void) { return process_getcwd_cached_len_c(); }

/** chdir；转发 process_chdir_c。 */
int32_t std_process_chdir(uint8_t *path) { return process_chdir_c(path); }

/** self_exe_path；转发 process_self_exe_path_c。 */
int32_t std_process_self_exe_path(uint8_t *buf, int32_t buf_size) {
  return process_self_exe_path_c(buf, buf_size);
}

/** self_exe_path_ptr；转发 process_self_exe_path_ptr_c。 */
uint8_t *std_process_self_exe_path_ptr(void) { return process_self_exe_path_ptr_c(); }

/** self_exe_path_cached_len；转发 process_self_exe_path_cached_len_c。 */
int32_t std_process_self_exe_path_cached_len(void) { return process_self_exe_path_cached_len_c(); }

/** spawn；转发 process_spawn_c。 */
int32_t std_process_spawn(uint8_t *program, uint8_t *argv) { return process_spawn_c(program, argv); }

/** spawn_io；转发 process_spawn_io_c。 */
int32_t std_process_spawn_io(uint8_t *program, uint8_t *argv, ShuxSpawnIo *io) {
  return process_spawn_io_c(program, argv, io);
}

/** exec；转发 process_exec_c。 */
int32_t std_process_exec(uint8_t *program, uint8_t *argv) { return process_exec_c(program, argv); }

/** waitpid；转发 process_waitpid_c。 */
int32_t std_process_waitpid(int32_t pid) { return process_waitpid_c(pid); }

/** spawn_simple；转发 process_spawn_simple_c。 */
int32_t std_process_spawn_simple(uint8_t *program) { return process_spawn_simple_c(program); }

/** exec_simple；转发 process_exec_simple_c。 */
int32_t std_process_exec_simple(uint8_t *program) { return process_exec_simple_c(program); }

/** pipe；转发 process_pipe_c。 */
int32_t std_process_pipe(int32_t *read_fd, int32_t *write_fd) { return process_pipe_c(read_fd, write_fd); }
