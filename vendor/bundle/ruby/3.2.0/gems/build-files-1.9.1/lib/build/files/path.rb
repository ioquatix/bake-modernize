# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

module Build
	module Files
		# Represents a file path with an absolute root and a relative offset:
		class Path
			def self.current
				self.new(::Dir.pwd)
			end
			
			def self.split(path)
				# Effectively dirname and basename:
				dirname, separator, filename = path.rpartition(File::SEPARATOR)
				filename, dot, extension = filename.rpartition(".")
				
				return dirname + separator, filename, dot + extension
			end
			
			# Returns the length of the prefix which is shared by two strings.
			def self.prefix_length(a, b)
				[a.size, b.size].min.times{|i| return i if a[i] != b[i]}
			end
			
			# Returns a list of components for a path, either represented as a Path instance or a String.
			def self.components(path)
				if Path === path
					path.components
				else
					path.split(File::SEPARATOR)
				end
			end
			
			def self.root(path)
				if Path === path
					path.root
				else
					File.dirname(path)
				end
			end
			
			# Return the shortest relative path to get to path from root. Root should be a directory with which you are computing the relative path.
			def self.shortest_path(path, root)
				path_components = Path.components(path)
				root_components = Path.components(root)
				
				# Find the common prefix:
				i = prefix_length(path_components, root_components) || 0
				
				# The difference between the root path and the required path, taking into account the common prefix:
				up = root_components.size - i
				
				components = [".."] * up + path_components[i..-1]
				
				if components.empty?
					return "."
				else
					return File.join(components)
				end
			end
			
			def self.relative_path(root, full_path)
				relative_offset = root.length
				
				# Deal with the case where the root may or may not end with the path separator:
				relative_offset += 1 unless root.end_with?(File::SEPARATOR)
				
				return full_path.slice(relative_offset..-1)
			end
			
			def self.[] path
				self === path ? path : self.new(path.to_s)
			end
			
			# Both paths must be full absolute paths, and path must have root as an prefix.
			def initialize(full_path, root = nil, relative_path = nil)
				# This is the object identity:
				@full_path = full_path
				
				if root
					@root = root
					@relative_path = relative_path
				else
					# Effectively dirname and basename:
					@root, _, @relative_path = full_path.rpartition(File::SEPARATOR)
				end
			end
			
			attr :root
			attr :full_path
			
			def length
				@full_path.length
			end
			
			alias size length
			
			def components
				@components ||= @full_path.split(File::SEPARATOR).freeze
			end
			
			def basename
				self.parts.last
			end
			
			def parent
				root = @root
				full_path = File.dirname(@full_path)
				
				while root.size > full_path.size
					root = Path.root(root)
				end
				
				if root.size == full_path.size
					root = Path.root(root)
				end
				
				self.class.new(full_path, root)
			end
			
			def start_with?(*args)
				@full_path.start_with?(*args)
			end
			
			alias parts components
			
			def relative_path
				@relative_path ||= Path.relative_path(@root.to_s, @full_path.to_s).freeze
			end
			
			def relative_parts
				dirname, _, basename = self.relative_path.rpartition(File::SEPARATOR)
				
				return dirname, basename
			end
			
			def append(extension)
				self.class.new(@full_path + extension, @root)
			end
			
			# Add a path component to the current path.
			# @param path [String, nil] (Optionally) the path to append.
			def +(path)
				if path
					self.class.new(File.join(@full_path, path), @root)
				else
					self
				end
			end
			
			# Use the current path to define a new root, with an optional sub-path.
			# @param path [String, nil] (Optionally) the path to append.
			def /(path)
				if path
					self.class.new(File.join(self, path), self)
				else
					self.class.new(self, self)
				end
			end
			
			def rebase(root)
				self.class.new(File.join(root, relative_path), root)
			end
			
			def with(root: @root, extension: nil, basename: false)
				relative_path = self.relative_path
				
				if basename
					dirname, filename, _ = self.class.split(relative_path)
					
					# Replace the filename if the basename is supplied:
					filename = basename if basename.is_a? String
					
					relative_path = dirname + filename
				end
				
				if extension
					relative_path = relative_path + extension
				end
				
				self.class.new(File.join(root, relative_path), root, relative_path)
			end
			
			def self.join(root, relative_path)
				self.new(File.join(root, relative_path), root)
			end
			
			# Expand a path within a given root.
			def self.expand(path, root = Dir.getwd)
				if path.start_with?(File::SEPARATOR)
					self.new(path)
				else
					self.join(root, path)
				end
			end
			
			def shortest_path(root)
				self.class.shortest_path(self, root)
			end
			
			def to_str
				@full_path.to_str
			end
			
			def to_path
				@full_path
			end
			
			def to_s
				# It's not guaranteed to be string.
				@full_path.to_s
			end
			
			def inspect
				"#{@root.inspect}/#{relative_path.inspect}"
			end
			
			def hash
				[@root, @full_path].hash
			end
			
			def eql?(other)
				self.class.eql?(other.class) and @root.eql?(other.root) and @full_path.eql?(other.full_path)
			end
			
			include Comparable
			
			def <=>(other)
				self.to_s <=> other.to_s
			end
			
			# Match a path with a given pattern, using `File#fnmatch`.
			def match(pattern, flags = 0)
				path = pattern.start_with?("/") ? full_path : relative_path
				
				return File.fnmatch(pattern, path, flags)
			end
			
			def for_reading
				[@full_path, File::RDONLY]
			end
			
			def for_writing
				[@full_path, File::CREAT|File::TRUNC|File::WRONLY]
			end
			
			def for_appending
				[@full_path, File::CREAT|File::APPEND|File::WRONLY]
			end
		end
	end
end
