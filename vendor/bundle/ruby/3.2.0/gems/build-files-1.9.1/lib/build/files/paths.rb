# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		class Paths < List
			def initialize(list, roots = nil)
				@list = Array(list).freeze
				@roots = roots
			end
			
			attr :list
			
			# The list of roots for a given list of immutable files is also immutable, so we cache it for performance:
			def roots
				@roots ||= super
			end
			
			def count
				@list.count
			end
			
			def each
				return to_enum(:each) unless block_given?
				
				@list.each{|path| yield path}
			end
			
			def eql?(other)
				self.class.eql?(other.class) and @list.eql?(other.list)
			end
		
			def hash
				@list.hash
			end
			
			def to_paths
				self
			end
			
			def inspect
				"<Paths #{@list.inspect}>"
			end
			
			def self.directory(root, relative_paths)
				paths = relative_paths.collect do |path|
					Path.join(root, path)
				end
				
				self.new(paths, [root])
			end
		end
		
		class Path
			def list(*relative_paths)
				Paths.directory(self, relative_paths)
			end
		end
	end
end
