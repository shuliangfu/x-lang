/**
 * ast_pool_type.c — Type pool cold accessors domain (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (type field read/write + find-or-alloc):
 * - pipeline_type_named_name_into / region_label_into / region_label_len_at
 * - pipeline_type_set_region_label_at / find_or_alloc_slice / find_or_alloc_ptr
 * - pipeline_type_kind_ord_at / elem_ref_at / array_size_at
 *
 * wave1166 G.7: migrated from pipeline_glue.c (was L1041-1153, L2216).
 * Colocated with type pool domain — all read/write ast_Type struct fields
 * via pipeline_arena_type_ptr (defined in ast_pool_arena.c, #include'd
 * before this file at ast_pool.c L886). Forward decls retained in glue.c
 * for callsites before ast_pool.c #include at glue.c L5388.
 *
 * Depends on same-TU: pipeline_arena_type_ptr, pipeline_arena_type_alloc
 * (both in ast_pool_arena.c, included before this file).
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these.
 * Wave: 1166 · no semantic change · pin stays 77b334842.
 */

/**
 * Copy Type.name[64] into out64; return name_len (0 if invalid).
 * Used by typeck/codegen to avoid .x nested array GEP typeck failures.
 */
int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64) {
  struct ast_Type *t;
  if (!arena || !out64 || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  if (!t)
    return 0;
  memcpy(out64, t->name, sizeof(t->name));
  return t->name_len;
}

/**
 * Copy Type.region_label[64] into out64; return region_label_len.
 * Used for TYPE_SLICE region labels and TYPE_PTR stack_local (WPO-S3).
 * Returns 0 for invalid/no label.
 */
int32_t pipeline_type_region_label_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64) {
  struct ast_Type *t;
  if (!arena || !out64 || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  if (!t || t->region_label_len <= 0)
    return 0;
  memcpy(out64, t->region_label, sizeof(t->region_label));
  return t->region_label_len;
}

/**
 * Read Type.region_label_len (slice / PTR region label length).
 * Returns 0 for invalid ref or no label.
 */
int32_t pipeline_type_region_label_len_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  return (t && t->region_label_len > 0) ? t->region_label_len : 0;
}

/**
 * Write region label for a TYPE_SLICE or TYPE_PTR slot (label_len must be 1..127).
 * wave245 G.7 有则补全: TYPE_PTR also carries region_label (stack_local *T).
 * Prefer find_or_alloc_* when allocating a new labelled type so shared
 * unlabelled nodes are never mutated in place.
 * Returns 1 on success, 0 on failure (invalid ref, wrong kind, etc.).
 */
int32_t pipeline_type_set_region_label_at(struct ast_ASTArena *arena, int32_t ref, uint8_t *label,
                                          int32_t label_len) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types || !label || label_len <= 0 || label_len > 127)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  if (!t || (t->kind != ast_TypeKind_TYPE_SLICE && t->kind != ast_TypeKind_TYPE_PTR))
    return 0;
  memset(t->region_label, 0, sizeof(t->region_label));
  memcpy(t->region_label, label, (size_t)label_len);
  t->region_label_len = label_len;
  return 1;
}

/**
 * Find or allocate a TYPE_SLICE for T[]<label> (elem_ref + region).
 * region_len==0 means unlabelled slice T[].
 * Returns existing or new type ref; 0 on failure.
 */
int32_t pipeline_type_find_or_alloc_slice(struct ast_ASTArena *a, int32_t elem_ref, uint8_t *region,
                                          int32_t region_len) {
  int32_t k;
  struct ast_Type *t;
  if (!a)
    return 0;
  if (region_len < 0 || region_len > 127)
    return 0;
  if (region_len > 0 && !region)
    return 0;
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == ast_TypeKind_TYPE_SLICE && t->elem_type_ref == elem_ref && t->array_size == 0 &&
        t->name_len == 0 && t->region_label_len == region_len &&
        (region_len == 0 ||
         (region && memcmp(t->region_label, region, (size_t)region_len) == 0)))
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = ast_TypeKind_TYPE_SLICE;
  t->elem_type_ref = elem_ref;
  if (region_len > 0 && region) {
    memcpy(t->region_label, region, (size_t)region_len);
    t->region_label_len = region_len;
  }
  return k;
}

/**
 * Find or allocate a TYPE_PTR for *elem_ref with optional region label.
 * region_len==0 means unlabelled *T (same key as plain find_or_alloc_ptr).
 * wave245 G.7: single type-pool authority for stack_local *Struct (WPO-S3);
 * Cap residual typeck_find_or_alloc_ptr_stack_local_c deleted after pure leave.
 * Returns existing or new type ref; 0 on failure.
 * PLATFORM: SHARED — host-cc Cap residual type pool face.
 */
int32_t pipeline_type_find_or_alloc_ptr(struct ast_ASTArena *a, int32_t elem_ref, uint8_t *region,
                                        int32_t region_len) {
  int32_t k;
  struct ast_Type *t;
  if (!a || elem_ref <= 0)
    return 0;
  if (region_len < 0 || region_len > 127)
    return 0;
  if (region_len > 0 && !region)
    return 0;
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == ast_TypeKind_TYPE_PTR && t->elem_type_ref == elem_ref && t->array_size == 0 &&
        t->name_len == 0 && t->region_label_len == region_len &&
        (region_len == 0 ||
         (region && memcmp(t->region_label, region, (size_t)region_len) == 0)))
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = ast_TypeKind_TYPE_PTR;
  t->elem_type_ref = elem_ref;
  if (region_len > 0 && region) {
    memcpy(t->region_label, region, (size_t)region_len);
    t->region_label_len = region_len;
  }
  return k;
}

/**
 * Read Type.kind as TypeKind ordinal. Returns -1 for invalid ref.
 * Used everywhere as the primary type kind discriminator.
 */
int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return -1;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? (int32_t)t->kind : -1;
}

/**
 * Read Type.elem_type_ref (pointer element type, vector element type, etc.).
 * Returns 0 for invalid ref.
 */
int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? t->elem_type_ref : 0;
}

/**
 * Read Type.array_size (array length, vector lane count, etc.).
 * Returns 0 for invalid ref.
 */
int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? t->array_size : 0;
}

/* wave1173 G.7: type init/find-or-alloc cluster (6 fns + 1 static helper)
 * migrated from pipeline_glue.c L3100-3235. Colocated with type pool domain
 * — all allocate/find type slots via pipeline_arena_type_alloc +
 * pipeline_arena_type_ptr. The static helper glue_type_kind_from_ord maps
 * a kind ordinal to ast_TypeKind enum (clamped to 0..16).
 *
 * No glue.c callsites for the 5 init/find_or_alloc fns (sole callers are
 * typeck_gen.c / codegen_gen.c seeds via extern). pipeline_type_ensure_by_kind_ord
 * has fwd decl at glue.c L773 (callsites at L7191/L8615-8622, all after
 * ast_pool.c #include at L5058 — fwd decl retained defensively).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * Map a kind ordinal to ast_TypeKind enum (clamped; invalid → TYPE_I32).
 * Why: typeck/codegen pass kind as int32_t for ABI stability; this helper
 *      restores the enum for struct field assignment.
 */
static enum ast_TypeKind glue_type_kind_from_ord(int32_t ord) {
  if (ord < 0 || ord > 16)
    return ast_TypeKind_TYPE_I32;
  return (enum ast_TypeKind)ord;
}

/**
 * Find or allocate a primitive type slot by kind ordinal (no name, no elem).
 * Why: typeck.x needs a C-resident allocator to avoid X struct field writes
 *      that trigger typeck failures during self-host bootstrap.
 * Contract: returns existing or new type ref; 0 on failure (null arena,
 *           kind_ord out of 0..16 range, or arena alloc exhausted).
 */
int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *a, int32_t kind_ord) {
  int32_t k;
  enum ast_TypeKind kind;
  struct ast_Type *t;
  if (!a || kind_ord < 0 || kind_ord > 16)
    return 0;
  kind = glue_type_kind_from_ord(kind_ord);
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == kind && t->name_len == 0 && t->elem_type_ref == 0 && t->array_size == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = kind;
  return k;
}

/**
 * Initialize a pre-allocated primitive type slot (memset + kind).
 * Why: typeck.x performs the dedup scan in X emit; this C helper only writes
 *      the slot to avoid X struct field assignment typeck failures.
 * Contract: returns 1 on success, 0 on failure (invalid ref/kind).
 */
int32_t pipeline_type_init_primitive_kind_at(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord) {
  struct ast_Type *t;
  if (!a || ref <= 0 || ref > a->num_types || kind_ord < 0 || kind_ord > 16)
    return 0;
  t = pipeline_arena_type_ptr(a, ref);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = glue_type_kind_from_ord(kind_ord);
  return 1;
}

/**
 * Initialize a pre-allocated TYPE_NAMED slot (memset + kind + name memcpy).
 * Why: typeck.x performs the name dedup scan in X emit; this C helper writes
 *      the slot fields to avoid X struct field assignment typeck failures.
 * Contract: returns 1 on success, 0 on failure (invalid ref/name/name_len).
 */
int32_t pipeline_type_init_named_at(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len) {
  struct ast_Type *t;
  if (!a || ref <= 0 || ref > a->num_types || !name || name_len <= 0 || name_len > 127)
    return 0;
  t = pipeline_arena_type_ptr(a, ref);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = ast_TypeKind_TYPE_NAMED;
  t->name_len = name_len;
  memcpy(t->name, name, (size_t)name_len);
  return 1;
}

/**
 * Initialize a pre-allocated compound type slot (memset + kind + elem + size).
 * Why: typeck.x performs the compound dedup scan in X emit; this C helper
 *      writes the slot fields to avoid X struct field assignment typeck failures.
 * Contract: returns 1 on success, 0 on failure (invalid ref/kind).
 */
int32_t pipeline_type_init_compound_kind_at(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord,
                                            int32_t elem_ref, int32_t array_size) {
  struct ast_Type *t;
  if (!a || ref <= 0 || ref > a->num_types || kind_ord < 0 || kind_ord > 15)
    return 0;
  t = pipeline_arena_type_ptr(a, ref);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = glue_type_kind_from_ord(kind_ord);
  t->elem_type_ref = elem_ref;
  t->array_size = array_size;
  return 1;
}

/**
 * Find or allocate a TYPE_NAMED slot by name (memcpy name into slot).
 * Why: avoids X writing Type.name field directly (typeck failure during
 *      self-host bootstrap); dedup scan + alloc in C.
 * Contract: returns existing or new type ref; 0 on failure.
 */
int32_t pipeline_type_find_or_alloc_named(struct ast_ASTArena *a, uint8_t *name, int32_t name_len) {
  int32_t k;
  struct ast_Type *t;
  if (!a || !name || name_len <= 0 || name_len > 127)
    return 0;
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == ast_TypeKind_TYPE_NAMED && t->name_len == name_len &&
        memcmp(t->name, name, (size_t)name_len) == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = ast_TypeKind_TYPE_NAMED;
  t->name_len = name_len;
  memcpy(t->name, name, (size_t)name_len);
  return k;
}

/**
 * Find or allocate a compound type (PTR/ARRAY/SLICE/VECTOR) by kind+elem+size.
 * Why: avoids X writing Type struct fields directly; dedup scan + alloc in C.
 * Contract: returns existing or new type ref; 0 on failure.
 */
int32_t pipeline_type_find_or_alloc_compound(struct ast_ASTArena *a, int32_t kind_ord, int32_t elem_ref,
                                             int32_t array_size) {
  int32_t k;
  enum ast_TypeKind kind;
  struct ast_Type *t;
  if (!a || kind_ord < 0 || kind_ord > 15)
    return 0;
  kind = glue_type_kind_from_ord(kind_ord);
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == kind && t->elem_type_ref == elem_ref && t->array_size == array_size && t->name_len == 0 &&
        t->region_label_len == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = kind;
  t->elem_type_ref = elem_ref;
  t->array_size = array_size;
  return k;
}
