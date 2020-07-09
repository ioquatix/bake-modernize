source "https://rubygems.org"

# Specify your gem's dependencies in bake-modernize.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-bundler"
end
