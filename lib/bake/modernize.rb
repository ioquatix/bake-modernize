# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require_relative 'modernize/license'
require_relative 'modernize/version'
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
					unless File.directory?(full_path)
						FileUtils.mkdir_p(full_path)
					end
				else
					unless FileUtils.identical?(path, full_path)
						FileUtils::Verbose.cp(path, full_path)
					end
				end
			end
		end
	end
end
