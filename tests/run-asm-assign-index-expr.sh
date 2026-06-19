#!/usr/bin/env bash
# asm 7.3：arr[i+lit] assign scratch 寻址；return INDEX 加法链。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/asm/assign_index_var_plus_lit.sx -o /tmp/shux_asm_assign_index_var_plus_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_plus_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: var+lit expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_plus_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: var+lit assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/binop_index_add_chain.sx -o /tmp/shux_asm_binop_index_add_chain 2>&1
exitcode=0
/tmp/shux_asm_binop_index_add_chain >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 30 ] && { echo "run-asm-assign-index-expr FAIL: index add chain expected 30, got $exitcode"; exit 1; }

$SHUX tests/asm/assign_index_var_plus_var.sx -o /tmp/shux_asm_assign_index_var_plus_var 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_plus_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i+j expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_plus_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i+j assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_plus_var_copy.sx -o /tmp/shux_asm_assign_index_var_plus_var_copy 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_plus_var_copy >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 15 ] && { echo "run-asm-assign-index-expr FAIL: i+j=arr[k] expected 15, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_plus_var_copy 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i+j=arr[k] still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_minus_lit.sx -o /tmp/shux_asm_assign_index_var_minus_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_minus_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i-lit expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_minus_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i-lit assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_minus_var.sx -o /tmp/shux_asm_assign_index_var_minus_var 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_minus_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i-j expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_minus_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i-j assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_mul_lit.sx -o /tmp/shux_asm_assign_index_var_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i*2 expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i*2 assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_lit_mul_var.sx -o /tmp/shux_asm_assign_index_lit_mul_var 2>&1
exitcode=0
/tmp/shux_asm_assign_index_lit_mul_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 88 ] && { echo "run-asm-assign-index-expr FAIL: 2*i expected 88, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_lit_mul_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: 2*i assign still uses mov x2"
  exit 1
fi

run_read_one() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  $SHUX "$src" -o "$out" 2>&1
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  [ "$exitcode" -ne "$want" ] && {
    echo "run-asm-assign-index-expr FAIL: $tag expected exit $want, got $exitcode"
    exit 1
  }
  if otool -tv "$out" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
    echo "run-asm-assign-index-expr FAIL: $tag still uses mov x2"
    exit 1
  fi
}

run_read_one tests/asm/index_read_var_mul_lit.sx /tmp/shux_asm_index_read_var_mul_lit 30 "read i*2"
run_read_one tests/asm/index_read_var_plus_lit.sx /tmp/shux_asm_index_read_var_plus_lit 10 "read i+1"
run_read_one tests/asm/index_read_var_minus_lit.sx /tmp/shux_asm_index_read_var_minus_lit 10 "read i-1"
run_read_one tests/asm/index_read_var_plus_var.sx /tmp/shux_asm_index_read_var_plus_var 15 "read i+j"
run_read_one tests/asm/index_read_var_mul_var.sx /tmp/shux_asm_index_read_var_mul_var 30 "read i*j"
run_read_one tests/asm/index_read_var_plus_var_plus_var.sx /tmp/shux_asm_index_read_var_plus_var_plus_var 40 "read i+j+k"
run_read_one tests/asm/index_read_var_plus_var_mul_lit.sx /tmp/shux_asm_index_read_var_plus_var_mul_lit 30 "read (i+j)*2"
run_read_one tests/asm/index_read_var_plus_paren_var_plus_var.sx /tmp/shux_asm_index_read_var_plus_paren_var_plus_var 40 "read i+(j+k)"
run_read_one tests/asm/index_read_var_add3_mul_lit.sx /tmp/shux_asm_index_read_var_add3_mul_lit 30 "read (i+j+k)*2"
run_read_one tests/asm/index_read_var_minus_var_plus_var.sx /tmp/shux_asm_index_read_var_minus_var_plus_var 30 "read i-j+k"

$SHUX tests/asm/assign_index_var_minus_var_plus_var.sx -o /tmp/shux_asm_assign_index_var_minus_var_plus_var 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_minus_var_plus_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i-j+k assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_minus_var_plus_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i-j+k assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_minus_var_plus_var.sx -o /tmp/shux_asm_assign_read_index_var_minus_var_plus_var 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_minus_var_plus_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read i-j+k expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_minus_var_plus_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read i-j+k still uses mov x2"
  exit 1
fi

run_read_one tests/asm/index_read_var_minus_var_minus_var.sx /tmp/shux_asm_index_read_var_minus_var_minus_var 30 "read (i-j)-k"
run_read_one tests/asm/index_read_var_minus_add3.sx /tmp/shux_asm_index_read_var_minus_add3 20 "read i-(j+k)"
run_read_one tests/asm/index_read_var_minus_var_mul_lit.sx /tmp/shux_asm_index_read_var_minus_var_mul_lit 30 "read (i-j)*2"

$SHUX tests/asm/assign_index_var_minus_var_minus_var.sx -o /tmp/shux_asm_assign_index_var_minus_var_minus_var 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_minus_var_minus_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: (i-j)-k assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_minus_var_minus_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: (i-j)-k assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_minus_add3.sx -o /tmp/shux_asm_assign_index_var_minus_add3 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_minus_add3 >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i-(j+k) assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_minus_add3 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i-(j+k) assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_minus_var_mul_lit.sx -o /tmp/shux_asm_assign_index_var_minus_var_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_minus_var_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: (i-j)*2 assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_minus_var_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: (i-j)*2 assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_minus_add3.sx -o /tmp/shux_asm_assign_read_index_var_minus_add3 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_minus_add3 >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read i-(j+k) expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_minus_add3 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read i-(j+k) still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_plus_paren_var_plus_var.sx -o /tmp/shux_asm_assign_index_var_plus_paren_var_plus_var 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_plus_paren_var_plus_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i+(j+k) assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_plus_paren_var_plus_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i+(j+k) assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_add3_mul_lit.sx -o /tmp/shux_asm_assign_index_var_add3_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_add3_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: (i+j+k)*2 assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_add3_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: (i+j+k)*2 assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_plus_var_plus_var.sx -o /tmp/shux_asm_assign_index_var_plus_var_plus_var 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_plus_var_plus_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i+j+k assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_plus_var_plus_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i+j+k assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_plus_var_mul_lit.sx -o /tmp/shux_asm_assign_index_var_plus_var_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_plus_var_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: (i+j)*2 assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_plus_var_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: (i+j)*2 assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_index_var_mul_var.sx -o /tmp/shux_asm_assign_index_var_mul_var 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_mul_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: i*j assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_mul_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: i*j assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_mul_lit.sx -o /tmp/shux_asm_assign_read_index_var_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read i*2 expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read i*2 still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_mul_var.sx -o /tmp/shux_asm_assign_read_index_var_mul_var 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_mul_var >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read i*j expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_mul_var 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read i*j still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_plus_var_mul_lit.sx -o /tmp/shux_asm_assign_read_index_var_plus_var_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_plus_var_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read (i+j)*2 expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_plus_var_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read (i+j)*2 still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_add3_mul_lit.sx -o /tmp/shux_asm_assign_read_index_var_add3_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_add3_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read (i+j+k)*2 expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_add3_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read (i+j+k)*2 still uses mov x2"
  exit 1
fi

run_read_one tests/asm/index_read_var_subadd3_mul_lit.sx /tmp/shux_asm_index_read_var_subadd3_mul_lit 30 "read (i-j+k)*2"

$SHUX tests/asm/assign_index_var_subadd3_mul_lit.sx -o /tmp/shux_asm_assign_index_var_subadd3_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_subadd3_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: (i-j+k)*2 assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_subadd3_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: (i-j+k)*2 assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_subadd3_mul_lit.sx -o /tmp/shux_asm_assign_read_index_var_subadd3_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_subadd3_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read (i-j+k)*2 expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_subadd3_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read (i-j+k)*2 still uses mov x2"
  exit 1
fi

run_read_one tests/asm/index_read_var_subsub3_mul_lit.sx /tmp/shux_asm_index_read_var_subsub3_mul_lit 30 "read (i-j-k)*2"

$SHUX tests/asm/assign_index_var_subsub3_mul_lit.sx -o /tmp/shux_asm_assign_index_var_subsub3_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_subsub3_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: (i-j-k)*2 assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_subsub3_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: (i-j-k)*2 assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_subsub3_mul_lit.sx -o /tmp/shux_asm_assign_read_index_var_subsub3_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_subsub3_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read (i-j-k)*2 expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_subsub3_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read (i-j-k)*2 still uses mov x2"
  exit 1
fi

run_read_one tests/asm/index_read_var_minus_add3_mul_lit.sx /tmp/shux_asm_index_read_var_minus_add3_mul_lit 30 "read (i-(j+k))*2"

$SHUX tests/asm/assign_index_var_minus_add3_mul_lit.sx -o /tmp/shux_asm_assign_index_var_minus_add3_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_index_var_minus_add3_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: (i-(j+k))*2 assign expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_index_var_minus_add3_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: (i-(j+k))*2 assign still uses mov x2"
  exit 1
fi

$SHUX tests/asm/assign_read_index_var_minus_add3_mul_lit.sx -o /tmp/shux_asm_assign_read_index_var_minus_add3_mul_lit 2>&1
exitcode=0
/tmp/shux_asm_assign_read_index_var_minus_add3_mul_lit >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 99 ] && { echo "run-asm-assign-index-expr FAIL: assign+read (i-(j+k))*2 expected 99, got $exitcode"; exit 1; }
if otool -tv /tmp/shux_asm_assign_read_index_var_minus_add3_mul_lit 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
  echo "run-asm-assign-index-expr FAIL: assign+read (i-(j+k))*2 still uses mov x2"
  exit 1
fi

echo "asm assign index expr OK"
