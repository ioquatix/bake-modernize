# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		class Path
			def glob(pattern)
				Glob.new(self, pattern)
			end
		end
		
		class Glob < List
			def initialize(root, pattern)
				@root = root
				@pattern = pattern
			end
			
			attr :root
			attr :pattern
			
			def roots
				[@root]
			end
			
			def full_pattern
				Path.join(@root, @pattern)
			end
			
			# Enumerate all paths matching the pattern.
			def each(&block)
				return to_enum unless block_given?
				
				::Dir.glob(full_pattern, ::File::FNM_DOTMATCH) do |path|
					# Ignore `.` and `..` entries.
					next if path =~ /\/..?$/
					
					yield Path.new(path, @root)
				end
			end
			
			def eql?(other)
				self.class.eql?(other.class) and @root.eql?(other.root) and @pattern.eql?(other.pattern)
			end
			
			def hash
				[@root, @pattern].hash
			end
			
			def include?(path)
				File.fnmatch(full_pattern, path)
			end
			
			def rebase(root)
				self.class.new(root, @pattern)
			end
			
			def inspect
				"<Glob #{full_pattern.inspect}>"
			end
		end
	end
end
