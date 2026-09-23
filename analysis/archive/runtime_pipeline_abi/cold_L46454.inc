/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after leftover-PE type_alias storage unique */

/*
 * wave262 cold twins: ast_pool_type_alias Cap residual pure leave.
 * type_alias unique extracted above with the real seed body; leftover rest
 * does not compile remaining alloc/set/getters (not unique). Hybrid product
 * links pure. Cold full seed compiles BSS in the OR then these helpers in
 * the same TU.
 * Layout ≡ C TypeAliasEntry: name[256]@0 | name_len@256 | target@260.
 * PLATFORM: SHARED freestanding type_alias Cap leave.
 */

static int wave262_ta_find_or_create(void *module) {
  int i;
  int found;
  if (!module)
    return -1;
  found = wave262_ta_find_slot(module);
  if (found >= 0)
    return found;
  for (i = 0; i < WAVE262_TA_SLOTS; i++) {
    if (g_wave262_ta_mod[i] == NULL) {
      g_wave262_ta_mod[i] = module;
      g_wave262_ta_n[i] = 0;
      g_wave262_ta_cap[i] = 0;
      g_wave262_ta_entries[i] = NULL;
      return i;
    }
  }
  return -1;
}

static int wave262_ta_ensure(int slot, int32_t need) {
  int32_t cap;
  int32_t new_cap;
  uint8_t *np;
  uint8_t *old;
  if (slot < 0 || slot >= WAVE262_TA_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  cap = g_wave262_ta_cap[slot];
  if (cap >= need)
    return 1;
  new_cap = cap < 8 ? 8 : cap;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE262_TA_ENTRY_SZ);
  if (!np)
    return 0;
  old = g_wave262_ta_entries[slot];
  if (old && g_wave262_ta_n[slot] > 0)
    memcpy(np, old, (size_t)g_wave262_ta_n[slot] * (size_t)WAVE262_TA_ENTRY_SZ);
  if (old)
    free(old);
  g_wave262_ta_entries[slot] = np;
  g_wave262_ta_cap[slot] = new_cap;
  return 1;
}

static uint8_t *wave262_ta_entry_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE262_TA_SLOTS)
    return NULL;
  if (idx < 0 || idx >= g_wave262_ta_n[slot])
    return NULL;
  if (!g_wave262_ta_entries[slot])
    return NULL;
  return g_wave262_ta_entries[slot] + (size_t)idx * (size_t)WAVE262_TA_ENTRY_SZ;
}

int32_t pipeline_module_type_alias_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *base;
  if (!module)
    return -1;
  s = wave262_ta_find_or_create(module);
  if (s < 0)
    return -1;
  n = g_wave262_ta_n[s];
  if (!wave262_ta_ensure(s, n + 1))
    return -1;
  base = g_wave262_ta_entries[s];
  if (!base)
    return -1;
  memset(base + (size_t)n * (size_t)WAVE262_TA_ENTRY_SZ, 0, (size_t)WAVE262_TA_ENTRY_SZ);
  g_wave262_ta_n[s] = n + 1;
  return n;
}

void pipeline_module_type_alias_set(void *module, int32_t idx, uint8_t *name, int32_t name_len,
                                    int32_t target_type_ref) {
  int s;
  uint8_t *e;
  int32_t i;
  if (!module || !name || name_len <= 0 || name_len > 255)
    return;
  s = wave262_ta_find_slot(module);
  if (s < 0)
    return;
  e = wave262_ta_entry_at(s, idx);
  if (!e)
    return;
  for (i = 0; i < name_len; i++)
    e[i] = name[i];
  for (i = name_len; i < 128; i++)
    e[i] = 0;
  memcpy(e + 256, &name_len, 4);
  memcpy(e + 260, &target_type_ref, 4);
}

int32_t pipeline_module_type_alias_name_len(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t n;
  s = wave262_ta_find_slot(module);
  if (s < 0)
    return 0;
  e = wave262_ta_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&n, e + 256, 4);
  return n;
}

uint8_t pipeline_module_type_alias_name_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *e;
  if (off < 0 || off >= 256)
    return 0;
  s = wave262_ta_find_slot(module);
  if (s < 0)
    return 0;
  e = wave262_ta_entry_at(s, idx);
  if (!e)
    return 0;
  return e[off];
}

int32_t pipeline_module_type_alias_target_ref(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t t;
  s = wave262_ta_find_slot(module);
  if (s < 0)
    return 0;
  e = wave262_ta_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&t, e + 260, 4);
  return t;
}

int32_t pipeline_module_num_type_aliases_at(void *module) {
  int s = wave262_ta_find_slot(module);
  if (s < 0)
    return 0;
  return g_wave262_ta_n[s];
}
/* XLANG_PABI_TYPE_ALIAS_THIN_END */

/*
 * wave263 cold twins: ast_pool_module_import Cap residual pure leave.
 * Freestanding multi-module ImportEntry map (340-byte entries) + select rows.
 * Hybrid product links pure (wave110); cold seed keeps bodies under #ifndef FROM_X.
 * Layout ≡ pure / C ImportEntry LE:
 *   path[256]@0 | path_len@256 | kind@260 | binding[256]@264 | binding_len@520
 *   | select_base@524 | select_count@528
 *   (Cap 4.2.8 sync with pure ImportEntry 532 — 2026-09-13; was 340 with
 *   binding[64], the pure side moved to binding[256] in 2efcc2b9e and this
 *   cold twin kept the 64-byte layout: a 256-byte binding name smashed the
 *   next entry.)
 * Select rows: 64B name + i32 lens (≡ pure, not Cap GrowVec 128B residual).
 * Soft-reset when module.num_imports@8 == 0 (parse / module reset).
 * PLATFORM: SHARED freestanding module_import Cap leave.
 */
/* XLANG_PABI_MODULE_IMPORT_THIN_BEGIN */
#define WAVE263_IMP_SLOTS 128
#define WAVE263_IMP_ENTRY_SZ 532
#define WAVE263_IMP_SEL_ROW 64
static void *g_wave263_imp_mod[WAVE263_IMP_SLOTS];
static int32_t g_wave263_imp_n[WAVE263_IMP_SLOTS];
static int32_t g_wave263_imp_cap[WAVE263_IMP_SLOTS];
static uint8_t *g_wave263_imp_entries[WAVE263_IMP_SLOTS];
static int32_t g_wave263_imp_sel_n[WAVE263_IMP_SLOTS];
static int32_t g_wave263_imp_sel_cap[WAVE263_IMP_SLOTS];
static uint8_t *g_wave263_imp_sel_rows[WAVE263_IMP_SLOTS];
static uint8_t *g_wave263_imp_sel_lens[WAVE263_IMP_SLOTS];

static int32_t wave263_imp_header_n(void *module) {
  int32_t n;
  if (!module)
    return 0;
  memcpy(&n, (uint8_t *)module + 8, 4);
  return n;
}

static void wave263_imp_set_header_n(void *module, int32_t n) {
  if (!module)
    return;
  memcpy((uint8_t *)module + 8, &n, 4);
}

static int wave263_imp_find_slot(void *module) {
  int i;
  if (!module)
    return -1;
  for (i = 0; i < WAVE263_IMP_SLOTS; i++) {
    if (g_wave263_imp_mod[i] == module)
      return i;
  }
  return -1;
}

static void wave263_imp_soft_sync(void *module) {
  int s;
  if (!module || wave263_imp_header_n(module) != 0)
    return;
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return;
  g_wave263_imp_n[s] = 0;
  g_wave263_imp_sel_n[s] = 0;
}

static int wave263_imp_find_or_create(void *module) {
  int i;
  int found;
  if (!module)
    return -1;
  wave263_imp_soft_sync(module);
  found = wave263_imp_find_slot(module);
  if (found >= 0)
    return found;
  for (i = 0; i < WAVE263_IMP_SLOTS; i++) {
    if (g_wave263_imp_mod[i] == NULL) {
      g_wave263_imp_mod[i] = module;
      g_wave263_imp_n[i] = 0;
      g_wave263_imp_cap[i] = 0;
      g_wave263_imp_entries[i] = NULL;
      g_wave263_imp_sel_n[i] = 0;
      g_wave263_imp_sel_cap[i] = 0;
      g_wave263_imp_sel_rows[i] = NULL;
      g_wave263_imp_sel_lens[i] = NULL;
      return i;
    }
  }
  return -1;
}

static int wave263_imp_ensure_entries(int slot, int32_t need) {
  int32_t cap;
  int32_t new_cap;
  uint8_t *np;
  uint8_t *old;
  if (slot < 0 || slot >= WAVE263_IMP_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  cap = g_wave263_imp_cap[slot];
  if (cap >= need)
    return 1;
  new_cap = cap < 8 ? 8 : cap;
  while (new_cap < need)
    new_cap *= 2;
  np = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE263_IMP_ENTRY_SZ);
  if (!np)
    return 0;
  memset(np, 0, (size_t)new_cap * (size_t)WAVE263_IMP_ENTRY_SZ);
  old = g_wave263_imp_entries[slot];
  if (old && g_wave263_imp_n[slot] > 0)
    memcpy(np, old, (size_t)g_wave263_imp_n[slot] * (size_t)WAVE263_IMP_ENTRY_SZ);
  if (old)
    free(old);
  g_wave263_imp_entries[slot] = np;
  g_wave263_imp_cap[slot] = new_cap;
  return 1;
}

static int wave263_imp_ensure_select(int slot, int32_t need) {
  int32_t cap;
  int32_t new_cap;
  uint8_t *nr;
  uint8_t *nl;
  uint8_t *orows;
  uint8_t *olens;
  if (slot < 0 || slot >= WAVE263_IMP_SLOTS)
    return 0;
  if (need <= 0)
    return 1;
  cap = g_wave263_imp_sel_cap[slot];
  if (cap >= need)
    return 1;
  new_cap = cap < 8 ? 8 : cap;
  while (new_cap < need)
    new_cap *= 2;
  nr = (uint8_t *)malloc((size_t)new_cap * (size_t)WAVE263_IMP_SEL_ROW);
  nl = (uint8_t *)malloc((size_t)new_cap * 4u);
  if (!nr || !nl) {
    free(nr);
    free(nl);
    return 0;
  }
  memset(nr, 0, (size_t)new_cap * (size_t)WAVE263_IMP_SEL_ROW);
  memset(nl, 0, (size_t)new_cap * 4u);
  orows = g_wave263_imp_sel_rows[slot];
  olens = g_wave263_imp_sel_lens[slot];
  if (orows && g_wave263_imp_sel_n[slot] > 0)
    memcpy(nr, orows, (size_t)g_wave263_imp_sel_n[slot] * (size_t)WAVE263_IMP_SEL_ROW);
  if (olens && g_wave263_imp_sel_n[slot] > 0)
    memcpy(nl, olens, (size_t)g_wave263_imp_sel_n[slot] * 4u);
  if (orows)
    free(orows);
  if (olens)
    free(olens);
  g_wave263_imp_sel_rows[slot] = nr;
  g_wave263_imp_sel_lens[slot] = nl;
  g_wave263_imp_sel_cap[slot] = new_cap;
  return 1;
}

static uint8_t *wave263_imp_entry_at(int slot, int32_t idx) {
  if (slot < 0 || slot >= WAVE263_IMP_SLOTS)
    return NULL;
  if (idx < 0 || idx >= g_wave263_imp_n[slot])
    return NULL;
  if (!g_wave263_imp_entries[slot])
    return NULL;
  return g_wave263_imp_entries[slot] + (size_t)idx * (size_t)WAVE263_IMP_ENTRY_SZ;
}

void pipeline_module_import_storage_release(void *module) {
  int s = wave263_imp_find_slot(module);
  if (s < 0)
    return;
  if (g_wave263_imp_entries[s])
    free(g_wave263_imp_entries[s]);
  if (g_wave263_imp_sel_rows[s])
    free(g_wave263_imp_sel_rows[s]);
  if (g_wave263_imp_sel_lens[s])
    free(g_wave263_imp_sel_lens[s]);
  g_wave263_imp_mod[s] = NULL;
  g_wave263_imp_entries[s] = NULL;
  g_wave263_imp_sel_rows[s] = NULL;
  g_wave263_imp_sel_lens[s] = NULL;
  g_wave263_imp_n[s] = 0;
  g_wave263_imp_cap[s] = 0;
  g_wave263_imp_sel_n[s] = 0;
  g_wave263_imp_sel_cap[s] = 0;
}

int32_t pipeline_module_import_alloc(void *module) {
  int s;
  int32_t n;
  uint8_t *base;
  if (!module)
    return -1;
  s = wave263_imp_find_or_create(module);
  if (s < 0)
    return -1;
  n = g_wave263_imp_n[s];
  if (!wave263_imp_ensure_entries(s, n + 1))
    return -1;
  base = g_wave263_imp_entries[s];
  if (!base)
    return -1;
  memset(base + (size_t)n * (size_t)WAVE263_IMP_ENTRY_SZ, 0, (size_t)WAVE263_IMP_ENTRY_SZ);
  g_wave263_imp_n[s] = n + 1;
  wave263_imp_set_header_n(module, n + 1);
  return n;
}

void pipeline_module_import_set_path(void *module, int32_t idx, uint8_t *bytes, int32_t len) {
  int s;
  uint8_t *e;
  int32_t i;
  if (!module || !bytes || len <= 0 || len > 255)
    return;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return;
  memset(e, 0, 256);
  for (i = 0; i < len; i++)
    e[i] = bytes[i];
  memcpy(e + 256, &len, 4);
}

int32_t pipeline_module_import_path_len(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t n;
  if (!module)
    return 0;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return 0;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&n, e + 256, 4);
  return n;
}

void pipeline_module_import_path_copy(void *module, int32_t idx, uint8_t *dst, int32_t dst_cap) {
  int s;
  uint8_t *e;
  int32_t n;
  int32_t i;
  if (!dst || dst_cap <= 0)
    return;
  dst[0] = 0;
  if (!module)
    return;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return;
  memcpy(&n, e + 256, 4);
  if (n >= dst_cap)
    n = dst_cap - 1;
  for (i = 0; i < n; i++)
    dst[i] = e[i];
  dst[n] = 0;
}

uint8_t pipeline_module_import_path_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *e;
  int32_t plen;
  if (!module || off < 0)
    return 0;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return 0;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&plen, e + 256, 4);
  if (off >= plen || off >= 256)
    return 0;
  return e[off];
}

void pipeline_module_import_set_kind(void *module, int32_t idx, int32_t kind) {
  int s;
  uint8_t *e;
  if (!module)
    return;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return;
  memcpy(e + 260, &kind, 4);
}

int32_t pipeline_module_import_kind_at(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t k;
  if (!module)
    return 0;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return 0;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&k, e + 260, 4);
  return k;
}

void pipeline_module_import_set_binding_name(void *module, int32_t idx, uint8_t *bytes, int32_t len) {
  int s;
  uint8_t *e;
  int32_t i;
  if (!module || !bytes || len <= 0 || len > 256)
    return;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return;
  memset(e + 264, 0, 256);
  for (i = 0; i < len; i++)
    e[264 + i] = bytes[i];
  memcpy(e + 520, &len, 4);
}

int32_t pipeline_module_import_binding_name_len(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t n;
  if (!module)
    return 0;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return 0;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&n, e + 520, 4);
  return n;
}

uint8_t pipeline_module_import_binding_name_byte_at(void *module, int32_t idx, int32_t off) {
  int s;
  uint8_t *e;
  int32_t bl;
  if (!module || off < 0 || off >= 256)
    return 0;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return 0;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&bl, e + 520, 4);
  if (off >= bl)
    return 0;
  return e[264 + off];
}

void pipeline_module_import_set_select_count(void *module, int32_t idx, int32_t n) {
  int s;
  uint8_t *e;
  if (!module)
    return;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return;
  memcpy(e + 528, &n, 4);
}

int32_t pipeline_module_import_append_select_name(void *module, int32_t idx, uint8_t *bytes, int32_t len) {
  int s;
  uint8_t *e;
  uint8_t *rows;
  uint8_t *lens;
  int32_t scount;
  int32_t vi;
  int32_t n;
  int32_t i;
  int32_t sbase;
  if (!module || !bytes || len <= 0 || idx < 0)
    return -1;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_or_create(module);
  if (s < 0)
    return -1;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return -1;
  memcpy(&scount, e + 528, 4);
  if (scount == 0) {
    sbase = g_wave263_imp_sel_n[s];
    memcpy(e + 524, &sbase, 4);
  }
  vi = g_wave263_imp_sel_n[s];
  if (!wave263_imp_ensure_select(s, vi + 1))
    return -1;
  rows = g_wave263_imp_sel_rows[s];
  lens = g_wave263_imp_sel_lens[s];
  if (!rows || !lens)
    return -1;
  memset(rows + (size_t)vi * (size_t)WAVE263_IMP_SEL_ROW, 0, (size_t)WAVE263_IMP_SEL_ROW);
  n = len > 255 ? 255 : len;
  if (n > WAVE263_IMP_SEL_ROW)
    n = WAVE263_IMP_SEL_ROW;
  for (i = 0; i < n; i++)
    rows[vi * WAVE263_IMP_SEL_ROW + i] = bytes[i];
  memcpy(lens + (size_t)vi * 4u, &n, 4);
  g_wave263_imp_sel_n[s] = vi + 1;
  scount = scount + 1;
  memcpy(e + 528, &scount, 4);
  return scount - 1;
}

int32_t pipeline_module_import_select_count_at(void *module, int32_t idx) {
  int s;
  uint8_t *e;
  int32_t n;
  if (!module)
    return 0;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return 0;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&n, e + 528, 4);
  return n;
}

void pipeline_module_import_set_select_name(void *module, int32_t idx, int32_t sel, uint8_t *bytes,
                                           int32_t len) {
  int s;
  uint8_t *e;
  uint8_t *rows;
  uint8_t *lens;
  int32_t scount;
  int32_t sbase;
  int32_t abs;
  int32_t n;
  int32_t i;
  int32_t ap;
  if (!module || !bytes || len <= 0 || sel < 0)
    return;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_or_create(module);
  if (s < 0)
    return;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return;
  for (;;) {
    memcpy(&scount, e + 528, 4);
    if (scount > sel)
      break;
    ap = pipeline_module_import_append_select_name(module, idx, bytes, len);
    if (ap < 0)
      return;
    memcpy(&scount, e + 528, 4);
    if (sel < scount - 1)
      return;
  }
  memcpy(&sbase, e + 524, 4);
  abs = sbase + sel;
  rows = g_wave263_imp_sel_rows[s];
  lens = g_wave263_imp_sel_lens[s];
  if (!rows || !lens || abs < 0 || abs >= g_wave263_imp_sel_n[s])
    return;
  memset(rows + (size_t)abs * (size_t)WAVE263_IMP_SEL_ROW, 0, (size_t)WAVE263_IMP_SEL_ROW);
  n = len > 255 ? 255 : len;
  if (n > WAVE263_IMP_SEL_ROW)
    n = WAVE263_IMP_SEL_ROW;
  for (i = 0; i < n; i++)
    rows[abs * WAVE263_IMP_SEL_ROW + i] = bytes[i];
  memcpy(lens + (size_t)abs * 4u, &n, 4);
}

int32_t pipeline_module_import_select_name_len(void *module, int32_t idx, int32_t sel) {
  int s;
  uint8_t *e;
  uint8_t *lens;
  int32_t scount;
  int32_t sbase;
  int32_t abs;
  int32_t n;
  if (!module || sel < 0)
    return 0;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return 0;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&scount, e + 528, 4);
  if (sel >= scount)
    return 0;
  memcpy(&sbase, e + 524, 4);
  abs = sbase + sel;
  if (abs < 0 || abs >= g_wave263_imp_sel_n[s])
    return 0;
  lens = g_wave263_imp_sel_lens[s];
  if (!lens)
    return 0;
  memcpy(&n, lens + (size_t)abs * 4u, 4);
  return n;
}

uint8_t pipeline_module_import_select_name_byte_at(void *module, int32_t idx, int32_t sel, int32_t off) {
  int s;
  uint8_t *e;
  uint8_t *rows;
  int32_t scount;
  int32_t sbase;
  int32_t abs;
  int32_t nlen;
  if (!module || sel < 0 || off < 0)
    return 0;
  wave263_imp_soft_sync(module);
  s = wave263_imp_find_slot(module);
  if (s < 0)
    return 0;
  e = wave263_imp_entry_at(s, idx);
  if (!e)
    return 0;
  memcpy(&scount, e + 528, 4);
  if (sel >= scount)
    return 0;
  memcpy(&sbase, e + 524, 4);
  abs = sbase + sel;
  if (abs < 0 || abs >= g_wave263_imp_sel_n[s])
    return 0;
  nlen = pipeline_module_import_select_name_len(module, idx, sel);
  if (off >= nlen || off >= WAVE263_IMP_SEL_ROW)
    return 0;
  rows = g_wave263_imp_sel_rows[s];
  if (!rows)
    return 0;
  return rows[abs * WAVE263_IMP_SEL_ROW + off];
}
/* XLANG_PABI_MODULE_IMPORT_THIN_END */

#endif /* close wave178 FROM_X for leftover-PE enum storage unique */
