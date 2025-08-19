# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require "fileutils"

require_relative "path"
require_relative "list"

module Build
	module Files
		class Path
			# Open a file with the specified mode.
			def open(mode, &block)
				File.open(self.to_s, mode, &block)
			end
			
			# Read the entire contents of the file.
			def read(mode = File::RDONLY)
				open(mode) do |file|
					file.read
				end
			end
			
			# Write a buffer to the file, creating it if it doesn't exist. 
			def write(buffer, mode = File::CREAT|File::TRUNC|File::WRONLY)
				open(mode) do |file|
					file.write(buffer)
				end
			end
			
			def copy(destination)
				if directory?
					destination.create
				else
					FileUtils.cp(self.to_s, destination.to_s)
				end
			end
			
			# Touch the file, changing it's last modified time.
			def touch
				FileUtils.touch(self.to_s)
			end
			
			def stat
				File.stat(self.to_s)
			end
			
			# Checks if the file exists in the local file system.
			def exist?
				File.exist?(self.to_s)
			end
			
			# Checks if the path refers to a directory.
			def directory?
				File.directory?(self.to_s)
			end
			
			def file?
				File.file?(self.to_s)
			end
			
			def symlink?
				File.symlink?(self.to_s)
			end
			
			def readable?
				File.readable?(self.to_s)
			end
			
			# The time the file was last modified.
			def modified_time
				File.mtime(self.to_s)
			end
			
			# Recursively create a directory hierarchy for the given path.
			def mkpath
				FileUtils.mkpath(self.to_s)
			end
			
			alias create mkpath
			
			# Recursively delete the given path and all contents.
			def rm
				FileUtils.rm_rf(self.to_s)
			end
			
			alias delete rm
		end
		
		class List
			# Touch all listed files.
			def touch
				each(&:touch)
			end
			
			# Check that all files listed exist.
			def exist?
				all?(&:exist?)
			end
			
			# Recursively create paths for all listed paths.
			def create
				each(&:create)
			end
			
			# Recursively delete all paths and all contents within those paths.
			def delete
				each(&:delete)
			end
			
			def copy(destination)
				each do |path|
					path.copy(destination / path.relative_path)
				end
			end
		end
	end
end
