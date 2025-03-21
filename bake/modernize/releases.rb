# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require "bake/modernize"
require "markly"

# Update the project to use bake-releases for release notes.
#
# @parameter root [String] The root directory of the project.
def releases(root: Dir.pwd)
	system("bundle", "add", "bake-releases", "--group", "maintenance", chdir: root)
	
	update_releases(File.join(root, "readme.md"))
	
	template_root = Bake::Modernize.template_path_for("releases")
	Bake::Modernize.copy_template(template_root, root)
end

private

DEFAULT_CONTRIBUTING = <<~MARKDOWN
## Releases

There are no documented releases.
MARKDOWN

def update_releases(readme_path)
	root = Markly.parse(File.read(readme_path))
	
	return if root.find_header("Releases")
	
	replacement = Markly.parse(DEFAULT_CONTRIBUTING)
	
	unless node = root.find_header("See Also")
		node = root.find_header("Contributing")
	end
	
	if node
		node.append_before(replacement)
	else
		root.append(replacement)
	end
	
	File.write(readme_path, root.to_markdown(width: 0))
end
