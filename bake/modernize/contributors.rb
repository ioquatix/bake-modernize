# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

def initialize(context)
	super
	
	require "bake/modernize/license"
end

# Extract changes from a repository and generate a list of contributors.
# @parameter root [String] The root directory of the repository.
# @parameter paths [Array(String)] The paths to extract changes from.
def extract(root:, paths:)
	authorship = Bake::Modernize::License::Authorship.new
	
	authorship.extract(root)
	
	modifications = []
	
	paths.each do |path|
		authorship.paths[path].each do |modification|
			modification = modification.to_h
			
			if modification[:path] != path
				modification[:original_path] = modification[:path]
				modification[:path] = path
			end
			
			modifications << modification
		end
	end
	
	modifications.sort_by!{|modification| modification[:time]}
	
	return modifications
end

# Map the changes to a new path.
# @parameter input [Array(Hash)] The list of changes.
# @parameter original_path [String] The original path of the changes.
# @parameter path [String] The path that now contains the content of the original changes.
def map(original_path, path, input:)
	input.each do |modification|
		if modification[:path] == original_path
			modification[:original_path] = modification[:path]
			modification[:path] = path
		end
	end
	
	return input
end
