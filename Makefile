# Shux 顶层 Makefile
# 委托 compiler 目录构建，产出 shux；测试等目标在此统一入口

.PHONY: all clean test test_c test_sx bootstrap-lexer bootstrap-token

# 默认目标：构建编译器 shux
all:
	$(MAKE) -C compiler

# 清理构建产物
clean:
	$(MAKE) -C compiler clean

# 测试（阶段 1：词法测试；后续接入 Parser 等）
test:
	$(MAKE) -C compiler test

# 仅 C 路径测试（run-*.sh，不含 sx 自举）
test_c:
	$(MAKE) -C compiler test_c

# 仅 sx 自举测试（bootstrap-driver-seed + run-lsp + run-all-sx 全量）
test_sx:
	$(MAKE) -C compiler test_sx

# 自举：用当前 shux 编译 .sx 词法分析器并运行，验证通过则打印 bootstrap-lexer OK
bootstrap-lexer:
	$(MAKE) -C compiler bootstrap-lexer

# 自举：用当前 shux 编译 token.sx 并运行（若 compiler 有该目标）
bootstrap-token:
	$(MAKE) -C compiler bootstrap-token
