/**
 * std/http/http2_test_tls_cert.inc.c — HTTP/2 TLS server 烟测用自签 PEM（localhost）
 *
 * 由 http2_server.inc.c #include；仅测试环境使用。
 */

static const char g_http2_test_tls_cert_pem[] =
    "-----BEGIN CERTIFICATE-----\n"
    "MIICBDCCAW2gAwIBAgIUTNXo4MHE383r7/pd01jJendYTEkwDQYJKoZIhvcNAQEL\n"
    "BQAwFDESMBAGA1UEAwwJbG9jYWxob3N0MB4XDTI2MDYxOTA1NDgxMloXDTM2MDYx\n"
    "NjA1NDgxMlowFDESMBAGA1UEAwwJbG9jYWxob3N0MIGfMA0GCSqGSIb3DQEBAQUA\n"
    "A4GNADCBiQKBgQDgN1w/H3R1BSwMQLy7k51UASReYp4IaVZ8d4mAwVpKrRBEgLmA\n"
    "YSI/izjc182/pvjRWnqKETPjuYRBGEIj44xDYG+g8Shjah/eVIsxmgAHI/lxbPwp\n"
    "C5Rp5O0HgBCbwoQ8RQ0SyVmS8KfKeQjBkOUGc8GXGXDplLtdLniB5cS+xwIDAQAB\n"
    "o1MwUTAdBgNVHQ4EFgQURqE85WpMbrC33tC2ZqS/fuJVJv8wHwYDVR0jBBgwFoAU\n"
    "RqE85WpMbrC33tC2ZqS/fuJVJv8wDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0B\n"
    "AQsFAAOBgQDGLGtKCDOmnFSHeqobsoCd+o3MjpilejkHHMQfYeMOhl+022jT1GwN\n"
    "7I/GylQoShgUadcGRqOsa5eDAgXTa3K6k1tO9C7woipHh5XzopWdbkicYaKn7+Rt\n"
    "504KcT/78cBNHvYajE3l5tDMdC3gC1Lh3bjy4BB1Z8VygmEgFPIgtg==\n"
    "-----END CERTIFICATE-----\n";

static const char g_http2_test_tls_key_pem[] =
    "-----BEGIN PRIVATE KEY-----\n"
    "MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAOA3XD8fdHUFLAxA\n"
    "vLuTnVQBJF5inghpVnx3iYDBWkqtEESAuYBhIj+LONzXzb+m+NFaeooRM+O5hEEY\n"
    "QiPjjENgb6DxKGNqH95UizGaAAcj+XFs/CkLlGnk7QeAEJvChDxFDRLJWZLwp8p5\n"
    "CMGQ5QZzwZcZcOmUu10ueIHlxL7HAgMBAAECgYBvAvnpRumiBq2IY4UOWkfLD8Wx\n"
    "9aHJCF6JwaWS2iiaUJV9VT6DEZSjYYsFzNNR0JnhDaseMOZAGdohYKFeo4sN46wk\n"
    "b8yS/qZZ0NKc1KzKO+5cLSbSurUcoRCPbyxockdmFlQWlGBfQ3VIRHfBskgS3369\n"
    "K6IDCeKXjieSSZzMAQJBAPNSxPBoKPKBDF+z2/AFxPlR94eTzMEtNBf2YBPOemui\n"
    "p7mY7/JMFCIsy6ArAuTeWdpUV5fPBMjFXEL5DQqibX8CQQDr5cIH8Cy+3j+Yl9uq\n"
    "aBbtHG4QztzIkvR9VTLJMsvDkZviWQU8HDxgv5LXWejBJ/WAi9KcpxRrOOVE4Kb2\n"
    "B2K5AkEArsZLE2udzeKH4s4sMpHSVEteAxJUxoUToAqmJFPxdxLUaunBoEapR4rp\n"
    "kFiUsZRM8hgW+sIGa7fnd2uwxGy7PQJBAIcRzlCnR6eeMAHaac+fvAjWL3t2Rtqd\n"
    "sloVL3gemqeHNx+aYzHw5O1so9Kky23VyG9rIBPMYxelwzj1/QOAZRkCQQDZFRGB\n"
    "xr45ce4rIbaP1G4MVl394+xB30Sy7XiSxtD3ForS7f2z+X1qQziPpzqfIi5kCZ2J\n"
    "niknVBC9XA4ajnnB\n"
    "-----END PRIVATE KEY-----\n";
