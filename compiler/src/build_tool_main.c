/**
 * build_tool_main.c — build_tool 极薄 main（G-05：替代 build_runtime.c 的 main）
 *
 * Darwin 等无 crt0_x86_64 宿主：链 build_runner + build_runtime_x + build_gen，
 * 本文件仅转调 build_runner.x 的 entry(argc, argv)。
 */
extern int entry(int argc, char **argv);

/** 进程入口；转 build_runner.x entry（-E 产物符号为 entry，非 build_entry）。 */
int main(int argc, char **argv) {
    return entry(argc, (void *)argv);
}
