# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'bake/modernize'

def git
	update(root: Dir.pwd)
end

def update(root:)
	if current_branch == "master"
		# https://github.com/github/renaming
		system("git", "branch", "-M", "main")
		system("git", "push", "-u", "origin", "main")
	end
	
	template_root = Bake::Modernize.template_path_for('git')
	Bake::Modernize.copy_template(template_root, root)
end

private

def current_branch
	require 'open3'
	
	output, status = Open3.capture2("git", "branch", "--show-current")
	
	unless status.success?
		raise "Could not get current branch!"
	end
	
	return output
end
