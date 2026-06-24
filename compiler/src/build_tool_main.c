/**
 * build_tool_main.c — build_tool 极薄 main（G-05：替代 build_runtime.c 的 main）
 *
 * Darwin 等无 crt0_x86_64 宿主：链 build_runner + build_runtime_sx + build_gen，
 * 本文件仅转调 entry(argc, argv)。
 */
extern int build_entry(int argc, char **argv);

/** 进程入口；转 build_runner.sx build_entry（-E-extern 模块前缀）。 */
int main(int argc, char **argv) {
    return build_entry(argc, (void *)argv);
}
