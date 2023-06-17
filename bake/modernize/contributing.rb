# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'bake/modernize'
require 'markly'

def contributing
	update(root: Dir.pwd)
	update_contributing(File.join(Dir.pwd, 'readme.md'))
end

def update(root:)
	template_root = Bake::Modernize.template_path_for('contributing')
	Bake::Modernize.copy_template(template_root, root)
end

private

DEFAULT_CONTRIBUTING = <<~EOF
## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.
EOF

def update_contributing(readme_path)
	root = Markly.parse(File.read(readme_path))
	
	replacement = Markly.parse(DEFAULT_CONTRIBUTING)
	
	return unless node = root.find_header("Contributing")
	
	node.replace_section(replacement)
	
	File.write(readme_path, root.to_markdown(width: 0))
end
