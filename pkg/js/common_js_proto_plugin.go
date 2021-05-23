package protoc

import (
	"path"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/stackb/rules_proto/pkg/protoc"
)

func init() {
	protoc.Plugins().MustRegisterPlugin("commonjs", &CommonJsPlugin{})
}

// CommonJsPlugin implements Plugin for the built-in js plugin with
// commonjs option.
type CommonJsPlugin struct{}

// Label implements part of the Plugin interface.
func (p *CommonJsPlugin) Label() label.Label {
	return label.New("build_stack_rules_proto", "protocolbuffers/protobuf", "common_js_plugin")
}

// ShouldApply implements part of the Plugin interface.
func (p *CommonJsPlugin) ShouldApply(rel string, cfg protoc.PackageConfig, lib protoc.ProtoLibrary) bool {
	for _, f := range lib.Files() {
		if f.HasMessages() || f.HasEnums() {
			return true
		}
	}
	return false
}

// Outputs implements part of the Plugin interface.
func (p *CommonJsPlugin) Outputs(rel string, cfg protoc.PackageConfig, lib protoc.ProtoLibrary) []string {
	srcs := make([]string, 0)
	for _, f := range lib.Files() {
		base := f.Name
		pkg := f.Package()
		if pkg.Name != "" {
			base = path.Join(strings.ReplaceAll(pkg.Name, ".", "/"), base)
		}
		if f.HasMessages() || f.HasEnums() {
			srcs = append(srcs, base+"_pb.js")
		}
	}
	return srcs
}