
require 'bake/modernize'

def actions
	update(root: Dir.pwd)
end

def update(root:)
	travis_path = File.expand_path(".travis.yml", root)
	
	if File.exist?(travis_path)
		FileUtils.rm_rf(travis_path)
	end
	
	template_root = Bake::Modernize.template_path_for('actions')
	Bake::Modernize.copy_template(template_root, root)
end
