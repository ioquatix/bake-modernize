# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'bake/modernize'
require 'markly'

def contributing
	if conduct_path = Dir["conduct.md"]
		FileUtils.rm_f(conduct_path)
	end
	
	update_contributing(File.join(Dir.pwd, 'readme.md'))
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

### Developer Certificate of Origin

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). All contributors to this project must agree to this document to have their contributions accepted.

### Contributor Covenant

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/). All contributors and participants agree to abide by its terms.
EOF

def update_contributing(readme_path)
	root = Markly.parse(File.read(readme_path))
	
	replacement = Markly.parse(DEFAULT_CONTRIBUTING)
	
	return unless node = root.find_header("Contributing")
	
	node.replace_section(replacement)
	
	File.write(readme_path, root.to_markdown(width: 0))
end
