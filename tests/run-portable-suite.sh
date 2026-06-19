#!/usr/bin/env bash
# run-portable-suite.sh — Tier P 便携测试套件（全平台必过）。
#
# 统一 .sx / shux-c 测试，不区分平台写业务代码；平台专有能力在子脚本内自动 N/A。
# 由 tests/run-ci-full-suite.sh 在所有 job 上调用。
#
# 用法：./tests/run-portable-suite.sh [--with-c-regression]
set -e
cd "$(dirname "$0")/.."

WITH_C_REGRESSION=0
for arg in "$@"; do
  case "$arg" in
    --with-c-regression) WITH_C_REGRESSION=1 ;;
    -h|--help)
      echo "Usage: $0 [--with-c-regression]"
      exit 0
      ;;
    *)
      echo "run-portable-suite: unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

echo "run-portable-suite: Tier P (host=$(ci_host_summary))"

# 非 x86_64 / MSYS2：-o 链接优先 shux-c（与 bootstrap-link-shux 一致）。
if ci_is_arm64_host || ci_is_windows_msys; then
  export SHUX_LINK_SHUX=./compiler/shux-c
fi

run_grep() {
  local log="$1"
  local pattern="$2"
  shift 2
  "$@" | tee "$log"
  grep -q "$pattern" "$log"
}

echo "── M-3 region typeck ──"
chmod +x tests/run-typeck-region.sh
run_grep /tmp/typeck_region.log 'region typeck OK' ./tests/run-typeck-region.sh

echo "── migrate sx gen gate ──"
chmod +x tests/run-migrate-sx-gen-gate.sh
run_grep /tmp/migrate_sx_gen.log 'migrate sx gen gate OK' ./tests/run-migrate-sx-gen-gate.sh

echo "── M-4 linear typeck ──"
chmod +x tests/run-typeck-linear.sh
run_grep /tmp/typeck_linear.log 'linear typeck OK' ./tests/run-typeck-linear.sh

echo "── ZC-3 slice field ──"
chmod +x tests/run-slice-field.sh tests/run-slice.sh
run_grep /tmp/slice_field.log 'slice field OK' ./tests/run-slice-field.sh
run_grep /tmp/slice_full.log 'slice test OK' ./tests/run-slice.sh

echo "── stdlib import ──"
chmod +x tests/run-stdlib-import.sh
run_grep /tmp/stdlib_import.log 'stdlib-import test OK' ./tests/run-stdlib-import.sh

echo "── STBL-002 std README sync ──"
chmod +x tests/run-stbl-readme-sync-gate.sh tests/lib/stbl-readme-sync.sh
run_grep /tmp/stbl_readme_sync.log 'stbl-readme-sync gate OK' ./tests/run-stbl-readme-sync-gate.sh

echo "── STBL-001 Tier-S manifest registry ──"
chmod +x tests/run-stbl-001-tier-s-gate.sh tests/lib/stbl-tier-s-registry.sh
run_grep /tmp/stbl_tier_s_gate.log 'stbl-tier-s gate OK' ./tests/run-stbl-001-tier-s-gate.sh

echo "── STBL-003 change RFC template ──"
chmod +x tests/run-stbl-003-change-rfc-template-gate.sh tests/lib/stbl-change-rfc-template.sh
run_grep /tmp/stbl_crfc_gate.log 'stbl-change-rfc-template gate OK' ./tests/run-stbl-003-change-rfc-template-gate.sh

echo "── STBL-004 import std -L layout ──"
chmod +x tests/run-stbl-004-import-std-layout-gate.sh tests/lib/stbl-import-std-layout.sh
run_grep /tmp/stbl_import_std_gate.log 'stbl-import-std-layout gate OK' ./tests/run-stbl-004-import-std-layout-gate.sh

echo "── BOOT-013 stdlib check matrix ──"
chmod +x tests/run-stdlib-check-matrix-gate.sh tests/run-stdlib-check-matrix.sh tests/lib/stdlib-check-matrix.sh
run_grep /tmp/stdlib_check_matrix_gate.log 'stdlib-check-matrix gate OK' ./tests/run-stdlib-check-matrix-gate.sh

echo "── CORE-008 core.mem intrinsic ──"
chmod +x tests/run-core-mem-intrinsic-gate.sh tests/lib/core-mem-intrinsic.sh
run_grep /tmp/core_mem_intrinsic_gate.log 'core-mem-intrinsic gate OK' ./tests/run-core-mem-intrinsic-gate.sh

echo "── CORE-009 core.builtin bitops ──"
chmod +x tests/run-core-builtin-bitops-gate.sh tests/lib/core-builtin-bitops.sh
run_grep /tmp/core_builtin_bitops_gate.log 'core-builtin-bitops gate OK' ./tests/run-core-builtin-bitops-gate.sh

echo "── CORE-010 core.fmt usize/isize/ptr ──"
chmod +x tests/run-core-fmt-widths-gate.sh tests/lib/core-fmt-widths.sh
run_grep /tmp/core_fmt_widths_gate.log 'core-fmt-widths gate OK' ./tests/run-core-fmt-widths-gate.sh

echo "── CORE-011 core.fmt f64 NaN/Inf/prec ──"
chmod +x tests/run-core-fmt-f64-special-gate.sh tests/lib/core-fmt-f64-special.sh
run_grep /tmp/core_fmt_f64_special_gate.log 'core-fmt-f64-special gate OK' ./tests/run-core-fmt-f64-special-gate.sh

echo "── CORE-012 core.debug assert extend ──"
chmod +x tests/run-core-debug-assert-extend-gate.sh tests/lib/core-debug-assert-extend.sh
run_grep /tmp/core_debug_assert_extend_gate.log 'core-debug-assert-extend gate OK' ./tests/run-core-debug-assert-extend-gate.sh

echo "── CORE-013 core.types i16/u16 width ──"
chmod +x tests/run-core-types-i16-u16-gate.sh tests/lib/core-types-i16-u16.sh
run_grep /tmp/core_types_i16_u16_gate.log 'core-types-i16-u16 gate OK' ./tests/run-core-types-i16-u16-gate.sh

echo "── CORE-001 core.types generic layout ──"
chmod +x tests/run-core-types-generic-layout-gate.sh tests/lib/core-types-generic-layout.sh
run_grep /tmp/core_types_gl_gate.log 'core-types-generic-layout gate OK' ./tests/run-core-types-generic-layout-gate.sh

echo "── CORE-002/003 Option/Result combinators ──"
chmod +x tests/run-core-option-result-gate.sh tests/lib/core-option-result.sh
run_grep /tmp/core_option_result_gate.log 'core-option-result gate OK' ./tests/run-core-option-result-gate.sh

echo "── CORE-004 slice subslice/split_at/chunks ──"
chmod +x tests/run-core-slice-api-gate.sh tests/lib/core-slice-api.sh
run_grep /tmp/core_slice_api_gate.log 'core-slice-api gate OK' ./tests/run-core-slice-api-gate.sh

echo "── CORE-005 cmp/Ordering ──"
chmod +x tests/run-core-cmp-ordering-gate.sh tests/lib/core-cmp-ordering.sh
run_grep /tmp/core_cmp_ordering_gate.log 'core-cmp-ordering gate OK' ./tests/run-core-cmp-ordering-gate.sh

echo "── CORE-006 iterator next protocol ──"
chmod +x tests/run-core-iterator-protocol-gate.sh tests/lib/core-iterator-protocol.sh
run_grep /tmp/core_iterator_gate.log 'core-iterator-protocol gate OK' ./tests/run-core-iterator-protocol-gate.sh

echo "── CORE-007 core.str BytesView ──"
chmod +x tests/run-core-str-view-gate.sh tests/lib/core-str-view.sh
run_grep /tmp/core_str_view_gate.log 'core-str-view gate OK' ./tests/run-core-str-view-gate.sh

echo "── STD-131 core.str find/split ──"
chmod +x tests/run-core-str-find-split-gate.sh tests/lib/core-str-find-split.sh
run_grep /tmp/core_str_find_split_gate.log 'core-str-find-split gate OK' ./tests/run-core-str-find-split-gate.sh

echo "── STD-132 std.env platform encoding ──"
chmod +x tests/run-std-env-platform-encoding-gate.sh tests/lib/std-env-platform-encoding.sh
run_grep /tmp/std_env_pe_gate.log 'std-env-platform-encoding gate OK' ./tests/run-std-env-platform-encoding-gate.sh

echo "── STD-133 std.time bench timer ──"
chmod +x tests/run-std-time-bench-timer-gate.sh tests/lib/std-time-bench-timer.sh
run_grep /tmp/std_time_bench_gate.log 'std-time-bench-timer gate OK' ./tests/run-std-time-bench-timer-gate.sh

echo "── STD-134 std.url IPv6 bracket host ──"
chmod +x tests/run-std-url-ipv6-host-gate.sh tests/lib/std-url-ipv6-host.sh
run_grep /tmp/std_url_ipv6_gate.log 'std-url-ipv6-host gate OK' ./tests/run-std-url-ipv6-host-gate.sh

echo "── STD-135 std.datetime timezone ──"
chmod +x tests/run-std-datetime-timezone-gate.sh tests/lib/std-datetime-timezone.sh
run_grep /tmp/std_dt_tz_gate.log 'std-datetime-timezone gate OK' ./tests/run-std-datetime-timezone-gate.sh

echo "── STD-136 std manifest/gate registry ──"
chmod +x tests/run-std-api-gate.sh tests/lib/std-api.sh
run_grep /tmp/std_api_gate.log 'std-api gate OK' ./tests/run-std-api-gate.sh

echo "── STD-137 std.time format/timezone ──"
chmod +x tests/run-std-time-format-timezone-gate.sh tests/lib/std-time-format-timezone.sh
run_grep /tmp/std_time_ftz_gate.log 'std-time-format-timezone gate OK' ./tests/run-std-time-format-timezone-gate.sh

echo "── STD-138 xplat deep boundary ──"
chmod +x tests/run-std-xplat-deep-boundary-gate.sh tests/lib/std-xplat-deep-boundary.sh
run_grep /tmp/std_xplat_deep_gate.log 'xplat-deep-boundary gate OK' ./tests/run-std-xplat-deep-boundary-gate.sh

echo "── STD-139 codec buffer reuse ──"
chmod +x tests/run-std-codec-buffer-reuse-gate.sh tests/lib/std-codec-buffer-reuse.sh
run_grep /tmp/std_codec_br_gate.log 'std-codec-buffer-reuse gate OK' ./tests/run-std-codec-buffer-reuse-gate.sh

echo "── STD-140 path extreme clean ──"
chmod +x tests/run-std-path-extreme-gate.sh tests/lib/std-path-extreme.sh
run_grep /tmp/std_path_extreme_gate.log 'std-path-extreme gate OK' ./tests/run-std-path-extreme-gate.sh

echo "── STD-141 docs/07 Phase 2 sync ──"
chmod +x tests/run-doc-07-phase2-sync-gate.sh tests/lib/doc-07-phase2-sync.sh
run_grep /tmp/std141_doc07_gate.log 'doc-07-phase2-sync gate OK' ./tests/run-doc-07-phase2-sync-gate.sh

echo "── STD-171 docs/07 Phase 3 sync ──"
chmod +x tests/run-doc-07-phase3-sync-gate.sh tests/lib/doc-07-phase3-sync.sh
run_grep /tmp/std171_doc07_gate.log 'doc-07-phase3-sync gate OK' ./tests/run-doc-07-phase3-sync-gate.sh

echo "── STD-142 process xplat ──"
chmod +x tests/run-std-process-xplat-gate.sh tests/lib/std-process-xplat.sh
run_grep /tmp/std_proc_xplat_gate.log 'std-process-xplat gate OK' ./tests/run-std-process-xplat-gate.sh

echo "── CORE-014 core full-module manifest ──"
chmod +x tests/run-core-api-gate.sh tests/lib/core-api.sh
run_grep /tmp/core_api_gate.log 'core-api gate OK' ./tests/run-core-api-gate.sh

echo "── CORE-015 core README / docs/07 sync ──"
chmod +x tests/run-core-readme-sync-gate.sh tests/lib/core-readme-sync.sh
run_grep /tmp/core_readme_sync_gate.log 'core-readme-sync gate OK' ./tests/run-core-readme-sync-gate.sh

echo "── STD-013/014 map/vec extend ──"
chmod +x tests/run-std-map-vec-extend-gate.sh tests/lib/std-map-vec-extend.sh
run_grep /tmp/std_map_vec_extend_gate.log 'std-map-vec-extend gate OK' ./tests/run-std-map-vec-extend-gate.sh

echo "── STD-015 std.set extend ──"
chmod +x tests/run-std-set-extend-gate.sh tests/lib/std-set-extend.sh
run_grep /tmp/std_set_extend_gate.log 'std-set-extend gate OK' ./tests/run-std-set-extend-gate.sh

echo "── STD-129 set union/intersect/difference ──"
chmod +x tests/run-std-set-ops-gate.sh tests/lib/std-set-ops.sh
run_grep /tmp/std_set_ops_gate.log 'std-set-ops gate OK' ./tests/run-std-set-ops-gate.sh

echo "── STD-017 std.heap trace ──"
chmod +x tests/run-std-heap-trace-gate.sh tests/lib/std-heap-trace.sh
run_grep /tmp/std_heap_trace_gate.log 'std-heap-trace gate OK' ./tests/run-std-heap-trace-gate.sh

echo "── STD-112 heap Allocator trait ──"
chmod +x tests/run-std-heap-allocator-gate.sh tests/lib/std-heap-allocator.sh
run_grep /tmp/std_heap_alloc_gate.log 'std-heap-allocator gate OK' ./tests/run-std-heap-allocator-gate.sh

echo "── STD-019 std.fmt multi format ──"
chmod +x tests/run-std-fmt-multi-gate.sh tests/lib/std-fmt-multi.sh tests/run-types-gate.sh
run_grep /tmp/types_gate.log 'types gate OK' ./tests/run-types-gate.sh
run_grep /tmp/std_fmt_multi_gate.log 'std-fmt-multi gate OK' ./tests/run-std-fmt-multi-gate.sh

echo "── STD-020 std.error map / last_error ──"
chmod +x tests/run-std-error-map-gate.sh tests/lib/std-error-map.sh
run_grep /tmp/std_error_map_gate.log 'std-error-map gate OK' ./tests/run-std-error-map-gate.sh

echo "── STD-025 std.env env_iter / args_iter ──"
chmod +x tests/run-std-env-iter-gate.sh tests/lib/std-env-iter.sh
run_grep /tmp/std_env_iter_gate.log 'std-env-iter gate OK' ./tests/run-std-env-iter-gate.sh

echo "── STD-130 random PRNG ──"
chmod +x tests/run-std-random-rng-gate.sh tests/lib/std-random-rng.sh
run_grep /tmp/std_random_rng_gate.log 'std-random-rng gate OK' ./tests/run-std-random-rng-gate.sh

echo "── STD-026 std.io fallback matrix (macOS/Windows) ──"
chmod +x tests/run-std-io-fallback-gate.sh tests/lib/std-io-fallback.sh
run_grep /tmp/std_io_fallback_gate.log 'std-io-fallback gate OK' ./tests/run-std-io-fallback-gate.sh

echo "── STD-027 std.dynlib Windows LoadLibrary ──"
chmod +x tests/run-std-dynlib-windows-gate.sh tests/lib/std-dynlib-windows.sh
run_grep /tmp/std_dynlib_win_gate.log 'std-dynlib-windows gate OK' ./tests/run-std-dynlib-windows-gate.sh

echo "── STD-028 std.runtime panic hook / EXC-002 ──"
chmod +x tests/run-std-runtime-panic-hook-gate.sh tests/lib/std-runtime-panic-hook.sh
run_grep /tmp/std_runtime_panic_gate.log 'std-runtime-panic gate OK' ./tests/run-std-runtime-panic-hook-gate.sh

echo "── STD-016 StrView ZC-4 integration ──"
chmod +x tests/run-std-strview-zc4-gate.sh tests/lib/std-strview-zc4.sh
run_grep /tmp/std_strview_zc4_gate.log 'std-strview-zc4 gate OK' ./tests/run-std-strview-zc4-gate.sh

echo "── STD-021/022 path/fs Windows ──"
chmod +x tests/run-std-path-fs-windows-gate.sh tests/lib/std-path-fs-windows.sh
run_grep /tmp/std_path_fs_win_gate.log 'std-path-fs-windows gate OK' ./tests/run-std-path-fs-windows-gate.sh

echo "── STD-023/024 process pipe/spawn ──"
chmod +x tests/run-std-process-pipe-spawn-gate.sh tests/lib/std-process-pipe-spawn.sh
run_grep /tmp/std_process_pps_gate.log 'std-process-pipe-spawn gate OK' ./tests/run-std-process-pipe-spawn-gate.sh

echo "── STD-034 json object/array ──"
chmod +x tests/run-std-json-object-array-gate.sh tests/lib/std-json-object-array.sh
run_grep /tmp/std_json_oa_gate.log 'std-json-object-array gate OK' ./tests/run-std-json-object-array-gate.sh

echo "── STD-035 json serialize ──"
chmod +x tests/run-std-json-serialize-gate.sh tests/lib/std-json-serialize.sh
run_grep /tmp/std_json_sz_gate.log 'std-json-serialize gate OK' ./tests/run-std-json-serialize-gate.sh

echo "── STD-116 json typed decode ──"
chmod +x tests/run-std-json-typed-decode-gate.sh tests/lib/std-json-typed-decode.sh
run_grep /tmp/std_json_typed_gate.log 'std-json-typed-decode gate OK' ./tests/run-std-json-typed-decode-gate.sh

echo "── STD-117 metrics obs correlation ──"
chmod +x tests/run-std-metrics-obs-gate.sh tests/lib/std-metrics-obs.sh
run_grep /tmp/std_metrics_obs_gate.log 'std-metrics-obs gate OK' ./tests/run-std-metrics-obs-gate.sh

echo "── STD-118 trace io/net/async hooks ──"
chmod +x tests/run-std-trace-hooks-gate.sh tests/lib/std-trace-hooks.sh
run_grep /tmp/std_trace_hooks_gate.log 'std-trace-hooks gate OK' ./tests/run-std-trace-hooks-gate.sh

echo "── STD-119 config YAML backend ──"
chmod +x tests/run-std-config-yaml-gate.sh tests/lib/std-config-yaml.sh
run_grep /tmp/std_config_yaml_gate.log 'std-config-yaml gate OK' ./tests/run-std-config-yaml-gate.sh

echo "── STD-120 std.db compat shim ──"
chmod +x tests/run-std-db-compat-gate.sh tests/lib/std-db-compat.sh
run_grep /tmp/std_db_compat_gate.log 'std-db-compat gate OK' ./tests/run-std-db-compat-gate.sh

echo "── STD-036 csv parse_row/write_row ──"
chmod +x tests/run-std-csv-row-gate.sh tests/lib/std-csv-row.sh
run_grep /tmp/std_csv_row_gate.log 'std-csv-row gate OK' ./tests/run-std-csv-row-gate.sh

echo "── STD-128 csv stream reader/writer ──"
chmod +x tests/run-std-csv-stream-gate.sh tests/lib/std-csv-stream.sh
run_grep /tmp/std_csv_stream_gate.log 'std-csv-stream gate OK' ./tests/run-std-csv-stream-gate.sh

echo "── STD-038 tar ustar traverse/extract ──"
chmod +x tests/run-std-tar-ustar-gate.sh tests/lib/std-tar-ustar.sh
run_grep /tmp/std_tar_ustar_gate.log 'std-tar-ustar gate OK' ./tests/run-std-tar-ustar-gate.sh

echo "── STD-152 tar long path / pax / dir ──"
chmod +x tests/run-std-tar-extended-gate.sh tests/lib/std-tar-extended.sh
run_grep /tmp/std_tar_extended_gate.log 'std-tar-extended gate OK' ./tests/run-std-tar-extended-gate.sh

echo "── STD-031 net WebSocket client draft ──"
chmod +x tests/run-std-net-ws-gate.sh tests/lib/std-net-ws.sh
run_grep /tmp/std_net_ws_gate.log 'std-net-ws gate OK' ./tests/run-std-net-ws-gate.sh

echo "── STD-030 net TLS prereq stub ──"
chmod +x tests/run-std-net-tls-gate.sh tests/lib/std-net-tls.sh
run_grep /tmp/std_net_tls_gate.log 'std-net-tls gate OK' ./tests/run-std-net-tls-gate.sh

echo "── STD-029 net DNS / IPv6 resolve ──"
chmod +x tests/run-std-net-dns-gate.sh tests/lib/std-net-dns.sh
run_grep /tmp/std_net_dns_gate.log 'std-net-dns gate OK' ./tests/run-std-net-dns-gate.sh

echo "── STD-037 unicode NFC / supplementary ──"
chmod +x tests/run-std-unicode-nfc-gate.sh tests/lib/std-unicode-nfc.sh
run_grep /tmp/std_unicode_nfc_gate.log 'std-unicode-nfc gate OK' ./tests/run-std-unicode-nfc-gate.sh

echo "── STD-114 unicode grapheme / case fold ──"
chmod +x tests/run-std-unicode-grapheme-case-gate.sh tests/lib/std-unicode-grapheme-case.sh
run_grep /tmp/std_unicode_grapheme_case_gate.log 'std-unicode-grapheme-case gate OK' ./tests/run-std-unicode-grapheme-case-gate.sh

echo "── STD-039 compress gzip stream round-trip ──"
chmod +x tests/run-std-compress-stream-gate.sh tests/lib/std-compress-stream.sh
run_grep /tmp/std_compress_stream_gate.log 'std-compress-stream gate OK' ./tests/run-std-compress-stream-gate.sh

echo "── STD-122 compress unified stream API ──"
chmod +x tests/run-std-compress-unified-stream-gate.sh tests/lib/std-compress-unified-stream.sh
run_grep /tmp/std_compress_unified_stream_gate.log 'std-compress-unified-stream gate OK' ./tests/run-std-compress-unified-stream-gate.sh

echo "── STD-123 fs dir/meta stat readdir ──"
chmod +x tests/run-std-fs-dirmeta-gate.sh tests/lib/std-fs-dirmeta.sh
run_grep /tmp/std_fs_dirmeta_gate.log 'std-fs-dirmeta gate OK' ./tests/run-std-fs-dirmeta-gate.sh

echo "── STD-124 regex atomic group (?>) ──"
chmod +x tests/run-std-regex-atomic-gate.sh tests/lib/std-regex-atomic.sh
run_grep /tmp/std_regex_atomic_gate.log 'std-regex-atomic gate OK' ./tests/run-std-regex-atomic-gate.sh

echo "── STD-125 compress Brotli optional backend ──"
chmod +x tests/run-std-compress-brotli-gate.sh tests/lib/std-compress-brotli.sh
run_grep /tmp/std_compress_brotli_gate.log 'std-compress-brotli gate OK' ./tests/run-std-compress-brotli-gate.sh

echo "── STD-136 compress brotli/zstd stream ──"
chmod +x tests/run-std-compress-brotli-zstd-stream-gate.sh
run_grep /tmp/std_compress_br_zs_stream_gate.log 'std-compress-brotli-zstd-stream gate OK' ./tests/run-std-compress-brotli-zstd-stream-gate.sh

echo "── STD-040 encoding hex/base64 string interop ──"
chmod +x tests/run-std-encoding-hex-base64-gate.sh tests/lib/std-encoding-hex-base64.sh
run_grep /tmp/std_encoding_hex_b64_gate.log 'std-encoding-hex-b64 gate OK' ./tests/run-std-encoding-hex-base64-gate.sh

echo "── STD-127 encoding Base32/percent ──"
chmod +x tests/run-std-encoding-extra-gate.sh tests/lib/std-encoding-extra.sh
run_grep /tmp/std_encoding_extra_gate.log 'std-encoding-extra gate OK' ./tests/run-std-encoding-extra-gate.sh

echo "── STD-109 base64 stream ──"
chmod +x tests/run-std-base64-stream-gate.sh tests/lib/std-base64-stream.sh
run_grep /tmp/std_base64_stream_gate.log 'std-base64-stream gate OK' ./tests/run-std-base64-stream-gate.sh

echo "── STD-110 codec compress/base64 stream ──"
chmod +x tests/run-std-codec-stream-gate.sh tests/lib/std-codec-stream.sh
run_grep /tmp/std_codec_stream_gate.log 'std-codec-stream gate OK' ./tests/run-std-codec-stream-gate.sh

echo "── STD-033 http chunked / keep-alive ──"
chmod +x tests/run-std-http-chunked-gate.sh tests/lib/std-http-chunked.sh
run_grep /tmp/std_http_chunked_gate.log 'std-http-chunked gate OK' ./tests/run-std-http-chunked-gate.sh

echo "── STD-032 http POST/HEAD/status ──"
chmod +x tests/run-std-http-methods-gate.sh tests/lib/std-http-methods.sh
run_grep /tmp/std_http_methods_gate.log 'std-http-methods gate OK' ./tests/run-std-http-methods-gate.sh

echo "── STD-107 http server + client pool ──"
chmod +x tests/run-std-http-server-pool-gate.sh tests/lib/std-http-server-pool.sh
run_grep /tmp/std_http_server_pool_gate.log 'std-http-server-pool gate OK' ./tests/run-std-http-server-pool-gate.sh

echo "── STD-041 async language bridge ──"
chmod +x tests/run-std-async-language-gate.sh tests/lib/std-async-language.sh
run_grep /tmp/std_async_lang_gate.log 'std-async-language gate OK' ./tests/run-std-async-language-gate.sh

echo "── STD-042 async IO CPS / std.io align ──"
chmod +x tests/run-std-async-io-cps-gate.sh tests/lib/std-async-io-cps.sh
run_grep /tmp/std_async_io_cps_gate.log 'std-async-io-cps gate OK' ./tests/run-std-async-io-cps-gate.sh

echo "── STD-043 thread pool / named thread ──"
chmod +x tests/run-std-thread-pool-gate.sh tests/lib/std-thread-pool.sh
run_grep /tmp/std_thread_pool_gate.log 'std-thread-pool gate OK' ./tests/run-std-thread-pool-gate.sh

echo "── STD-044 channel unbounded / close semantics ──"
chmod +x tests/run-std-channel-unbounded-gate.sh tests/lib/std-channel-unbounded.sh
run_grep /tmp/std_channel_unbounded_gate.log 'std-channel-unbounded gate OK' ./tests/run-std-channel-unbounded-gate.sh

echo "── STD-098 channel select (2-way) ──"
chmod +x tests/run-std-channel-select-gate.sh tests/lib/std-channel-select.sh
run_grep /tmp/std_channel_select_gate.log 'std-channel-select gate OK' ./tests/run-std-channel-select-gate.sh

echo "── STD-045 sync RwLock/Condvar ──"
chmod +x tests/run-std-sync-rwlock-condvar-gate.sh tests/lib/std-sync-rwlock-condvar.sh
run_grep /tmp/std_sync_rwlock_condvar_gate.log 'std-sync-rwlock-condvar gate OK' ./tests/run-std-sync-rwlock-condvar-gate.sh

echo "── STD-111 sync lock diag ──"
chmod +x tests/run-std-sync-lock-diag-gate.sh tests/lib/std-sync-lock-diag.sh
run_grep /tmp/std_sync_lock_diag_gate.log 'std-sync-lock-diag gate OK' ./tests/run-std-sync-lock-diag-gate.sh

echo "── STD-046 atomic ordering / fence ──"
chmod +x tests/run-std-atomic-ordering-gate.sh tests/lib/std-atomic-ordering.sh
run_grep /tmp/std_atomic_ordering_gate.log 'std-atomic-ordering gate OK' ./tests/run-std-atomic-ordering-gate.sh

echo "── STD-146 atomic i16/u16 i64/u64 widen ──"
chmod +x tests/run-std-atomic-widen-gate.sh tests/lib/std-atomic-widen.sh
run_grep /tmp/std_atomic_widen_gate.log 'std-atomic-widen gate OK' ./tests/run-std-atomic-widen-gate.sh

echo "── STD-047 simd shuffle/select ──"
chmod +x tests/run-std-simd-shuffle-select-gate.sh tests/lib/std-simd-shuffle-select.sh
run_grep /tmp/std_simd_shuffle_select_gate.log 'std-simd-shuffle-select gate OK' ./tests/run-std-simd-shuffle-select-gate.sh

echo "── STD-SIMD-INTRINSIC simd mul/sub/dot ──"
chmod +x tests/run-std-simd-intrinsic-gate.sh tests/lib/std-simd-intrinsic.sh
run_grep /tmp/std_simd_intrinsic_gate.log 'std-simd-intrinsic gate OK' ./tests/run-std-simd-intrinsic-gate.sh

echo "── STD-061 simd prod bench ──"
chmod +x tests/run-std-simd-prod-gate.sh tests/run-perf-simd-shuffle-select.sh tests/lib/std-simd-prod.sh
run_grep /tmp/std_simd_prod_gate.log 'std-simd-prod gate OK' ./tests/run-std-simd-prod-gate.sh

echo "── STD-153 simd autovec strategy / xplat perf ──"
chmod +x tests/run-std-simd-autovec-strategy-gate.sh tests/lib/std-simd-autovec-strategy.sh
run_grep /tmp/std_simd_autovec_gate.log 'std-simd-autovec gate OK' ./tests/run-std-simd-autovec-strategy-gate.sh

echo "── STD-048 queue concurrent wrapper ──"
chmod +x tests/run-std-queue-concurrent-gate.sh tests/lib/std-queue-concurrent.sh
run_grep /tmp/std_queue_concurrent_gate.log 'std-queue-concurrent gate OK' ./tests/run-std-queue-concurrent-gate.sh

echo "── STD-049 crypto AES-GCM ──"
chmod +x tests/run-std-crypto-aes-gcm-gate.sh tests/lib/std-crypto-aes-gcm.sh
run_grep /tmp/std_crypto_aes_gcm_gate.log 'std-crypto-aes-gcm gate OK' ./tests/run-std-crypto-aes-gcm-gate.sh

echo "── STD-113 crypto ChaCha20-Poly1305 ──"
chmod +x tests/run-std-crypto-chacha20-poly1305-gate.sh tests/lib/std-crypto-chacha20-poly1305.sh
run_grep /tmp/std_crypto_chacha_gate.log 'std-crypto-chacha20-poly1305 gate OK' ./tests/run-std-crypto-chacha20-poly1305-gate.sh

echo "── STD-126 crypto Ed25519 ──"
chmod +x tests/run-std-crypto-ed25519-gate.sh tests/lib/std-crypto-ed25519.sh
run_grep /tmp/std_crypto_ed25519_gate.log 'std-crypto-ed25519 gate OK' ./tests/run-std-crypto-ed25519-gate.sh

echo "── STD-050 crypto SHA-512 / HMAC ──"
chmod +x tests/run-std-crypto-sha512-hmac-gate.sh tests/lib/std-crypto-sha512-hmac.sh
run_grep /tmp/std_crypto_sha512_hmac_gate.log 'std-crypto-sha512-hmac gate OK' ./tests/run-std-crypto-sha512-hmac-gate.sh

echo "── STD-051 regex pure engine ──"
chmod +x tests/run-std-regex-gate.sh tests/lib/std-regex.sh
run_grep /tmp/std_regex_gate.log 'std-regex gate OK' ./tests/run-std-regex-gate.sh

echo "── STD-062 regex perf bench ──"
chmod +x tests/run-std-regex-perf-gate.sh tests/run-perf-regex-match.sh tests/lib/std-regex-perf.sh
run_grep /tmp/std_regex_perf_gate.log 'std-regex-perf gate OK' ./tests/run-std-regex-perf-gate.sh

echo "── STD-052 backtrace symbolicate ──"
chmod +x tests/run-std-backtrace-symbolicate-gate.sh tests/lib/std-backtrace-symbolicate.sh
run_grep /tmp/std_backtrace_sym_gate.log 'std-backtrace-symbolicate gate OK' ./tests/run-std-backtrace-symbolicate-gate.sh

echo "── STD-147 backtrace xplat symbol quality ──"
chmod +x tests/run-std-backtrace-xplat-gate.sh tests/lib/std-backtrace-xplat.sh
run_grep /tmp/std_backtrace_xplat_gate.log 'std-backtrace-xplat gate OK' ./tests/run-std-backtrace-xplat-gate.sh

echo "── STD-053 log multi-sink ──"
chmod +x tests/run-std-log-multi-sink-gate.sh tests/lib/std-log-multi-sink.sh
run_grep /tmp/std_log_multi_sink_gate.log 'std-log-multi-sink gate OK' ./tests/run-std-log-multi-sink-gate.sh

echo "── STD-106 log rotate-async ──"
chmod +x tests/run-std-log-rotate-async-gate.sh tests/lib/std-log-rotate-async.sh
run_grep /tmp/std_log_rotate_async_gate.log 'std-log-rotate-async gate OK' ./tests/run-std-log-rotate-async-gate.sh

echo "── STD-054 test bench/fuzz ──"
chmod +x tests/run-std-test-bench-fuzz-gate.sh tests/lib/std-test-bench-fuzz.sh
run_grep /tmp/std_test_bench_fuzz_gate.log 'std-test-bench-fuzz gate OK' ./tests/run-std-test-bench-fuzz-gate.sh

echo "── STD-143 test executable bench/fuzz ──"
chmod +x tests/run-std-test-executable-gate.sh tests/lib/std-test-executable.sh
run_grep /tmp/std_test_exec_gate.log 'std-test-executable gate OK' ./tests/run-std-test-executable-gate.sh

echo "── STD-145 test unified runner ──"
chmod +x tests/run-std-test-runner-gate.sh tests/lib/std-test-runner.sh
run_grep /tmp/std_test_runner_gate.log 'std-test-runner gate OK' ./tests/run-std-test-runner-gate.sh

echo "── STD-055 ffi CString lifecycle ──"
chmod +x tests/run-std-ffi-cstring-lifecycle-gate.sh tests/lib/std-ffi-cstring-lifecycle.sh
run_grep /tmp/std_ffi_cstring_gate.log 'std-ffi-cstring gate OK' ./tests/run-std-ffi-cstring-lifecycle-gate.sh

echo "── STD-151 ffi struct/callback ──"
chmod +x tests/run-std-ffi-struct-callback-gate.sh tests/lib/std-ffi-struct-callback.sh
run_grep /tmp/std_ffi_struct_cb_gate.log 'std-ffi-struct-callback gate OK' ./tests/run-std-ffi-struct-callback-gate.sh

echo "── STD-056 hash hasher trait ──"
chmod +x tests/run-std-hash-hasher-trait-gate.sh tests/lib/std-hash-hasher-trait.sh
run_grep /tmp/std_hash_hasher_trait_gate.log 'std-hash-hasher-trait gate OK' ./tests/run-std-hash-hasher-trait-gate.sh

echo "── STD-148 hash default strategy ──"
chmod +x tests/run-std-hash-default-strategy-gate.sh tests/lib/std-hash-default-strategy.sh
run_grep /tmp/std_hash_default_strategy_gate.log 'std-hash-default-strategy gate OK' ./tests/run-std-hash-default-strategy-gate.sh

echo "── STD-057 db SQLite3 prototype ──"
chmod +x tests/run-std-sqlite-gate.sh tests/lib/std-sqlite-sqlite.sh
run_grep /tmp/std_sqlite_sqlite_gate.log 'std-sqlite gate OK' ./tests/run-std-sqlite-gate.sh

echo "── STD-154 sqlite docs/07 sync ──"
chmod +x tests/run-std-sqlite-docs-sync-gate.sh tests/lib/std-sqlite-docs-sync.sh
run_grep /tmp/std_sqlite_docs_sync_gate.log 'std-sqlite-docs-sync gate OK' ./tests/run-std-sqlite-docs-sync-gate.sh

echo "── STD-065 db exec tx deep smoke ──"
chmod +x tests/run-std-sqlite-exec-deep-gate.sh tests/lib/std-sqlite-exec-deep.sh
run_grep /tmp/std_sqlite_exec_deep_gate.log 'std-sqlite-exec-deep gate OK' ./tests/run-std-sqlite-exec-deep-gate.sh

echo "── STD-066 db query_rows row iterate ──"
chmod +x tests/run-std-sqlite-query-rows-gate.sh tests/lib/std-sqlite-query-rows.sh
run_grep /tmp/std_sqlite_query_rows_gate.log 'std-sqlite-query-rows gate OK' ./tests/run-std-sqlite-query-rows-gate.sh

echo "── STD-067 db next_row column cursor ──"
chmod +x tests/run-std-sqlite-next-row-gate.sh tests/lib/std-sqlite-next-row.sh
run_grep /tmp/std_sqlite_next_row_gate.log 'std-sqlite-next-row gate OK' ./tests/run-std-sqlite-next-row-gate.sh

chmod +x tests/run-std-sqlite-row-col-text-gate.sh tests/lib/std-sqlite-row-col-text.sh
run_grep /tmp/std_sqlite_row_col_text_gate.log 'std-sqlite-row-col-text gate OK' ./tests/run-std-sqlite-row-col-text-gate.sh

chmod +x tests/run-std-sqlite-row-col-blob-gate.sh tests/lib/std-sqlite-row-col-blob.sh
run_grep /tmp/std_sqlite_row_col_blob_gate.log 'std-sqlite-row-col-blob gate OK' ./tests/run-std-sqlite-row-col-blob-gate.sh

echo "── STD-137 sqlite blob stream ──"
chmod +x tests/run-std-sqlite-blob-stream-gate.sh tests/lib/std-sqlite-blob-stream.sh
run_grep /tmp/std_sqlite_blob_stream_gate.log 'std-sqlite-blob-stream gate OK' ./tests/run-std-sqlite-blob-stream-gate.sh

echo "── STD-138 sqlite threading doc ──"
chmod +x tests/run-std-sqlite-threading-gate.sh
run_grep /tmp/std_sqlite_threading_gate.log 'std-sqlite-threading gate OK' ./tests/run-std-sqlite-threading-gate.sh

echo "── STD-139 sqlite stub backend ──"
chmod +x tests/run-std-sqlite-stub-gate.sh tests/lib/std-sqlite-stub.sh
run_grep /tmp/std_sqlite_stub_gate.log 'std-sqlite-stub gate OK' ./tests/run-std-sqlite-stub-gate.sh

echo "── STD-058 elf ELF64 parse ──"
chmod +x tests/run-std-elf-parse-gate.sh tests/lib/std-elf-parse.sh
run_grep /tmp/std_elf_parse_gate.log 'std-elf-parse gate OK' ./tests/run-std-elf-parse-gate.sh

echo "── STD-063 elf section deep parse ──"
chmod +x tests/run-std-elf-deep-gate.sh tests/lib/std-elf-deep.sh
run_grep /tmp/std_elf_deep_gate.log 'std-elf-deep gate OK' ./tests/run-std-elf-deep-gate.sh

echo "── STD-064 elf program header parse ──"
chmod +x tests/run-std-elf-phdr-gate.sh tests/lib/std-elf-phdr.sh
run_grep /tmp/std_elf_phdr_gate.log 'std-elf-phdr gate OK' ./tests/run-std-elf-phdr-gate.sh

echo "── STD-121 elf min write roundtrip ──"
chmod +x tests/run-std-elf-write-gate.sh tests/lib/std-elf-write.sh
run_grep /tmp/std_elf_write_gate.log 'std-elf-write gate OK' ./tests/run-std-elf-write-gate.sh

echo "── STD-059 math fenv flags ──"
chmod +x tests/run-std-math-fenv-gate.sh tests/lib/std-math-fenv.sh
run_grep /tmp/std_math_fenv_gate.log 'std-math-fenv gate OK' ./tests/run-std-math-fenv-gate.sh

echo "── STD-149 math fenv capability ──"
chmod +x tests/run-std-math-fenv-capability-gate.sh tests/lib/std-math-fenv-capability.sh
run_grep /tmp/std_math_fenv_cap_gate.log 'std-math-fenv-cap gate OK' ./tests/run-std-math-fenv-capability-gate.sh

echo "── STD-115 math special functions ──"
chmod +x tests/run-std-math-special-gate.sh tests/lib/std-math-special.sh
run_grep /tmp/std_math_special_gate.log 'std-math-special gate OK' ./tests/run-std-math-special-gate.sh

echo "── STD-060 sort stable/cmp ──"
chmod +x tests/run-std-sort-stable-cmp-gate.sh tests/lib/std-sort-stable-cmp.sh
run_grep /tmp/std_sort_stable_cmp_gate.log 'std-sort-stable-cmp gate OK' ./tests/run-std-sort-stable-cmp-gate.sh

echo "── STD-150 sort key comparator ──"
chmod +x tests/run-std-sort-key-cmp-gate.sh tests/lib/std-sort-key-cmp.sh
run_grep /tmp/std_sort_key_cmp_gate.log 'std-sort-key-cmp gate OK' ./tests/run-std-sort-key-cmp-gate.sh

echo "── BOOT-014 std link contract ──"
chmod +x tests/run-boot-std-link-contract-gate.sh tests/lib/boot-std-link-contract.sh
run_grep /tmp/boot_std_link_gate.log 'boot-std-link-contract gate OK' ./tests/run-boot-std-link-contract-gate.sh

echo "── BOOT-015 semantic smoke vec/map/heap ──"
chmod +x tests/run-boot-015-semantic-smoke-gate.sh tests/run-bootstrap-semantic-smoke-vec-map-heap.sh tests/lib/boot-015-semantic-smoke.sh
run_grep /tmp/boot015_semantic_gate.log 'boot-015-semantic-smoke gate OK' ./tests/run-boot-015-semantic-smoke-gate.sh

echo "── BOOT-016 shux_asm std symbol Top-12 ──"
chmod +x tests/run-boot-016-std-asm-symbols-gate.sh tests/lib/boot-016-std-asm-symbols.sh
run_grep /tmp/boot016_std_sym_gate.log 'boot-016-std-asm-symbols gate OK' ./tests/run-boot-016-std-asm-symbols-gate.sh

echo "── BOOT-018 parser/std decouple ──"
chmod +x tests/run-boot-018-parser-std-decouple-gate.sh tests/lib/boot-018-parser-std-decouple.sh
run_grep /tmp/boot018_decouple_gate.log 'boot-018-parser-std-decouple gate OK' ./tests/run-boot-018-parser-std-decouple-gate.sh

echo "── STD-018 std.mem / core.mem boundary ──"
chmod +x tests/run-std-mem-boundary-gate.sh tests/lib/std-mem-boundary.sh
run_grep /tmp/std_mem_boundary_gate.log 'std-mem-boundary gate OK' ./tests/run-std-mem-boundary-gate.sh

echo "── STD-144 std.mem safe boundary ──"
chmod +x tests/run-std-mem-safe-gate.sh tests/lib/std-mem-safe.sh
run_grep /tmp/std_mem_safe_gate.log 'std-mem-safe gate OK' ./tests/run-std-mem-safe-gate.sh

echo "── STD-155 std.bytes Arena collaboration ──"
chmod +x tests/run-std-bytes-arena-gate.sh tests/lib/std-bytes-arena.sh
run_grep /tmp/std_bytes_arena_gate.log 'std-bytes-arena gate OK' ./tests/run-std-bytes-arena-gate.sh

echo "── STD-156 std.context Cookbook ──"
chmod +x tests/run-std-context-cookbook-gate.sh tests/lib/std-context-cookbook.sh
run_grep /tmp/std_context_cookbook_gate.log 'std-context-cookbook gate OK' ./tests/run-std-context-cookbook-gate.sh

echo "── STD-157 core.slice generic tools ──"
run_grep /tmp/core_slice_api_gate2.log 'core-slice-api gate OK' ./tests/run-core-slice-api-gate.sh

echo "── STD-158 std.error cross-module semantics ──"
chmod +x tests/run-std-error-semantics-gate.sh tests/lib/std-error-semantics.sh
run_grep /tmp/std_error_semantics_gate.log 'std-error-semantics gate OK' ./tests/run-std-error-semantics-gate.sh

echo "── STD-168 comprehensive check ──"
chmod +x tests/run-comprehensive-check-gate.sh tests/run-doc-07-comprehensive-audit-gate.sh tests/run-placeholder-inventory-gate.sh tests/run-std-string-unicode-gate.sh
run_grep /tmp/comprehensive_check_gate.log 'comprehensive-check gate OK' ./tests/run-comprehensive-check-gate.sh

echo "── TST-001 boundary wave 1 (io/fs/net/string) ──"
chmod +x tests/run-next-yellow-clear-gate.sh
run_grep /tmp/next_yellow_clear_gate.log 'next-yellow-clear gate OK' ./tests/run-next-yellow-clear-gate.sh

echo "── TST-001 boundary wave 1 (io/fs/net/string) ──"
chmod +x tests/run-tst-001-boundary-gate.sh tests/lib/tst-001-boundary.sh
run_grep /tmp/tst001_boundary_gate.log 'tst-001-boundary gate OK' ./tests/run-tst-001-boundary-gate.sh

echo "── TST-002 boundary wave 2 (heap/vec/map/process) ──"
chmod +x tests/run-tst-002-boundary-gate.sh tests/lib/tst-002-boundary.sh
run_grep /tmp/tst002_boundary_gate.log 'tst-002-boundary gate OK' ./tests/run-tst-002-boundary-gate.sh

echo "── TST-003 std round-trip vectors ──"
chmod +x tests/run-tst-003-std-roundtrip-gate.sh tests/lib/tst-003-std-roundtrip.sh
run_grep /tmp/tst003_roundtrip_gate.log 'tst-003-roundtrip gate OK' ./tests/run-tst-003-std-roundtrip-gate.sh

echo "── TST-004 std sanitizer nightly ──"
chmod +x tests/run-tst-004-std-sanitize-gate.sh tests/run-tst-004-std-sanitize-nightly.sh tests/lib/tst-004-std-sanitize.sh
run_grep /tmp/tst004_sanitize_gate.log 'tst-004-std-sanitize gate OK' ./tests/run-tst-004-std-sanitize-gate.sh

echo "── IO unified gate (同一套 .sx 全平台) ──"
chmod +x tests/run-io-unified-gate.sh
./tests/run-io-unified-gate.sh | tee /tmp/io_unified_gate.log
grep -q 'io unified gate OK' /tmp/io_unified_gate.log

echo "── STD-003 std.fs cross-platform ──"
chmod +x tests/run-std-fs-api-gate.sh
./tests/run-std-fs-api-gate.sh | tee /tmp/std_fs_gate.log
grep -q 'std-fs-api gate OK' /tmp/std_fs_gate.log

echo "── BOOT-004 bootstrap stage diag ──"
chmod +x tests/run-bootstrap-stage-diag-gate.sh
./tests/run-bootstrap-stage-diag-gate.sh | tee /tmp/boot_stage_diag_gate.log
grep -q 'bootstrap-stage-diag gate OK' /tmp/boot_stage_diag_gate.log

echo "── COMP-012 riscv64 regression manifest ──"
chmod +x tests/run-comp-riscv64-gate.sh tests/run-comp-riscv64.sh tests/lib/comp-riscv64.sh
./tests/run-comp-riscv64-gate.sh | tee /tmp/comp_riscv64_gate.log
grep -q 'comp-riscv64 gate OK' /tmp/comp_riscv64_gate.log

echo "── COMP-016 riscv64 wave matrix ──"
chmod +x tests/run-comp-riscv64-wave-gate.sh tests/lib/comp-riscv64-wave.sh
./tests/run-comp-riscv64-wave-gate.sh | tee /tmp/comp_riscv64_wave_gate.log
grep -q 'comp-riscv64-wave gate OK' /tmp/comp_riscv64_wave_gate.log

echo "── COMP-018 riscv64 QEMU user smoke ──"
chmod +x tests/run-comp-riscv64-qemu-gate.sh tests/lib/comp-riscv64-qemu.sh tests/run-comp-riscv64-qemu-smoke.sh
./tests/run-comp-riscv64-qemu-gate.sh | tee /tmp/comp_riscv64_qemu_gate.log
grep -q 'comp-riscv64-qemu gate OK' /tmp/comp_riscv64_qemu_gate.log

echo "── COMP-011 Windows backend manifest ──"
chmod +x tests/run-comp-win-backend-gate.sh tests/run-comp-win-backend.sh tests/lib/comp-win-backend.sh
./tests/run-comp-win-backend-gate.sh | tee /tmp/comp_win_backend_gate.log
grep -q 'comp-win-backend gate OK' /tmp/comp_win_backend_gate.log

echo "── COMP-007 incremental compile manifest ──"
chmod +x tests/run-comp-incr-compile-gate.sh tests/run-comp-incr-compile.sh tests/lib/comp-incr-compile.sh
./tests/run-comp-incr-compile-gate.sh | tee /tmp/comp_incr_compile_gate.log
grep -q 'comp-incr-compile gate OK' /tmp/comp_incr_compile_gate.log

echo "── COMP-020 incr-compile wave tier gate ──"
chmod +x tests/run-comp-incr-compile-wave-gate.sh tests/lib/comp-incr-compile-wave.sh
./tests/run-comp-incr-compile-wave-gate.sh | tee /tmp/comp_incr_compile_wave_gate.log
grep -q 'comp-incr-compile-wave gate OK' /tmp/comp_incr_compile_wave_gate.log

echo "── COMP-021 incr-compile prod tier ──"
chmod +x tests/run-comp-incr-compile-prod-gate.sh tests/lib/comp-incr-compile-prod.sh
./tests/run-comp-incr-compile-prod-gate.sh | tee /tmp/comp_incr_compile_prod_gate.log
grep -q 'comp-incr-compile-prod gate OK' /tmp/comp_incr_compile_prod_gate.log

echo "── COMP-010 size attribution manifest ──"
chmod +x tests/run-comp-size-attrib-gate.sh tests/run-comp-size-attrib.sh tests/lib/comp-size-attrib.sh
./tests/run-comp-size-attrib-gate.sh | tee /tmp/comp_size_attrib_gate.log
grep -q 'comp-size-attrib gate OK' /tmp/comp_size_attrib_gate.log

echo "── COMP-009 frontend/backend contract manifest ──"
chmod +x tests/run-comp-feb-contract-gate.sh tests/run-comp-feb-contract.sh tests/lib/comp-feb-contract.sh
./tests/run-comp-feb-contract-gate.sh | tee /tmp/comp_feb_contract_gate.log
grep -q 'comp-feb-contract gate OK' /tmp/comp_feb_contract_gate.log

echo "── COMP-008 link symbol conflict manifest ──"
chmod +x tests/run-comp-link-sym-gate.sh tests/run-comp-link-sym.sh tests/lib/comp-link-sym.sh
./tests/run-comp-link-sym-gate.sh | tee /tmp/comp_link_sym_gate.log
grep -q 'comp-link-sym gate OK' /tmp/comp_link_sym_gate.log

echo "── COMP-006 instruction selection manifest ──"
chmod +x tests/run-comp-isel-gate.sh tests/run-comp-isel.sh tests/lib/comp-isel.sh
./tests/run-comp-isel-gate.sh | tee /tmp/comp_isel_gate.log
grep -q 'comp-isel gate OK' /tmp/comp_isel_gate.log

echo "── COMP-014 isel P0 wave ──"
chmod +x tests/run-comp-isel-p0-gate.sh tests/lib/comp-isel-p0.sh
./tests/run-comp-isel-p0-gate.sh | tee /tmp/comp_isel_p0.log
grep -q 'comp-isel-p0 gate OK' /tmp/comp_isel_p0.log

echo "── COMP-005 regalloc strategy manifest ──"
chmod +x tests/run-comp-regalloc-gate.sh tests/run-comp-regalloc.sh tests/lib/comp-regalloc.sh
./tests/run-comp-regalloc-gate.sh | tee /tmp/comp_regalloc_gate.log
grep -q 'comp-regalloc gate OK' /tmp/comp_regalloc_gate.log

echo "── COMP-013 regalloc quality wave ──"
chmod +x tests/run-comp-regalloc-quality-gate.sh tests/lib/comp-regalloc-quality.sh
./tests/run-comp-regalloc-quality-gate.sh | tee /tmp/comp_regalloc_quality.log
grep -q 'comp-regalloc-quality gate OK' /tmp/comp_regalloc_quality.log

echo "── COMP-004 WPO v1 manifest ──"
chmod +x tests/run-comp-wpo-gate.sh tests/run-comp-wpo.sh tests/lib/comp-wpo.sh
./tests/run-comp-wpo-gate.sh | tee /tmp/comp_wpo_gate.log
grep -q 'comp-wpo gate OK' /tmp/comp_wpo_gate.log

echo "── COMP-015 WPO prod tier gate ──"
chmod +x tests/run-comp-wpo-prod-gate.sh tests/lib/comp-wpo-prod.sh
./tests/run-comp-wpo-prod-gate.sh | tee /tmp/comp_wpo_prod_gate.log
grep -q 'comp-wpo-prod gate OK' /tmp/comp_wpo_prod_gate.log

echo "── COMP-017 WPO default tier gate ──"
chmod +x tests/run-comp-wpo-default-gate.sh tests/lib/comp-wpo-default.sh
./tests/run-comp-wpo-default-gate.sh | tee /tmp/comp_wpo_default_gate.log
grep -q 'comp-wpo-default gate OK' /tmp/comp_wpo_default_gate.log

echo "── COMP-019 WPO global tier gate ──"
chmod +x tests/run-comp-wpo-global-gate.sh tests/lib/comp-wpo-global.sh
./tests/run-comp-wpo-global-gate.sh | tee /tmp/comp_wpo_global_gate.log
grep -q 'comp-wpo-global gate OK' /tmp/comp_wpo_global_gate.log

echo "── TYPE-005 zero-cost abstraction manifest ──"
chmod +x tests/run-type-zero-cost-gate.sh tests/run-type-zero-cost.sh tests/lib/type-zero-cost.sh
./tests/run-type-zero-cost-gate.sh | tee /tmp/type_zero_cost_gate.log
grep -q 'type-zero-cost gate OK' /tmp/type_zero_cost_gate.log

echo "── TYPE-004 FFI type bridge manifest ──"
chmod +x tests/run-type-ffi-bridge-gate.sh tests/run-type-ffi-bridge.sh tests/lib/type-ffi-bridge.sh
./tests/run-type-ffi-bridge-gate.sh | tee /tmp/type_ffi_bridge_gate.log
grep -q 'type-ffi-bridge gate OK' /tmp/type_ffi_bridge_gate.log

echo "── TYPE-003 borrow conflict manifest ──"
chmod +x tests/run-type-borrow-conflict-gate.sh tests/run-type-borrow-conflict.sh tests/lib/type-borrow-conflict.sh
./tests/run-type-borrow-conflict-gate.sh | tee /tmp/type_borrow_conflict_gate.log
grep -q 'type-borrow-conflict gate OK' /tmp/type_borrow_conflict_gate.log

echo "── LANG-008 lifetime diagnostic manifest ──"
chmod +x tests/run-lang-lifetime-diag-gate.sh tests/run-lang-lifetime-diag.sh tests/lib/lang-lifetime-diag.sh
./tests/run-lang-lifetime-diag-gate.sh | tee /tmp/lang_lifetime_diag_gate.log
grep -q 'lang-lifetime-diag gate OK' /tmp/lang_lifetime_diag_gate.log

echo "── LANG-005 ABI stability manifest ──"
chmod +x tests/run-lang-abi-stability-gate.sh tests/run-lang-abi-stability.sh tests/lib/lang-abi-stability.sh
./tests/run-lang-abi-stability-gate.sh | tee /tmp/lang_abi_stability_gate.log
grep -q 'lang-abi-stability gate OK' /tmp/lang_abi_stability_gate.log

echo "── LANG-004 trait interface manifest ──"
chmod +x tests/run-lang-trait-gate.sh tests/run-lang-trait.sh tests/lib/lang-trait.sh
./tests/run-lang-trait-gate.sh | tee /tmp/lang_trait_gate.log
grep -q 'lang-trait gate OK' /tmp/lang_trait_gate.log

echo "── LANG-003 generic monomorph manifest ──"
chmod +x tests/run-lang-generic-gate.sh tests/run-lang-generic.sh tests/lib/lang-generic.sh
./tests/run-lang-generic-gate.sh | tee /tmp/lang_generic_gate.log
grep -q 'lang-generic gate OK' /tmp/lang_generic_gate.log

echo "── LANG-001 feature gate manifest ──"
chmod +x tests/run-lang-feature-gate-gate.sh tests/run-lang-feature-gate.sh tests/lib/lang-feature-gate.sh scripts/shux-lang-edition.sh
./tests/run-lang-feature-gate-gate.sh | tee /tmp/lang_feature_gate.log
grep -q 'lang-feature-gate gate OK' /tmp/lang_feature_gate.log

echo "── LANG-002 import cross-platform ──"
chmod +x tests/run-lang-import-gate.sh
./tests/run-lang-import-gate.sh | tee /tmp/lang_import_gate.log
grep -q 'lang-import gate OK' /tmp/lang_import_gate.log

echo "── LANG-006 const eval / CTFE ──"
chmod +x tests/run-lang-const-eval-gate.sh tests/run-lang-const-eval.sh tests/lib/lang-const-eval.sh
./tests/run-lang-const-eval-gate.sh | tee /tmp/lang_const_eval_gate.log
grep -q 'lang-const-eval gate OK' /tmp/lang_const_eval_gate.log

echo "── EXC-002 panic/abort boundary ──"
chmod +x tests/run-exc-panic-abort-gate.sh
./tests/run-exc-panic-abort-gate.sh | tee /tmp/exc_panic_abort_gate.log
grep -q 'exc-panic-abort gate OK' /tmp/exc_panic_abort_gate.log

echo "── EXC-003 error code layer ──"
chmod +x tests/run-exc-error-code-layer-gate.sh
./tests/run-exc-error-code-layer-gate.sh | tee /tmp/exc_code_layer_gate.log
grep -q 'exc-error-code-layer gate OK' /tmp/exc_code_layer_gate.log

echo "── STD-011 std error code unify ──"
chmod +x tests/run-std-error-unify-gate.sh
./tests/run-std-error-unify-gate.sh | tee /tmp/std_error_unify.log
grep -q 'std-error-unify gate OK' /tmp/std_error_unify.log

echo "── EXC-004 error chain ──"
chmod +x tests/run-exc-error-chain-gate.sh
./tests/run-exc-error-chain-gate.sh | tee /tmp/exc_error_chain.log
grep -q 'exc-error-chain gate OK' /tmp/exc_error_chain.log

echo "── EXC-005 CLI/LSP error display ──"
chmod +x tests/run-exc-cli-lsp-error-gate.sh
./tests/run-exc-cli-lsp-error-gate.sh | tee /tmp/exc_cli_lsp.log
grep -q 'exc-cli-lsp-error gate OK' /tmp/exc_cli_lsp.log

echo "── EXC-006 error recovery suite ──"
chmod +x tests/run-exc-error-recovery-gate.sh
./tests/run-exc-error-recovery-gate.sh | tee /tmp/exc_error_recovery.log
grep -q 'exc-error-recovery gate OK' /tmp/exc_error_recovery.log

echo "── STD-004 std.async scheduler (1M stress) ──"
chmod +x tests/run-std-async-api-gate.sh
./tests/run-std-async-api-gate.sh | tee /tmp/std_async_gate.log
grep -q 'std-async-api gate OK' /tmp/std_async_gate.log

echo "── SAFE-003 unsafe audit ledger ──"
chmod +x tests/run-safe-unsafe-audit-gate.sh
./tests/run-safe-unsafe-audit-gate.sh | tee /tmp/safe_unsafe_audit_gate.log
grep -q 'safe-unsafe-audit gate OK' /tmp/safe_unsafe_audit_gate.log

echo "── SAFE-004 FFI memory contract ──"
chmod +x tests/run-safe-ffi-contract-gate.sh tests/lib/safe-ffi.sh
./tests/run-safe-ffi-contract-gate.sh | tee /tmp/safe_ffi_contract.log
grep -q 'safe-ffi-contract gate OK' /tmp/safe_ffi_contract.log

echo "── SAFE-005 leak nightly manifest ──"
chmod +x tests/run-safe-leak-nightly-gate.sh tests/run-safe-leak-nightly.sh tests/lib/safe-leak.sh
./tests/run-safe-leak-nightly-gate.sh | tee /tmp/safe_leak_nightly_gate.log
grep -q 'safe-leak-nightly gate OK' /tmp/safe_leak_nightly_gate.log

echo "── SAFE-007 crash evidence bundle ──"
chmod +x tests/run-safe-crash-evidence-gate.sh tests/run-safe-crash-evidence.sh tests/lib/safe-crash.sh
./tests/run-safe-crash-evidence-gate.sh | tee /tmp/safe_crash_evidence_gate.log
grep -q 'safe-crash-evidence gate OK' /tmp/safe_crash_evidence_gate.log

echo "── SAFE-006 race detect experimental ──"
chmod +x tests/run-safe-race-detect-gate.sh tests/run-safe-race-detect.sh tests/lib/safe-race.sh
./tests/run-safe-race-detect-gate.sh | tee /tmp/safe_race_detect_gate.log
grep -q 'safe-race-detect gate OK' /tmp/safe_race_detect_gate.log

echo "── TOOL-001 formatter style manifest ──"
chmod +x tests/run-tool-fmt-gate.sh tests/lib/tool-fmt.sh tests/run-fmt-cmd.sh tests/run-fmt-check-cmd.sh tests/run-fmt-wrap.sh
./tests/run-tool-fmt-gate.sh | tee /tmp/tool_fmt_gate.log
grep -q 'tool-fmt gate OK' /tmp/tool_fmt_gate.log

echo "── TOOL-002 linter rules manifest ──"
chmod +x tests/run-tool-lint-gate.sh tests/run-lint-check.sh tests/lib/tool-lint.sh
./tests/run-tool-lint-gate.sh | tee /tmp/tool_lint_gate.log
grep -q 'tool-lint gate OK' /tmp/tool_lint_gate.log

echo "── TOOL-003 LSP completion manifest ──"
chmod +x tests/run-tool-lsp-completion-gate.sh tests/run-lsp-completion.sh tests/lib/tool-lsp-completion.sh
./tests/run-tool-lsp-completion-gate.sh | tee /tmp/tool_lsp_completion_gate.log
grep -q 'tool-lsp-completion gate OK' /tmp/tool_lsp_completion_gate.log

echo "── TOOL-004 LSP diag perf manifest ──"
chmod +x tests/run-tool-lsp-diag-perf-gate.sh tests/run-lsp-diag-perf.sh tests/lib/tool-lsp-diag-perf.sh
./tests/run-tool-lsp-diag-perf-gate.sh | tee /tmp/tool_lsp_diag_perf_gate.log
grep -q 'tool-lsp-diag-perf gate OK' /tmp/tool_lsp_diag_perf_gate.log

echo "── TOOL-005 debug symbols manifest ──"
chmod +x tests/run-tool-debug-symbols-gate.sh tests/run-debug-symbols.sh tests/lib/tool-debug-symbols.sh tests/run-backtrace.sh
./tests/run-tool-debug-symbols-gate.sh | tee /tmp/tool_debug_symbols_gate.log
grep -q 'tool-debug-symbols gate OK' /tmp/tool_debug_symbols_gate.log

echo "── TOOL-006 project scaffold manifest ──"
chmod +x tests/run-tool-scaffold-gate.sh tests/run-tool-scaffold.sh tests/lib/tool-scaffold.sh scripts/shux-new.sh
./tests/run-tool-scaffold-gate.sh | tee /tmp/tool_scaffold_gate.log
grep -q 'tool-scaffold gate OK' /tmp/tool_scaffold_gate.log

echo "── TOOL-007 pkgmgr design manifest ──"
chmod +x tests/run-tool-pkgmgr-gate.sh tests/run-pkgmgr-resolve.sh tests/lib/tool-pkgmgr.sh scripts/shux-deps-resolve.sh
./tests/run-tool-pkgmgr-gate.sh | tee /tmp/tool_pkgmgr_gate.log
grep -q 'tool-pkgmgr gate OK' /tmp/tool_pkgmgr_gate.log

echo "── TOOL-008 deps lock manifest ──"
chmod +x tests/run-tool-deps-lock-gate.sh tests/run-deps-lock.sh tests/lib/tool-deps-lock.sh scripts/shux-deps-lock.sh scripts/shux-deps-verify.sh
./tests/run-tool-deps-lock-gate.sh | tee /tmp/tool_deps_lock_gate.log
grep -q 'tool-deps-lock gate OK' /tmp/tool_deps_lock_gate.log

echo "── TOOL-009 vscode 0.2 stable release ──"
chmod +x tests/run-tool-vscode-020-gate.sh tests/run-tool-vscode-pack.sh tests/lib/tool-vscode-020.sh
./tests/run-tool-vscode-020-gate.sh | tee /tmp/tool_vscode_020_gate.log
grep -q 'tool-vscode-020 gate OK' /tmp/tool_vscode_020_gate.log

echo "── ENG-001 perf baseline registry ──"
chmod +x tests/run-eng-baseline-governance-gate.sh
./tests/run-eng-baseline-governance-gate.sh | tee /tmp/eng_baseline_gov.log
grep -q 'eng-baseline-governance gate OK' /tmp/eng_baseline_gov.log

echo "── ENG-003 cross-platform CI matrix ──"
chmod +x tests/run-eng-crossplatform-ci-gate.sh
./tests/run-eng-crossplatform-ci-gate.sh | tee /tmp/eng_crossplatform_ci.log
grep -q 'eng-crossplatform-ci gate OK' /tmp/eng_crossplatform_ci.log

echo "── ENG-004 branch protection & release precheck ──"
chmod +x tests/run-eng-branch-release-gate.sh tests/run-eng-release-precheck.sh tests/lib/eng-branch-release-gate.sh
./tests/run-eng-branch-release-gate.sh | tee /tmp/eng_branch_release.log
grep -q 'eng-branch-release-gate gate OK' /tmp/eng_branch_release.log

echo "── ENG-005 version release rhythm ──"
chmod +x tests/run-eng-version-release-rhythm-gate.sh tests/lib/eng-version-release-rhythm.sh
./tests/run-eng-version-release-rhythm-gate.sh | tee /tmp/eng_version_rhythm.log
grep -q 'eng-version-release-rhythm gate OK' /tmp/eng_version_rhythm.log

echo "── ENG-006 rollback emergency drill ──"
chmod +x tests/run-eng-rollback-emergency-gate.sh tests/run-eng-rollback-drill.sh tests/lib/eng-rollback-emergency.sh
./tests/run-eng-rollback-emergency-gate.sh | tee /tmp/eng_rollback_emergency.log
grep -q 'eng-rollback-emergency gate OK' /tmp/eng_rollback_emergency.log

echo "── ENG-007 security audit periodic ──"
chmod +x tests/run-eng-security-audit-gate.sh tests/run-eng-security-audit.sh tests/lib/eng-security-audit.sh
./tests/run-eng-security-audit-gate.sh | tee /tmp/eng_security_audit_gate.log
grep -q 'eng-security-audit gate OK' /tmp/eng_security_audit_gate.log

echo "── COMP-003 codegen regression ──"
chmod +x tests/run-codegen-regression-gate.sh
./tests/run-codegen-regression-gate.sh | tee /tmp/codegen_regression.log
grep -qE 'codegen-regression gate OK|codegen-regression gate SKIP bench' /tmp/codegen_regression.log

echo "── COMP-002 typeck hotpath ──"
chmod +x tests/run-typeck-hotpath-gate.sh
./tests/run-typeck-hotpath-gate.sh | tee /tmp/typeck_hotpath.log
grep -qE 'typeck-hotpath gate OK|typeck-hotpath gate SKIP hooks' /tmp/typeck_hotpath.log

echo "── ENG-002 quality gate registry ──"
chmod +x tests/run-eng-quality-gate-gate.sh
./tests/run-eng-quality-gate-gate.sh | tee /tmp/eng_quality_gate.log
grep -q 'eng-quality-gate gate OK' /tmp/eng_quality_gate.log

echo "── COMP-001 parser mega7 plan ──"
chmod +x tests/run-comp-parser-mega7-gate.sh
./tests/run-comp-parser-mega7-gate.sh | tee /tmp/comp_parser_mega7.log
grep -qE 'comp-parser-mega7 gate OK|comp-parser-mega7 gate SKIP hooks' /tmp/comp_parser_mega7.log

echo "── BOOT-010 force_stub risk registry ──"
chmod +x tests/run-boot-force-stub-gate.sh
./tests/run-boot-force-stub-gate.sh | tee /tmp/boot_force_stub.log
grep -qE 'boot-force-stub gate OK|boot-force-stub SKIP check/hooks' /tmp/boot_force_stub.log

echo "── BOOT-017 stdlib per-module dogfood ──"
chmod +x tests/run-boot-017-stdlib-dogfood-gate.sh tests/run-boot-017-stdlib-dogfood.sh tests/lib/boot-017-stdlib-dogfood.sh
run_grep /tmp/boot017_stdlib_dogfood_gate.log 'boot-017-stdlib-dogfood gate OK' ./tests/run-boot-017-stdlib-dogfood-gate.sh

echo "── BOOT-012 bootstrap perf regression ──"
chmod +x tests/run-bootstrap-perf-gate.sh
./tests/run-bootstrap-perf-gate.sh | tee /tmp/bootstrap_perf.log
grep -qE 'bootstrap-perf gate OK|perf-compile-dogfood gate SKIP bench' /tmp/bootstrap_perf.log

echo "── BOOT-005 failure taxonomy ──"
chmod +x tests/run-bootstrap-failure-taxonomy-gate.sh
./tests/run-bootstrap-failure-taxonomy-gate.sh | tee /tmp/bootstrap_failure_taxonomy.log
grep -q 'bootstrap-failure-taxonomy gate OK' /tmp/bootstrap_failure_taxonomy.log

echo "── BOOT-011 bootstrap cross-platform report ──"
chmod +x tests/run-bootstrap-crossplatform-gate.sh
./tests/run-bootstrap-crossplatform-gate.sh | tee /tmp/bootstrap_crossplatform.log
grep -q 'bootstrap-crossplatform gate OK' /tmp/bootstrap_crossplatform.log

echo "── BOOT-029 std.sys freestanding write ──"
chmod +x tests/run-std-sys-gate.sh
run_grep /tmp/std_sys_gate.log 'std-sys gate OK' ./tests/run-std-sys-gate.sh

echo "── DOC-002 selfhost architecture doc ──"
chmod +x tests/run-doc-selfhost-architecture-gate.sh
./tests/run-doc-selfhost-architecture-gate.sh | tee /tmp/doc_selfhost_arch.log
grep -q 'doc-selfhost-architecture gate OK' /tmp/doc_selfhost_arch.log

echo "── OBS-001 compile phase timing ──"
chmod +x tests/run-obs-compile-phase-timing-gate.sh
./tests/run-obs-compile-phase-timing-gate.sh | tee /tmp/obs_phase_timing.log
grep -q 'obs-compile-phase-timing gate OK' /tmp/obs_phase_timing.log

echo "── OBS-002 async runtime trace ──"
chmod +x tests/run-obs-async-runtime-trace-gate.sh
./tests/run-obs-async-runtime-trace-gate.sh | tee /tmp/obs_async_trace.log
grep -q 'obs-async-runtime-trace gate OK' /tmp/obs_async_trace.log

echo "── OBS-003 structured log ──"
chmod +x tests/run-obs-structured-log-gate.sh tests/lib/obs-structured-log.sh
./tests/run-obs-structured-log-gate.sh | tee /tmp/obs_struct_log.log
grep -q 'obs-structured-log gate OK' /tmp/obs_struct_log.log

echo "── OBS-004 perf regression alert ──"
chmod +x tests/run-obs-perf-regression-alert-gate.sh tests/run-obs-perf-regression-alert.sh tests/lib/obs-perf-regression-alert.sh
./tests/run-obs-perf-regression-alert-gate.sh | tee /tmp/obs_perf_alert.log
grep -q 'obs-perf-regression-alert gate OK' /tmp/obs_perf_alert.log

echo "── PERF-006 cache miss governance ──"
chmod +x tests/run-perf-cache-miss-gate.sh tests/lib/perf-cache-miss.sh
./tests/run-perf-cache-miss-gate.sh | tee /tmp/perf_cache_miss.log
grep -q 'perf-cache-miss gate OK' /tmp/perf_cache_miss.log

echo "── PERF-010 coldstart manifest ──"
chmod +x tests/run-perf-coldstart-gate.sh tests/lib/perf-coldstart.sh
./tests/run-perf-coldstart-gate.sh | tee /tmp/perf_coldstart_gate.log
grep -q 'perf-coldstart gate OK' /tmp/perf_coldstart_gate.log

echo "── PERF-007 alloc hotspot governance ──"
chmod +x tests/run-perf-alloc-hotspot-gate.sh tests/run-perf-alloc-hotspot.sh tests/lib/perf-alloc-hotspot.sh
./tests/run-perf-alloc-hotspot-gate.sh | tee /tmp/perf_alloc_hotspot.log
grep -q 'perf-alloc-hotspot gate OK' /tmp/perf_alloc_hotspot.log

echo "── PERF-008 syscall batch governance ──"
chmod +x tests/run-perf-syscall-batch-gate.sh tests/run-perf-syscall-batch.sh tests/lib/perf-syscall-batch.sh
./tests/run-perf-syscall-batch-gate.sh | tee /tmp/perf_syscall_batch.log
grep -q 'perf-syscall-batch gate OK' /tmp/perf_syscall_batch.log

echo "── PERF-009 net zero-copy CPU/byte ──"
chmod +x tests/run-perf-net-zc-gate.sh tests/run-perf-net-zc.sh tests/lib/perf-net-zc.sh
./tests/run-perf-net-zc-gate.sh | tee /tmp/perf_net_zc.log
grep -q 'perf-net-zc gate OK' /tmp/perf_net_zc.log

echo "── PERF-011 Zig strategy dashboard ──"
chmod +x tests/run-perf-zig-strategy-dashboard-gate.sh tests/run-perf-zig-strategy-dashboard.sh tests/lib/zig-strategy-dashboard.sh
./tests/run-perf-zig-strategy-dashboard-gate.sh | tee /tmp/perf_zig_strategy.log
grep -q 'perf-zig-strategy gate OK' /tmp/perf_zig_strategy.log

echo "── DOC-001 stdlib cookbook ──"
chmod +x tests/run-doc-stdlib-cookbook-gate.sh tests/lib/doc-cookbook.sh
./tests/run-doc-stdlib-cookbook-gate.sh | tee /tmp/doc_cookbook.log
grep -q 'doc-stdlib-cookbook gate OK' /tmp/doc_cookbook.log

echo "── DOC-006 cookbook expand (35+) ──"
chmod +x tests/run-doc-cookbook-expand-gate.sh
./tests/run-doc-cookbook-expand-gate.sh | tee /tmp/doc_cookbook_expand.log
grep -q 'doc-cookbook-expand gate OK' /tmp/doc_cookbook_expand.log

echo "── DOC-007 docs/07 std fulltable ──"
chmod +x tests/run-doc-07-stdlib-fulltable-gate.sh tests/lib/doc-07-stdlib-fulltable.sh
./tests/run-doc-07-stdlib-fulltable-gate.sh | tee /tmp/doc07_fulltable.log
grep -q 'doc-07-stdlib-fulltable gate OK' /tmp/doc07_fulltable.log

echo "── DOC-008 Phase 2 doc close ──"
chmod +x tests/run-doc-phase2-close-gate.sh tests/lib/doc-phase2-close.sh
./tests/run-doc-phase2-close-gate.sh | tee /tmp/doc_phase2_close.log
grep -q 'doc-phase2-close gate OK' /tmp/doc_phase2_close.log

echo "── STD-012 std examples catalog ──"
chmod +x tests/run-std-examples-gate.sh tests/run-std-examples.sh tests/lib/std-examples.sh
./tests/run-std-examples-gate.sh | tee /tmp/std_examples.log
grep -q 'std-examples gate OK' /tmp/std_examples.log

echo "── STD-005 std.time precision ──"
chmod +x tests/run-std-time-gate.sh tests/lib/std-time.sh
./tests/run-std-time-gate.sh | tee /tmp/std_time.log
grep -q 'std-time gate OK' /tmp/std_time.log

echo "── STD-006 std.crypto minimal security ──"
chmod +x tests/run-std-crypto-gate.sh tests/run-std-crypto.sh tests/lib/std-crypto.sh
./tests/run-std-crypto-gate.sh | tee /tmp/std_crypto.log
grep -q 'std-crypto gate OK' /tmp/std_crypto.log

echo "── STD-007 std.compress gzip/zstd ──"
chmod +x tests/run-std-compress-gate.sh tests/run-std-compress.sh tests/lib/std-compress.sh
./tests/run-std-compress-gate.sh | tee /tmp/std_compress.log
grep -q 'std-compress gate OK' /tmp/std_compress.log

echo "── STD-008 std.json zero-copy parse ──"
chmod +x tests/run-std-json-gate.sh tests/lib/std-json.sh
./tests/run-std-json-gate.sh | tee /tmp/std_json.log
grep -q 'std-json gate OK' /tmp/std_json.log

echo "── STD-009 std.http server bench ──"
chmod +x tests/run-std-http-gate.sh tests/run-perf-http.sh tests/lib/perf-http.sh
./tests/run-std-http-gate.sh | tee /tmp/std_http.log
grep -q 'std-http gate OK' /tmp/std_http.log

echo "── STD-HTTP-HTTPS std.http HTTPS client ──"
chmod +x tests/run-std-http-https-gate.sh tests/lib/std-http-https.sh
run_grep /tmp/std_http_https_gate.log 'std-http-https gate OK' ./tests/run-std-http-https-gate.sh

echo "── STD-HTTP-H2 http/2 wire format ──"
chmod +x tests/run-std-http-h2-gate.sh tests/lib/std-http-h2.sh
run_grep /tmp/std_http_h2_gate.log 'std-http-h2 gate OK' ./tests/run-std-http-h2-gate.sh

echo "── STD-010 std.sqlite prereq RFC draft ──"
chmod +x tests/run-std-sqlite-prereq-gate.sh tests/run-std-sqlite.sh tests/lib/std-sqlite.sh
./tests/run-std-sqlite-prereq-gate.sh | tee /tmp/std_sqlite_gate.log
grep -q 'std-sqlite prereq gate OK' /tmp/std_sqlite_gate.log

echo "── DOC-003 perf tuning handbook ──"
chmod +x tests/run-doc-perf-tuning-gate.sh
./tests/run-doc-perf-tuning-gate.sh | tee /tmp/doc_perf_tuning.log
grep -q 'doc-perf-tuning gate OK' /tmp/doc_perf_tuning.log

echo "── PERF-005 perf flamegraph Top20 ──"
chmod +x tests/run-perf-flamegraph-gate.sh tests/run-perf-flamegraph.sh tests/lib/perf-flamegraph.sh
./tests/run-perf-flamegraph-gate.sh | tee /tmp/perf_flamegraph.log
grep -qE 'perf-flamegraph gate OK' /tmp/perf_flamegraph.log

echo "── DOC-004 memory safety & error guide ──"
chmod +x tests/run-doc-memory-safety-error-gate.sh
./tests/run-doc-memory-safety-error-gate.sh | tee /tmp/doc_mem_safe_err.log
grep -q 'doc-memory-safety-error gate OK' /tmp/doc_mem_safe_err.log

echo "── DOC-014 Q4 2027 roadmap refresh (incl. DOC-005) ──"
chmod +x tests/run-doc-public-roadmap-q4-2027-gate.sh tests/lib/doc-public-roadmap-q4-2027.sh
./tests/run-doc-public-roadmap-q4-2027-gate.sh | tee /tmp/doc_public_roadmap_q4_2027.log
grep -q 'doc-public-roadmap-q4-2027 gate OK' /tmp/doc_public_roadmap_q4_2027.log

echo "── DOC-013 Q3 roadmap refresh (incl. DOC-005) ──"
chmod +x tests/run-doc-public-roadmap-q3-gate.sh tests/lib/doc-public-roadmap-q3.sh
./tests/run-doc-public-roadmap-q3-gate.sh | tee /tmp/doc_public_roadmap_q3.log
grep -q 'doc-public-roadmap-q3 gate OK' /tmp/doc_public_roadmap_q3.log

echo "── PLAN-001 Phase 3 roadmap ──"
chmod +x tests/run-phase3-roadmap-gate.sh tests/lib/phase3-roadmap.sh
./tests/run-phase3-roadmap-gate.sh | tee /tmp/phase3_roadmap.log
grep -q 'phase3-roadmap gate OK' /tmp/phase3_roadmap.log

echo "── PLAN-002 Phase 3 wave2 roadmap ──"
chmod +x tests/run-phase3-roadmap-wave2-gate.sh tests/lib/phase3-roadmap-wave2.sh
./tests/run-phase3-roadmap-wave2-gate.sh | tee /tmp/phase3_roadmap_wave2.log
grep -q 'phase3-roadmap-wave2 gate OK' /tmp/phase3_roadmap_wave2.log

echo "── PLAN-003 Phase 3 wave3 roadmap ──"
chmod +x tests/run-phase3-roadmap-wave3-gate.sh tests/lib/phase3-roadmap-wave3.sh
./tests/run-phase3-roadmap-wave3-gate.sh | tee /tmp/phase3_roadmap_wave3.log
grep -q 'phase3-roadmap-wave3 gate OK' /tmp/phase3_roadmap_wave3.log

echo "── PLAN-004 Phase 3 wave4 roadmap ──"
chmod +x tests/run-phase3-roadmap-wave4-gate.sh tests/lib/phase3-roadmap-wave4.sh
./tests/run-phase3-roadmap-wave4-gate.sh | tee /tmp/phase3_roadmap_wave4.log
grep -q 'phase3-roadmap-wave4 gate OK' /tmp/phase3_roadmap_wave4.log

echo "── PLAN-005 Phase 3 wave5 roadmap ──"
chmod +x tests/run-phase3-roadmap-wave5-gate.sh tests/lib/phase3-roadmap-wave5.sh
./tests/run-phase3-roadmap-wave5-gate.sh | tee /tmp/phase3_roadmap_wave5.log
grep -q 'phase3-roadmap-wave5 gate OK' /tmp/phase3_roadmap_wave5.log

echo "── PLAN-006 Phase 3 wave6 roadmap ──"
chmod +x tests/run-phase3-roadmap-wave6-gate.sh tests/lib/phase3-roadmap-wave6.sh
./tests/run-phase3-roadmap-wave6-gate.sh | tee /tmp/phase3_roadmap_wave6.log
grep -q 'phase3-roadmap-wave6 gate OK' /tmp/phase3_roadmap_wave6.log

echo "── PLAN-007 Phase 3 wave7 roadmap ──"
chmod +x tests/run-phase3-roadmap-wave7-gate.sh tests/lib/phase3-roadmap-wave7.sh
./tests/run-phase3-roadmap-wave7-gate.sh | tee /tmp/phase3_roadmap_wave7.log
grep -q 'phase3-roadmap-wave7 gate OK' /tmp/phase3_roadmap_wave7.log

echo "── PLAN-009 Phase 3 wave9 roadmap (draft) ──"
chmod +x tests/run-phase3-roadmap-wave9-gate.sh tests/lib/phase3-roadmap-wave9.sh
./tests/run-phase3-roadmap-wave9-gate.sh | tee /tmp/phase3_roadmap_wave9.log
grep -q 'phase3-roadmap-wave9 gate OK' /tmp/phase3_roadmap_wave9.log

echo "── PLAN-008 Phase 3 wave8 roadmap ──"
chmod +x tests/run-phase3-roadmap-wave8-gate.sh tests/lib/phase3-roadmap-wave8.sh
./tests/run-phase3-roadmap-wave8-gate.sh | tee /tmp/phase3_roadmap_wave8.log
grep -q 'phase3-roadmap-wave8 gate OK' /tmp/phase3_roadmap_wave8.log

echo "── LANG-009 Option<T> generic struct ──"
chmod +x tests/run-lang-option-generic-gate.sh tests/lib/lang-option-generic.sh
./tests/run-lang-option-generic-gate.sh | tee /tmp/lang009_option.log
grep -q 'lang-option-generic gate OK' /tmp/lang009_option.log

echo "── LANG-010 Result<T,E> generic struct ──"
chmod +x tests/run-lang-result-generic-gate.sh tests/lib/lang-result-generic.sh
./tests/run-lang-result-generic-gate.sh | tee /tmp/lang010_result.log
grep -q 'lang-result-generic gate OK' /tmp/lang010_result.log

echo "── CORE-016 Option/Result unify ──"
chmod +x tests/run-core-option-result-unify-gate.sh tests/lib/core-option-result-unify.sh
./tests/run-core-option-result-unify-gate.sh | tee /tmp/core016_unify.log
grep -q 'core-option-result-unify gate OK' /tmp/core016_unify.log

echo "── BOOT-019 Stage2 parser/typeck dogfood ──"
chmod +x tests/run-boot-019-stage2-dogfood-gate.sh tests/lib/boot-019-stage2-dogfood.sh tests/run-bootstrap-stage2-dogfood-parser-typeck.sh
./tests/run-boot-019-stage2-dogfood-gate.sh | tee /tmp/boot019_dogfood.log
grep -q 'boot-019-stage2-dogfood gate OK' /tmp/boot019_dogfood.log

echo "── BOOT-020 mega7 parser milestone ──"
chmod +x tests/run-boot-020-mega7-milestone-gate.sh tests/lib/boot-020-mega7-milestone.sh
./tests/run-boot-020-mega7-milestone-gate.sh | tee /tmp/boot020_milestone.log
grep -q 'boot-020-mega7-milestone gate OK' /tmp/boot020_milestone.log

echo "── BOOT-021 mega7 B1–B7 promote wave ──"
chmod +x tests/run-boot-021-mega7-promote-gate.sh tests/lib/boot-021-mega7-promote.sh tests/run-parser-mega7-promote-wave.sh
./tests/run-boot-021-mega7-promote-gate.sh | tee /tmp/boot021_promote.log
grep -q 'boot-021-mega7-promote gate OK' /tmp/boot021_promote.log

echo "── BOOT-022 mega7 emit promote wave ──"
chmod +x tests/run-boot-022-mega7-emit-gate.sh tests/lib/boot-022-mega7-emit.sh tests/run-parser-mega7-emit-wave.sh
./tests/run-boot-022-mega7-emit-gate.sh | tee /tmp/boot022_emit.log
grep -q 'boot-022-mega7-emit gate OK' /tmp/boot022_emit.log

echo "── BOOT-023 mega7 7/7 full emit ──"
chmod +x tests/run-boot-023-mega7-full-emit-gate.sh tests/lib/boot-023-mega7-full-emit.sh
./tests/run-boot-023-mega7-full-emit-gate.sh | tee /tmp/boot023_full_emit.log
grep -q 'boot-023-mega7-full-emit gate OK' /tmp/boot023_full_emit.log

echo "── BOOT-024 parser bootstrap C2 emit ──"
chmod +x tests/run-boot-024-parser-bootstrap-emit-gate.sh tests/lib/boot-024-parser-bootstrap-emit.sh
./tests/run-boot-024-parser-bootstrap-emit-gate.sh | tee /tmp/boot024_bootstrap_emit.log
grep -q 'boot-024-parser-bootstrap-emit gate OK' /tmp/boot024_bootstrap_emit.log

echo "── BOOT-025 parser gen1/gen2 consistency ──"
chmod +x tests/run-boot-025-parser-gen12-consistency-gate.sh tests/lib/boot-025-parser-gen12-consistency.sh
./tests/run-boot-025-parser-gen12-consistency-gate.sh | tee /tmp/boot025_gen12.log
grep -q 'boot-025-parser-gen12-consistency gate OK' /tmp/boot025_gen12.log

echo "── BOOT-026 parser C4 SU bootstrap ──"
chmod +x tests/run-boot-026-parser-c4-bootstrap-gate.sh tests/lib/boot-026-parser-c4-bootstrap.sh
./tests/run-boot-026-parser-c4-bootstrap-gate.sh | tee /tmp/boot026_c4.log
grep -q 'boot-026-parser-c4-bootstrap gate OK' /tmp/boot026_c4.log

echo "── BOOT-028 shux_asm2 CI matrix ──"
chmod +x tests/run-boot-028-shux-asm2-ci-matrix-gate.sh tests/lib/boot-028-shux-asm2-ci-matrix.sh
./tests/run-boot-028-shux-asm2-ci-matrix-gate.sh | tee /tmp/boot028_asm2_ci.log
grep -q 'boot-028-shux-asm2-ci-matrix gate OK' /tmp/boot028_asm2_ci.log

echo "── BOOT-027 shux_asm2 cross-platform ──"
chmod +x tests/run-boot-027-shux-asm2-cross-gate.sh tests/lib/boot-027-shux-asm2-cross.sh tests/run-shux-asm2-cross-smoke.sh
./tests/run-boot-027-shux-asm2-cross-gate.sh | tee /tmp/boot027_asm2_cross.log
grep -q 'boot-027-shux-asm2-cross gate OK' /tmp/boot027_asm2_cross.log

echo "── ZC-006 zero-copy semantics whitepaper ──"
chmod +x tests/run-zc-semantics-gate.sh
./tests/run-zc-semantics-gate.sh | tee /tmp/zc_semantics.log
grep -q 'zc-semantics gate OK' /tmp/zc_semantics.log

echo "── ZC-007 zero-copy copy proof template ──"
chmod +x tests/run-zc-copy-proof-gate.sh
./tests/run-zc-copy-proof-gate.sh | tee /tmp/zc_copy_proof.log
grep -q 'zc-copy-proof gate OK' /tmp/zc_copy_proof.log

echo "── ZC-008 zero-copy metrics dashboard ──"
chmod +x tests/run-zc-dashboard-gate.sh tests/run-zc-dashboard.sh tests/lib/zc-dashboard.sh
./tests/run-zc-dashboard-gate.sh | tee /tmp/zc_dashboard.log
grep -q 'zc-dashboard gate OK' /tmp/zc_dashboard.log

if [ "$WITH_C_REGRESSION" -eq 1 ]; then
  echo "── portable C regression (run-portable-c) ──"
  chmod +x tests/run-portable-c.sh
  ./tests/run-portable-c.sh | tee /tmp/portable_c.log
  grep -q 'run-portable-c OK' /tmp/portable_c.log
fi

echo "run-portable-suite OK (Tier P)"
