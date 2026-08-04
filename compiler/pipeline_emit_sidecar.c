/* pipeline_emit_sidecar.c — emit sidecar 状态域（自 ast_pool.c 抽出）
 *
 * driver_emit_lib_root_*：driver 编排 lib_root 列表（DriverEmitSidecar 池，typedef 在 ast 早期 struct 区）。
 * asm_qual_sym_layer_*：backend import 限定符号 field 层栈（AsmQualSymScratch + GrowVec）。
 * 同 TU #include；公共符号。 */

static DriverEmitSidecar *driver_emit_sidecar_get(uint8_t *state, int create) {
  int i;
  if (!state)
    return NULL;
  for (i = 0; i < MAX_DRIVER_EMIT_SIDECARS; i++) {
    if (g_driver_emit_sc[i].used && g_driver_emit_sc[i].state == state)
      return &g_driver_emit_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_DRIVER_EMIT_SIDECARS; i++) {
    if (!g_driver_emit_sc[i].used) {
      g_driver_emit_sc[i].state = state;
      g_driver_emit_sc[i].used = 1;
      if (!grow_vec_init(&g_driver_emit_sc[i].lib_root_rows, 256, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_driver_emit_sc[i].lib_root_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      return &g_driver_emit_sc[i];
    }
  }
  return NULL;
}

void driver_emit_lib_root_reset(uint8_t *state) {
  DriverEmitSidecar *sc = driver_emit_sidecar_get(state, 0);
  if (!sc)
    return;
  sc->lib_root_rows.len = 0;
  sc->lib_root_lens.len = 0;
}

/**
 * Release the DriverEmitSidecar for `state` (free GrowVecs, mark slot free).
 *
 * Must be called before free(state) for any heap compile/emit state that used
 * driver_emit_append_lib_root. Without this, directory check exhausts the table
 * after MAX_DRIVER_EMIT_SIDECARS sessions and import -L roots stop applying.
 * PLATFORM: SHARED — dual-host check after change.
 */
void driver_emit_lib_root_release(uint8_t *state) {
  int i;
  if (!state)
    return;
  for (i = 0; i < MAX_DRIVER_EMIT_SIDECARS; i++) {
    if (!g_driver_emit_sc[i].used || g_driver_emit_sc[i].state != state)
      continue;
    grow_vec_free(&g_driver_emit_sc[i].lib_root_rows);
    grow_vec_free(&g_driver_emit_sc[i].lib_root_lens);
    g_driver_emit_sc[i].state = NULL;
    g_driver_emit_sc[i].used = 0;
    return;
  }
}

int32_t driver_emit_append_lib_root(uint8_t *state, uint8_t *path, int32_t len) {
  DriverEmitSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!state || !path || len <= 0)
    return -1;
  if (!(sc = driver_emit_sidecar_get(state, 1)))
    return -1;
  idx = grow_vec_push(&sc->lib_root_rows);
  if (idx < 0 || grow_vec_push(&sc->lib_root_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, idx);
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, idx);
  if (!row || !pl)
    return -1;
  n = len > 255 ? 255 : len;
  memset(row, 0, 256);
  memcpy(row, path, (size_t)n);
  *pl = n;
  return idx;
}

int32_t driver_emit_lib_root_count(uint8_t *state) {
  DriverEmitSidecar *sc = driver_emit_sidecar_get(state, 0);
  return sc ? sc->lib_root_rows.len : 0;
}

int32_t driver_emit_lib_root_len(uint8_t *state, int32_t i) {
  DriverEmitSidecar *sc;
  int32_t *pl;
  if (!state || i < 0 || !(sc = driver_emit_sidecar_get(state, 0)) || i >= sc->lib_root_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  return pl ? *pl : 0;
}

void driver_emit_lib_root_copy(uint8_t *state, int32_t i, uint8_t *dst, int32_t cap) {
  DriverEmitSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (!state || i < 0 || !(sc = driver_emit_sidecar_get(state, 0)) || i >= sc->lib_root_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** backend.x：import 限定符号解析时的 field 层栈（替代 [16][64] 栈数组）。 */
typedef struct {
  int inited;
  GrowVec layer_rows;
  GrowVec layer_lens;
} AsmQualSymScratch;

static AsmQualSymScratch g_asm_qual_sym;

/** 惰性初始化 asm 限定符号 scratch 池。 */
static void asm_qual_sym_scratch_ensure(void) {
  if (g_asm_qual_sym.inited)
    return;
  if (!grow_vec_init(&g_asm_qual_sym.layer_rows, 64, AST_POOL_INIT_CAP))
    return;
  if (!grow_vec_init(&g_asm_qual_sym.layer_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
    return;
  g_asm_qual_sym.inited = 1;
}

/** 清空 field 层栈。 */
void asm_qual_sym_layer_reset(void) {
  asm_qual_sym_scratch_ensure();
  g_asm_qual_sym.layer_rows.len = 0;
  g_asm_qual_sym.layer_lens.len = 0;
}

/** 追加一层 field 名（最多 63 字节）；返回层下标，失败 -1。 */
int32_t asm_qual_sym_layer_push(uint8_t *bytes, int32_t len) {
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!bytes || len <= 0)
    return -1;
  asm_qual_sym_scratch_ensure();
  if (!g_asm_qual_sym.inited)
    return -1;
  n = len > 127 ? 127 : len;
  idx = grow_vec_push(&g_asm_qual_sym.layer_rows);
  if (idx < 0 || grow_vec_push(&g_asm_qual_sym.layer_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&g_asm_qual_sym.layer_rows, idx);
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, idx);
  if (!row || !pl)
    return -1;
  memset(row, 0, 64);
  memcpy(row, bytes, (size_t)n);
  *pl = n;
  return idx;
}

/** 当前层数。 */
int32_t asm_qual_sym_layer_count(void) {
  asm_qual_sym_scratch_ensure();
  return g_asm_qual_sym.inited ? g_asm_qual_sym.layer_rows.len : 0;
}

/** 第 i 层 field 名长度。 */
int32_t asm_qual_sym_layer_len(int32_t i) {
  int32_t *pl;
  if (i < 0 || !g_asm_qual_sym.inited || i >= g_asm_qual_sym.layer_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, i);
  return pl ? *pl : 0;
}

/** 拷贝第 i 层 field 名到 dst（cap 含 NUL 余量）。 */
void asm_qual_sym_layer_copy(int32_t i, uint8_t *dst, int32_t cap) {
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (i < 0 || !g_asm_qual_sym.inited || i >= g_asm_qual_sym.layer_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, i);
  row = (uint8_t *)grow_vec_at(&g_asm_qual_sym.layer_rows, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}
