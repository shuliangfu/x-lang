/* STD-085：mbedTLS TLS 握手烟测入口（须 SHUX_TLS_SMOKE_PORT + net-o-mbedtls） */
extern int net_tls_mbedtls_smoke_c(void);

int main(void) {
  return net_tls_mbedtls_smoke_c();
}
