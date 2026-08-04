# std_and_panic_objs.mk — wave813 · 11.3.1 B7B
#
# Single-authority object list for product/test std+panic companions
# (STD_AND_PANIC_O). Used by `make std-objs`, bootstrap-token/lexer/parser,
# and test_c prereqs.
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# full inventory. Shell scripts must not hardcode a second .o inventory
# (see bootstrap_token_lexer_smoke.sh / run_compiler_tests.sh).
#
# wave813: moved out of compiler/Makefile inline body (list residual of
# std_core_product_make_graph). NOT physical delete — thin edges + mk lists
# + remaining B2 ensure graph still residual.
#
# PLATFORM: SHARED base list; PLATFORM: LINUX x86_64 appends freestanding
# crt0 companions for product -o link (matches historic Makefile ifeq).

# Base product std + runtime companions (65 leaves). Paths relative to compiler/.
STD_AND_PANIC_O = ../std/heap/heap.o ../std/heap/page_mmap.o ../std/sys/sys.o ../std/sys/linux.o ../core/mem/mem.o ../std/map/map.o ../std/set/set.o ../std/process/process.o ../std/string/string.o ../std/path/path.o ../std/runtime/runtime.o ../std/net/net.o ../std/thread/thread.o ../std/async/scheduler.o ../std/time/time.o ../std/random/random.o ../std/env/env.o ../std/sync/sync.o ../std/encoding/encoding.o ../std/base64/base64.o ../std/crypto/crypto.o ../std/log/log.o ../std/atomic/atomic.o ../std/channel/channel.o ../std/backtrace/backtrace.o ../std/hash/hash.o ../std/math/math.o ../std/sort/sort.o ../std/ffi/ffi.o ../std/json/json.o ../std/csv/csv.o ../std/regex/regex.o ../std/unicode/unicode.o ../std/dynlib/dynlib.o ../std/http/http.o ../std/tar/tar.o ../std/simd/simd.o ../std/context/context.o ../std/error/error.o ../std/trace/trace.o ../std/test/test.o runtime_panic.o runtime_link_abi_user_env.o runtime_asm_io_stubs.o runtime_process_argv.o runtime_process_os_glue.o runtime_test_fn_invoke.o runtime_random_fill.o runtime_time_os.o runtime_dynlib_os.o runtime_env_os.o runtime_backtrace_platform.o runtime_log_os.o runtime_math_libm.o runtime_atomic_glue.o runtime_channel_glue.o runtime_net_udp_batch.o runtime_net_workers.o runtime_sync_os.o runtime_sync_lock_diag_tls.o runtime_thread_glue.o runtime_scheduler_glue.o runtime_http_glue.o runtime_crypto_inc_glue.o runtime_ed25519_ref10_glue.o

# PLATFORM: LINUX x86_64 — freestanding user entry companions for product -o.
# UNAME_S / UNAME_M must be defined by the including Makefile (or empty → skip).
ifeq ($(UNAME_S),Linux)
ifeq ($(UNAME_M),x86_64)
STD_AND_PANIC_O += crt0_user.o freestanding_io.o
endif
endif
