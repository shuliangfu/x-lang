/* STD-083：OpenSSL TLS 握手烟测入口（须 SHUX_TLS_SMOKE_PORT + net-o-openssl） */
extern int net_tls_openssl_smoke_c(void);

int main(void) {
  return net_tls_openssl_smoke_c();
}
