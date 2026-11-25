#!/usr/bin/env python3
"""Local leftover smoke HTTP server for tests/run-http.sh (127.0.0.1:PORT)."""
import socket
import sys

def main() -> None:
    port = int(sys.argv[1])
    body = (
        b"HTTP/1.0 200 OK\r\n"
        b"Content-Length: 5\r\n"
        b"Connection: close\r\n"
        b"\r\n"
        b"Hello"
    )
    srv = socket.socket()
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", port))
    srv.listen(16)
    while True:
        c, _ = srv.accept()
        try:
            c.settimeout(2.0)
            buf = b""
            while b"\r\n\r\n" not in buf:
                chunk = c.recv(4096)
                if not chunk:
                    break
                buf += chunk
            c.sendall(body)
        except Exception:
            pass
        finally:
            try:
                c.close()
            except Exception:
                pass

if __name__ == "__main__":
    main()
