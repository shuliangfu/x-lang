// Minimal entry: import only codegen to exercise coff/backend dep prerun full parse+typeck path.
const codegen = import("codegen");

/**
 * Dummy function so the module is non-empty after import.
 * Returns 0.
 */
function dummy(): i32 {
  return 0;
}
