; Tree-sitter indentation rules for Xlang (Neovim / Helix)
; 约定与 editors/vscode/language-configuration.json indentationRules 对齐

[
  (block)
  (struct_body)
  (match_statement)
] @indent.begin

[
  "}"
  "]"
  ")"
] @indent.end

(_ "[" @indent.branch) @indent.begin
(_ "(" @indent.branch) @indent.begin

(match_arm (_) @indent.begin)
