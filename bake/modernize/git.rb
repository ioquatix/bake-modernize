
require 'bake/modernize'

def git
	update(root: Dir.pwd)
end

def update(root:)
	if current_branch != "main"
		# https://github.com/github/renaming
		system("git", "branch", "-M", "main")
		system("git", "push", "-u", "origin", "main")
	end
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
