# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2026, by Samuel Williams.

require "bake/modernize"

def editorconfig(root: Dir.pwd)
	update(root: root)
end

def update(root:)
	template_root = Bake::Modernize.template_path_for("editorconfig")
	Bake::Modernize.copy_template(template_root, root)
end
