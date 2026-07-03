#include <stdlib.h>
#ifndef _WIN32
#include <unistd.h>
#endif

extern int main_entry(int argc, char **argv);

int main(int argc, char **argv) {
    /* _exit to bypass atexit/global-dtor crash in SX self-hosted build */
    int r = main_entry(argc, argv);
    _exit(r);
}
