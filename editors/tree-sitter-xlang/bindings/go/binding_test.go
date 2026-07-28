package tree_sitter_xlang_test

import (
	"testing"

	tree_sitter "github.com/smacker/go-tree-sitter"
	tree_sitter_xlang "github.com/shuliangfu/x-lang/editors/tree-sitter-xlang/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_xlang.Language())
	if language == nil {
		t.Errorf("Error loading Xlang grammar")
	}
}
