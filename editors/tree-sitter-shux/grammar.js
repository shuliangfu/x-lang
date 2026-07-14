/**
 * Shux grammar for tree-sitter
 *
 * 【Why 逻辑根源】权威来源为 compiler/src/lexer/lexer.x 的 try_keyword（字节码匹配）
 * 与 editors/vscode/grammars/x.tmLanguage.json（已验证的 TextMate 模式）。
 * 禁止双权威：本文件必须与 lexer.x / parser.x 同步演进。
 *
 * 【Invariant 状态不变量】关键字使用 string literal，tree-sitter 自动处理
 * 关键字 vs 标识符的歧义（word: identifier）。注释 / 空白归入 extras。
 *
 * 【Asm/Perf 性能预期】tree-sitter 增量解析，编辑大文件 O(edit) 重解析；
 * 生成的 parser.c 编译为 native，无运行时分配（除错误恢复）。
 */

const PRIMITIVE_TYPES = [
  'i8', 'i16', 'i32', 'i64', 'isize',
  'u8', 'u16', 'u32', 'u64', 'usize',
  'f32', 'f64',
  'bool', 'void',
  'i32x4', 'i32x8', 'i32x16',
  'u32x4', 'u32x8', 'u32x16',
];

// 运算符优先级（从低到高）
const PREC = {
  assignment: 1,
  or: 2,
  and: 3,
  bit_or: 4,
  bit_xor: 5,
  bit_and: 6,
  comparison: 7,
  shift: 8,
  additive: 9,
  multiplicative: 10,
  unary: 11,
  as: 12,
  call: 13,
  member: 14,
};

module.exports = grammar({
  name: 'shux',

  // 不设 word：避免 identifier 词法抢占 type_name，确保 struct_literal (Type { ... }) 正确解析

  extras: $ => [
    /\s/,
    $.line_comment,
    $.block_comment,
    $.hash_comment,
  ],

  conflicts: $ => [
    [$.struct_literal, $._non_struct_expression],
    [$.field_expression, $.method_call_expression],
    [$.slice_type],
    [$.match_arm],
    [$._declaration, $._expression],
    [$.pointer_type, $.array_type],
    [$.array_type, $.function_type],
    // return 后 ; 可选（block 尾 return 无分号）导致 `return (expr)` 歧义：
    //   1. return (expr);  2. return (expr)  3. return;  (expr)...
    [$.return_statement],
    // expression_statement 的 ; 可选后，`expr }` 可解析为 expression_statement 或 block 尾表达式
    [$.expression_statement, $.block],
    // let 的 = expr 和 ; 都可选后，`let x: Type [` 歧义：array_type 继续 vs let 结束后接 [
    [$.array_type, $.let_declaration],
    // ternary vs await_expression：`await expr ? a : b` 歧义
    [$.ternary_expression, $.await_expression],
    // function_type 的可选返回类型 vs ternary 的 `:`：`... as function() : Type` 歧义
    [$.function_type],
    // array_type 自身递归：`[N]T[M]` 可能是 [N](T[M]) 或 ([N]T)[M]
    [$.array_type],
    // unsafe/region/with_arena block 既是 statement 又是 expression
    [$._declaration, $._non_struct_expression],
  ],

  rules: {
    /* ==================== 顶层 ==================== */

    source_file: $ => repeat($._top_level),

    _top_level: $ => choice(
      $.function_declaration,
      $.struct_declaration,
      $.enum_declaration,
      $.trait_declaration,
      $.impl_declaration,
      $.type_declaration,
      $.import_declaration,
      $.top_level_let,
      $.top_level_const,
      $.attribute_item,
    ),

    // 顶层 let/const（全局变量）：与 block 内 let 语法相同，但用于模块顶层
    top_level_let: $ => seq(
      repeat($.modifier),
      'let',
      field('name', $.identifier),
      optional(seq(':', $._type)),
      optional(seq('=', $._expression)),
      optional(';'),
    ),

    top_level_const: $ => seq(
      repeat($.modifier),
      'const',
      field('name', $.identifier),
      optional(seq(':', $._type)),
      '=',
      $._expression,
      optional(';'),
    ),

    /* ==================== 注释 ==================== */

    // 行注释：// 到行尾
    line_comment: $ => token(seq('//', /.*/)),

    // 数字注释：# 开头但不是 #[（属性）
    hash_comment: $ => token(seq('#', /[^\[].*/)),

    // 块注释：/* */，支持嵌套；用否定式正则避免 \*+ 贪婪吞掉闭合 */
    block_comment: $ => token(/\/\*([^*]|\*+[^*/])*\*+\//),

    /* ==================== 属性 ==================== */

    // #[name] 或 #[name(args)]
    attribute_item: $ => seq(
      '#[',
      $.attribute_name,
      optional($.attribute_args),
      ']',
    ),

    attribute_name: $ => $.identifier,

    // 属性参数：支持嵌套括号（如 #[cfg(not(target_os = "linux"))]）
    attribute_args: $ => seq('(', repeat(choice(/[^()]+/, seq('(', /[^()]*/, ')'))), ')'),

    /* ==================== 标识符与字面量 ==================== */

    // type_name 定义在 identifier 之前：tree-sitter 词法分析器对等长匹配选择先定义的规则，
    // 确保大写开头标识符优先匹配为 type_name（用于 struct_literal/类型高亮）
    type_name: $ => /[A-Z][a-zA-Z0-9_]*/,

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,

    integer_literal: $ => token(seq(
      choice(
        /0[xX][0-9a-fA-F]+/,
        /0[oO][0-7]+/,
        /0[bB][01]+/,
        /[0-9]+/,
      ),
      optional(/u?i?(8|16|32|64|size)/),
    )),

    float_literal: $ => token(seq(
      /[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?/,
      optional(/[fF]/),
    )),

    string_literal: $ => seq(
      '"',
      repeat(choice(
        $.escape_sequence,
        /[^"\\]/,
      )),
      '"',
    ),

    escape_sequence: $ => token.immediate(seq('\\', /./)),

    boolean_literal: $ => choice('true', 'false'),

    /* ==================== 声明 ==================== */

    function_declaration: $ => seq(
      repeat($.modifier),
      'function',
      field('name', $.identifier),
      optional($.generic_params),
      field('parameters', $.parameter_list),
      optional(seq(':', field('return_type', $._type))),
      choice(
        field('body', $.block),
        ';',
      ),
    ),

    // 泛型参数：<T, U>
    generic_params: $ => seq('<', $.type_name, repeat(seq(',', $.type_name)), optional(','), '>'),

    modifier: $ => choice(
      'export',
      'extern',
      $.extern_abi,
      'packed',
      'soa',
      'align',
      $.allow_padding,
    ),

    // extern "C" / extern "X"
    extern_abi: $ => seq('extern', $.abi_string),

    abi_string: $ => choice('"C"', '"X"'),

    // allow(padding) 前缀：用 token 包裹避免 'allow' 词法抢占 identifier
    // （否则 `allow = expr;` 中的 allow 被误匹配为 allow_padding 的首 token）
    allow_padding: $ => token(seq('allow', '(', 'padding', ')')),

    parameter_list: $ => seq(
      '(',
      optional(seq($.parameter, repeat(seq(',', $.parameter)))),
      optional(','),
      ')',
    ),

    parameter: $ => seq(
      field('name', $.identifier),
      optional(seq(':', field('type', $._type))),
    ),

    struct_declaration: $ => seq(
      repeat($.modifier),
      'struct',
      field('name', $.type_name),
      field('body', $.struct_body),
    ),

    // struct 体：字段分隔符可选（逗号/分号/换行均可），SHUX 真实代码存在无分隔符仅换行的情况
    struct_body: $ => seq(
      '{',
      repeat(seq($.struct_field, optional(choice(',', ';')))),
      '}',
    ),

    struct_field: $ => seq(
      field('name', $.identifier),
      ':',
      field('type', $._type),
    ),

    enum_declaration: $ => seq(
      repeat($.modifier),
      'enum',
      field('name', $.type_name),
      '{',
      optional(seq($.enum_variant, repeat(seq(',', $.enum_variant)))),
      optional(','),
      '}',
    ),

    enum_variant: $ => $.type_name,

    trait_declaration: $ => seq(
      repeat($.modifier),
      'trait',
      field('name', $.type_name),
      '{',
      repeat($._declaration),
      '}',
    ),

    impl_declaration: $ => seq(
      repeat($.modifier),
      'impl',
      field('name', $.type_name),
      '{',
      repeat($._declaration),
      '}',
    ),

    type_declaration: $ => seq(
      repeat($.modifier),
      'type',
      field('name', $.type_name),
      '=',
      $._type,
      ';',
    ),

    // const mod = import("path");
    // const NAME = expr;
    import_declaration: $ => seq(
      'const',
      field('name', $.identifier),
      '=',
      'import',
      '(',
      $.string_literal,
      ')',
      ';',
    ),

    /* ==================== 类型 ==================== */

    _type: $ => choice(
      $.primitive_type,
      $.type_name,
      $.qualified_type,
      $.pointer_type,
      $.slice_type,
      $.array_type,
      $.generic_type,
      $.function_type,
    ),

    primitive_type: $ => choice(...PRIMITIVE_TYPES),

    // 限定类型名：module.Type（如 ast.Expr、token.TokenKind）
    qualified_type: $ => seq($.identifier, '.', $.type_name),

    pointer_type: $ => seq('*', $._type),

    // T[]<lifetime>  或  T[] — prec(1) 让 []< 优先匹配 lifetime 而非比较运算
    slice_type: $ => prec(1, seq(
      $._type,
      '[]',
      optional(seq('<', $.identifier, '>')),
    )),

    // 数组类型：SHUX 同时支持 T[N]（C 风格）和 [N]T（Go 风格）
    array_type: $ => choice(
      seq($._type, '[', $.integer_literal, ']'),
      seq('[', $.integer_literal, ']', $._type),
    ),

    // Option<T> / Result<T,E> — prec(1) 让 Type< 优先匹配泛型而非比较运算
    generic_type: $ => prec(1, seq(
      $.type_name,
      '<',
      $._type,
      repeat(seq(',', $._type)),
      optional(','),
      '>',
    )),

    function_type: $ => seq(
      'function',
      '(',
      optional(seq($._type, repeat(seq(',', $._type)))),
      ')',
      optional(seq(':', $._type)),
    ),

    /* ==================== 语句 ==================== */

    _declaration: $ => choice(
      $.function_declaration,
      $.let_declaration,
      $.const_declaration,
      $.expression_statement,
      $.return_statement,
      $.if_expression,
      $.match_statement,
      $.while_statement,
      $.for_statement,
      $.loop_statement,
      $.break_statement,
      $.continue_statement,
      $.defer_statement,
      $.goto_statement,
      $.unsafe_block,
      $.region_block,
      $.with_arena_block,
    ),

    goto_statement: $ => seq('goto', $.identifier, ';'),

    // let 后 ; 可选：SHUX parser 在 let 初值后若遇 return/if/while/for/} 即视为语句结束
    // （parser.x parser_rewind_lex_for_following_stmt）；struct_literal 末尾 } 后常省略 ;
    // = expr 可选：SHUX 支持 `let x: Type;`（仅声明未初始化）
    let_declaration: $ => seq(
      'let',
      field('name', $.identifier),
      optional(seq(':', $._type)),
      optional(seq('=', $._expression)),
      optional(';'),
    ),

    const_declaration: $ => seq(
      'const',
      field('name', $.identifier),
      optional(seq(':', $._type)),
      '=',
      $._expression,
      optional(';'),
    ),

    // 表达式语句 ; 可选：block 尾表达式无分号（SHUX 尾表达式语义）
    expression_statement: $ => seq($._expression, optional(';')),

    // return 的 ; 可选：SHUX 允许 block 内 return 后直接 }（如 `if c { return E }`）
    return_statement: $ => seq('return', optional($._expression), optional(';')),

    // if 既是语句也是表达式（SHUX 支持 `return if cond { 0 } else { 1 };`）
    if_expression: $ => seq(
      'if',
      field('condition', $._non_struct_expression),
      field('consequence', $.block),
      optional(seq('else', field('alternative', choice($.block, $.if_expression)))),
    ),

    match_statement: $ => seq(
      'match',
      field('value', $._expression),
      '{',
      repeat($.match_arm),
      '}',
    ),

    match_arm: $ => seq(
      field('pattern', $._expression),
      '=>',
      field('value', choice(
        $._expression,
        seq('return', optional($._expression)),
        'break',
        'continue',
      )),
      optional(','),
    ),

    while_statement: $ => seq(
      'while',
      field('condition', $._non_struct_expression),
      field('body', $.block),
    ),

    // for (i : 0 .. n) { }
    for_statement: $ => seq(
      'for',
      '(',
      field('name', $.identifier),
      ':',
      field('start', $._expression),
      '..',
      field('end', $._expression),
      ')',
      field('body', $.block),
    ),

    loop_statement: $ => seq(
      'loop',
      field('body', $.block),
    ),

    break_statement: $ => seq('break', ';'),

    continue_statement: $ => seq('continue', ';'),

    defer_statement: $ => seq('defer', $._expression, ';'),

    unsafe_block: $ => seq('unsafe', $.block),

    region_block: $ => seq('region', $.block),

    with_arena_block: $ => seq('with_arena', $.block),

    /* ==================== 块 ==================== */

    // block：语句序列 + 可选尾表达式（无分号返回值，如 `{ stmt; expr }`）
    block: $ => seq(
      '{',
      repeat($._declaration),
      optional($._expression),
      '}',
    ),

    /* ==================== 表达式 ==================== */

    // 完整表达式（含 struct_literal / if_expression）
    _expression: $ => choice(
      $._non_struct_expression,
      $.struct_literal,
      $.if_expression,
    ),

    // 不含 struct_literal 的表达式，用于 if/while/for 条件
    // 避免 `if Type { }` 歧义（struct_literal vs condition + block）
    _non_struct_expression: $ => choice(
      $.identifier,
      $.type_name,
      $.integer_literal,
      $.float_literal,
      $.string_literal,
      $.boolean_literal,
      $.self_expression,
      $.panic_expression,
      $.unary_expression,
      $.binary_expression,
      $.cast_expression,
      $.call_expression,
      $.field_expression,
      $.method_call_expression,
      $.index_expression,
      $.array_literal,
      $.parenthesized_expression,
      $.await_expression,
      $.block_expression,
      $.ternary_expression,
      $.unsafe_block,
      $.region_block,
      $.with_arena_block,
    ),

    // 三元运算符：cond ? a : b
    ternary_expression: $ => prec.right(seq(
      $._expression, '?', $._expression, ':', $._expression,
    )),

    self_expression: $ => 'self',

    // panic 可作为表达式（如 `n => panic`）
    panic_expression: $ => 'panic',

    await_expression: $ => seq('await', $._expression),

    // block 作为表达式（tail return：最后一条表达式作为返回值）
    block_expression: $ => $.block,

    parenthesized_expression: $ => seq('(', $._expression, ')'),

    unary_expression: $ => prec(PREC.unary, seq(
      choice('!', '-', '*', '&', '~'),
      $._expression,
    )),

    // expr as Type（类型转换）
    cast_expression: $ => prec(PREC.as, seq(
      $._expression,
      'as',
      $._type,
    )),

    binary_expression: $ => choice(
      prec.left(PREC.multiplicative, seq($._expression, choice('*', '/', '%'), $._expression)),
      prec.left(PREC.additive, seq($._expression, choice('+', '-'), $._expression)),
      prec.left(PREC.shift, seq($._expression, choice('<<', '>>'), $._expression)),
      prec.left(PREC.and, seq($._expression, '&&', $._expression)),
      prec.left(PREC.or, seq($._expression, '||', $._expression)),
      prec.left(PREC.bit_and, seq($._expression, '&', $._expression)),
      prec.left(PREC.bit_or, seq($._expression, '|', $._expression)),
      prec.left(PREC.bit_xor, seq($._expression, '^', $._expression)),
      prec.left(PREC.comparison, seq($._expression, choice('==', '!=', '<', '>', '<=', '>='), $._expression)),
      prec.right(PREC.assignment, seq($._expression, choice('=', '+=', '-=', '*=', '/=', '%='), $._expression)),
    ),

    call_expression: $ => prec(PREC.call, seq(
      field('function', $._expression),
      field('arguments', $.argument_list),
    )),

    argument_list: $ => seq(
      '(',
      optional(seq($._expression, repeat(seq(',', $._expression)))),
      optional(','),
      ')',
    ),

    field_expression: $ => prec(PREC.member, seq(
      $._expression,
      '.',
      field('field', choice($.identifier, $.type_name)),
    )),

    method_call_expression: $ => prec(PREC.member, seq(
      $._expression,
      '.',
      field('method', choice($.identifier, $.type_name)),
      optional($.generic_args),
      field('arguments', $.argument_list),
    )),

    // 泛型实参：<Type>（方法调用时，如 types.size_of<BrotliStream>()）
    generic_args: $ => seq('<', $._type, repeat(seq(',', $._type)), optional(','), '>'),

    // arr[i] 索引
    index_expression: $ => prec(PREC.member, seq(
      $._expression,
      '[',
      $._expression,
      ']',
    )),

    array_literal: $ => seq(
      '[',
      optional(seq($._expression, repeat(seq(',', $._expression)))),
      optional(','),
      ']',
    ),

    // struct_literal: Type { field: value, ... }
    struct_literal: $ => seq(
      $.type_name,
      '{',
      optional(seq($.struct_literal_field, repeat(seq(',', $.struct_literal_field)))),
      optional(','),
      '}',
    ),

    struct_literal_field: $ => seq(
      field('name', $.identifier),
      ':',
      field('value', $._expression),
    ),
  },
});
