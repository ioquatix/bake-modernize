# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		class Composite < List
			def initialize(files, roots = nil)
				@files = []
				
				files.each do |list|
					if list.kind_of? Composite
						@files += list.files
					elsif List.kind_of? List
						@files << list
					else
						# Try to convert into a explicit paths list:
						@files << Paths.new(list)
					end
				end
				
				@files.freeze
				@roots = roots
			end
			
			attr :files
			
			def freeze
				self.roots
				
				super
			end
			
			def each
				return to_enum(:each) unless block_given?
				
				@files.each do |files|
					files.each{|path| yield path}
				end
			end
			
			def roots
				@roots ||= @files.collect(&:roots).flatten.uniq
			end
			
			def eql?(other)
				self.class.eql?(other.class) and @files.eql?(other.files)
			end
		
			def hash
				@files.hash
			end
			
			def +(list)
				if list.kind_of? Composite
					self.class.new(@files + list.files)
				else
					self.class.new(@files + [list])
				end
			end
		
			def include?(path)
				@files.any? {|list| list.include?(path)}
			end
		
			def rebase(root)
				self.class.new(@files.collect{|list| list.rebase(root)}, [root])
			end
		
			def to_paths
				self.class.new(@files.collect(&:to_paths), roots: @roots)
			end
			
			def inspect
				"<Composite #{@files.inspect}>"
			end
		end
		
		List::NONE = Composite.new([]).freeze
	end
end
