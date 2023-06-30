# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

require 'rugged'
require 'yaml'

module Bake
	module Modernize
		module License
			GIT_BLAME_IGNORE_REVS = ".git-blame-ignore-revs"
			
			class SkipList
				def self.for(root)
					full_path = File.join(root, GIT_BLAME_IGNORE_REVS)
					
					if File.exist?(full_path)
						skip_list = self.new
						skip_list.extract(full_path)
						return skip_list
					end
				end
				
				def initialize(revisions = [])
					@revisions = Set.new(revisions)
				end
				
				def extract(path)
					File.open(path, 'r') do |file|
						file.each_line do |line|
							# Skip empty lines and comments
							next if line =~ /^\s*(#|$)/
							# Parse line
							@revisions << line.strip
						end
					end
				end
				
				def ignore?(commit)
					@revisions.include?(commit.oid)
				end
			end
			
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
							
							
							user = extract_from_line(line)
							if commit_email = user[:commit_email] and proper_name = user[:proper_name]
								@names[commit_email] = proper_name
							end
						end
					end
				end
				
				# Format: Proper Name <proper@email.xx> Commit Name <commit@email.xx>
				PATTERN = /
					(?<proper_name>[^<]+)?
					(\s+<(?<proper_email>[^>]+)>)?
					(\s+(?<commit_name>[^<]+)?)?
					\s+<(?<commit_email>[^>]+)>
				/x
				
				def extract_from_line(line)
					line.match(PATTERN)
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
				Modification = Struct.new(:author, :time, :path, :id) do
					def full_name
						author[:name]
					end
					
					def key
						self.id || "#{self.author[:email]}:#{self.time.iso8601}"
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
					@paths = Hash.new{|h,k| h[k] = []}
					@commits = Hash.new{|h,k| h[k] = []}
				end
				
				attr :paths
				
				def add(path, author, time, id = nil)
					modification = Modification.new(author, time, path, id)
					
					@commits[modification.key] << modification
					@paths[path] << modification
				end
				
				def extract(root = Dir.pwd)
					mailmap = Mailmap.for(root)
					skip_list = SkipList.for(root)
					
					if contributors = Contributors.for(root)
						contributors.each do |path, author, time|
							add(path, author, time)
						end
					end
					
					walk(Rugged::Repository.discover(root), mailmap: mailmap, skip_list: skip_list)
					
					return self
				end
				
				def sorted_authors
					authors = Hash.new{|h,k| h[k] = 0}
					
					@commits.each do |key, modifications|
						modifications.map(&:full_name).uniq.each do |full_name|
							authors[full_name] += 1
						end
					end
					
					return authors.sort_by{|k,v| [-v, k]}.map(&:first)
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
				
				def walk(repository, mailmap: nil, skip_list: nil, show: "HEAD")
					Rugged::Walker.walk(repository, show: show, sort: DEFAULT_SORT) do |commit|
						next if skip_list&.ignore?(commit)
						
						diff = commit.diff
						
						# We relax the threshold for copy and rename detection because we want to detect files that have been moved and modified more generously.
						diff.find_similar!(
							rename_threshold: 25,
							copy_threshold: 25,
							ignore_whitespace: true,
						)
						
						diff.each_delta do |delta|
							old_path = delta.old_file[:path]
							new_path = delta.new_file[:path]
							
							@paths[new_path] ||= []
							
							if old_path != new_path
								# The file was moved, move copyright information too:
								Console.logger.debug(self, "Moving #{old_path} to #{new_path}", similarity: delta.similarity)
								@paths[new_path].concat(@paths[old_path])
							end
							
							author = commit.author
							
							if mailmap
								if name = mailmap.names[author[:email]]
									author[:name] = name
								end
							end
							
							add(new_path, author, commit.time, commit.oid)
						end
					end
				end
			end
		end
	end
end
