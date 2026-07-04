/**
 * runtime_log_os.c — F-log OS 胶层（F-ZC：自 std/log/log_os_glue.c 迁入）
 *
 * 多 sink、文件轮转、异步缓冲、log_emit_bytes_c；格式化在 log.x；与 log.o 一并链入。
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <io.h>
#include <fcntl.h>
#define STDERR_FILENO 2
static int log_write_fd(int fd, const void *buf, size_t len) { return (int)_write((int)fd, buf, (unsigned)len); }
#else
#ifndef _WIN32
#include <unistd.h>
#endif
#include <fcntl.h>
#include <sys/stat.h>
static int log_write_fd(int fd, const void *buf, size_t len) { return (int)write(fd, buf, len); }
#endif

/** sink 掩码位（与 mod.x SINK_* 一致）。 */
#define LOG_SINK_STDERR 1
#define LOG_SINK_FILE 2

/** 异步环形缓冲：32 槽 × 512B（STD-106）。 */
#define LOG_ASYNC_SLOTS 32
#define LOG_ASYNC_SLOT_SIZE 512

typedef struct {
  int32_t len;
  uint8_t data[LOG_ASYNC_SLOT_SIZE];
} log_async_slot_t;

static int32_t s_min_level = 0; /* 0=debug, 1=info, 2=warn, 3=error */
static int32_t s_sink_mask = LOG_SINK_STDERR;
static int s_file_fd = -1;
static int s_env_applied = 0;
static char s_file_path[512];
static int32_t s_file_path_len = 0;
static int64_t s_file_bytes = 0;
static int32_t s_rotate_max_bytes = 0;
static int32_t s_rotate_max_backups = 0;
static int32_t s_async_enabled = 0;
static log_async_slot_t s_async_queue[LOG_ASYNC_SLOTS];
static int32_t s_async_count = 0;

/** 前向声明。 */
void log_close_file_sink_c(void);
static int32_t log_write_sync(const void *buf, size_t len);
int32_t log_async_flush_c(void);

/** 首次写日志时读取 SHUX_LOG_MIN_LEVEL（0–3）。 */
static void log_apply_env_once(void) {
  if (s_env_applied) return;
  s_env_applied = 1;
  const char *v = getenv("SHUX_LOG_MIN_LEVEL");
  if (v && v[0]) {
    int l = atoi(v);
    if (l >= 0 && l <= 3) s_min_level = (int32_t)l;
  }
}

void log_set_min_level_c(int32_t level) {
  if (level >= 0 && level <= 3) s_min_level = level;
}

/** 设置活跃 sink 掩码：LOG_SINK_STDERR | LOG_SINK_FILE。 */
void log_set_sink_mask_c(int32_t mask) {
  s_sink_mask = mask;
}

/** 打开追加写文件 sink；path[len] 不必 NUL 结尾。成功 0，失败 -1。 */
int32_t log_set_file_sink_c(const uint8_t *path, int32_t len) {
  log_close_file_sink_c();
  if (!path || len <= 0) return -1;
  char tmp[512];
  if (len >= (int32_t)sizeof(tmp)) len = (int32_t)sizeof(tmp) - 1;
  memcpy(tmp, path, (size_t)len);
  tmp[len] = 0;
  s_file_path_len = len;
  memcpy(s_file_path, tmp, (size_t)len + 1);
  s_file_bytes = 0;
#if !defined(_WIN32) && !defined(_WIN64)
  {
    struct stat st;
    if (stat(tmp, &st) == 0 && st.st_size > 0) s_file_bytes = (int64_t)st.st_size;
  }
#endif
#if defined(_WIN32) || defined(_WIN64)
  s_file_fd = _open(tmp, _O_WRONLY | _O_CREAT | _O_APPEND | _O_BINARY, _S_IWRITE);
#else
  s_file_fd = open(tmp, O_WRONLY | O_CREAT | O_APPEND, 0644);
#endif
  return (s_file_fd >= 0) ? 0 : -1;
}

/** 关闭文件 sink（若已打开）。 */
void log_close_file_sink_c(void) {
  if (s_file_fd >= 0) {
#if defined(_WIN32) || defined(_WIN64)
    _close(s_file_fd);
#else
    close(s_file_fd);
#endif
    s_file_fd = -1;
  }
}

/** 文件 sink 超限时轮转：max_backups=0 截断，1..8 备份 path.N。 */
static int32_t log_do_rotate(void) {
  char oldpath[520];
  char newpath[520];
  int32_t max_b;

  if (s_rotate_max_bytes <= 0 || s_file_path_len <= 0) return 0;
  max_b = s_rotate_max_backups;
  if (max_b < 0) max_b = 0;
  if (max_b > 8) max_b = 8;

  log_close_file_sink_c();

  if (max_b == 0) {
#if defined(_WIN32) || defined(_WIN64)
    s_file_fd = _open(s_file_path, _O_WRONLY | _O_CREAT | _O_TRUNC | _O_BINARY, _S_IWRITE);
#else
    s_file_fd = open(s_file_path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
#endif
  } else {
    snprintf(oldpath, sizeof(oldpath), "%s.%d", s_file_path, max_b);
#if !defined(_WIN32) && !defined(_WIN64)
    unlink(oldpath);
#endif
    for (int32_t i = max_b - 1; i >= 1; i--) {
      snprintf(oldpath, sizeof(oldpath), "%s.%d", s_file_path, i);
      snprintf(newpath, sizeof(newpath), "%s.%d", s_file_path, i + 1);
      rename(oldpath, newpath);
    }
    snprintf(newpath, sizeof(newpath), "%s.1", s_file_path);
    rename(s_file_path, newpath);
#if defined(_WIN32) || defined(_WIN64)
    s_file_fd = _open(s_file_path, _O_WRONLY | _O_CREAT | _O_APPEND | _O_BINARY, _S_IWRITE);
#else
    s_file_fd = open(s_file_path, O_WRONLY | O_CREAT | O_APPEND, 0644);
#endif
  }
  s_file_bytes = 0;
  return (s_file_fd >= 0) ? 0 : -1;
}

/** 同步写文件 sink（含轮转计数）。 */
static int32_t log_write_file_sync(const void *buf, size_t len) {
  if (!(s_sink_mask & LOG_SINK_FILE) || s_file_fd < 0) return 0;
  if (s_rotate_max_bytes > 0 && s_file_bytes + (int64_t)len > s_rotate_max_bytes) {
    if (log_do_rotate() != 0) return -1;
  }
  if (log_write_fd(s_file_fd, buf, len) != (int)len) return -1;
  s_file_bytes += (int64_t)len;
  return 0;
}

/** 同步写所有活跃 sink（不经异步队列）。 */
static int32_t log_write_sync(const void *buf, size_t len) {
  if (s_sink_mask & LOG_SINK_STDERR) {
    if (log_write_fd(STDERR_FILENO, buf, len) != (int)len) return -1;
  }
  if (log_write_file_sync(buf, len) != 0) return -1;
  return 0;
}

/** 入队一行；队列满时先 flush。 */
static int32_t log_async_enqueue(const void *buf, size_t len) {
  if (len > LOG_ASYNC_SLOT_SIZE) return -1;
  if (s_async_count >= LOG_ASYNC_SLOTS) {
    if (log_async_flush_c() != 0) return -1;
    if (s_async_count >= LOG_ASYNC_SLOTS) return -1;
  }
  s_async_queue[s_async_count].len = (int32_t)len;
  memcpy(s_async_queue[s_async_count].data, buf, len);
  s_async_count++;
  return 0;
}

/** 写一行：异步模式下入队，否则直写 sink。 */
static int32_t log_emit_bytes(const void *buf, size_t len) {
  if (s_async_enabled) return log_async_enqueue(buf, len);
  return log_write_sync(buf, len);
}

/** 设置轮转阈值；须先 set_file_sink。成功 0，失败 -1。 */
int32_t log_set_rotate_c(int32_t max_bytes, int32_t max_backups) {
  if (max_bytes < 0 || max_backups < 0 || max_backups > 8) return -1;
  s_rotate_max_bytes = max_bytes;
  s_rotate_max_backups = max_backups;
  return 0;
}

/** 启用/关闭异步缓冲；关闭前先 flush。 */
int32_t log_set_async_enabled_c(int32_t enabled) {
  if (enabled) {
    s_async_enabled = 1;
    return 0;
  }
  if (s_async_enabled) {
    if (log_async_flush_c() != 0) return -1;
    s_async_enabled = 0;
  }
  return 0;
}

/** 刷出异步缓冲到活跃 sink。 */
int32_t log_async_flush_c(void) {
  int32_t i;
  for (i = 0; i < s_async_count; i++) {
    if (log_write_sync(s_async_queue[i].data, (size_t)s_async_queue[i].len) != 0) return -1;
  }
  s_async_count = 0;
  return 0;
}


/** F-log v1：供 log.x 调用的导出桥。 */
void log_apply_env_once_c(void) {
  log_apply_env_once();
}

int32_t log_get_min_level_c(void) {
  log_apply_env_once();
  return s_min_level;
}

int32_t log_emit_bytes_c(const uint8_t *buf, int32_t len) {
  if (!buf || len <= 0) return -1;
  return log_emit_bytes(buf, (size_t)len);
}

extern int32_t log_write_c(int32_t level, const uint8_t *ptr, int32_t len);
extern int32_t log_write_structured_kv_c(const uint8_t *component, int32_t level, const uint8_t *kv_body);

/** STD-053 C 烟测：人类行 + 结构化行 + 级别过滤金样。 */
int32_t log_multi_sink_smoke_c(const char *path) {
  const uint8_t msg_ok[] = "sink_ok";
  const uint8_t filtered[] = "filtered";
  char buf[512];
  size_t total;
  FILE *fp;

  if (!path) return 1;

  log_set_min_level_c(0);
  log_set_sink_mask_c(LOG_SINK_FILE);
  if (log_set_file_sink_c((const uint8_t *)path, (int32_t)strlen(path)) != 0) return 2;
  if (log_write_c(1, msg_ok, 7) != 0) return 3;
  if (log_write_structured_kv_c((const uint8_t *)"std_log_smoke", 1, (const uint8_t *)"event=smoke") != 0) {
    return 4;
  }
  log_close_file_sink_c();

  fp = fopen(path, "r");
  if (!fp) return 5;
  total = fread(buf, 1, sizeof(buf) - 1, fp);
  buf[total] = 0;
  fclose(fp);
  if (!strstr(buf, "[INFO] sink_ok")) return 6;
  if (!strstr(buf, "shux: level=info component=std_log_smoke")) return 7;

  /* 级别过滤：min=WARN 时 INFO "filtered" 不落盘 */
#if !defined(_WIN32) && !defined(_WIN64)
  unlink(path);
#endif
  log_set_min_level_c(2);
  log_set_sink_mask_c(LOG_SINK_FILE);
  if (log_set_file_sink_c((const uint8_t *)path, (int32_t)strlen(path)) != 0) return 8;
  log_write_c(1, filtered, 8);
  if (log_write_c(2, msg_ok, 7) != 0) return 9;
  log_close_file_sink_c();

  fp = fopen(path, "r");
  if (!fp) return 10;
  total = fread(buf, 1, sizeof(buf) - 1, fp);
  buf[total] = 0;
  fclose(fp);
#if !defined(_WIN32) && !defined(_WIN64)
  unlink(path);
#endif
  if (strstr(buf, "filtered")) return 11;
  if (!strstr(buf, "[WARN] sink_ok")) return 12;

  log_set_min_level_c(0);
  log_set_sink_mask_c(LOG_SINK_STDERR);
  return 0;
}

/** STD-106 C 烟测：异步 defer/flush + 文件轮转金样。 */
int32_t log_rotate_async_smoke_c(const char *path) {
  const uint8_t async_msg[] = "async1";
  const uint8_t rotate_msg[] = "rotate_line_xx";
  char path1[520];
  char buf[512];
  size_t total;
  FILE *fp;

  if (!path) return 1;

#if !defined(_WIN32) && !defined(_WIN64)
  unlink(path);
#endif
  snprintf(path1, sizeof(path1), "%s.1", path);
#if !defined(_WIN32) && !defined(_WIN64)
  unlink(path1);
#endif

  log_set_min_level_c(1);
  log_set_sink_mask_c(LOG_SINK_FILE);
  if (log_set_file_sink_c((const uint8_t *)path, (int32_t)strlen(path)) != 0) return 2;

  if (log_set_async_enabled_c(1) != 0) return 3;
  if (log_write_c(1, async_msg, 6) != 0) return 4;

  fp = fopen(path, "r");
  if (fp) {
    total = fread(buf, 1, sizeof(buf) - 1, fp);
    buf[total] = 0;
    fclose(fp);
    if (strstr(buf, "async1")) return 5;
  }

  if (log_async_flush_c() != 0) return 6;

  fp = fopen(path, "r");
  if (!fp) return 7;
  total = fread(buf, 1, sizeof(buf) - 1, fp);
  buf[total] = 0;
  fclose(fp);
  if (!strstr(buf, "[INFO] async1")) return 8;

  log_set_async_enabled_c(0);
  if (log_set_rotate_c(48, 1) != 0) return 9;

  {
    int i;
    for (i = 0; i < 5; i++) {
      if (log_write_c(1, rotate_msg, 14) != 0) return 10;
    }
  }
  log_close_file_sink_c();

  fp = fopen(path1, "r");
  if (!fp) return 11;
  total = fread(buf, 1, sizeof(buf) - 1, fp);
  buf[total] = 0;
  fclose(fp);
  if (!strstr(buf, "rotate_line_xx")) return 12;

#if !defined(_WIN32) && !defined(_WIN64)
  unlink(path);
  unlink(path1);
#endif
  log_set_rotate_c(0, 0);
  log_set_min_level_c(0);
  log_set_sink_mask_c(LOG_SINK_STDERR);
  return 0;
}
