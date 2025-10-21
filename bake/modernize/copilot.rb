# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Copilot.
# Copyright, 2025, by Samuel Williams.

require "bake/modernize"

def copilot
	update(root: Dir.pwd)
end

def update(root:)
	template_root = Bake::Modernize.template_path_for("copilot")
	Bake::Modernize.copy_template(template_root, root)
end
