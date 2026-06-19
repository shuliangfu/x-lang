/* tests/http/https_smoke_ok.c — STD-HTTP-HTTPS C 烟测入口 */
extern int http_https_smoke_c(void);

/** 运行 HTTPS 烟测；桩 TLS 时返回 0（SKIP）。 */
int main(void) { return http_https_smoke_c(); }
