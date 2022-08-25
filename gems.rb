# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	
	gem "bake-github-pages"
	gem "utopia-project"
end
