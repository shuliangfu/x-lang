package tree_sitter_shux_test

import (
	"testing"

	tree_sitter "github.com/smacker/go-tree-sitter"
	"github.com/tree-sitter/tree-sitter-shux"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_shux.Language())
	if language == nil {
		t.Errorf("Error loading Shux grammar")
	}
}
