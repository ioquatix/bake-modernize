# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "bake/modernize"
require "build/files/system"

def readme
	update(root: Dir.pwd)
end

def update(root:)
	update_filenames(root)
end

private

def update_filenames(root)
	root = Build::Files::Path.new(root)
	md_files = root.glob("*.md")
	
	# Move all .yml files to .yaml files :)
	md_files.each do |path|
		new_path = path.with(basename: path.basename.downcase)
		
		unless new_path == path
			Console.logger.info(self, "Moving #{path} to #{new_path}...")
			system("git", "mv", "-f", path, new_path)
		end
	end
end
