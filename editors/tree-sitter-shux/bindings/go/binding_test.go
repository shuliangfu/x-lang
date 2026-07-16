package tree_sitter_shux_test

import (
	"testing"

	tree_sitter "github.com/smacker/go-tree-sitter"
	tree_sitter_shux "github.com/shuliangfu/shux/editors/tree-sitter-shux/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_shux.Language())
	if language == nil {
		t.Errorf("Error loading Shux grammar")
	}
}
