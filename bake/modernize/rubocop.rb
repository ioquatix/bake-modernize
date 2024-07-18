# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'bake/modernize'
require 'build/files/system'

def rubocop
	update(root: Dir.pwd)
end

def update(root:)
	system("bundle", "add", "rubocop", "--group", "maintenance", chdir: root)
	
	template_root = Bake::Modernize.template_path_for('rubocop')
	Bake::Modernize.copy_template(template_root, root)
	
	system("bundle", "update", chdir: root)
	system("bundle", "exec", "rubocop", chdir: root)
end
