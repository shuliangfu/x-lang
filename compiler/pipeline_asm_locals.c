/* ============================================================================
 * pipeline_asm_locals.c — backend asm local slot + block slot sidecar management
 *
 * wave1252 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   AsmLocalSlotEntry/AsmLocalsSidecar + AsmBlockSlotSidecar types
 *   asm_locals_sidecar_get + asm_block_slot_sidecar_get
 *   asm_ctx_local_reset/count/append/name_len/name_byte_at/name_copy64/offset_at/find_offset
 *   pipeline_asm_local_offset_c (backend.x local_offset C impl)
 *   asm_ctx_block_slot_reset/set/get
 *
 * GrowVec-backed sidecar pools replacing fixed locals[24] arrays.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 * Depends on GrowVec + AST_POOL_INIT_CAP (defined in ast_pool.c host TU).
 *
 * PLATFORM: SHARED.
 * ============================================================================ */
/** backend.x：AsmFuncCtx 局部变量 grow 池（替代 locals[24]）。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t offset;
} AsmLocalSlotEntry;

typedef struct {
  void *ctx;
  int used;
  GrowVec slots;
} AsmLocalsSidecar;

#define MAX_ASM_LOCALS_SIDECARS 64

static AsmLocalsSidecar g_asm_locals_sc[MAX_ASM_LOCALS_SIDECARS];

static AsmLocalsSidecar *asm_locals_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_asm_locals_sc[i].used && g_asm_locals_sc[i].ctx == (void *)ctx)
      return &g_asm_locals_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_asm_locals_sc[i].used) {
      g_asm_locals_sc[i].ctx = (void *)ctx;
      g_asm_locals_sc[i].used = 1;
      if (!grow_vec_init(&g_asm_locals_sc[i].slots, sizeof(AsmLocalSlotEntry), AST_POOL_INIT_CAP))
        return NULL;
      return &g_asm_locals_sc[i];
    }
  }
  return NULL;
}

/** 前向声明：块→slot_base 表与 locals 同生命周期，ctx_reset 须一并清空。 */
void asm_ctx_block_slot_reset(uint8_t *ctx);

/** 清空某 AsmFuncCtx 的局部槽 grow 池；同步清空 block_slot 以免跨函数/跨 dep 模块 block_ref 碰撞误跳过 fill。 */
void asm_ctx_local_reset(uint8_t *ctx) {
  AsmLocalsSidecar *sc = asm_locals_sidecar_get(ctx, 0);
  if (sc)
    sc->slots.len = 0;
  asm_ctx_block_slot_reset(ctx);
}

/** 局部槽数量。 */
int32_t asm_ctx_local_count(uint8_t *ctx) {
  AsmLocalsSidecar *sc = asm_locals_sidecar_get(ctx, 0);
  return sc ? sc->slots.len : 0;
}

/** 追加局部槽；返回下标，失败 -1。 */
int32_t asm_ctx_local_append(uint8_t *ctx, uint8_t *name, int32_t name_len, int32_t offset) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  int32_t idx;
  int32_t n;
  int32_t k;
  if (!ctx || !name || name_len <= 0)
    return -1;
  if (!(sc = asm_locals_sidecar_get(ctx, 1)))
    return -1;
  idx = grow_vec_push(&sc->slots);
  if (idx < 0)
    return -1;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  if (!ent)
    return -1;
  memset(ent, 0, sizeof(*ent));
  n = name_len > 127 ? 127 : name_len;
  for (k = 0; k < n; k++)
    ent->name[k] = name[k];
  ent->name_len = name_len;
  ent->offset = offset;
  return idx;
}

int32_t asm_ctx_local_name_len(uint8_t *ctx, int32_t idx) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  if (idx < 0 || !(sc = asm_locals_sidecar_get(ctx, 0)) || idx >= sc->slots.len)
    return 0;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  return ent ? ent->name_len : 0;
}

uint8_t asm_ctx_local_name_byte_at(uint8_t *ctx, int32_t idx, int32_t off) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  if (idx < 0 || off < 0 || !(sc = asm_locals_sidecar_get(ctx, 0)) || idx >= sc->slots.len)
    return 0;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  if (!ent || off >= ent->name_len)
    return 0;
  return ent->name[off];
}

void asm_ctx_local_name_copy64(uint8_t *ctx, int32_t idx, uint8_t *dst) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  int32_t k;
  if (!dst)
    return;
  /* wave581 Cap residual: ABI *copy64; AsmLocalSlotEntry.name is u8[128]. */
  memset(dst, 0, 128);
  if (idx < 0 || !(sc = asm_locals_sidecar_get(ctx, 0)) || idx >= sc->slots.len)
    return;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  if (!ent)
    return;
  for (k = 0; k < ent->name_len && k < 127; k++)
    dst[k] = ent->name[k];
}

int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  if (idx < 0 || !(sc = asm_locals_sidecar_get(ctx, 0)) || idx >= sc->slots.len)
    return 0;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  return ent ? ent->offset : 0;
}

/** 自后向前查局部名，返回栈偏移；未找到返回 -1（内层块同名覆盖外层）。 */
int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len) {
  AsmLocalsSidecar *sc;
  int32_t i;
  int32_t k;
  AsmLocalSlotEntry *ent;
  if (!ctx || !name || name_len <= 0)
    return -1;
  if (!(sc = asm_locals_sidecar_get(ctx, 0)))
    return -1;
  for (i = sc->slots.len - 1; i >= 0; i--) {
    ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, i);
    if (!ent || ent->name_len != name_len)
      continue;
    for (k = 0; k < name_len; k++) {
      if (ent->name[k] != name[k])
        break;
    }
    if (k == name_len)
      return ent->offset;
  }
  return -1;
}

struct backend_AsmFuncCtx;

/**
 * backend.x local_offset 的 C 实现（含零字节占位名回退）；M8-tail 薄包装 bl 目标。
 */
int32_t pipeline_asm_local_offset_c(struct backend_AsmFuncCtx *ctx, uint8_t *name, int32_t name_len) {
  uint8_t *key;
  int32_t nloc;
  int32_t i;
  int32_t k;
  int32_t eq;
  int32_t j;
  int32_t all_zero;
  if (!ctx || !name || name_len <= 0)
    return -1;
  key = (uint8_t *)ctx;
  nloc = asm_ctx_local_count(key);
  for (i = 0; i < nloc; i++) {
    if (asm_ctx_local_name_len(key, i) == name_len) {
      eq = 1;
      for (k = 0; k < name_len && eq != 0; k++) {
        if (name[k] != asm_ctx_local_name_byte_at(key, i, k))
          eq = 0;
      }
      if (eq != 0)
        return asm_ctx_local_offset_at(key, i);
    }
  }
  /** 与 backend.x 一致：name_len<=32 且 sidecar 槽名为全零时仍匹配（自举 tear 修复路径）。 */
  if (name_len > 0 && name_len <= 32) {
    for (j = 0; j < nloc; j++) {
      if (asm_ctx_local_name_len(key, j) == name_len) {
        all_zero = 1;
        for (k = 0; k < name_len && all_zero != 0; k++) {
          if (asm_ctx_local_name_byte_at(key, j, k) != 0)
            all_zero = 0;
        }
        if (all_zero != 0)
          return asm_ctx_local_offset_at(key, j);
      }
    }
  }
  return -1;
}

/** backend.x：块 ref → 该块 const/let 在 sidecar 中的起始槽下标（树遍历 fill 时写入）。 */
typedef struct {
  void *ctx;
  int used;
  GrowVec block_refs;
  GrowVec slot_bases;
} AsmBlockSlotSidecar;

static AsmBlockSlotSidecar g_asm_block_slot_sc[MAX_ASM_LOCALS_SIDECARS];

static AsmBlockSlotSidecar *asm_block_slot_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_asm_block_slot_sc[i].used && g_asm_block_slot_sc[i].ctx == (void *)ctx)
      return &g_asm_block_slot_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_asm_block_slot_sc[i].used) {
      g_asm_block_slot_sc[i].ctx = (void *)ctx;
      g_asm_block_slot_sc[i].used = 1;
      if (!grow_vec_init(&g_asm_block_slot_sc[i].block_refs, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&g_asm_block_slot_sc[i].slot_bases, sizeof(int32_t), AST_POOL_INIT_CAP)) {
        grow_vec_free(&g_asm_block_slot_sc[i].block_refs);
        return NULL;
      }
      return &g_asm_block_slot_sc[i];
    }
  }
  return NULL;
}

/** 清空某 AsmFuncCtx 的块槽基址表（与 asm_ctx_local_reset 同生命周期）。 */
void asm_ctx_block_slot_reset(uint8_t *ctx) {
  AsmBlockSlotSidecar *sc = asm_block_slot_sidecar_get(ctx, 0);
  if (sc) {
    sc->block_refs.len = 0;
    sc->slot_bases.len = 0;
  }
}

/** 记录 block_ref 在 sidecar 中的起始槽下标（fill 前调用）。 */
void asm_ctx_block_slot_set(uint8_t *ctx, int32_t block_ref, int32_t slot_base) {
  AsmBlockSlotSidecar *sc;
  int32_t *pr;
  int32_t *pb;
  if (!ctx || block_ref <= 0)
    return;
  if (!(sc = asm_block_slot_sidecar_get(ctx, 1)))
    return;
  if (grow_vec_push(&sc->block_refs) < 0 || grow_vec_push(&sc->slot_bases) < 0)
    return;
  pr = (int32_t *)grow_vec_at(&sc->block_refs, sc->block_refs.len - 1);
  pb = (int32_t *)grow_vec_at(&sc->slot_bases, sc->slot_bases.len - 1);
  if (pr)
    *pr = block_ref;
  if (pb)
    *pb = slot_base;
}

/** 查 block_ref 的起始槽下标；未登记返回 -1。 */
int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref) {
  AsmBlockSlotSidecar *sc;
  int32_t i;
  int32_t *pr;
  int32_t *pb;
  if (!ctx || block_ref <= 0)
    return -1;
  if (!(sc = asm_block_slot_sidecar_get(ctx, 0)))
    return -1;
  for (i = sc->block_refs.len - 1; i >= 0; i--) {
    pr = (int32_t *)grow_vec_at(&sc->block_refs, i);
    if (!pr || *pr != block_ref)
      continue;
    pb = (int32_t *)grow_vec_at(&sc->slot_bases, i);
    return pb ? *pb : -1;
  }
  return -1;
}
