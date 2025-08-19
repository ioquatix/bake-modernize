# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		class Directory < List
			def self.join(*args)
				self.new(Path.join(*args))
			end
			
			def initialize(root)
				@root = root
			end
			
			def root
				@root
			end
			
			def roots
				[root]
			end
			
			def each
				return to_enum(:each) unless block_given?
				
				# We match both normal files with * and dotfiles with .?*
				Dir.glob(@root + "**/{*,.?*}") do |path|
					yield Path.new(path, @root)
				end
			end
			
			def eql?(other)
				self.class.eql?(other.class) and @root.eql?(other.root)
			end
			
			def hash
				@root.hash
			end
		
			def include?(path)
				# Would be true if path is a descendant of full_path.
				path.start_with?(@root)
			end
		
			def rebase(root)
				self.class.new(@root.rebase(root))
			end
			
			# Convert a Directory into a String, can be used as an argument to a command.
			def to_str
				@root.to_str
			end
			
			def to_s
				to_str
			end
			
			def to_path
				@root
			end
		end
	end
end
