==================
Test 1: Functions
==================

export function add(a: i32, b: i32): i32 {
  return a + b;
}

---

(source_file
  (function_declaration
    (modifier)
    name: (identifier)
    parameters: (parameter_list
      (parameter
        name: (identifier)
        type: (primitive_type))
      (parameter
        name: (identifier)
        type: (primitive_type)))
    return_type: (primitive_type)
    body: (block
      (return_statement
        (binary_expression
          (identifier)
          (identifier))))))

==================
Test 2: Structs
==================

allow(padding) struct Point {
  x: i32,
  y: i32,
}

---

(source_file
  (struct_declaration
    (modifier
      (allow_padding))
    name: (type_name)
    body: (struct_body
      (struct_field
        name: (identifier)
        type: (primitive_type))
      (struct_field
        name: (identifier)
        type: (primitive_type)))))

==================
Test 3: Extern ABI
==================

extern "C" function printf(fmt: *u8): i32;

---

(source_file
  (function_declaration
    (modifier
      (extern_abi
        (abi_string)))
    name: (identifier)
    parameters: (parameter_list
      (parameter
        name: (identifier)
        type: (pointer_type
          (primitive_type))))
    return_type: (primitive_type)))

==================
Test 4: Match and For
==================

export function test(x: i32, n: i32): void {
  match x {
    0 => return,
    n => panic,
  }
  for (i : 0 .. n) {
    arr[i] = arr[i] + 1;
  }
}

---

(source_file
  (function_declaration
    (modifier)
    name: (identifier)
    parameters: (parameter_list
      (parameter
        name: (identifier)
        type: (primitive_type))
      (parameter
        name: (identifier)
        type: (primitive_type)))
    return_type: (primitive_type)
    body: (block
      (match_statement
        value: (identifier)
        (match_arm
          pattern: (integer_literal))
        (match_arm
          pattern: (identifier)
          value: (panic_expression)))
      (for_statement
        name: (identifier)
        start: (integer_literal)
        end: (identifier)
        body: (block
          (expression_statement
            (binary_expression
              (index_expression
                (identifier)
                (identifier))
              (binary_expression
                (index_expression
                  (identifier)
                  (identifier))
                (integer_literal)))))))))
