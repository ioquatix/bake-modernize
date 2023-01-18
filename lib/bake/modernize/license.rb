# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'rugged'
require 'yaml'

module Bake
	module Modernize
		module License
			class Mailmap
				def self.for(root)
					full_path = File.join(root, '.mailmap')
					
					if File.exist?(full_path)
						mailmap = self.new
						mailmap.extract(full_path)
						return mailmap
					end
				end
				
				def initialize
					@names = {}
				end
				
				attr :names
				
				def extract(path)
					File.open(path, 'r') do |file|
						file.each_line do |line|
							# Skip comments
							next if line =~ /^#/
							# Skip empty lines
							next if line =~ /^\s*$/
							# Parse line
							# Format: Full Name <email@address>
							line.match(/^(.*) <(.*)>$/) do |match|
								@names[match[2]] = match[1]
							end
						end
					end
				end
			end

			class Contributors
				# The default path is the root of the repository and for authors who have contributed to the entire repository or unspecified paths in the past.
				DEFAULT_PATH = '.'
				
				def self.for(root)
					full_path = File.join(root, '.contributors.yaml')
					
					if File.exist?(full_path)
						contributors = self.new
						contributors.extract(full_path)
						return contributors
					end
				end

				def initialize
					@contributions = []
				end
				
				def each(&block)
					@contributions.each do |contribution|
						yield (contribution[:path] || DEFAULT_PATH), contribution[:author], contribution[:time]
					end
				end
				
				def extract(path)
					@contributions.concat(
						YAML.load_file(path, aliases: true, symbolize_names: true, permitted_classes: [Date, Time])
					)
				end
			end

			class Authorship
				Modification = Struct.new(:author, :time, :path) do
					def full_name
						author[:name]
					end
				end
				
				Copyright = Struct.new(:dates, :author) do
					def <=> other
						self.to_a <=> other.to_a
					end
					
					def statement
						years = self.dates.map(&:year).uniq
						return "Copyright, #{years.join('-')}, by #{author}."
					end
				end
				
				def initialize
					@paths = {}
				end
				
				attr :paths
				
				def add(path, author, time)
					@paths[path] ||= []
					@paths[path] << Modification.new(author, time, path)
				end
				
				def extract(root = Dir.pwd)
					mailmap = Mailmap.for(root)
					
					if contributors = Contributors.for(root)
						contributors.each do |path, author, time|
							add(path, author, time)
						end
					end
					
					walk(Rugged::Repository.discover(root), mailmap: mailmap)
					
					return self
				end
				
				def copyrights
					copyrights_for_modifications(@paths.values.flatten)
				end
				
				def copyrights_for_path(path)
					copyrights_for_modifications(@paths[path])
				end
				
				def copyrights_for_modifications(modifications)
					authors = modifications.group_by{|modification| modification.full_name}
					
					authors.map do |name, modifications|
						Copyright.new(modifications.map(&:time).minmax, name)
					end.sort
				end
				
				private
				
				DEFAULT_SORT = Rugged::SORT_DATE | Rugged::SORT_TOPO | Rugged::SORT_REVERSE
				
				def walk(repository, mailmap: nil, show: "HEAD")
					Rugged::Walker.walk(repository, show: show, sort: DEFAULT_SORT) do |commit|
						diff = commit.diff
						diff.find_similar!
				
						diff.each_delta do |delta|
							old_path = delta.old_file[:path]
							new_path = delta.new_file[:path]
							
							@paths[new_path] ||= []
							
							if old_path != new_path
								# The file was moved, move copyright information too:
								@paths[new_path].concat(@paths[old_path])
							end
							
							author = commit.author
							
							if mailmap
								if name = mailmap.names[author[:email]]
									author[:name] = name
								end
							end
							
							@paths[new_path] << Modification.new(author, commit.time, new_path)
						end
					end
				end
			end
		end
	end
end
