# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "path"

module Build
	module Files
		# A list of paths, where #each yields instances of Path.
		class List
			include Enumerable
			
			def roots
				collect{|path| path.root}.sort.uniq
			end
			
			# Create a composite list out of two other lists:
			def +(list)
				Composite.new([self, list])
			end
			
			def -(list)
				Difference.new(self, list)
			end
			
			# This isn't very efficient, but it IS generic.
			def ==(other)
				if self.class == other.class
					self.eql?(other)
				elsif other.kind_of? self.class
					self.to_a.sort == other.to_a.sort
				else
					super
				end
			end
			
			# Does this list of files include the path of any other?
			def intersects? other
				other.any?{|path| include?(path)}
			end
			
			def empty?
				each do
					return false
				end
				
				return true
			end
			
			def with(**options)
				return to_enum(:with, **options) unless block_given?
				
				paths = []
				
				self.each do |path|
					updated_path = path.with(**options)
					
					yield path, updated_path
					
					paths << updated_path
				end
				
				return Paths.new(paths)
			end
			
			def rebase(root)
				Paths.new(self.collect{|path| path.rebase(root)}, [root])
			end
			
			def to_paths
				Paths.new(each.to_a)
			end
			
			def map
				Paths.new(super)
			end
			
			def self.coerce(arg)
				if arg.kind_of? self
					arg
				else
					Paths.new(arg)
				end
			end
			
			def to_s
				inspect
			end
		end
	end
end

require_relative "difference"
