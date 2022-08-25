# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require 'bake/modernize'

def gemfile
	update(root: Dir.pwd)
end

def update(root:)
	gemfile_path = File.expand_path("Gemfile", root)
	gems_path = File.expand_path("gems.rb", root)
	
	if File.exist?(gemfile_path)
		FileUtils::Verbose.mv gemfile_path, gems_path
	end
	
	gemfile_lock_path = File.expand_path("Gemfile.lock", root)
	gems_locked_path = File.expand_path("gems.locked", root)
	
	if File.exist?(gemfile_lock_path)
		FileUtils::Verbose.mv gemfile_lock_path, gems_locked_path
	end
	
	gitignore_path = File.expand_path(".gitignore", root)
	
	if File.exist?(gitignore_path)
		lines = File.readlines(gitignore_path)
		
		if index = lines.index{|pattern| pattern =~ /Gemfile\.lock/}
			lines[index] = "/gems.locked"
		elsif !lines.index{|pattern| pattern =~ /gems\.locked/}
			lines << ""
			lines << "/gems.locked"
		end
		
		File.open(gitignore_path, "w") do |file|
			file.puts(lines)
		end
	end
end
