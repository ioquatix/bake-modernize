# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.
# Copyright, 2025, by Copilot.

def modernize
	call(
		"modernize:git",
		"modernize:readme",
		"modernize:actions",
		"modernize:editorconfig",
		"modernize:gemfile",
		"modernize:rubocop",
		"modernize:signing",
		"modernize:gemspec",
		"modernize:license",
		"modernize:contributing",
		"modernize:copilot",
	)
end
