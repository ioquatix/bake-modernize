# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "rugged"

module Bake
	module Modernize
		# Utilities for inspecting git repositories.
		module Git
			# The current branch name for the repository at the given root.
			def self.current_branch(root = Dir.pwd, default: nil)
				begin
					repository = Rugged::Repository.discover(root)
					head = repository.head
					
					if head.branch?
						return head.name.delete_prefix("refs/heads/")
					end
				rescue Rugged::ReferenceError, Rugged::RepositoryError
				end
				
				return default
			end
		end
	end
end
