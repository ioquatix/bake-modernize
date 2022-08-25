# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

require 'bake/modernize'

def editorconfig
	update(root: Dir.pwd)
end

def update(root:)
	editorconfig_path = File.expand_path(".editorconfig", root)
	
	if File.exist?(editorconfig_path)
		FileUtils.rm_rf(editorconfig_path)
	end
	
	template_root = Bake::Modernize.template_path_for('editorconfig')
	Bake::Modernize.copy_template(template_root, root)
end
