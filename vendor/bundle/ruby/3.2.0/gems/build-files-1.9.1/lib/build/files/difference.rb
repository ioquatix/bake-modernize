# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		class Difference < List
			def initialize(list, excludes)
				@list = list
				@excludes = excludes
			end
			
			attr :files
			
			def freeze
				@list.freeze
				@excludes.freeze
				
				super
			end
			
			def each
				return to_enum(:each) unless block_given?
				
				@list.each do |path|
					yield path unless @excludes.include?(path)
				end
			end
			
			def -(list)
				self.class.new(@list, Composite.new(@excludes, list))
			end
			
			def include?(path)
				@list.includes?(path) and !@excludes.include?(path)
			end
			
			def rebase(root)
				self.class.new(@files.collect{|list| list.rebase(root)}, [root])
			end
			
			def inspect
				"<Difference #{@files.inspect} - #{@excludes.inspect}>"
			end
		end
	end
end
