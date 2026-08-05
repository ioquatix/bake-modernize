# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2026, by Samuel Williams.

require "bake/modernize"
require "build/files/system"

def rubocop(root: Dir.pwd)
	update(root: root)
end

def update(root:)
	system("bundle", "add", "rubocop", "rubocop-md", "rubocop-socketry", "--group", "test", chdir: root)
	
	template_root = Bake::Modernize.template_path_for("rubocop")
	Bake::Modernize.copy_template(template_root, root)
	
	system("bundle", "update", chdir: root)
	system("bundle", "exec", "rubocop", chdir: root)
end
