# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2023, by Samuel Williams.

def modernize
	call('modernize:git', 'modernize:readme', 'modernize:actions', 'modernize:editorconfig', 'modernize:gemfile', 'modernize:signing', 'modernize:gemspec', 'modernize:license', 'modernize:frozen_string_literal', 'modernize:contributing')
end
