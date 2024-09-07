# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "bake/modernize"

def git
	update(root: Dir.pwd)
end

def update(root:)
	if current_branch == "master"
		# https://github.com/github/renaming
		system("git", "branch", "-M", "main")
		system("git", "push", "-u", "origin", "main")
	end
	
	current_gitignore_custom_lines = self.current_gitignore_custom_lines(root)
	
	template_root = Bake::Modernize.template_path_for("git")
	Bake::Modernize.copy_template(template_root, root)
	
	if current_gitignore_custom_lines
		File.open(File.join(root, ".gitignore"), "a") do |file|
			file.puts
			file.puts(current_gitignore_custom_lines)
		end
	end
end

private

def current_gitignore_custom_lines(root)
	gitignore_path = File.join(root, ".gitignore")
	
	if File.exist?(gitignore_path)
		lines = File.readlines(gitignore_path)
		if blank_index = lines.index{|line| line =~ /^\s*$/}
			lines.shift(blank_index+1)
			return lines
		end
	end
end

def current_branch
	require "open3"
	
	output, status = Open3.capture2("git", "branch", "--show-current")
	
	unless status.success?
		raise "Could not get current branch!"
	end
	
	return output
end
