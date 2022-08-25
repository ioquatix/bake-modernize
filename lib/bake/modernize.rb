# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require "bake/modernize/version"
require 'build/files/glob'
require 'fileutils'

module Bake
	module Modernize
		ROOT = File.expand_path("../..", __dir__)
		
		TEMPLATE_ROOT = Build::Files::Path.new(ROOT) + "template"
		
		def self.template_path_for(path)
			TEMPLATE_ROOT + path
		end
		
		def self.copy_template(source_path, destination_path)
			glob = Build::Files::Glob.new(source_path, '**/*')
			
			glob.each do |path|
				full_path = File.join(destination_path, path.relative_path)
				
				if File.directory?(path)
					FileUtils::Verbose.mkdir_p(full_path)
				else
					FileUtils::Verbose.cp(path, full_path)
				end
			end
		end
	end
end
